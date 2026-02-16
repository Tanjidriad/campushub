require('dotenv').config();
const express = require('express');
const http = require('http');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const { Server } = require('socket.io');
const passport = require('passport');

// Import configurations
const connectDB = require('./config/db');
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

// Import socket handler
const chatHandler = require('./socket/chatHandler');

// Initialize Express app
const app = express();
app.set('trust proxy', 1); // Trust first proxy (Coolify/Traefik)
const server = http.createServer(app);

// Initialize Socket.io
const io = new Server(server, {
    cors: {
        origin: process.env.FRONTEND_URL || '*',
        methods: ['GET', 'POST'],
        credentials: true,
    },
    pingTimeout: 60000,
    pingInterval: 25000,
});

// Connect to MongoDB
connectDB();

// ============== MIDDLEWARE ==============

// Security middleware
app.use(helmet());

// CORS
app.use(cors({
    origin: process.env.FRONTEND_URL || '*',
    credentials: true,
}));

// Rate limiting - enabled for production, relaxed for development
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: process.env.NODE_ENV === 'production' ? 100 : 1000, // Strict in production
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
    max: process.env.NODE_ENV === 'production' ? 10 : 100, // Very strict in production
    message: {
        success: false,
        message: 'Too many authentication attempts, please try again later',
    },
});
app.use('/api/auth/login', authLimiter);
app.use('/api/auth/register', authLimiter);

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Logging (only in development)
if (process.env.NODE_ENV === 'development') {
    app.use(morgan('dev'));
}

// Passport middleware
app.use(passport.initialize());

// ============== ROUTES ==============

// Health check
app.get('/health', (req, res) => {
    res.json({
        success: true,
        message: 'CampusHub Pro API is running',
        timestamp: new Date().toISOString(),
        environment: process.env.NODE_ENV,
    });
});

// Deep link redirect for password reset (email clients don't support custom URL schemes)
app.get('/reset-password/:token', (req, res) => {
    const token = req.params.token;
    const appUrl = `${process.env.APP_URL}reset-password/${token}`;

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
                .btn-secondary {
                    background: #E5E7EB;
                    color: #374151;
                }
                .btn-secondary:hover { background: #D1D5DB; }
                .note { font-size: 12px; color: #999; margin-top: 20px; }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>🔐 Reset Your Password</h1>
                <p>Click the button below to open the CampusHub Pro app and reset your password.</p>
                <a href="${appUrl}" class="btn">Open App</a>
                <p class="note">If the app doesn't open, make sure you have CampusHub Pro installed on your device.</p>
            </div>
            <script>
                // Try to open the app automatically
                setTimeout(function() {
                    window.location.href = "${appUrl}";
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
app.use('/api/admin', adminRoutes);

// 404 handler
app.use(notFound);

// Error handler
app.use(errorHandler);

// ============== SOCKET.IO ==============

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

// Run on startup and every hour
runScheduledTasks();
setInterval(runScheduledTasks, 60 * 60 * 1000);

// ============== START SERVER ==============

const PORT = process.env.PORT || 5000;

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

module.exports = { app, server, io };
