// CampusHub Pro API v1.0.1 - Coolify deploy test
require('dotenv').config();

// Validate required environment variables before anything else starts
const REQUIRED_ENV_VARS = [
    'MONGODB_URI',
    'JWT_SECRET',
    'JWT_REFRESH_SECRET',
    'CLOUDINARY_CLOUD_NAME',
    'CLOUDINARY_API_KEY',
    'CLOUDINARY_API_SECRET',
];
const missingVars = REQUIRED_ENV_VARS.filter(v => !process.env[v]);
if (missingVars.length > 0) {
    console.error(`❌ Missing required environment variables: ${missingVars.join(', ')}`);
    console.error('Please check your .env file and ensure all required variables are set.');
    process.exit(1);
}

// Build CORS allowed origins from env (comma-separated list) or fall back to localhost only
const allowedOrigins = process.env.FRONTEND_URL
    ? process.env.FRONTEND_URL.split(',').map(o => o.trim())
    : ['http://localhost:3000', 'http://localhost:5000'];

const corsOptions = {
    origin: (origin, callback) => {
        // Allow requests with no origin header (mobile apps, Postman, curl)
        // Auto-allow Vercel and Netlify for easy frontend deployments
        if (!origin || 
            allowedOrigins.includes(origin) || 
            origin.endsWith('.vercel.app') || 
            origin.endsWith('.netlify.app')) {
            return callback(null, true);
        }
        callback(new Error(`CORS: origin '${origin}' not in allowed list`));
    },
    credentials: true,
};
const express = require('express');
const http = require('http');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const mongoSanitize = require('express-mongo-sanitize');
const rateLimit = require('express-rate-limit');
const { Server } = require('socket.io');
const passport = require('passport');
const { logger } = require('./utils/logger');

// Import configurations
const connectDB = require('./config/db');
const mongoose = require('mongoose');
require('./config/passport');

// Import middleware
const { errorHandler, notFound } = require('./middleware/errorHandler');

// Import routes
const authRoutes = require('./routes/auth');
const listingsRoutes = require('./routes/listings');
const chatRoutes = require('./routes/chat');
const adminRoutes = require('./routes/admin');
const reviewsRoutes = require('./routes/reviews');
const usersRoutes = require('./routes/users');
const reportsRoutes = require('./routes/reports');
const notificationsRoutes = require('./routes/notifications');
const categoriesRoutes = require('./routes/categories');
const offerRoutes = require('./routes/offers');
const educationConfigRoutes = require('./routes/educationConfig');

// Import socket handler
const chatHandler = require('./socket/chatHandler');

// Initialize Express app
const app = express();
app.set('trust proxy', 1); // Trust first proxy (Coolify/Traefik)
const server = http.createServer(app);

// Initialize Socket.io
const io = new Server(server, {
    cors: corsOptions,
    pingTimeout: 60000,
    pingInterval: 25000,
});

// Connect to MongoDB
connectDB();

// ============== MIDDLEWARE ==============

// Security middleware
app.use(helmet());
app.use(compression());

// Request correlation ID for tracing
const correlationId = require('./middleware/correlationId');
app.use(correlationId);

// CORS — uses corsOptions defined at top of file (strict origin allowlist)
app.use(cors(corsOptions));

// Rate limiting - enabled for production, relaxed for development
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: process.env.NODE_ENV === 'production' ? 500 : 1000, // 500 req / 15 min in production
    message: {
        success: false,
        message: 'Too many requests, please try again later',
    },
    standardHeaders: true,
    legacyHeaders: false,
    skip: (req) => process.env.NODE_ENV === 'development', // Skip in dev if needed
});
app.use('/api/', limiter);

// Stricter rate limit for auth routes
const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: process.env.NODE_ENV === 'production' ? 20 : 100, // Strict for auth
    message: {
        success: false,
        message: 'Too many authentication attempts, please try again later',
    },
    skip: (req) => process.env.NODE_ENV === 'development', // No limit in dev
});
app.use('/api/auth/login', authLimiter);
app.use('/api/auth/register', authLimiter);

// Very strict rate limit for password reset (prevent email enumeration & DoS on mail service)
const passwordResetLimiter = rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    max: process.env.NODE_ENV === 'production' ? 3 : 50, // 3 per hour in production
    message: {
        success: false,
        message: 'Too many password reset attempts, please try again later',
    },
    skip: (req) => process.env.NODE_ENV === 'development',
});
app.use('/api/auth/forgot-password', passwordResetLimiter);
app.use('/api/auth/reset-password', passwordResetLimiter);

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Sanitize request data against NoSQL injection
app.use(mongoSanitize());

// Logging
if (process.env.NODE_ENV === 'development') {
    app.use(morgan('dev'));
} else {
    // Production: use pino-http for structured JSON logging
    app.use((req, res, next) => {
        const start = Date.now();
        res.on('finish', () => {
            logger.info({
                method: req.method,
                url: req.originalUrl,
                status: res.statusCode,
                duration: Date.now() - start,
                ip: req.ip,
            }, `${req.method} ${req.originalUrl} ${res.statusCode}`);
        });
        next();
    });
}

// Passport middleware
app.use(passport.initialize());

// ============== ROUTES ==============

// Health check
app.get('/health', async (req, res) => {
    const checks = {};

    // MongoDB check
    checks.mongodb = mongoose.connection.readyState === 1 ? 'connected' : 'disconnected';

    // Redis check (optional)
    try {
        const { redis } = require('./config/redisClient');
        if (redis) {
            await redis.ping();
            checks.redis = 'connected';
        } else {
            checks.redis = 'not configured';
        }
    } catch {
        checks.redis = 'disconnected';
    }

    const allHealthy = checks.mongodb === 'connected';
    const status = allHealthy ? 'healthy' : 'degraded';

    res.status(allHealthy ? 200 : 503).json({
        success: allHealthy,
        status,
        message: 'CampusHub Pro API is running',
        uptime: Math.floor(process.uptime()),
        timestamp: new Date().toISOString(),
        environment: process.env.NODE_ENV,
        version: require('./package.json').version,
        checks,
    });
});

// Deep link redirect for password reset (email clients don't support custom URL schemes)
app.get('/reset-password/:token', (req, res) => {
    const token = encodeURIComponent(req.params.token);
    const baseUrl = (process.env.APP_URL || '').replace(/["'<>]/g, '');
    const appUrl = `${baseUrl}reset-password/${token}`;

    res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>Reset Password - CampusHub Pro</title>
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <style>
                body { 
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; 
                    display: flex; 
                    justify-content: center; 
                    align-items: center; 
                    height: 100vh; 
                    margin: 0; 
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                }
                .container { 
                    text-align: center; 
                    padding: 40px; 
                    background: white; 
                    border-radius: 16px; 
                    box-shadow: 0 10px 40px rgba(0,0,0,0.2); 
                    max-width: 400px;
                    margin: 20px;
                }
                h1 { color: #4F46E5; margin-bottom: 16px; font-size: 24px; }
                p { color: #666; margin-bottom: 24px; line-height: 1.6; }
                .btn {
                    display: inline-block;
                    background: #4F46E5;
                    color: white;
                    padding: 14px 32px;
                    border-radius: 8px;
                    text-decoration: none;
                    font-weight: 600;
                    margin: 8px;
                }
                .btn:hover { background: #4338CA; }
                .note { font-size: 12px; color: #999; margin-top: 20px; }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>&#128272; Reset Your Password</h1>
                <p>Click the button below to open the CampusHub Pro app and reset your password.</p>
                <a href="${appUrl}" class="btn">Open App</a>
                <p class="note">If the app doesn't open, make sure you have CampusHub Pro installed on your device.</p>
            </div>
            <script>
                // Try to open the app automatically
                setTimeout(function() {
                    window.location.href = ${JSON.stringify(appUrl)};
                }, 500);
            </script>
        </body>
        </html>
    `);
});

// API Info
app.get('/api', (req, res) => {
    res.json({
        success: true,
        name: 'CampusHub Pro API',
        version: '1.0.0',
        documentation: '/api/docs',
        endpoints: {
            auth: '/api/auth',
            listings: '/api/listings',
            chat: '/api/chat',
            users: '/api/users',
            reviews: '/api/reviews',
            reports: '/api/reports',
            notifications: '/api/notifications',
            admin: '/api/admin',
            educationConfig: '/api/education-config',
        },
    });
});

// Mount routes
app.use('/api/auth', authRoutes);
app.use('/api/listings', listingsRoutes);
app.use('/api/categories', categoriesRoutes);
app.use('/api/chat', chatRoutes);
app.use('/api/users', usersRoutes);
app.use('/api/reviews', reviewsRoutes);
app.use('/api/reports', reportsRoutes);
app.use('/api/notifications', notificationsRoutes);
app.use('/api/offers', offerRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/education-config', educationConfigRoutes);

// 404 handler
app.use(notFound);

// Error handler
app.use(errorHandler);

// ============== SOCKET.IO ==============

const socketManager = require('./socket/socketManager');
socketManager.setIO(io);
chatHandler(io);

// ============== SCHEDULED TASKS ==============

// Auto-expire listings (runs every hour)
const Listing = require('./models/Listing');
const runScheduledTasks = async () => {
    try {
        const expiredCount = await Listing.expireListings();
        if (expiredCount > 0) {
            console.log(`⏰ Auto-expired ${expiredCount} listings`);
        }
        const unfeaturedCount = await Listing.expireFeatured();
        if (unfeaturedCount > 0) {
            console.log(`⭐ Un-featured ${unfeaturedCount} expired promotions`);
        }
    } catch (error) {
        console.error('Error in scheduled tasks:', error);
    }
};

// Run on startup and every hour (skip in test to avoid open handles)
if (process.env.NODE_ENV !== 'test') {
    runScheduledTasks();
    setInterval(runScheduledTasks, 60 * 60 * 1000);
}

// ============== START SERVER ==============

const PORT = process.env.PORT || 5000;

if (process.env.NODE_ENV !== 'test') {
    server.listen(PORT, () => {
        console.log(`
  ╔═══════════════════════════════════════════════════╗
  ║                                                   ║
  ║   🚀 CampusHub Pro API Server                     ║
  ║                                                   ║
  ║   Environment: ${process.env.NODE_ENV || 'development'}                        ║
  ║   Port: ${PORT}                                       ║
  ║   Health: http://localhost:${PORT}/health             ║
  ║   API: http://localhost:${PORT}/api                   ║
  ║                                                   ║
  ╚═══════════════════════════════════════════════════╝
  `);
    });
}

// Handle unhandled promise rejections
process.on('unhandledRejection', (err) => {
    console.error('Unhandled Rejection:', err);
    // Close server & exit process
    server.close(() => process.exit(1));
});

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
    console.error('Uncaught Exception:', err);
    process.exit(1);
});

// Graceful shutdown helper
const gracefulShutdown = (signal) => {
    console.log(`⏳ ${signal} received — shutting down gracefully...`);
    server.close(() => {
        // Close Socket.IO connections
        io.close(() => {
            console.log('✅ Socket.IO closed.');
        });

        // Close Redis
        const { redis } = require('./config/redisClient');
        if (redis) {
            redis.quit().catch(() => { });
            console.log('✅ Redis connection closed.');
        }

        // Close MongoDB
        mongoose.connection.close(false, () => {
            console.log('✅ MongoDB connection closed. Process exiting.');
            process.exit(0);
        });
    });

    // Force exit after 10s if graceful shutdown hangs
    setTimeout(() => {
        console.error('❌ Forced shutdown after timeout.');
        process.exit(1);
    }, 10000);
};

// Graceful shutdown on SIGTERM (Docker/Coolify/PM2) and SIGINT (Ctrl+C)
process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

module.exports = { app, server, io };

// Trigger deploy 03/15/2026 03:37:10
