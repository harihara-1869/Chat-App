import admin from 'firebase-admin';
import Device from '../models/device.model.js';
import User from '../models/user.model.js';
import dotenv from 'dotenv';

dotenv.config();

let firebaseInitialized = false;

function initializeFirebase() {
  if (firebaseInitialized) return true;
  
  try {
    if (admin.apps.length > 0) {
      firebaseInitialized = true;
      return true;
    }

    const serviceAccount = {
      projectId: process.env.FIREBASE_PROJECT_ID,
      privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    };

    if (!serviceAccount.projectId || !serviceAccount.privateKey || !serviceAccount.clientEmail) {
      console.warn('Firebase credentials not configured. Push notifications disabled.');
      return false;
    }

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });

    firebaseInitialized = true;
    console.log('Firebase Admin initialized successfully');
    return true;
  } catch (error) {
    console.error('Failed to initialize Firebase Admin:', error.message);
    return false;
  }
}

export async function sendPushNotification(userId, eventName, payload) {
  if (!initializeFirebase()) {
    console.warn('FCM not initialized, skipping notification for user:', userId);
    return;
  }

  try {
    const device = await Device.findOne({ userId });
    if (!device?.fcmToken) {
      console.log('No FCM token for user:', userId);
      return;
    }

    const user = await User.findById(userId).select('fullName');
    const senderName = user?.fullName || 'Someone';

    const notificationData = {
      eventName,
      senderId: payload.senderId,
      senderName,
      conversationId: payload.conversationId || payload._id?.toString(),
      messageId: payload._id?.toString(),
      timestamp: new Date().toISOString(),
    };

    const message = {
      token: device.fcmToken,
      data: notificationData,
      android: {
        priority: 'high',
        collapseKey: `chat_${userId}`,
        notification: {
          channelId: 'chat_messages',
          priority: 'high',
        },
      },
      apns: {
        payload: {
          aps: {
            contentAvailable: true,
            sound: 'default',
          },
        },
        headers: {
          'apns-priority': '10',
          'apns-collapse-id': `chat_${userId}`,
        },
      },
    };

    await admin.messaging().send(message);
    console.log(`Push notification sent to user ${userId} for event ${eventName}`);
  } catch (error) {
    if (error.code === 'messaging/registration-token-not-registered' ||
        error.code === 'messaging/invalid-registration-token') {
      console.log(`Invalid FCM token for user ${userId}, clearing...`);
      await Device.findOneAndUpdate({ userId }, { $unset: { fcmToken: 1 } });
    } else {
      console.error(`FCM send error for user ${userId}:`, error.message);
    }
  }
}

export async function sendMessageNotification(payload) {
  await sendPushNotification(payload.receiverId, 'newMessage', payload);
}

export async function sendFriendRequestNotification(payload, receiverId) {
  await sendPushNotification(receiverId, 'friendRequest', {
    ...payload,
    conversationId: payload._id?.toString(),
  });
}

export async function sendFriendAcceptedNotification(payload, receiverId) {
  await sendPushNotification(receiverId, 'friendAccepted', {
    ...payload,
    conversationId: payload._id?.toString(),
  });
}
