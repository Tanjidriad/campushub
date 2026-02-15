/**
 * Firebase Admin SDK Configuration
 * Handles push notifications via Firebase Cloud Messaging (FCM)
 */
const admin = require('firebase-admin');
const path = require('path');

let firebaseApp = null;

const initializeFirebase = () => {
    if (firebaseApp) {
        return firebaseApp;
    }

    try {
        let serviceAccount;

        // Option 1: Load from Environment Variable (Best for Coolify/Production)
        if (process.env.FIREBASE_SERVICE_ACCOUNT) {
            try {
                // Try parsing as regular JSON string
                serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
            } catch (e) {
                // If failed, try parsing as Base64 encoded JSON
                const buffer = Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT, 'base64');
                serviceAccount = JSON.parse(buffer.toString('utf-8'));
            }
        }
        // Option 2: Load from local file (Development)
        else {
            const serviceAccountPath = path.join(__dirname, 'firebase-service-account.json');
            // Check if file exists to avoid crashing if it's missing in production
            const fs = require('fs');
            if (fs.existsSync(serviceAccountPath)) {
                serviceAccount = require(serviceAccountPath);
            } else {
                throw new Error('firebase-service-account.json not found and FIREBASE_SERVICE_ACCOUNT env var not set');
            }
        }

        firebaseApp = admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
            projectId: serviceAccount.project_id,
        });

        console.log('🔥 Firebase Admin SDK initialized');
        return firebaseApp;
    } catch (error) {
        console.error('Firebase initialization error:', error.message);
        console.warn('⚠️  Push notifications will be disabled');
        return null;
    }
};

// Initialize on module load
initializeFirebase();

/**
 * Send push notification to a single device
 * @param {string} token - FCM device token
 * @param {object} payload - Notification payload
 * @returns {Promise<string|null>} - Message ID or null on failure
 */
const sendToDevice = async (token, payload) => {
    if (!firebaseApp) {
        console.warn('Firebase not initialized, skipping push notification');
        return null;
    }

    try {
        const message = {
            token,
            notification: {
                title: payload.title,
                body: payload.body,
            },
            data: payload.data || {},
            android: {
                priority: 'high',
                notification: {
                    channelId: 'chat_messages',
                    priority: 'high',
                    defaultSound: true,
                    defaultVibrateTimings: true,
                },
            },
            apns: {
                payload: {
                    aps: {
                        alert: {
                            title: payload.title,
                            body: payload.body,
                        },
                        sound: 'default',
                        badge: payload.badge || 1,
                    },
                },
            },
        };

        const response = await admin.messaging().send(message);
        console.log(`📱 Push sent: ${response}`);
        return response;
    } catch (error) {
        console.error('Push notification error:', error.message);

        // Handle invalid token
        if (error.code === 'messaging/invalid-registration-token' ||
            error.code === 'messaging/registration-token-not-registered') {
            return { error: 'invalid_token', token };
        }

        return null;
    }
};

/**
 * Send push notification to multiple devices
 * @param {string[]} tokens - Array of FCM device tokens
 * @param {object} payload - Notification payload
 * @returns {Promise<object>} - Results with success/failure counts
 */
const sendToMultipleDevices = async (tokens, payload) => {
    if (!firebaseApp || !tokens || tokens.length === 0) {
        return { successCount: 0, failureCount: 0, invalidTokens: [] };
    }

    try {
        const message = {
            notification: {
                title: payload.title,
                body: payload.body,
            },
            data: payload.data || {},
            android: {
                priority: 'high',
                notification: {
                    channelId: 'chat_messages',
                    priority: 'high',
                    defaultSound: true,
                },
            },
            apns: {
                payload: {
                    aps: {
                        sound: 'default',
                        badge: payload.badge || 1,
                    },
                },
            },
        };

        const response = await admin.messaging().sendEachForMulticast({
            tokens,
            ...message,
        });

        // Collect invalid tokens for cleanup
        const invalidTokens = [];
        response.responses.forEach((res, idx) => {
            if (!res.success) {
                const error = res.error;
                if (error?.code === 'messaging/invalid-registration-token' ||
                    error?.code === 'messaging/registration-token-not-registered') {
                    invalidTokens.push(tokens[idx]);
                }
            }
        });

        console.log(`📱 Push sent to ${response.successCount}/${tokens.length} devices`);

        return {
            successCount: response.successCount,
            failureCount: response.failureCount,
            invalidTokens,
        };
    } catch (error) {
        console.error('Multicast push error:', error.message);
        return { successCount: 0, failureCount: tokens.length, invalidTokens: [] };
    }
};

/**
 * Check if Firebase is available
 */
const isFirebaseAvailable = () => !!firebaseApp;

module.exports = {
    initializeFirebase,
    sendToDevice,
    sendToMultipleDevices,
    isFirebaseAvailable,
    admin,
};
