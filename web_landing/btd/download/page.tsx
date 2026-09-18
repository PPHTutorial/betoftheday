// web_landing/btd/download/page.tsx
import React from 'react';
import { Metadata } from 'next';
import { APP, STATS } from '../data';
import { Glow, NavBar, Footer, PlayBadge } from '../shared';
import {
  Download,
  Smartphone,
  ShieldCheck,
  CheckCircle2,
  Sparkles,
  Zap,
  Lock,
  ArrowRight,
} from 'lucide-react';

export const metadata: Metadata = {
  title: `Download ${APP.name} | Android APK & Google Play`,
  description: `Get ${APP.name} on Android via the Google Play Store. Free daily match tips, Expected Goals (xG) ratings, and high-probability VIP accumulators.`,
};

export default function DownloadPage() {
  return (
    <div
      className="min-h-screen text-slate-100 flex flex-col selection:bg-emerald-500 selection:text-white"
      style={{ backgroundColor: APP.bg }}
    >
      <Glow />
      <NavBar />

      <main className="flex-1 relative z-10 pt-32 pb-24">
        {/* Header */}
        <section className="max-w-4xl mx-auto px-6 text-center">
          <div
            className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full text-xs font-semibold mb-6 border"
            style={{
              backgroundColor: `${APP.accent}14`,
              borderColor: `${APP.accent}40`,
              color: APP.accentLight,
            }}
          >
            <Download className="w-3.5 h-3.5" />
            <span>INSTANT INSTALLATION</span>
          </div>

          <h1 className="text-4xl md:text-6xl font-black tracking-tight text-white mb-6">
            Get{' '}
            <span
              style={{
                backgroundImage: `linear-gradient(135deg, #FFFFFF, ${APP.accentLight})`,
                WebkitBackgroundClip: 'text',
                WebkitTextFillColor: 'transparent',
              }}
            >
              {APP.name}
            </span>{' '}
            Free
          </h1>

          <p className="text-slate-400 text-base md:text-lg max-w-xl mx-auto leading-relaxed mb-8">
            Install the latest version directly from Google Play. Start accessing high-confidence daily football tips, xG indicators, and live match scores.
          </p>

          <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
            <PlayBadge />
          </div>
        </section>

        {/* Requirements & App Details */}
        <section className="max-w-4xl mx-auto px-6 mt-16">
          <div
            className="p-8 md:p-10 rounded-3xl border backdrop-blur-xl"
            style={{
              backgroundColor: 'rgba(255, 255, 255, 0.02)',
              borderColor: 'rgba(255, 255, 255, 0.08)',
            }}
          >
            <h2 className="text-xl font-bold text-white mb-6 flex items-center gap-2">
              <Smartphone className="w-5 h-5 text-emerald-400" />
              <span>Platform Specifications &amp; Compatibility</span>
            </h2>

            <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 py-4 border-y border-white/5">
              <div>
                <div className="text-xs text-slate-400">Current Release</div>
                <div className="text-sm font-bold text-white mt-1">v1.0.0+1</div>
              </div>
              <div>
                <div className="text-xs text-slate-400">OS Compatibility</div>
                <div className="text-sm font-bold text-white mt-1">Android 6.0+</div>
              </div>
              <div>
                <div className="text-xs text-slate-400">Package ID</div>
                <div className="text-sm font-mono text-emerald-400 mt-1 truncate">
                  {APP.packageId}
                </div>
              </div>
              <div>
                <div className="text-xs text-slate-400">Pricing</div>
                <div className="text-sm font-bold text-emerald-400 mt-1">Free with VIP tier</div>
              </div>
            </div>

            <div className="mt-8 space-y-3">
              <div className="flex items-center gap-3 text-xs md:text-sm text-slate-300">
                <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0" />
                <span>Verified Clean &amp; Secure via Google Play Protect</span>
              </div>
              <div className="flex items-center gap-3 text-xs md:text-sm text-slate-300">
                <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0" />
                <span>Lightweight installation footprint (&lt; 25MB download)</span>
              </div>
              <div className="flex items-center gap-3 text-xs md:text-sm text-slate-300">
                <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0" />
                <span>Encrypted local storage for offline bookmarks and favorites</span>
              </div>
              <div className="flex items-center gap-3 text-xs md:text-sm text-slate-300">
                <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0" />
                <span>No intrusive full-screen popups or audio autoplay ads</span>
              </div>
            </div>
          </div>
        </section>

        {/* What to Expect Card */}
        <section className="max-w-4xl mx-auto px-6 mt-12">
          <div
            className="p-8 rounded-3xl border"
            style={{
              backgroundColor: `${APP.accentBg}25`,
              borderColor: `${APP.accent}30`,
            }}
          >
            <h3 className="text-lg font-bold text-white mb-4 flex items-center gap-2">
              <Zap className="w-5 h-5 text-emerald-400" />
              <span>What to Expect After Launch</span>
            </h3>
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 text-xs md:text-sm text-slate-300">
              <div className="p-4 rounded-xl bg-white/[0.02] border border-white/5">
                <div className="font-bold text-white mb-1">1. Daily Top Pick</div>
                Instant access to today’s highest-confidence mathematical banker pick upon opening.
              </div>
              <div className="p-4 rounded-xl bg-white/[0.02] border border-white/5">
                <div className="font-bold text-white mb-1">2. Rolling Free Unlock</div>
                Unlock premium fixtures for free on a daily rolling cadence without paying upfront.
              </div>
              <div className="p-4 rounded-xl bg-white/[0.02] border border-white/5">
                <div className="font-bold text-white mb-1">3. Live Goal Feed</div>
                Real-time tracking for ongoing matches so you never miss a critical momentum shift.
              </div>
            </div>
          </div>
        </section>
      </main>

      <Footer />
    </div>
  );
}
