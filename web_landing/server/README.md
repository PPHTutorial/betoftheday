# Bet Of The Day — Server Push Notification System

Complete Next.js backend module for broadcasting and serving push notifications to the **Bet Of The Day** Android & iOS apps.

---

## 1. Architecture Overview

```
[ Next.js Server / serviceworker ]
     │
     ├── 1. /api/notifications/register   <-- App registers FCM Token & Favorite Clubs
     ├── 2. /api/notifications/send       <-- Dispatches Rich Match Push via Firebase Admin
     └── 3. /api/notifications/cron       <-- Automated matchday & live updates cron
            │
            ▼ (FCM HTTP v1 / Topic: btd_all)
[ Google Firebase Cloud Messaging ]
            │
            ▼
[ Android Device Notification Drawer ]
   ┌──────────────────────────────────────────────────────────┐
   │ 🔴 LIVE 75' | Arsenal 2 - 1 Chelsea                      │
   │ Premier League • Live Play                               │
   ├──────────────────────────────────────────────────────────┤
   │ ⚽ Score: 2 - 1 (75')                                    │
   │ 📊 xG: 1.84 - 0.92  |  Form: W-W-D vs L-W-D              │
   │ 🎲 Win Prob: Arsenal 65% • Draw 20% • Chelsea 15%        │
   │ 🎯 Model Pick: Both Teams To Score (Yes) & Over 2.5      │
   │ 💰 Odds: 1: 1.75 | X: 3.80 | 2: 4.60                     │
   │ 🏟️ Venue: Emirates Stadium, London                       │
   │ 👉 Tap to inspect live expected goals & probability model│
   └──────────────────────────────────────────────────────────┘
```

---

## 2. Next.js API Routes

Copy the contents of `app/api/notifications/` into your Next.js project (`serviceworker/app/api/notifications/`):

### A. Device Registration: `POST /api/notifications/register`
Called automatically by the Flutter app upon launch and token generation.
- Registers device token, platform (`android`), and user's favorite clubs.
- Subscribes the device to FCM topic `btd_all` and club topics (`team_arsenal`).

```json
{
  "token": "dK91_f8LmZ...",
  "appId": "btd",
  "platform": "android",
  "topic": "btd_all",
  "favoriteTeams": ["Arsenal", "Real Madrid"]
}
```

### B. Send Push Notification: `POST /api/notifications/send`
Admin and backend endpoint to dispatch match alerts.
- Header: `Authorization: Bearer <NOTIFICATION_API_SECRET>`
- Body:
```json
{
  "topic": "btd_all",
  "title": "🔴 LIVE 72' | Arsenal 2 - 1 Chelsea",
  "body": "Arsenal takes the lead! xG: 1.84 - 0.92 • Top Pick: Over 2.5",
  "matchData": {
    "homeTeam": "Arsenal",
    "awayTeam": "Chelsea",
    "score": "2 - 1",
    "matchTime": "72'",
    "league": "Premier League",
    "xg": "1.84 - 0.92",
    "prediction": "Home Win & Over 2.5",
    "prob": "Arsenal 65% • Draw 20% • Chelsea 15%",
    "odds": "1: 1.75 | X: 3.80 | 2: 4.60",
    "venue": "Emirates Stadium"
  }
}
```

### C. Automated Cron: `GET /api/notifications/cron`
Configure in `vercel.json` to run every hour or every 15 minutes during match hours. Fetches live fixtures and broadcasts updates.

---

## 3. Environment Variables

Add to your Next.js `.env` or Vercel Environment Variables:

```env
# Secret token for protecting /api/notifications/send
NOTIFICATION_API_SECRET=btd_secret_2026
CRON_SECRET=btd_cron_2026

# Firebase Admin Service Account Key JSON
# (Downloaded from Firebase Console -> Project Settings -> Service accounts)
FIREBASE_SERVICE_ACCOUNT_KEY='{"type":"service_account","project_id":"betoftheday-2022",...}'
```

---

## 4. Testing Locally via CLI

Run the included Node.js test script to send an instant push directly to your phone:

```bash
# Broadcast to all users
node send_push_cli.js --topic btd_all --home "Arsenal" --away "Chelsea" --score "2 - 1" --time "75'"

# Or send to a specific device token (copy from Settings -> FCM Push Token in the app)
node send_push_cli.js --token "YOUR_FCM_TOKEN" --home "Real Madrid" --away "Barcelona" --score "3 - 2"
```
