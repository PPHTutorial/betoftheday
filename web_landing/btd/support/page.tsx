// web_landing/btd/support/page.tsx
'use client';

import React, { useState, useMemo } from 'react';
import Link from 'next/link';
import { APP, FAQS, COMMUNITY_LINKS } from '../data';
import { Glow, NavBar, Footer } from '../shared';
import {
  Search,
  ChevronDown,
  HelpCircle,
  MessageSquare,
  Sparkles,
  LifeBuoy,
  CreditCard,
  Smartphone,
  Cpu,
  Mail,
} from 'lucide-react';
import {
  FaDiscord,
  FaTelegram,
  FaWhatsapp,
  FaXTwitter,
} from 'react-icons/fa6';

const COMMUNITY_ICONS: Record<string, React.ComponentType<{ size?: number; className?: string }>> = {
  telegram: FaTelegram,
  discord: FaDiscord,
  twitter: FaXTwitter,
  whatsapp: FaWhatsapp,
};

const EXTENDED_FAQS = [
  ...FAQS,
  {
    question: 'How do I restore my purchases on a new phone?',
    answer:
      'Open the Bet Of The Day app on your new device (logged into the same Google Play account), navigate to Settings > Restore Purchases. The app will securely query Google Play and RevenueCat to reactivate your PRO or Lifetime access immediately.',
  },
  {
    question: 'What time are daily predictions updated?',
    answer:
      'Our AI pipeline begins ingesting team sheets, early odds drifts, and squad declarations at 00:00 UTC daily. Picks are refreshed continuously up until match kickoff to incorporate late lineup breaking news.',
  },
  {
    question: 'Are historical prediction results audited?',
    answer:
      'Yes. Every finished fixture is logged in our historical archive with the predicted probability vs final outcome. We do not retroactively modify or erase past tips.',
  },
];

export default function SupportPage() {
  const [searchQuery, setSearchQuery] = useState('');
  const [openIndex, setOpenIndex] = useState<number | null>(0);

  const filteredFaqs = useMemo(() => {
    if (!searchQuery.trim()) return EXTENDED_FAQS;
    const q = searchQuery.toLowerCase();
    return EXTENDED_FAQS.filter(
      (f) => f.question.toLowerCase().includes(q) || f.answer.toLowerCase().includes(q)
    );
  }, [searchQuery]);

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
            <LifeBuoy className="w-3.5 h-3.5" />
            <span>HELP &amp; DOCUMENTATION</span>
          </div>

          <h1 className="text-4xl md:text-5xl font-black tracking-tight text-white mb-4">
            How can we help you today?
          </h1>

          <p className="text-slate-400 text-base md:text-lg max-w-xl mx-auto leading-relaxed mb-8">
            Find answers to frequently asked questions about {APP.name}, subscription management, and algorithm methodology.
          </p>

          {/* Search Box */}
          <div className="max-w-xl mx-auto relative">
            <Search className="w-5 h-5 absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search questions (e.g. refund, xG, restore, billing)..."
              className="w-full pl-12 pr-4 py-4 rounded-2xl bg-white/[0.04] border border-white/10 text-white placeholder:text-slate-500 text-sm focus:outline-none focus:border-emerald-400 shadow-xl transition-all"
            />
            {searchQuery && (
              <button
                onClick={() => setSearchQuery('')}
                className="absolute right-4 top-1/2 -translate-y-1/2 text-xs text-slate-400 hover:text-white"
              >
                Clear
              </button>
            )}
          </div>
        </section>

        {/* Quick Help Categories */}
        <section className="max-w-5xl mx-auto px-6 mt-14">
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div
              className="p-5 rounded-2xl border bg-white/[0.02] border-white/5 flex items-center gap-4 cursor-pointer hover:border-emerald-500/30 transition-colors"
              onClick={() => setSearchQuery('subscription')}
            >
              <div className="w-10 h-10 rounded-xl bg-emerald-500/10 text-emerald-400 flex items-center justify-center shrink-0">
                <CreditCard className="w-5 h-5" />
              </div>
              <div>
                <div className="font-bold text-white text-sm">Billing &amp; VIP</div>
                <div className="text-xs text-slate-400">Manage subscriptions</div>
              </div>
            </div>

            <div
              className="p-5 rounded-2xl border bg-white/[0.02] border-white/5 flex items-center gap-4 cursor-pointer hover:border-emerald-500/30 transition-colors"
              onClick={() => setSearchQuery('algorithm')}
            >
              <div className="w-10 h-10 rounded-xl bg-emerald-500/10 text-emerald-400 flex items-center justify-center shrink-0">
                <Cpu className="w-5 h-5" />
              </div>
              <div>
                <div className="font-bold text-white text-sm">AI Predictions</div>
                <div className="text-xs text-slate-400">xG &amp; Poisson modeling</div>
              </div>
            </div>

            <div
              className="p-5 rounded-2xl border bg-white/[0.02] border-white/5 flex items-center gap-4 cursor-pointer hover:border-emerald-500/30 transition-colors"
              onClick={() => setSearchQuery('device')}
            >
              <div className="w-10 h-10 rounded-xl bg-emerald-500/10 text-emerald-400 flex items-center justify-center shrink-0">
                <Smartphone className="w-5 h-5" />
              </div>
              <div>
                <div className="font-bold text-white text-sm">App &amp; Setup</div>
                <div className="text-xs text-slate-400">Android &amp; features</div>
              </div>
            </div>
          </div>
        </section>

        {/* FAQ Accordion Section */}
        <section className="max-w-4xl mx-auto px-6 mt-14">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-xl font-bold text-white">Frequently Asked Questions</h2>
            <span className="text-xs text-slate-400">{filteredFaqs.length} results</span>
          </div>

          {filteredFaqs.length === 0 ? (
            <div className="text-center py-12 p-8 rounded-3xl border border-white/5 bg-white/[0.01]">
              <HelpCircle className="w-10 h-10 mx-auto text-slate-500 mb-3" />
              <div className="text-white font-semibold">No questions matched your query</div>
              <p className="text-slate-400 text-xs mt-1 mb-4">
                Try searching for a different keyword or contact our support team.
              </p>
              <button
                onClick={() => setSearchQuery('')}
                className="text-xs text-emerald-400 underline font-semibold"
              >
                Reset Search
              </button>
            </div>
          ) : (
            <div className="space-y-3">
              {filteredFaqs.map((faq, idx) => {
                const isOpen = openIndex === idx;

                return (
                  <div
                    key={idx}
                    className="rounded-2xl border transition-colors overflow-hidden"
                    style={{
                      backgroundColor: isOpen ? 'rgba(255, 255, 255, 0.035)' : 'rgba(255, 255, 255, 0.015)',
                      borderColor: isOpen ? 'rgba(16, 185, 129, 0.3)' : 'rgba(255, 255, 255, 0.06)',
                    }}
                  >
                    <button
                      onClick={() => setOpenIndex(isOpen ? null : idx)}
                      className="w-full text-left p-5 md:p-6 flex items-center justify-between gap-4"
                    >
                      <span className="font-bold text-sm md:text-base text-white">
                        {faq.question}
                      </span>
                      <ChevronDown
                        className={`w-5 h-5 shrink-0 transition-transform duration-200 text-slate-400 ${
                          isOpen ? 'rotate-180 text-emerald-400' : ''
                        }`}
                      />
                    </button>
                    {isOpen && (
                      <div className="px-5 md:px-6 pb-6 pt-1 text-slate-300 text-xs md:text-sm leading-relaxed border-t border-white/5">
                        {faq.answer}
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
          )}
        </section>

        {/* Community Links */}
        <section className="max-w-4xl mx-auto px-6 mt-20">
          <div className="text-center mb-8">
            <h2 className="text-2xl font-bold text-white">Join Our Community</h2>
            <p className="text-slate-400 text-sm mt-1">
              Connect with fellow bettors, share slips, and receive instant kickoff updates
            </p>
          </div>

          <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
            {COMMUNITY_LINKS.map((c) => {
              const Icon = COMMUNITY_ICONS[c.kind] || MessageSquare;

              return (
                <a
                  key={c.kind}
                  href={c.url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="p-5 rounded-2xl border bg-white/[0.02] border-white/5 flex flex-col items-center justify-center gap-3 text-center transition-all hover:scale-105 hover:border-white/20"
                >
                  <div
                    className="w-12 h-12 rounded-xl flex items-center justify-center text-white text-xl"
                    style={{ backgroundColor: c.color }}
                  >
                    <Icon size={22} />
                  </div>
                  <span className="text-xs font-bold text-white">{c.label}</span>
                </a>
              );
            })}
          </div>
        </section>

        {/* Still Need Help Box */}
        <section className="max-w-3xl mx-auto px-6 mt-16 text-center">
          <div
            className="p-8 rounded-3xl border"
            style={{
              backgroundColor: `${APP.accentBg}30`,
              borderColor: `${APP.accent}30`,
            }}
          >
            <Mail className="w-8 h-8 mx-auto mb-3 text-emerald-400" />
            <h3 className="text-xl font-bold text-white mb-2">Still need help?</h3>
            <p className="text-slate-300 text-xs md:text-sm max-w-md mx-auto mb-6">
              If your question isn’t answered above, contact our technical support directly or write to us at{' '}
              <span className="text-emerald-300 font-semibold">{APP.email}</span>.
            </p>
            <Link
              href="/btd/contact"
              className="inline-flex items-center gap-2 px-6 py-2.5 rounded-full text-white text-xs font-bold uppercase tracking-wider transition-all hover:scale-105"
              style={{
                background: `linear-gradient(135deg, ${APP.accent}, ${APP.accentDark})`,
                boxShadow: `0 4px 16px ${APP.accent}33`,
              }}
            >
              Contact Support Team
            </Link>
          </div>
        </section>
      </main>

      <Footer />
    </div>
  );
}
