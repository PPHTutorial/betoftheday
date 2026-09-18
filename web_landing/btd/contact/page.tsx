// web_landing/btd/contact/page.tsx
'use client';

import React, { useState } from 'react';
import { APP } from '../data';
import { Glow, NavBar, Footer } from '../shared';
import {
  Mail,
  MessageSquare,
  Send,
  CheckCircle2,
  Sparkles,
  HelpCircle,
  Building,
} from 'lucide-react';

export default function ContactPage() {
  const [formState, setFormState] = useState({
    name: '',
    email: '',
    subject: 'General Inquiry',
    message: '',
  });
  const [submitted, setSubmitted] = useState(false);
  const [loading, setLoading] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    // Simulate clean dispatch or prepare mailto fallback
    setTimeout(() => {
      setLoading(false);
      setSubmitted(true);
    }, 600);
  };

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
            <Sparkles className="w-3.5 h-3.5" />
            <span>DIRECT ASSISTANCE</span>
          </div>

          <h1 className="text-4xl md:text-5xl font-black tracking-tight text-white mb-4">
            Get in Touch with Our Team
          </h1>

          <p className="text-slate-400 text-base md:text-lg max-w-xl mx-auto leading-relaxed">
            Have a question about subscriptions, feature ideas, bug reports, or partnership opportunities? We are here to help.
          </p>
        </section>

        {/* Content Container */}
        <section className="max-w-5xl mx-auto px-6 mt-12">
          <div className="grid grid-cols-1 md:grid-cols-12 gap-8">
            {/* Left Column: Direct Info */}
            <div className="md:col-span-5 space-y-6">
              <div
                className="p-8 rounded-3xl border backdrop-blur-xl"
                style={{
                  backgroundColor: 'rgba(255, 255, 255, 0.02)',
                  borderColor: 'rgba(255, 255, 255, 0.07)',
                }}
              >
                <h2 className="text-xl font-bold text-white mb-6">Contact Information</h2>

                <div className="space-y-6">
                  <div className="flex items-start gap-4">
                    <div
                      className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0"
                      style={{
                        backgroundColor: `${APP.accent}20`,
                        color: APP.accentLight,
                      }}
                    >
                      <Mail className="w-5 h-5" />
                    </div>
                    <div>
                      <div className="text-xs text-slate-400 font-medium">Email Us Directly</div>
                      <a
                        href={`mailto:${APP.email}`}
                        className="text-sm font-semibold text-emerald-400 hover:underline block mt-0.5"
                      >
                        {APP.email}
                      </a>
                      <div className="text-[11px] text-slate-500 mt-1">
                        Average response time: &lt; 24 hours
                      </div>
                    </div>
                  </div>

                  <div className="flex items-start gap-4">
                    <div
                      className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0"
                      style={{
                        backgroundColor: `${APP.accent}20`,
                        color: APP.accentLight,
                      }}
                    >
                      <Building className="w-5 h-5" />
                    </div>
                    <div>
                      <div className="text-xs text-slate-400 font-medium">Publisher</div>
                      <div className="text-sm font-semibold text-white mt-0.5">
                        {APP.company}
                      </div>
                      <div className="text-[11px] text-slate-500 mt-1">
                        Mobile App Development &amp; AI Intelligence
                      </div>
                    </div>
                  </div>

                  <div className="flex items-start gap-4">
                    <div
                      className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0"
                      style={{
                        backgroundColor: `${APP.accent}20`,
                        color: APP.accentLight,
                      }}
                    >
                      <HelpCircle className="w-5 h-5" />
                    </div>
                    <div>
                      <div className="text-xs text-slate-400 font-medium">Need Immediate Help?</div>
                      <div className="text-sm text-slate-300 mt-0.5">
                        Check our comprehensive FAQs in the{' '}
                        <a href="/btd/support" className="text-emerald-400 underline font-medium">
                          Support Hub
                        </a>.
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* Right Column: Contact Form */}
            <div className="md:col-span-7">
              <div
                className="p-8 md:p-10 rounded-3xl border backdrop-blur-xl"
                style={{
                  backgroundColor: 'rgba(255, 255, 255, 0.025)',
                  borderColor: 'rgba(255, 255, 255, 0.08)',
                }}
              >
                {submitted ? (
                  <div className="text-center py-12">
                    <div
                      className="w-16 h-16 mx-auto rounded-full flex items-center justify-center mb-6"
                      style={{ backgroundColor: `${APP.accent}20`, color: APP.accentLight }}
                    >
                      <CheckCircle2 className="w-10 h-10" />
                    </div>
                    <h3 className="text-2xl font-bold text-white mb-2">Message Sent!</h3>
                    <p className="text-slate-400 max-w-md mx-auto text-sm mb-6 leading-relaxed">
                      Thank you for reaching out to {APP.name}. Our support engineers will review your note and get back to you at{' '}
                      <span className="text-white font-medium">{formState.email}</span> promptly.
                    </p>
                    <button
                      onClick={() => {
                        setSubmitted(false);
                        setFormState({ name: '', email: '', subject: 'General Inquiry', message: '' });
                      }}
                      className="px-6 py-2.5 rounded-full text-xs font-bold uppercase tracking-wider text-slate-200 border border-white/10 hover:bg-white/5 transition-colors"
                    >
                      Send Another Message
                    </button>
                  </div>
                ) : (
                  <form onSubmit={handleSubmit} className="space-y-5">
                    <h2 className="text-xl font-bold text-white mb-4">Send a Direct Message</h2>

                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      <div>
                        <label className="block text-xs font-semibold text-slate-400 mb-1.5">
                          Your Name
                        </label>
                        <input
                          type="text"
                          required
                          value={formState.name}
                          onChange={(e) => setFormState({ ...formState, name: e.target.value })}
                          placeholder="e.g. John Doe"
                          className="w-full px-4 py-3 rounded-xl bg-white/[0.04] border border-white/10 text-white text-sm focus:outline-none focus:border-emerald-400 transition-colors"
                        />
                      </div>
                      <div>
                        <label className="block text-xs font-semibold text-slate-400 mb-1.5">
                          Email Address
                        </label>
                        <input
                          type="email"
                          required
                          value={formState.email}
                          onChange={(e) => setFormState({ ...formState, email: e.target.value })}
                          placeholder="john@example.com"
                          className="w-full px-4 py-3 rounded-xl bg-white/[0.04] border border-white/10 text-white text-sm focus:outline-none focus:border-emerald-400 transition-colors"
                        />
                      </div>
                    </div>

                    <div>
                      <label className="block text-xs font-semibold text-slate-400 mb-1.5">
                        Subject
                      </label>
                      <select
                        value={formState.subject}
                        onChange={(e) => setFormState({ ...formState, subject: e.target.value })}
                        className="w-full px-4 py-3 rounded-xl bg-[#13161C] border border-white/10 text-white text-sm focus:outline-none focus:border-emerald-400 transition-colors"
                      >
                        <option value="General Inquiry">General Inquiry</option>
                        <option value="Subscription & Billing">Subscription &amp; Billing</option>
                        <option value="Bug Report">Bug Report</option>
                        <option value="Feature Request">Feature Request</option>
                        <option value="Partnership & Sponsorship">Partnership &amp; Sponsorship</option>
                      </select>
                    </div>

                    <div>
                      <label className="block text-xs font-semibold text-slate-400 mb-1.5">
                        Message
                      </label>
                      <textarea
                        required
                        rows={5}
                        value={formState.message}
                        onChange={(e) => setFormState({ ...formState, message: e.target.value })}
                        placeholder="Please describe your question or issue in detail..."
                        className="w-full px-4 py-3 rounded-xl bg-white/[0.04] border border-white/10 text-white text-sm focus:outline-none focus:border-emerald-400 transition-colors resize-none"
                      />
                    </div>

                    <button
                      type="submit"
                      disabled={loading}
                      className="w-full py-3.5 rounded-full text-white font-bold text-sm flex items-center justify-center gap-2 transition-all duration-200 hover:scale-[1.01] active:scale-[0.99] disabled:opacity-50"
                      style={{
                        background: `linear-gradient(135deg, ${APP.accent}, ${APP.accentDark})`,
                        boxShadow: `0 8px 24px ${APP.accent}33`,
                      }}
                    >
                      {loading ? (
                        <span>Sending Message...</span>
                      ) : (
                        <>
                          <Send className="w-4 h-4" />
                          <span>Submit Message</span>
                        </>
                      )}
                    </button>
                  </form>
                )}
              </div>
            </div>
          </div>
        </section>
      </main>

      <Footer />
    </div>
  );
}
