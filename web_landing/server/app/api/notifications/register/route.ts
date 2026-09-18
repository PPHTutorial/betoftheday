import { NextRequest, NextResponse } from 'next/server';

// In-memory token registry (or connect to Upstash Redis / Vercel KV / MongoDB / PostgreSQL)
// Format: { [token: string]: { appId: string, platform: string, favoriteTeams: string[], lastSeen: number } }
const deviceRegistry: Record<string, {
  appId: string;
  platform: string;
  favoriteTeams: string[];
  lastSeen: number;
}> = {};

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const { token, appId = 'btd', platform = 'android', favoriteTeams = [], topic = 'btd_all' } = body;

    if (!token || typeof token !== 'string') {
      return NextResponse.json(
        { error: 'Missing or invalid FCM registration token' },
        { status: 400 }
      );
    }

    // Record device registration
    deviceRegistry[token] = {
      appId,
      platform,
      favoriteTeams: Array.isArray(favoriteTeams) ? favoriteTeams : [],
      lastSeen: Date.now(),
    };

    console.log(`[FCM Register] Registered device: ${token.substring(0, 15)}... | Teams: ${favoriteTeams.length}`);

    // If Firebase Admin SDK is initialized on the server, subscribe to topic
    try {
      const admin = await import('firebase-admin');
      if (admin.apps.length > 0) {
        await admin.messaging().subscribeToTopic(token, topic);
        console.log(`[FCM Register] Subscribed ${token.substring(0, 10)}... to topic ${topic}`);

        // Also subscribe to each favorite team topic: team_<slug>
        for (const team of favoriteTeams) {
          const teamTopic = `team_${team.toLowerCase().replace(/[^a-z0-9]/g, '_')}`;
          await admin.messaging().subscribeToTopic(token, teamTopic);
        }
      }
    } catch (e) {
      // Firebase Admin might not be configured in local dev without service account, gracefully proceed
      console.warn('[FCM Register] Topic subscription notice:', (e as Error).message);
    }

    return NextResponse.json({
      success: true,
      message: 'Device successfully registered for push notifications',
      appId,
      subscribedTopic: topic,
      favoriteTeamsCount: favoriteTeams.length,
      totalRegisteredDevices: Object.keys(deviceRegistry).length,
    });
  } catch (err: any) {
    console.error('[FCM Register Error]:', err);
    return NextResponse.json(
      { error: err.message || 'Internal Server Error' },
      { status: 500 }
    );
  }
}

export async function GET() {
  return NextResponse.json({
    status: 'online',
    service: 'BetOfTheDay FCM Push Notification Registry',
    activeDevicesCount: Object.keys(deviceRegistry).length,
    timestamp: new Date().toISOString(),
  });
}
