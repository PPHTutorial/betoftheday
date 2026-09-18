// web_landing/btd/legal/LegalView.tsx
'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { useRouter, useSearchParams } from 'next/navigation';
import { APP } from '../data';
import { Glow, NavBar, Footer } from '../shared';
import {
  Shield,
  FileText,
  Lock,
  Cookie,
  CreditCard,
  Building,
  Calendar,
  Sparkles,
} from 'lucide-react';

const TABS = [
  { id: 'privacy', label: 'Privacy Policy', icon: Shield },
  { id: 'tos', label: 'Terms of Service', icon: FileText },
  { id: 'eula', label: 'EULA', icon: Lock },
  { id: 'cookies', label: 'Cookie Policy', icon: Cookie },
  { id: 'refund', label: 'Refund Policy', icon: CreditCard },
] as const;

type TabId = typeof TABS[number]['id'];

export default function LegalView({ initialTab = 'privacy' }: { initialTab?: TabId }) {
  const router = useRouter();
  const searchParams = useSearchParams();
  const tabParam = searchParams.get('tab') as TabId;

  const [activeTab, setActiveTab] = useState<TabId>(
    TABS.some((t) => t.id === tabParam) ? tabParam : initialTab
  );

  useEffect(() => {
    if (tabParam && TABS.some((t) => t.id === tabParam)) {
      setActiveTab(tabParam);
    }
  }, [tabParam]);

  const handleTabChange = (tab: TabId) => {
    setActiveTab(tab);
    router.push(`/btd/legal?tab=${tab}`, { scroll: false });
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
            <Shield className="w-3.5 h-3.5" />
            <span>COMPLIANCE &amp; LEGAL FRAMEWORK</span>
          </div>

          <h1 className="text-3xl md:text-5xl font-black tracking-tight text-white mb-4">
            Legal Terms &amp; Policies
          </h1>

          <div className="flex items-center justify-center gap-6 text-xs text-slate-400">
            <span className="flex items-center gap-1.5">
              <Building className="w-3.5 h-3.5 text-emerald-400" />
              {APP.company}
            </span>
            <span className="flex items-center gap-1.5">
              <Calendar className="w-3.5 h-3.5 text-emerald-400" />
              Effective: {APP.lastUpdated}
            </span>
          </div>
        </section>

        {/* Tab Navigation Pill Bar */}
        <section className="max-w-4xl mx-auto px-6 mt-10">
          <div className="flex flex-wrap items-center justify-center gap-2 p-1.5 rounded-2xl bg-white/[0.03] border border-white/10 backdrop-blur-xl">
            {TABS.map((tab) => {
              const Icon = tab.icon;
              const isActive = activeTab === tab.id;

              return (
                <button
                  key={tab.id}
                  onClick={() => handleTabChange(tab.id)}
                  className="flex items-center gap-2 px-4 py-2.5 rounded-xl text-xs md:text-sm font-semibold transition-all duration-200"
                  style={{
                    backgroundColor: isActive ? APP.accent : 'transparent',
                    color: isActive ? '#FFFFFF' : '#94A3B8',
                    boxShadow: isActive ? `0 4px 14px ${APP.accent}4D` : 'none',
                  }}
                >
                  <Icon className="w-4 h-4" />
                  <span>{tab.label}</span>
                </button>
              );
            })}
          </div>
        </section>

        {/* Legal Text Content Card */}
        <section className="max-w-4xl mx-auto px-6 mt-10">
          <div
            className="p-8 md:p-12 rounded-3xl border backdrop-blur-xl bg-white/[0.02] border-white/10"
          >
            {activeTab === 'privacy' && <PrivacyContent />}
            {activeTab === 'tos' && <TosContent />}
            {activeTab === 'eula' && <EulaContent />}
            {activeTab === 'cookies' && <CookiesContent />}
            {activeTab === 'refund' && <RefundContent />}
          </div>
        </section>
      </main>

      <Footer />
    </div>
  );
}

function PrivacyContent() {
  return (
    <article className="prose prose-invert max-w-none space-y-6 text-slate-300 text-sm leading-relaxed">
      <h2 className="text-2xl font-bold text-white border-b border-white/10 pb-4">
        Privacy Policy for {APP.name}
      </h2>

      <p>
        Welcome to <strong>{APP.name}</strong> (&ldquo;we&rdquo;, &ldquo;our&rdquo;, or &ldquo;us&rdquo;), operated by <strong>{APP.company}</strong>. We are committed to protecting your privacy and ensuring transparency regarding how your data is handled when you use our mobile application and companion web services.
      </p>

      <h3 className="text-lg font-bold text-white mt-6">1. Information We Collect</h3>
      <p>
        We do not collect personal identifying information (such as your physical address or government ID) unless you explicitly contact us via support. When you use {APP.name}, the following data may be processed automatically:
      </p>
      <ul className="list-disc pl-6 space-y-2">
        <li>
          <strong>Device &amp; Hardware Identifiers:</strong> Operating system version, device model, screen resolution, and language settings to ensure proper UI scaling and localization.
        </li>
        <li>
          <strong>Analytics &amp; Usage Telemetry:</strong> Anonymized interaction logs including screens viewed, button clicks, match lookups, and session duration to improve app stability and user experience.
        </li>
        <li>
          <strong>Advertising Identifiers:</strong> Google Advertising ID (GAID) collected by third-party advertising SDKs for interest-based ad measurement and fraud detection.
        </li>
        <li>
          <strong>Purchase &amp; Entitlement Data:</strong> App Store transaction tokens and RevenueCat anonymous subscriber IDs to verify subscription status and deliver VIP features.
        </li>
      </ul>

      <h3 className="text-lg font-bold text-white mt-6">2. Third-Party Service Providers</h3>
      <p>
        To deliver our services, we integrate vetted, enterprise-grade third-party software development kits (SDKs):
      </p>
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 my-4">
        <div className="p-4 rounded-xl bg-white/[0.02] border border-white/5">
          <div className="font-bold text-white mb-1">Google AdMob</div>
          <p className="text-xs text-slate-400">
            Delivers rewarded and interstitial ads. AdMob uses advertising identifiers in compliance with Google Play Developer Policies.
          </p>
        </div>
        <div className="p-4 rounded-xl bg-white/[0.02] border border-white/5">
          <div className="font-bold text-white mb-1">RevenueCat</div>
          <p className="text-xs text-slate-400">
            Manages in-app subscriptions, receipt validation, and entitlements across devices securely without exposing financial details.
          </p>
        </div>
        <div className="p-4 rounded-xl bg-white/[0.02] border border-white/5">
          <div className="font-bold text-white mb-1">Firebase (Google)</div>
          <p className="text-xs text-slate-400">
            Provides crash diagnostics, real-time telemetry, and push notifications for kickoff alerts and fixture updates.
          </p>
        </div>
        <div className="p-4 rounded-xl bg-white/[0.02] border border-white/5">
          <div className="font-bold text-white mb-1">Local Secure Storage</div>
          <p className="text-xs text-slate-400">
            Stores your local favorites, theme preferences, and cached predictions locally on your device via encrypted storage.
          </p>
        </div>
      </div>

      <h3 className="text-lg font-bold text-white mt-6">3. Data Retention &amp; Security</h3>
      <p>
        We employ industry-standard encryption protocols (TLS/HTTPS) for all data in transit. We retain anonymized aggregate analytics data only for as long as necessary to analyze trends, detect anomalies, and optimize server infrastructure.
      </p>

      <h3 className="text-lg font-bold text-white mt-6">4. Children&rsquo;s Privacy (COPPA Compliance)</h3>
      <p>
        {APP.name} is intended for sports enthusiasts aged 18 and older (or the legal age of majority in your jurisdiction). We do not knowingly solicit or collect personal information from children under 13. If you believe a minor has provided us with personal data, please contact us immediately.
      </p>

      <h3 className="text-lg font-bold text-white mt-6">5. Your Rights (GDPR &amp; CCPA)</h3>
      <p>
        Under applicable regulations (including GDPR and CCPA), you have the right to request access to, rectification of, or erasure of any data associated with your device identifier. You may also opt out of personalized ads at any time via your Android device settings (Settings &gt; Google &gt; Ads &gt; Delete advertising ID).
      </p>

      <h3 className="text-lg font-bold text-white mt-6">6. Contact Us</h3>
      <p>
        If you have questions regarding this Privacy Policy, please contact our Data Protection team at{' '}
        <a href={`mailto:${APP.email}`} className="text-emerald-400 underline">
          {APP.email}
        </a>.
      </p>
    </article>
  );
}

function TosContent() {
  return (
    <article className="prose prose-invert max-w-none space-y-6 text-slate-300 text-sm leading-relaxed">
      <h2 className="text-2xl font-bold text-white border-b border-white/10 pb-4">
        Terms of Service
      </h2>

      <p>
        These Terms of Service (&ldquo;Terms&rdquo;) govern your use of the <strong>{APP.name}</strong> mobile application and related web services operated by <strong>{APP.company}</strong>. By installing or accessing {APP.name}, you agree to be bound by these Terms.
      </p>

      <h3 className="text-lg font-bold text-white mt-6">1. Informational &amp; Entertainment Use Only</h3>
      <p className="p-4 rounded-xl bg-amber-500/10 border border-amber-500/20 text-amber-200">
        <strong>IMPORTANT NOTICE:</strong> {APP.name} is an analytics and statistical advisory application intended solely for informational and entertainment purposes. {APP.name} is NOT a sportsbook, gambling operator, or betting platform. We do not accept wagers, take deposits, or distribute financial returns.
      </p>

      <h3 className="text-lg font-bold text-white mt-6">2. Subscription &amp; Billing Terms</h3>
      <ul className="list-disc pl-6 space-y-2">
        <li>
          <strong>PRO Subscriptions:</strong> BTD offers Monthly and Yearly auto-renewing subscriptions, as well as Lifetime access purchases, unlocking all VIP Banker tips, unlimited matches, and an ad-free interface.
        </li>
        <li>
          <strong>Billing:</strong> Payments are charged to your Google Play account at confirmation of purchase. Subscriptions automatically renew unless auto-renew is turned off at least 24 hours before the end of the current billing cycle.
        </li>
        <li>
          <strong>Management:</strong> You can manage and cancel your subscriptions anytime in your Google Play Store account settings.
        </li>
      </ul>

      <h3 className="text-lg font-bold text-white mt-6">3. Intellectual Property</h3>
      <p>
        All proprietary algorithms, expected goal models, UI designs, codebases, logos, and prediction databases are the exclusive intellectual property of {APP.company}. You may not decompile, reverse-engineer, scrape, redistribute, or reproduce any part of our service without prior written consent.
      </p>

      <h3 className="text-lg font-bold text-white mt-6">4. Disclaimer of Warranties &amp; Limitation of Liability</h3>
      <p>
        Sports events are inherently volatile and unpredictable. We provide statistical projections &ldquo;AS IS&rdquo; without warranties of any kind. {APP.company} shall not be liable for any financial losses, missed betting profits, or damages resulting from reliance on probabilities or tips provided within the app.
      </p>

      <h3 className="text-lg font-bold text-white mt-6">5. Governing Law</h3>
      <p>
        These Terms are governed by and construed in accordance with applicable laws without regard to conflict of law principles.
      </p>
    </article>
  );
}

function EulaContent() {
  return (
    <article className="prose prose-invert max-w-none space-y-6 text-slate-300 text-sm leading-relaxed">
      <h2 className="text-2xl font-bold text-white border-b border-white/10 pb-4">
        End User License Agreement (EULA)
      </h2>

      <p>
        This End User License Agreement (&ldquo;EULA&rdquo;) is a legal agreement between you and <strong>{APP.company}</strong> for the software product <strong>{APP.name}</strong>.
      </p>

      <h3 className="text-lg font-bold text-white mt-6">1. Grant of License</h3>
      <p>
        {APP.company} grants you a personal, revocable, non-exclusive, non-transferable, limited license to download, install, and use the Application strictly in accordance with the terms of this Agreement and Google Play Store terms.
      </p>

      <h3 className="text-lg font-bold text-white mt-6">2. Restrictions on Use</h3>
      <p>You agree not to, and you will not permit others to:</p>
      <ul className="list-disc pl-6 space-y-2">
        <li>License, sell, rent, lease, assign, host, or commercially exploit the Application.</li>
        <li>Modify, make derivative works of, disassemble, decrypt, reverse compile, or reverse engineer any part of the Application.</li>
        <li>Extract our proprietary algorithms, scrapers, or prediction outputs for re-distribution or syndication.</li>
      </ul>

      <h3 className="text-lg font-bold text-white mt-6">3. Updates &amp; Termination</h3>
      <p>
        We may from time to time provide enhancements or updates to the Application. This EULA remains in effect until terminated by you or {APP.company}. Upon termination, you must cease all use of the Application and delete all copies.
      </p>
    </article>
  );
}

function CookiesContent() {
  return (
    <article className="prose prose-invert max-w-none space-y-6 text-slate-300 text-sm leading-relaxed">
      <h2 className="text-2xl font-bold text-white border-b border-white/10 pb-4">
        Cookie &amp; Local Storage Policy
      </h2>

      <p>
        This Cookie &amp; Local Storage Policy explains how <strong>{APP.name}</strong> and <strong>{APP.company}</strong> use cookies, cache files, and mobile local storage mechanisms (such as SharedPreferences and FlutterSecureStorage).
      </p>

      <h3 className="text-lg font-bold text-white mt-6">1. What We Store Locally on Your Device</h3>
      <ul className="list-disc pl-6 space-y-2">
        <li>
          <strong>User Preferences:</strong> Storing active theme selection, preferred accent colors, and notification opt-ins.
        </li>
        <li>
          <strong>Unlocked Match IDs:</strong> In-memory and persistent sets of fixtures unlocked via daily free slots or rewarded ads, ensuring you do not lose access during your session.
        </li>
        <li>
          <strong>Bookmarked Matches:</strong> Local identifiers of games saved to your favorites tab.
        </li>
        <li>
          <strong>Cached Odds &amp; Predictions:</strong> Short-lived local cache to minimize unnecessary mobile network requests and enable offline reading.
        </li>
      </ul>

      <h3 className="text-lg font-bold text-white mt-6">2. Third-Party Web Cookies</h3>
      <p>
        Our companion web landing page may use essential session cookies for analytics and performance monitoring. You can manage or disable cookies via your browser preferences.
      </p>
    </article>
  );
}

function RefundContent() {
  return (
    <article className="prose prose-invert max-w-none space-y-6 text-slate-300 text-sm leading-relaxed">
      <h2 className="text-2xl font-bold text-white border-b border-white/10 pb-4">
        Refund Policy
      </h2>

      <p>
        At <strong>{APP.company}</strong>, we strive to deliver transparent, high-value sports intelligence. All purchases in <strong>{APP.name}</strong> are processed directly through the <strong>Google Play Store In-App Billing</strong> system.
      </p>

      <h3 className="text-lg font-bold text-white mt-6">1. Google Play 48-Hour Refund Window</h3>
      <p>
        If you made a purchase or subscription within the last 48 hours, you can request a direct refund through Google Play&rsquo;s automated refund portal:
      </p>
      <ol className="list-decimal pl-6 space-y-2">
        <li>Go to <code>play.google.com</code> and log into your Google account.</li>
        <li>Navigate to <strong>Account &gt; Order History</strong>.</li>
        <li>Locate your purchase of <em>{APP.name}</em> and select <strong>Request a refund</strong>.</li>
      </ol>

      <h3 className="text-lg font-bold text-white mt-6">2. Subscriptions &amp; Cancellations</h3>
      <p>
        You can cancel your subscription at any point before your renewal date. When you cancel, you will maintain full VIP access until the end of your current paid billing period. We do not offer partial refunds for unused days within an active monthly or yearly cycle.
      </p>

      <h3 className="text-lg font-bold text-white mt-6">3. Contacting Developer Support</h3>
      <p>
        If you experience technical issues restoring your purchase or if you believe an erroneous charge was processed, please email us at{' '}
        <a href={`mailto:${APP.email}`} className="text-emerald-400 underline">
          {APP.email}
        </a>{' '}
        with your Google Play Order GPA receipt number (e.g., <code>GPA.XXXX-XXXX-XXXX-XXXXX</code>).
      </p>
    </article>
  );
}
