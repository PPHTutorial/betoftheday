// web_landing/privacies/btd/tos/page.tsx
import React from 'react';
import { Metadata } from 'next';
import { APP } from '../../../btd/data';

export const metadata: Metadata = {
  title: `Terms of Service | ${APP.name}`,
  description: `Official Terms of Service for ${APP.name} by ${APP.company}. Details on subscription billing, advisory nature, and liability limits.`,
};

export default function TosPage() {
  return (
    <article className="prose prose-invert max-w-none space-y-6 text-slate-300 text-sm leading-relaxed">
      <div className="border-b border-white/10 pb-4 mb-6">
        <h1 className="text-2xl md:text-3xl font-black text-white">Terms of Service</h1>
        <p className="text-xs text-slate-400 mt-1">Last Updated: {APP.lastUpdated} | Effective Immediately</p>
      </div>

      <p>
        These Terms of Service (&ldquo;Terms&rdquo;) establish the legally binding contract between you and <strong>{APP.company}</strong> regarding your installation, access, and use of the <strong>{APP.name}</strong> mobile software application and related web pages.
      </p>

      <div className="p-4 rounded-2xl bg-amber-500/10 border border-amber-500/20 text-amber-200 text-xs md:text-sm">
        <strong>IMPORTANT NOTICE &amp; DISCLAIMER:</strong> {APP.name} is an analytical, informational, and sports statistics advisory application. It is <em>not</em> a gambling operator, sportsbook, bookmaker, or wager facilitation platform. We do not accept bets, stake funds, or provide guaranteed financial returns.
      </div>

      <h2 className="text-lg font-bold text-white mt-6">1. Eligibility &amp; Acceptance</h2>
      <p>
        By downloading or using {APP.name}, you represent that you are at least 18 years old (or the legal age of majority in your jurisdiction) and have the full power and authority to enter into this agreement. If you do not agree to all terms, you must uninstall the application immediately.
      </p>

      <h2 className="text-lg font-bold text-white mt-6">2. VIP Subscriptions &amp; In-App Billing</h2>
      <ul className="list-disc pl-6 space-y-2">
        <li>
          <strong>Tiers &amp; Features:</strong> BTD provides optional paid subscriptions (&ldquo;Monthly PRO&rdquo;, &ldquo;Yearly PRO&rdquo;) and a non-recurring &ldquo;Lifetime VIP&rdquo; entitlement that unlock premium banker picks, unrestricted match views, and remove ad placements.
        </li>
        <li>
          <strong>Payment Processing:</strong> Transactions are securely conducted via Google Play In-App Billing and verified using RevenueCat. You authorize Google to charge your selected payment method.
        </li>
        <li>
          <strong>Automatic Renewal:</strong> Monthly and Yearly plans automatically renew unless cancelled at least 24 hours prior to the conclusion of the active subscription period.
        </li>
        <li>
          <strong>Cancellation:</strong> You may cancel anytime directly through the Google Play Store Subscriptions console. Cancellations take effect at the close of the current paid billing cycle.
        </li>
      </ul>

      <h2 className="text-lg font-bold text-white mt-6">3. Permitted Use &amp; Intellectual Property</h2>
      <p>
        All proprietary algorithms, machine learning weights, Poisson models, Expected Goals calculations, logos, iconography, and code are owned exclusively by {APP.company}. You are granted a limited, personal, revocable, non-transferable license to use the app for individual entertainment and sports analysis. You may not re-sell, distribute, reverse-engineer, scrape, or republish our predictive outputs.
      </p>

      <h2 className="text-lg font-bold text-white mt-6">4. Disclaimer of Warranties</h2>
      <p>
        The software and statistical predictions are provided on an &ldquo;AS IS&rdquo; and &ldquo;AS AVAILABLE&rdquo; basis. Football and sports match results are subject to human variance, weather, referee decisions, and chance. {APP.company} makes no warranties that predictions will result in winning bets or financial gain.
      </p>

      <h2 className="text-lg font-bold text-white mt-6">5. Limitation of Liability</h2>
      <p>
        To the maximum extent permitted by law, {APP.company}, its officers, directors, and employees shall not be liable for any direct, indirect, incidental, punitive, or consequential damages resulting from your reliance on data, odds, or predictions within {APP.name}.
      </p>

      <h2 className="text-lg font-bold text-white mt-6">6. Governing Law &amp; Dispute Resolution</h2>
      <p>
        These Terms shall be governed and interpreted in accordance with the laws of the jurisdiction in which {APP.company} operates, without giving effect to any conflict of law provisions.
      </p>

      <h2 className="text-lg font-bold text-white mt-6">7. Contact</h2>
      <p>
        Inquiries concerning these Terms of Service should be directed to{' '}
        <a href={`mailto:${APP.email}`} className="text-emerald-400 underline">{APP.email}</a>.
      </p>
    </article>
  );
}
