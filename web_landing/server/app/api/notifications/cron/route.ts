import { NextRequest, NextResponse } from 'next/server';

export async function GET(req: NextRequest) {
  try {
    // Verify Vercel Cron secret or custom secret
    const authHeader = req.headers.get('authorization');
    const cronSecret = process.env.CRON_SECRET || 'btd_cron_2026';

    if (authHeader !== `Bearer ${cronSecret}` && req.nextUrl.searchParams.get('key') !== cronSecret) {
      // In production, guard the endpoint
      if (process.env.NODE_ENV === 'production') {
        return NextResponse.json({ error: 'Unauthorized cron trigger' }, { status: 401 });
      }
    }

    console.log('[Cron] Checking daily football matches for push dispatch...');

    // Scrape or fetch today's top matches from predicd
    const res = await fetch('https://www.predicd.com/en/football/', {
      headers: {
        'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      },
      next: { revalidate: 60 },
    });

    if (!res.ok) {
      return NextResponse.json({ error: 'Failed to fetch match data from upstream' }, { status: 502 });
    }

    const html = await res.text();

    // Match extraction regex
    const matchRegex = /data-home="([^"]+)"[^>]*data-away="([^"]+)"/g;
    const matches: Array<{ home: string; away: string }> = [];
    let match;
    while ((match = matchRegex.exec(html)) !== null && matches.length < 5) {
      matches.push({ home: match[1], away: match[2] });
    }

    if (matches.length === 0) {
      return NextResponse.json({ message: 'No featured matches found at this hour', count: 0 });
    }

    const topMatch = matches[0];

    // Automatically trigger notification broadcast through the send route
    const sendUrl = new URL('/api/notifications/send', req.url);
    const apiSecret = process.env.NOTIFICATION_API_SECRET || 'btd_secret_2026';

    const pushPayload = {
      topic: 'btd_all',
      title: `⚽ Matchday Focus: ${topMatch.home} vs ${topMatch.away}`,
      body: `Today's top prediction is live! Check xG trends & tactical analysis.`,
      matchData: {
        homeTeam: topMatch.home,
        awayTeam: topMatch.away,
        matchTime: 'Today',
        league: 'Top Fixture',
        prediction: 'Expert Analysis Ready',
      },
    };

    const pushRes = await fetch(sendUrl.toString(), {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${apiSecret}`,
      },
      body: JSON.stringify(pushPayload),
    });

    const pushResult = await pushRes.json();

    return NextResponse.json({
      success: true,
      timestamp: new Date().toISOString(),
      dispatchedMatch: topMatch,
      pushResult,
    });
  } catch (err: any) {
    console.error('[Cron Error]:', err);
    return NextResponse.json({ error: err.message }, { status: 500 });
  }
}
