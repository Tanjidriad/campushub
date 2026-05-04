const mongoose = require('mongoose');
const { logger } = require('../utils/logger');

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGODB_URI, {
      maxPoolSize: 10,       // Max concurrent connections
      minPoolSize: 2,        // Keep at least 2 connections warm
      serverSelectionTimeoutMS: 5000,  // Fail fast if MongoDB unreachable
      socketTimeoutMS: 45000,          // Close idle sockets after 45s
    });
    logger.info({ host: conn.connection.host }, 'MongoDB connected');
  } catch (error) {
    if (process.env.NODE_ENV === 'test') {
      logger.warn({ err: error }, 'MongoDB connection failed in test mode, continuing');
      return;
    }
    logger.fatal({ err: error }, 'MongoDB connection failed');
    process.exit(1);
  }
};

// Handle connection events
mongoose.connection.on('disconnected', () => {
  logger.warn('MongoDB disconnected');
});

mongoose.connection.on('reconnected', () => {
  logger.info('MongoDB reconnected');
});

module.exports = connectDB;
