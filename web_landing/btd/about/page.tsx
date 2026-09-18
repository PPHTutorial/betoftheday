// web_landing/btd/about/page.tsx
import React from 'react';
import { Metadata } from 'next';
import Link from 'next/link';
import { APP } from '../data';
import { Glow, NavBar, Footer, PlayBadge } from '../shared';
import {
  Sparkles,
  ShieldCheck,
  Target,
  Users,
  Code2,
  TrendingUp,
  Award,
} from 'lucide-react';

export const metadata: Metadata = {
  title: `About ${APP.name} | Advanced AI Sports Predictions`,
  description: `Learn how ${APP.name} by ${APP.company} transforms football forecasting using predictive analytics, expected goals (xG), and Poisson distribution algorithms.`,
};

export default function AboutPage() {
  return (
    <div
      className="min-h-screen text-slate-100 flex flex-col selection:bg-emerald-500 selection:text-white"
      style={{ backgroundColor: APP.bg }}
    >
      <Glow />
      <NavBar />

      <main className="flex-1 relative z-10 pt-32 pb-24">
        {/* Hero Section */}
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
            <span>THE SCIENCE OF WINNING</span>
          </div>

          <h1 className="text-4xl md:text-6xl font-black tracking-tight text-white leading-tight mb-6">
            Empowering Football Fans with{' '}
            <span
              style={{
                backgroundImage: `linear-gradient(135deg, #FFFFFF, ${APP.accentLight})`,
                WebkitBackgroundClip: 'text',
                WebkitTextFillColor: 'transparent',
              }}
            >
              Algorithmic Precision
            </span>
          </h1>

          <p className="text-lg md:text-xl text-slate-400 max-w-3xl mx-auto leading-relaxed">
            {APP.name} was built to bridge the gap between emotional guesswork and true statistical probabilities. By leveraging advanced machine learning, expected goals (xG), and Poisson modeling, we bring institutional-grade football intelligence directly to your fingertips.
          </p>
        </section>

        {/* Mission & Story Grid */}
        <section className="max-w-6xl mx-auto px-6 mt-20">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            <div
              className="p-8 md:p-10 rounded-3xl border relative overflow-hidden backdrop-blur-xl"
              style={{
                backgroundColor: 'rgba(255, 255, 255, 0.02)',
                borderColor: 'rgba(255, 255, 255, 0.07)',
              }}
            >
              <div
                className="w-12 h-12 rounded-2xl flex items-center justify-center mb-6"
                style={{
                  backgroundColor: `${APP.accent}20`,
                  color: APP.accentLight,
                }}
              >
                <Target className="w-6 h-6" />
              </div>
              <h2 className="text-2xl font-bold text-white mb-4">Our Mission</h2>
              <p className="text-slate-300 leading-relaxed mb-4">
                At {APP.company}, we believe every sports enthusiast deserves access to unbiased, mathematically sound analytics. Bookmakers have spent decades building algorithmic models to calculate house margins. Our goal is to level the playing field by providing transparent probability estimates and value identification.
              </p>
              <p className="text-slate-400 leading-relaxed text-sm">
                We continuously refine our neural predictive architectures against tens of thousands of historic fixture events across European top flights, South American leagues, and fast-growing international tournaments.
              </p>
            </div>

            <div
              className="p-8 md:p-10 rounded-3xl border relative overflow-hidden backdrop-blur-xl"
              style={{
                backgroundColor: 'rgba(255, 255, 255, 0.02)',
                borderColor: 'rgba(255, 255, 255, 0.07)',
              }}
            >
              <div
                className="w-12 h-12 rounded-2xl flex items-center justify-center mb-6"
                style={{
                  backgroundColor: `${APP.accent}20`,
                  color: APP.accentLight,
                }}
              >
                <Code2 className="w-6 h-6" />
              </div>
              <h2 className="text-2xl font-bold text-white mb-4">How BTD Works</h2>
              <p className="text-slate-300 leading-relaxed mb-4">
                Raw football scores are notoriously deceptive. A team can scrape a 1–0 victory despite conceding 2.8 Expected Goals (xG). {APP.name} scrapes beyond surface stats, simulating thousands of match trajectories.
              </p>
              <p className="text-slate-400 leading-relaxed text-sm">
                Our model aggregates shot quality, passing sequence chains, injury updates, fatigue decay, and market odds movements to generate realistic probabilities for 1X2, Over/Under 2.5, Both Teams to Score (BTTS), and Double Chance.
              </p>
            </div>
          </div>
        </section>

        {/* Pillars / Values */}
        <section className="max-w-6xl mx-auto px-6 mt-16">
          <div className="text-center mb-12">
            <h2 className="text-2xl md:text-3xl font-bold text-white">Our Core Principles</h2>
            <p className="text-slate-400 text-sm mt-2">The standards that guide every feature we build</p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div
              className="p-6 rounded-2xl border backdrop-blur-lg"
              style={{
                backgroundColor: 'rgba(255, 255, 255, 0.02)',
                borderColor: 'rgba(255, 255, 255, 0.06)',
              }}
            >
              <ShieldCheck className="w-8 h-8 mb-4 text-emerald-400" />
              <h3 className="font-bold text-white text-lg mb-2">Total Transparency</h3>
              <p className="text-slate-400 text-sm leading-relaxed">
                We archive all match predictions, win rates, and streak records openly. We never delete historical picks or manufacture fake streaks.
              </p>
            </div>

            <div
              className="p-6 rounded-2xl border backdrop-blur-lg"
              style={{
                backgroundColor: 'rgba(255, 255, 255, 0.02)',
                borderColor: 'rgba(255, 255, 255, 0.06)',
              }}
            >
              <TrendingUp className="w-8 h-8 mb-4 text-emerald-400" />
              <h3 className="font-bold text-white text-lg mb-2">Responsible Play</h3>
              <p className="text-slate-400 text-sm leading-relaxed">
                Sports betting carries inherent risk. We advocate strict bankroll management, unit sizing, and using our data as an informative advisory tool.
              </p>
            </div>

            <div
              className="p-6 rounded-2xl border backdrop-blur-lg"
              style={{
                backgroundColor: 'rgba(255, 255, 255, 0.02)',
                borderColor: 'rgba(255, 255, 255, 0.06)',
              }}
            >
              <Award className="w-8 h-8 mb-4 text-emerald-400" />
              <h3 className="font-bold text-white text-lg mb-2">Continuous Innovation</h3>
              <p className="text-slate-400 text-sm leading-relaxed">
                Our engineering team consistently introduces improved neural weights, live telemetry, and instant real-time odds analysis.
              </p>
            </div>
          </div>
        </section>

        {/* Company & Team */}
        <section className="max-w-4xl mx-auto px-6 mt-20 text-center">
          <div
            className="p-8 md:p-12 rounded-3xl border relative overflow-hidden"
            style={{
              backgroundColor: 'rgba(16, 185, 129, 0.04)',
              borderColor: 'rgba(16, 185, 129, 0.2)',
            }}
          >
            <Users className="w-10 h-10 mx-auto mb-4 text-emerald-400" />
            <h2 className="text-2xl md:text-3xl font-bold text-white mb-4">
              Engineered with Passion by {APP.company}
            </h2>
            <p className="text-slate-300 max-w-2xl mx-auto leading-relaxed text-sm md:text-base mb-8">
              We are a dedicated collective of software engineers, sports data scientists, and mobile architects focused on crafting lightning-fast, beautifully designed apps that solve real user problems.
            </p>
            <div className="flex flex-wrap items-center justify-center gap-4">
              <PlayBadge />
              <Link
                href="/btd/contact"
                className="inline-flex items-center gap-2 px-6 py-3 rounded-full text-slate-200 text-sm font-semibold border transition-colors hover:bg-white/5"
                style={{ borderColor: 'rgba(255, 255, 255, 0.15)' }}
              >
                Get in Touch
              </Link>
            </div>
          </div>
        </section>
      </main>

      <Footer />
    </div>
  );
}
