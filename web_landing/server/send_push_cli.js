/**
 * Bet Of The Day — CLI Push Notification Dispatcher
 *
 * Usage:
 *   node send_push_cli.js --topic btd_all --title "Arsenal vs Chelsea" --home "Arsenal" --away "Chelsea" --score "2 - 1" --time "72'"
 *   node send_push_cli.js --token "YOUR_FCM_TOKEN" --home "Real Madrid" --away "Barcelona"
 */

const https = require('https');
const fs = require('fs');
const path = require('path');

// Parse CLI arguments
const args = process.argv.slice(2);
function getArg(key, fallback = '') {
  const idx = args.indexOf(`--${key}`);
  if (idx !== -1 && idx + 1 < args.length) return args[idx + 1];
  return fallback;
}

const token = getArg('token');
const topic = getArg('topic', token ? '' : 'btd_all');
const homeTeam = getArg('home', 'Arsenal');
const awayTeam = getArg('away', 'Chelsea');
const score = getArg('score', '2 - 1');
const matchTime = getArg('time', "72'");
const xg = getArg('xg', '1.84 - 0.92');
const prediction = getArg('prediction', 'Home Win & Over 2.5');
const prob = getArg('prob', 'Arsenal 65% • Draw 20% • Chelsea 15%');
const odds = getArg('odds', '1: 1.75 | X: 3.80 | 2: 4.60');
const league = getArg('league', 'Premier League');
const venue = getArg('venue', 'Emirates Stadium, London');

const defaultTitle = `🔴 LIVE ${matchTime} | ${homeTeam} ${score} ${awayTeam}`;
const title = getArg('title', defaultTitle);
const defaultBody = `${homeTeam} in the lead! xG: ${xg} • Pick: ${prediction}`;
const body = getArg('body', defaultBody);

console.log('----------------------------------------------------');
console.log('🚀 Bet Of The Day — Dispatching Rich Match Push');
console.log('----------------------------------------------------');
console.log(`🎯 Target:       ${token ? `Device Token (${token.substring(0, 15)}...)` : `Topic (${topic})`}`);
console.log(`📌 Title:        ${title}`);
console.log(`📝 Body:         ${body}`);
console.log(`⚽ Match:        ${homeTeam} vs ${awayTeam} (${score})`);
console.log(`📊 Stats:        xG ${xg} | Prob: ${prob}`);
console.log('----------------------------------------------------');

// Read Firebase service account if present
let serviceAccount = null;
const possiblePaths = [
  path.join(__dirname, 'service-account.json'),
  path.join(process.cwd(), 'service-account.json'),
];

for (const p of possiblePaths) {
  if (fs.existsSync(p)) {
    try {
      serviceAccount = JSON.parse(fs.readFileSync(p, 'utf8'));
      console.log(`✅ Loaded Firebase Service Account from: ${p}`);
      break;
    } catch (e) {}
  }
}

if (!serviceAccount && process.env.FIREBASE_SERVICE_ACCOUNT_KEY) {
  try {
    serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_KEY);
    console.log('✅ Loaded Firebase Service Account from environment variable');
  } catch (e) {}
}

if (serviceAccount) {
  // Use google-auth-library or firebase-admin if installed
  try {
    const admin = require('firebase-admin');
    if (!admin.apps.length) {
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        projectId: serviceAccount.project_id,
      });
    }

    const payload = {
      notification: { title, body },
      data: {
        title,
        body,
        homeTeam,
        awayTeam,
        score,
        matchTime,
        xg,
        prediction,
        prob,
        odds,
        league,
        venue,
        appId: 'btd',
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'btd_updates',
          priority: 'max',
          defaultSound: true,
          defaultVibrateTimings: true,
          icon: 'ic_launcher',
        },
      },
    };

    if (token) {
      admin.messaging().send({ ...payload, token })
        .then((res) => console.log('🎉 Push notification sent successfully! Message ID:', res))
        .catch((err) => console.error('❌ Error sending push:', err));
    } else {
      admin.messaging().send({ ...payload, topic })
        .then((res) => console.log(`🎉 Broadcast sent to topic "${topic}"! Message ID:`, res))
        .catch((err) => console.error('❌ Error broadcasting push:', err));
    }
  } catch (e) {
    console.error('Note: firebase-admin package not found. Install with `npm i firebase-admin` in your server directory.');
  }
} else {
  console.log('💡 Tip: Place your Firebase service account JSON as `service-account.json` in this directory');
  console.log('   or test via your deployed server endpoint: POST https://your-server.vercel.app/api/notifications/send');
}
