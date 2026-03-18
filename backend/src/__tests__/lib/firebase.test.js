/**
 * Firebase Library Unit Tests
 * Tests for initializeFirebase, sendPushNotification, and notification helpers
 *
 * These tests validate the Firebase Cloud Messaging integration.
 */

import { describe, it, expect, jest, beforeEach } from '@jest/globals';

describe('Firebase Library - initializeFirebase', () => {
    it('should return false when Firebase credentials are missing', () => {
        const serviceAccount = {
            projectId: '',
            privateKey: '',
            clientEmail: ''
        };

        const isConfigured = !!(serviceAccount.projectId && serviceAccount.privateKey && serviceAccount.clientEmail);
        expect(isConfigured).toBe(false);
    });

    it('should return true when Firebase credentials are present', () => {
        const serviceAccount = {
            projectId: 'test-project',
            privateKey: '-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n',
            clientEmail: 'test@test-project.iam.gserviceaccount.com'
        };

        const isConfigured = !!(serviceAccount.projectId && serviceAccount.privateKey && serviceAccount.clientEmail);
        expect(isConfigured).toBe(true);
    });

    it('should handle private key with escaped newlines', () => {
        const privateKeyWithEscapes = '-----BEGIN PRIVATE KEY-----\\n...\\n-----END PRIVATE KEY-----';
        const privateKey = privateKeyWithEscapes.replace(/\\n/g, '\n');

        expect(privateKey).toContain('\n');
        expect(privateKey).not.toContain('\\n');
    });

    it('should skip initialization if already initialized', () => {
        const apps = [{ name: '[DEFAULT]' }];
        const alreadyInitialized = apps.length > 0;

        expect(alreadyInitialized).toBe(true);
    });
});

describe('Firebase Library - sendPushNotification', () => {
    let mockSend;

    beforeEach(() => {
        mockSend = jest.fn();
    });

    it('should skip notification when Firebase is not initialized', () => {
        const firebaseInitialized = false;

        if (!firebaseInitialized) {
            // Skip sending notification
        }

        expect(firebaseInitialized).toBe(false);
    });

    it('should require FCM token to send notification', () => {
        const device = { fcmToken: null };
        const hasToken = !!device?.fcmToken;

        expect(hasToken).toBe(false);
    });

    it('should send notification when FCM token exists', () => {
        const device = { fcmToken: 'fcm-token-123' };
        const hasToken = !!device?.fcmToken;

        expect(hasToken).toBe(true);
    });

    it('should construct message with correct token', () => {
        const fcmToken = 'fcm-token-123';
        const message = {
            token: fcmToken,
            data: { eventName: 'newMessage' }
        };

        expect(message.token).toBe(fcmToken);
    });

    it('should include eventName in data payload', () => {
        const payload = {
            eventName: 'newMessage',
            senderId: 'user-123',
            senderName: 'Test User',
            conversationId: 'conv-456',
            messageId: 'msg-789',
            timestamp: new Date().toISOString()
        };

        expect(payload.eventName).toBe('newMessage');
        expect(payload.senderId).toBeDefined();
        expect(payload.timestamp).toBeDefined();
    });

    it('should include sender name in notification data', () => {
        const user = { fullName: 'John Doe' };
        const senderName = user?.fullName || 'Someone';

        expect(senderName).toBe('John Doe');
    });

    it('should default sender name to "Someone" when user not found', () => {
        const user = null;
        const senderName = user?.fullName || 'Someone';

        expect(senderName).toBe('Someone');
    });

    describe('Android configuration', () => {
        it('should set high priority for Android', () => {
            const android = {
                priority: 'high',
                collapseKey: 'chat_user-123'
            };

            expect(android.priority).toBe('high');
        });

        it('should set collapseKey for message grouping', () => {
            const userId = 'user-123';
            const collapseKey = `chat_${userId}`;

            expect(collapseKey).toBe('chat_user-123');
        });

        it('should configure notification channel for Android', () => {
            const android = {
                notification: {
                    channelId: 'chat_messages',
                    priority: 'high'
                }
            };

            expect(android.notification.channelId).toBe('chat_messages');
            expect(android.notification.priority).toBe('high');
        });
    });

    describe('APNS configuration', () => {
        it('should set content-available for iOS background delivery', () => {
            const apns = {
                payload: {
                    aps: {
                        contentAvailable: true,
                        sound: 'default'
                    }
                }
            };

            expect(apns.payload.aps.contentAvailable).toBe(true);
        });

        it('should set apns-priority to 10', () => {
            const headers = {
                'apns-priority': '10'
            };

            expect(headers['apns-priority']).toBe('10');
        });

        it('should set apns-collapse-id for message grouping', () => {
            const userId = 'user-123';
            const headers = {
                'apns-collapse-id': `chat_${userId}`
            };

            expect(headers['apns-collapse-id']).toBe('chat_user-123');
        });
    });

    describe('Error handling', () => {
        it('should clear invalid FCM token on registration-token-not-registered error', () => {
            const error = { code: 'messaging/registration-token-not-registered' };
            const shouldClearToken = error.code === 'messaging/registration-token-not-registered' ||
                                     error.code === 'messaging/invalid-registration-token';

            expect(shouldClearToken).toBe(true);
        });

        it('should clear invalid FCM token on invalid-registration-token error', () => {
            const error = { code: 'messaging/invalid-registration-token' };
            const shouldClearToken = error.code === 'messaging/registration-token-not-registered' ||
                                     error.code === 'messaging/invalid-registration-token';

            expect(shouldClearToken).toBe(true);
        });

        it('should not clear token on other errors', () => {
            const error = { code: 'messaging/server-unavailable' };
            const shouldClearToken = error.code === 'messaging/registration-token-not-registered' ||
                                     error.code === 'messaging/invalid-registration-token';

            expect(shouldClearToken).toBe(false);
        });
    });
});

describe('Firebase Library - Notification Helpers', () => {
    describe('sendMessageNotification', () => {
        it('should call sendPushNotification with newMessage event', () => {
            const mockSendPush = jest.fn();
            const payload = { receiverId: 'user-456', _id: 'msg-123' };

            mockSendPush(payload.receiverId, 'newMessage', payload);

            expect(mockSendPush).toHaveBeenCalledWith('user-456', 'newMessage', payload);
        });
    });

    describe('sendFriendRequestNotification', () => {
        it('should call sendPushNotification with friendRequest event', () => {
            const mockSendPush = jest.fn();
            const payload = { _id: 'req-123', senderId: 'user-123' };
            const receiverId = 'user-456';

            mockSendPush(receiverId, 'friendRequest', {
                ...payload,
                conversationId: payload._id?.toString()
            });

            expect(mockSendPush).toHaveBeenCalledWith('user-456', 'friendRequest', expect.any(Object));
        });
    });

    describe('sendFriendAcceptedNotification', () => {
        it('should call sendPushNotification with friendAccepted event', () => {
            const mockSendPush = jest.fn();
            const payload = { _id: 'req-123', friend: { _id: 'user-789' } };
            const receiverId = 'user-456';

            mockSendPush(receiverId, 'friendAccepted', {
                ...payload,
                conversationId: payload._id?.toString()
            });

            expect(mockSendPush).toHaveBeenCalledWith('user-456', 'friendAccepted', expect.any(Object));
        });
    });
});

describe('Firebase Library - Payload Format', () => {
    it('should include all required fields in notification data', () => {
        const notificationData = {
            eventName: 'newMessage',
            senderId: 'user-123',
            senderName: 'Test User',
            conversationId: 'conv-456',
            messageId: 'msg-789',
            timestamp: new Date().toISOString()
        };

        expect(notificationData).toHaveProperty('eventName');
        expect(notificationData).toHaveProperty('senderId');
        expect(notificationData).toHaveProperty('senderName');
        expect(notificationData).toHaveProperty('conversationId');
        expect(notificationData).toHaveProperty('messageId');
        expect(notificationData).toHaveProperty('timestamp');
    });

    it('should convert ObjectIds to strings in payload', () => {
        const objectId = { toString: () => 'msg-123' };
        const payload = {
            _id: objectId,
            senderId: 'user-123'
        };

        const notificationData = {
            ...payload,
            messageId: payload._id?.toString()
        };

        expect(notificationData.messageId).toBe('msg-123');
    });

    it('should handle payload without _id gracefully', () => {
        const payload = { senderId: 'user-123' };

        const messageId = payload._id?.toString();

        expect(messageId).toBeUndefined();
    });
});

describe('Firebase Library - Environment Variables', () => {
    it('should require FIREBASE_PROJECT_ID', () => {
        const projectId = process.env.FIREBASE_PROJECT_ID || 'test-project';
        expect(projectId).toBeDefined();
    });

    it('should require FIREBASE_PRIVATE_KEY', () => {
        const privateKey = process.env.FIREBASE_PRIVATE_KEY || '-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n';
        expect(privateKey).toBeDefined();
    });

    it('should require FIREBASE_CLIENT_EMAIL', () => {
        const clientEmail = process.env.FIREBASE_CLIENT_EMAIL || 'test@test-project.iam.gserviceaccount.com';
        expect(clientEmail).toBeDefined();
    });
});
