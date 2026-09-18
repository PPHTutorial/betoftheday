import { NextRequest, NextResponse } from 'next/server';
import admin from 'firebase-admin';

// Initialize Firebase Admin SDK singleton
function getFirebaseAdmin() {
  if (admin.apps.length > 0) {
    return admin;
  }

  // 1. Try FIREBASE_SERVICE_ACCOUNT_KEY JSON string env variable
  const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT_KEY;
  if (serviceAccountJson) {
    try {
      const serviceAccount = JSON.parse(serviceAccountJson);
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        projectId: serviceAccount.project_id || 'betoftheday-2022',
      });
      console.log('[Firebase Admin] Initialized with FIREBASE_SERVICE_ACCOUNT_KEY');
      return admin;
    } catch (e) {
      console.error('[Firebase Admin] Failed to parse service account JSON:', e);
    }
  }

  // 2. Try default Google Application Credentials
  try {
    admin.initializeApp({
      projectId: process.env.FIREBASE_PROJECT_ID || 'betoftheday-2022',
    });
    console.log('[Firebase Admin] Initialized with default credentials');
    return admin;
  } catch (e) {
    console.warn('[Firebase Admin] Could not initialize Admin SDK:', (e as Error).message);
    return null;
  }
}

export async function POST(req: NextRequest) {
  try {
    const authHeader = req.headers.get('authorization');
    const apiSecret = process.env.NOTIFICATION_API_SECRET || 'btd_secret_2026';

    // Verify authentication secret
    if (authHeader !== `Bearer ${apiSecret}` && req.nextUrl.searchParams.get('secret') !== apiSecret) {
      return NextResponse.json(
        { error: 'Unauthorized. Provide valid Bearer token in Authorization header.' },
        { status: 401 }
      );
    }

    const body = await req.json();
    const {
      topic = 'btd_all',
      token,
      title = '⚽ Bet Of The Day Alert',
      body: notifBody = 'Live match statistics & predictions updated!',
      matchData = {},
    } = body;

    const fbAdmin = getFirebaseAdmin();
    if (!fbAdmin) {
      return NextResponse.json(
        {
          error:
            'Firebase Admin SDK is not initialized. Please set FIREBASE_SERVICE_ACCOUNT_KEY in your .env.',
        },
        { status: 500 }
      );
    }

    // Convert all data values to strings (FCM data payload requirement)
    const stringifiedData: Record<string, string> = {
      title,
      body: notifBody,
      appId: 'btd',
      timestamp: new Date().toISOString(),
    };

    for (const [key, value] of Object.entries(matchData)) {
      if (value !== null && value !== undefined) {
        stringifiedData[key] = String(value);
      }
    }

    // Base FCM Message structure
    const baseMessage = {
      notification: {
        title,
        body: notifBody,
      },
      data: stringifiedData,
      android: {
        priority: 'high' as const,
        notification: {
          channelId: 'btd_updates',
          priority: 'max' as const,
          defaultSound: true,
          defaultVibrateTimings: true,
          icon: 'ic_launcher',
          color: '#10B981',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
    };

    let messageId: string;

    if (token) {
      // Send directly to targeted device token
      messageId = await fbAdmin.messaging().send({
        ...baseMessage,
        token,
      });
      console.log(`[Push Notification Sent to Token]: ${messageId}`);
    } else {
      // Broadcast to FCM Topic (reaches all registered users!)
      messageId = await fbAdmin.messaging().send({
        ...baseMessage,
        topic,
      });
      console.log(`[Push Notification Broadcast to Topic "${topic}"]: ${messageId}`);
    }

    return NextResponse.json({
      success: true,
      messageId,
      target: token ? `token: ${token.substring(0, 15)}...` : `topic: ${topic}`,
      notification: { title, body: notifBody },
      matchData: stringifiedData,
    });
  } catch (err: any) {
    console.error('[Send Push Error]:', err);
    return NextResponse.json(
      { error: err.message || 'Failed to dispatch push notification' },
      { status: 500 }
    );
  }
}
