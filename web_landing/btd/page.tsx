// web_landing/btd/page.tsx
// Main Landing Page conforming to Section 18.6 and Section 19 of CODEINK_APP_BLUEPRINT.md

'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import {
  APP,
  FEATURES,
  HOW_IT_WORKS_STEPS,
  STATS,
  PLANS,
  FAQS,
  COMMUNITY_LINKS,
} from './data';
import {
  NavBar,
  Footer,
  Glow,
  PlayBadge,
  ImgPlaceholder,
} from './shared';
import {
  BrainCircuit,
  Activity,
  ShieldCheck,
  Radio,
  TrendingUp,
  Bell,
  CheckCircle2,
  ChevronDown,
  Sparkles,
  ArrowRight,
  Trophy,
} from 'lucide-react';
import {
  FaTelegram,
  FaDiscord,
  FaXTwitter,
  FaWhatsapp,
} from 'react-icons/fa6';

// ── Accent values (Section 18.4) ─────────────────────────────────────────────
const ACCENT = '#10B981';
const ACCENT_DARK = '#059669';
const ACCENT_LIGHT = '#34D399';
const ACCENT_BG = '#064E3B';
const BG = '#08090D';

const ICON_MAP: Record<string, React.ComponentType<{ className?: string; style?: React.CSSProperties }>> = {
  BrainCircuit,
  Activity,
  ShieldCheck,
  Radio,
  TrendingUp,
  Bell,
};

const COMMUNITY_ICONS: Record<string, React.ComponentType<{ size?: number }>> = {
  telegram: FaTelegram,
  discord: FaDiscord,
  twitter: FaXTwitter,
  whatsapp: FaWhatsapp,
};

export default function LandingPage() {
  const [openFaq, setOpenFaq] = useState<number | null>(0);

  return (
    <div
      className="min-h-screen text-white selection:bg-emerald-500/30 selection:text-emerald-300 font-sans antialiased overflow-x-hidden"
      style={{ background: BG }}
    >
      <Glow />
      <NavBar />

      {/* ── 1. HERO SECTION ──────────────────────────────────────────────── */}
      <section className="relative pt-36 pb-24 lg:pt-44 lg:pb-32 px-6">
        <div className="max-w-7xl mx-auto grid grid-cols-1 lg:grid-cols-12 gap-16 items-center">
          <div className="lg:col-span-7 space-y-8 text-center lg:text-left">
            <div
              className="inline-flex items-center gap-2.5 px-4 py-2 rounded-full text-xs font-extrabold uppercase tracking-widest"
              style={{
                background: `${ACCENT}1A`,
                color: ACCENT_LIGHT,
                border: `1px solid ${ACCENT}33`,
              }}
            >
              <Sparkles size={14} />
              <span>Next-Gen Football Analytics Engine</span>
            </div>

            <h1 className="text-5xl md:text-7xl font-extrabold tracking-tight leading-[1.05] text-white">
              Stop Guessing.{' '}
              <span style={{ color: ACCENT }}>Start Winning</span> With AI
              Precision.
            </h1>

            <p className="text-lg md:text-xl text-gray-400 max-w-2xl leading-relaxed">
              {APP.oneLiner} Comprehensive expected goals (xG), win probabilities,
              and daily high-conviction banker accas in real time.
            </p>

            <div className="flex flex-col sm:flex-row items-center justify-center lg:justify-start gap-4 pt-2">
              <PlayBadge />
              <Link
                href="/btd/features"
                className="inline-flex items-center gap-2 px-8 py-3.5 rounded-full text-sm font-bold text-white transition-all hover:bg-white/10"
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.1)',
                }}
              >
                Explore Features <ArrowRight size={16} />
              </Link>
            </div>

            <div className="flex items-center justify-center lg:justify-start gap-6 pt-4 text-xs text-gray-500">
              <span className="flex items-center gap-1.5">
                <CheckCircle2 size={14} style={{ color: ACCENT }} /> Daily Free Unlocks
              </span>
              <span className="flex items-center gap-1.5">
                <CheckCircle2 size={14} style={{ color: ACCENT }} /> No Mandatory Sign-Up
              </span>
              <span className="flex items-center gap-1.5">
                <CheckCircle2 size={14} style={{ color: ACCENT }} /> 50+ Leagues
              </span>
            </div>
          </div>

          {/* Floating Phone Mockup */}
          <div className="lg:col-span-5 flex justify-center">
            <div
              className="relative w-full max-w-[340px] rounded-[42px] p-3 shadow-2xl transition-transform hover:scale-[1.02]"
              style={{
                background: 'linear-gradient(180deg, rgba(255,255,255,0.15) 0%, rgba(255,255,255,0.02) 100%)',
                boxShadow: `0 24px 60px -12px ${ACCENT}26`,
              }}
            >
              <div
                className="w-full rounded-[34px] overflow-hidden p-6 space-y-5"
                style={{ background: '#0F1218' }}
              >
                {/* Simulated App Header */}
                <div className="flex items-center justify-between border-b border-white/5 pb-4">
                  <div className="flex items-center gap-2">
                    <span className="text-xl font-black text-emerald-400">BTD</span>
                    <span className="text-[10px] uppercase font-bold tracking-wider px-2 py-0.5 rounded bg-emerald-500/10 text-emerald-300">
                      LIVE
                    </span>
                  </div>
                  <span className="text-xs text-gray-400">Today's Picks</span>
                </div>

                {/* Match Card Simulation */}
                <div
                  className="rounded-2xl p-4 space-y-3"
                  style={{ background: 'rgba(255,255,255,0.04)' }}
                >
                  <div className="flex justify-between items-center text-[11px] text-gray-400">
                    <span className="font-bold text-white">Premier League</span>
                    <span className="text-emerald-400 font-semibold">Today • 20:00</span>
                  </div>
                  <div className="flex items-center justify-between py-2">
                    <div className="text-center w-1/3">
                      <div className="w-9 h-9 rounded-full bg-white/10 mx-auto mb-1 flex items-center justify-center font-bold text-xs">
                        ARS
                      </div>
                      <span className="text-xs font-bold">Arsenal</span>
                    </div>
                    <div className="text-center w-1/3">
                      <span className="text-xs font-extrabold tracking-widest text-emerald-400">VS</span>
                      <div className="text-[10px] text-gray-500 mt-1">xG 2.4 vs 1.1</div>
                    </div>
                    <div className="text-center w-1/3">
                      <div className="w-9 h-9 rounded-full bg-white/10 mx-auto mb-1 flex items-center justify-center font-bold text-xs">
                        CHE
                      </div>
                      <span className="text-xs font-bold">Chelsea</span>
                    </div>
                  </div>

                  <div
                    className="p-2.5 rounded-xl flex items-center justify-between text-xs"
                    style={{ background: `${ACCENT}14` }}
                  >
                    <span className="font-bold" style={{ color: ACCENT_LIGHT }}>
                      AI TIP: Home Win & Over 1.5
                    </span>
                    <span className="font-black text-white">74% Prob</span>
                  </div>
                </div>

                {/* Second Match Simulation */}
                <div
                  className="rounded-2xl p-4 space-y-2.5"
                  style={{ background: 'rgba(255,255,255,0.04)' }}
                >
                  <div className="flex justify-between items-center text-[11px] text-gray-400">
                    <span className="font-bold text-white">Champions League</span>
                    <span className="text-emerald-400 font-semibold">Tomorrow • 21:00</span>
                  </div>
                  <div className="flex justify-between items-center text-xs font-bold pt-1">
                    <span>Real Madrid</span>
                    <span className="text-emerald-400">Over 2.5 Goals (81%)</span>
                  </div>
                </div>

                <div className="text-center pt-2">
                  <span className="text-[11px] text-gray-500 font-medium">
                    Verified Poisson & Monte Carlo Engine
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ── 2. STATS STRIP ───────────────────────────────────────────────── */}
      <section
        className="border-y border-white/5 py-12"
        style={{ background: 'rgba(255,255,255,0.015)' }}
      >
        <div className="max-w-7xl mx-auto px-6 grid grid-cols-2 md:grid-cols-4 gap-8 text-center">
          {STATS.map((s) => (
            <div key={s.label} className="space-y-1">
              <div
                className="text-4xl lg:text-5xl font-extrabold tracking-tight"
                style={{ color: ACCENT }}
              >
                {s.value}
              </div>
              <div className="text-xs md:text-sm text-gray-400 font-medium">
                {s.label}
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* ── 3. FEATURES SECTION ──────────────────────────────────────────── */}
      <section id="features" className="py-24 px-6 relative z-10">
        <div className="max-w-7xl mx-auto space-y-16">
          <div className="text-center max-w-3xl mx-auto space-y-4">
            <div
              className="inline-block px-4 py-1.5 text-xs font-bold tracking-widest uppercase rounded-full"
              style={{ background: `${ACCENT}14`, color: ACCENT_LIGHT }}
            >
              Algorithmic Advantage
            </div>
            <h2 className="text-4xl lg:text-5xl font-extrabold tracking-tight text-white">
              Engineered For The Analytical Bettor
            </h2>
            <p className="text-gray-400 text-base md:text-lg leading-relaxed">
              Every prediction is computed through quantitative models, goal
              expectancies, and real-time odds telemetry.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {FEATURES.map((f) => {
              const Icon = ICON_MAP[f.icon] || BrainCircuit;
              return (
                <div
                  key={f.id}
                  className="p-8 rounded-3xl transition-all duration-200 hover:translate-y-[-4px]"
                  style={{ background: 'rgba(255,255,255,0.04)' }}
                >
                  <div className="flex items-center justify-between mb-6">
                    <div
                      className="w-12 h-12 rounded-2xl flex items-center justify-center"
                      style={{ background: `${ACCENT}14` }}
                    >
                      <Icon style={{ color: ACCENT_LIGHT }} className="w-6 h-6" />
                    </div>
                    <span
                      className="text-[10px] font-extrabold uppercase tracking-widest px-3 py-1 rounded-full"
                      style={{
                        background: f.tier === 'pro' ? `${ACCENT}26` : 'rgba(255,255,255,0.08)',
                        color: f.tier === 'pro' ? ACCENT_LIGHT : '#9CA3AF',
                      }}
                    >
                      {f.badge}
                    </span>
                  </div>
                  <h3 className="text-xl font-bold text-white mb-2">{f.title}</h3>
                  <p className="text-sm text-gray-400 leading-relaxed">{f.desc}</p>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* ── 4. HOW IT WORKS ──────────────────────────────────────────────── */}
      <section
        className="py-24 px-6 border-y border-white/5"
        style={{ background: 'rgba(255,255,255,0.015)' }}
      >
        <div className="max-w-7xl mx-auto space-y-16">
          <div className="text-center max-w-3xl mx-auto space-y-4">
            <div
              className="inline-block px-4 py-1.5 text-xs font-bold tracking-widest uppercase rounded-full"
              style={{ background: `${ACCENT}14`, color: ACCENT_LIGHT }}
            >
              Simple Workflow
            </div>
            <h2 className="text-4xl lg:text-5xl font-extrabold tracking-tight text-white">
              How Bet Of The Day Powers Your Bets
            </h2>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {HOW_IT_WORKS_STEPS.map((s) => (
              <div
                key={s.step}
                className="p-8 rounded-3xl relative space-y-4"
                style={{ background: 'rgba(255,255,255,0.03)' }}
              >
                <div
                  className="text-3xl font-black tracking-widest"
                  style={{ color: ACCENT_LIGHT }}
                >
                  {s.step}
                </div>
                <h3 className="text-xl font-bold text-white">{s.title}</h3>
                <p className="text-sm text-gray-400 leading-relaxed">{s.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── 5. PRICING & VIP TIERS ───────────────────────────────────────── */}
      <section id="pricing" className="py-24 px-6">
        <div className="max-w-7xl mx-auto space-y-16">
          <div className="text-center max-w-3xl mx-auto space-y-4">
            <div
              className="inline-block px-4 py-1.5 text-xs font-bold tracking-widest uppercase rounded-full"
              style={{ background: `${ACCENT}14`, color: ACCENT_LIGHT }}
            >
              Subscription Tiers
            </div>
            <h2 className="text-4xl lg:text-5xl font-extrabold tracking-tight text-white">
              Transparent Pricing. Maximum Value.
            </h2>
            <p className="text-gray-400 text-base md:text-lg">
              Unlock unlimited simultaneous predictions, banker picks, and full xG
              analytics with BTD PRO.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8 items-stretch">
            {PLANS.map((plan) => (
              <div
                key={plan.id}
                className={`rounded-3xl p-8 flex flex-col justify-between relative transition-all ${
                  plan.popular ? 'border-2' : 'border border-white/5'
                }`}
                style={{
                  background: plan.popular ? 'rgba(16, 185, 129, 0.05)' : 'rgba(255,255,255,0.03)',
                  borderColor: plan.popular ? ACCENT : 'rgba(255,255,255,0.06)',
                }}
              >
                {plan.popular && (
                  <div
                    className="absolute -top-3.5 left-1/2 -translate-x-1/2 px-4 py-1 rounded-full text-[11px] font-black tracking-widest uppercase text-black"
                    style={{ background: ACCENT }}
                  >
                    BEST VALUE • {plan.savings}
                  </div>
                )}

                <div className="space-y-6">
                  <div>
                    <h3 className="text-2xl font-black text-white">{plan.name}</h3>
                    <p className="text-xs text-gray-400 mt-1">{plan.desc}</p>
                  </div>

                  <div className="flex items-baseline gap-1">
                    <span className="text-5xl font-black text-white">{plan.price}</span>
                    <span className="text-sm text-gray-400">{plan.period}</span>
                  </div>

                  <ul className="space-y-3 pt-4 border-t border-white/10">
                    {plan.features.map((feat) => (
                      <li key={feat} className="flex items-center gap-3 text-sm text-gray-300">
                        <CheckCircle2 size={16} style={{ color: ACCENT }} />
                        <span>{feat}</span>
                      </li>
                    ))}
                  </ul>
                </div>

                <div className="pt-8">
                  <Link
                    href="/btd/download"
                    className={`block w-full py-3.5 text-center rounded-full text-sm font-bold transition-all ${
                      plan.popular
                        ? 'text-black hover:scale-105 active:scale-95'
                        : 'text-white hover:bg-white/10'
                    }`}
                    style={{
                      background: plan.popular ? ACCENT : 'rgba(255,255,255,0.08)',
                    }}
                  >
                    {plan.cta}
                  </Link>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── 6. COMMUNITY SECTION ─────────────────────────────────────────── */}
      <section
        className="py-20 px-6 border-y border-white/5"
        style={{ background: 'rgba(255,255,255,0.015)' }}
      >
        <div className="max-w-4xl mx-auto text-center space-y-8">
          <div className="space-y-3">
            <h2 className="text-3xl font-extrabold text-white">
              Join Our Betting Community
            </h2>
            <p className="text-gray-400 text-sm max-w-xl mx-auto">
              Get daily free coupon drops, participate in betting discussions, and
              receive real-time injury and odds updates.
            </p>
          </div>

          <div className="flex flex-wrap items-center justify-center gap-3">
            {COMMUNITY_LINKS.map((link) => {
              const Icon = COMMUNITY_ICONS[link.kind] || Trophy;
              return (
                <a
                  key={link.label}
                  href={link.url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center gap-2.5 px-6 py-3 rounded-full text-sm font-semibold text-white transition-transform hover:scale-105 active:scale-95"
                  style={{ background: link.color }}
                >
                  <Icon size={16} /> {link.label}
                </a>
              );
            })}
          </div>
        </div>
      </section>

      {/* ── 7. FAQ ACCORDION ─────────────────────────────────────────────── */}
      <section id="faq" className="py-24 px-6">
        <div className="max-w-4xl mx-auto space-y-12">
          <div className="text-center space-y-3">
            <div
              className="inline-block px-4 py-1.5 text-xs font-bold tracking-widest uppercase rounded-full"
              style={{ background: `${ACCENT}14`, color: ACCENT_LIGHT }}
            >
              Frequently Asked Questions
            </div>
            <h2 className="text-4xl font-extrabold text-white">
              Got Questions? We’ve Got Answers.
            </h2>
          </div>

          <div className="space-y-4">
            {FAQS.map((faq, idx) => {
              const isOpen = openFaq === idx;
              return (
                <div
                  key={faq.question}
                  className="rounded-2xl border border-white/5 overflow-hidden transition-colors"
                  style={{ background: 'rgba(255,255,255,0.03)' }}
                >
                  <button
                    onClick={() => setOpenFaq(isOpen ? null : idx)}
                    className="w-full text-left p-6 flex items-center justify-between gap-4"
                  >
                    <span className="font-bold text-base text-white">
                      {faq.question}
                    </span>
                    <ChevronDown
                      size={18}
                      className={`text-gray-400 transition-transform duration-200 ${
                        isOpen ? 'rotate-180 text-emerald-400' : ''
                      }`}
                    />
                  </button>
                  {isOpen && (
                    <div className="px-6 pb-6 text-sm text-gray-400 leading-relaxed border-t border-white/5 pt-4">
                      {faq.answer}
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* ── 8. DOWNLOAD CTA BLOCK ────────────────────────────────────────── */}
      <section className="py-20 px-6">
        <div
          className="max-w-6xl mx-auto rounded-[36px] p-10 lg:p-16 text-center space-y-8 relative overflow-hidden"
          style={{ background: ACCENT_BG }}
        >
          <div className="max-w-2xl mx-auto space-y-4 relative z-10">
            <h2 className="text-4xl lg:text-5xl font-black text-white leading-tight">
              Get Bet Of The Day Today
            </h2>
            <p className="text-emerald-100/80 text-base md:text-lg">
              Download free on Android. Unlock high-conviction predictions and
              never bet blindly again.
            </p>
            <div className="pt-4 flex justify-center">
              <PlayBadge />
            </div>
          </div>
        </div>
      </section>

      <Footer />
    </div>
  );
}
