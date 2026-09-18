// web_landing/btd/features/page.tsx
import React from 'react';
import { Metadata } from 'next';
import Link from 'next/link';
import { APP, FEATURES } from '../data';
import { Glow, NavBar, Footer, PlayBadge } from '../shared';
import {
  BrainCircuit,
  Activity,
  ShieldCheck,
  Radio,
  TrendingUp,
  Bell,
  CheckCircle2,
  Lock,
  Sparkles,
  ArrowRight,
  BarChart3,
  Flame,
  Zap,
  Layers,
} from 'lucide-react';

export const metadata: Metadata = {
  title: `Features | ${APP.name} — AI Football Analytics`,
  description: `Explore the high-precision tools in ${APP.name}: Monte Carlo match simulations, Expected Goals (xG) metrics, VIP Banker accumulators, and real-time live match telemetry.`,
};

const ICON_MAP: Record<string, React.ComponentType<{ className?: string }>> = {
  BrainCircuit,
  Activity,
  ShieldCheck,
  Radio,
  TrendingUp,
  Bell,
};

export default function FeaturesPage() {
  return (
    <div
      className="min-h-screen text-slate-100 flex flex-col selection:bg-emerald-500 selection:text-white"
      style={{ backgroundColor: APP.bg }}
    >
      <Glow />
      <NavBar />

      <main className="flex-1 relative z-10 pt-32 pb-24">
        {/* Header */}
        <section className="max-w-5xl mx-auto px-6 text-center">
          <div
            className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full text-xs font-semibold mb-6 border"
            style={{
              backgroundColor: `${APP.accent}14`,
              borderColor: `${APP.accent}40`,
              color: APP.accentLight,
            }}
          >
            <Sparkles className="w-3.5 h-3.5" />
            <span>FEATURE SUITE</span>
          </div>

          <h1 className="text-4xl md:text-6xl font-black tracking-tight text-white leading-tight mb-6">
            Institutional Sports Analytics in{' '}
            <span
              style={{
                backgroundImage: `linear-gradient(135deg, #FFFFFF, ${APP.accentLight})`,
                WebkitBackgroundClip: 'text',
                WebkitTextFillColor: 'transparent',
              }}
            >
              Your Palm
            </span>
          </h1>

          <p className="text-lg md:text-xl text-slate-400 max-w-2xl mx-auto leading-relaxed">
            Every feature in {APP.name} is engineered to eliminate guesswork and surface verifiable value using mathematical probability modeling.
          </p>
        </section>

        {/* Feature Cards Grid */}
        <section className="max-w-6xl mx-auto px-6 mt-16">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {FEATURES.map((f) => {
              const Icon = ICON_MAP[f.icon] || BrainCircuit;
              const isPro = f.tier === 'pro';

              return (
                <div
                  key={f.id}
                  className="p-8 rounded-3xl border transition-all duration-300 hover:translate-y-[-4px] backdrop-blur-xl relative overflow-hidden flex flex-col justify-between group"
                  style={{
                    backgroundColor: 'rgba(255, 255, 255, 0.02)',
                    borderColor: 'rgba(255, 255, 255, 0.07)',
                  }}
                >
                  <div>
                    <div className="flex items-center justify-between mb-6">
                      <div
                        className="w-12 h-12 rounded-2xl flex items-center justify-center transition-transform group-hover:scale-110"
                        style={{
                          backgroundColor: `${APP.accent}18`,
                          color: APP.accentLight,
                        }}
                      >
                        <Icon className="w-6 h-6" />
                      </div>
                      <span
                        className="text-[11px] font-bold uppercase tracking-wider px-3 py-1 rounded-full border"
                        style={{
                          backgroundColor: isPro ? 'rgba(245, 158, 11, 0.15)' : `${APP.accent}15`,
                          borderColor: isPro ? 'rgba(245, 158, 11, 0.3)' : `${APP.accent}30`,
                          color: isPro ? '#FBBF24' : APP.accentLight,
                        }}
                      >
                        {f.badge}
                      </span>
                    </div>

                    <h3 className="text-xl font-bold text-white mb-3 group-hover:text-emerald-300 transition-colors">
                      {f.title}
                    </h3>
                    <p className="text-slate-400 text-sm leading-relaxed mb-6">
                      {f.desc}
                    </p>
                  </div>

                  <div className="pt-4 border-t border-white/5 flex items-center justify-between text-xs">
                    <span className="text-slate-500 font-medium">Availability</span>
                    <span
                      className="font-bold flex items-center gap-1.5"
                      style={{ color: isPro ? '#FBBF24' : APP.accentLight }}
                    >
                      {isPro ? <Lock className="w-3.5 h-3.5" /> : <CheckCircle2 className="w-3.5 h-3.5" />}
                      {isPro ? 'PRO Subscription' : 'Free Core Feature'}
                    </span>
                  </div>
                </div>
              );
            })}
          </div>
        </section>

        {/* Deep Dive Breakdown */}
        <section className="max-w-5xl mx-auto px-6 mt-24">
          <div
            className="p-8 md:p-12 rounded-3xl border"
            style={{
              backgroundColor: 'rgba(255, 255, 255, 0.015)',
              borderColor: 'rgba(255, 255, 255, 0.08)',
            }}
          >
            <div className="flex items-center gap-3 mb-6 text-emerald-400">
              <BarChart3 className="w-6 h-6" />
              <span className="text-xs uppercase tracking-widest font-bold">Deep Dive</span>
            </div>

            <h2 className="text-2xl md:text-3xl font-bold text-white mb-6">
              How the Mathematical Engine Calculates Win Probabilities
            </h2>

            <div className="space-y-6 text-slate-300 text-sm md:text-base leading-relaxed">
              <p>
                Unlike traditional tipsters who rely on subjective opinions, {APP.name} utilizes an algorithmic pipeline that processes three foundational layers:
              </p>

              <div className="grid grid-cols-1 md:grid-cols-3 gap-4 pt-2">
                <div className="p-5 rounded-2xl bg-white/[0.03] border border-white/5">
                  <div className="flex items-center gap-2 font-bold text-white mb-2">
                    <Zap className="w-4 h-4 text-emerald-400" />
                    <span>1. Attack vs Defense xG</span>
                  </div>
                  <p className="text-xs text-slate-400 leading-normal">
                    Evaluating true shot creation, box entries, and defensive concession rates over rolling 5 and 15-game windows.
                  </p>
                </div>

                <div className="p-5 rounded-2xl bg-white/[0.03] border border-white/5">
                  <div className="flex items-center gap-2 font-bold text-white mb-2">
                    <Layers className="w-4 h-4 text-emerald-400" />
                    <span>2. Poisson Simulation</span>
                  </div>
                  <p className="text-xs text-slate-400 leading-normal">
                    Running 10,000 simulations per match to yield accurate probability matrices for exact goal scorelines.
                  </p>
                </div>

                <div className="p-5 rounded-2xl bg-white/[0.03] border border-white/5">
                  <div className="flex items-center gap-2 font-bold text-white mb-2">
                    <Flame className="w-4 h-4 text-emerald-400" />
                    <span>3. Market Edge Detection</span>
                  </div>
                  <p className="text-xs text-slate-400 leading-normal">
                    Comparing calculated fair odds against sportsbooks to uncover positive expected value (+EV) opportunities.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* CTA Banner */}
        <section className="max-w-4xl mx-auto px-6 mt-20 text-center">
          <div
            className="p-8 md:p-12 rounded-3xl border"
            style={{
              backgroundColor: `${APP.accentBg}40`,
              borderColor: `${APP.accent}30`,
            }}
          >
            <h2 className="text-3xl font-extrabold text-white mb-4">
              Experience the Full AI Prediction Suite
            </h2>
            <p className="text-slate-300 max-w-xl mx-auto mb-8 text-sm md:text-base">
              Download {APP.name} now on Google Play and start making informed, data-driven football picks today.
            </p>
            <div className="flex justify-center">
              <PlayBadge />
            </div>
          </div>
        </section>
      </main>

      <Footer />
    </div>
  );
}
