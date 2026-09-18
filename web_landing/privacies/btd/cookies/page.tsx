// web_landing/privacies/btd/cookies/page.tsx
import React from 'react';
import { Metadata } from 'next';
import { APP } from '../../../btd/data';

export const metadata: Metadata = {
  title: `Cookie & Local Storage Policy | ${APP.name}`,
  description: `Cookie and Local Storage Policy for ${APP.name} by ${APP.company}. Explaining on-device cache, encryption, and preferences.`,
};

export default function CookiesPage() {
  return (
    <article className="prose prose-invert max-w-none space-y-6 text-slate-300 text-sm leading-relaxed">
      <div className="border-b border-white/10 pb-4 mb-6">
        <h1 className="text-2xl md:text-3xl font-black text-white">Cookie &amp; Local Storage Policy</h1>
        <p className="text-xs text-slate-400 mt-1">Last Updated: {APP.lastUpdated} | Effective Immediately</p>
      </div>

      <p>
        This Cookie &amp; Local Storage Policy describes how <strong>{APP.name}</strong> and <strong>{APP.company}</strong> use cookies, local cache files, and device storage mechanisms on both our companion web landing pages and Android application.
      </p>

      <h2 className="text-lg font-bold text-white mt-6">1. What is On-Device Local Storage?</h2>
      <p>
        Mobile applications do not utilize web browser cookies in the traditional desktop sense. Instead, {APP.name} utilizes mobile system storage primitives provided by the Android OS:
      </p>
      <ul className="list-disc pl-6 space-y-2">
        <li>
          <strong>SharedPreferences:</strong> Lightweight key-value storage used to store non-sensitive state such as selected dark/light theme options, dynamic user accent color selections, push notification preferences, and onboarding completion flags.
        </li>
        <li>
          <strong>Encrypted Local Storage:</strong> Secure storage mechanisms that cache your unlocked match tokens, active VIP entitlements, and bookmarked matches to prevent repetitive network lookups and support offline viewing.
        </li>
        <li>
          <strong>HTTP Memory &amp; Disk Cache:</strong> Short-term cache for fixture logos, team badges, and live score states to ensure high-performance rendering without excessive battery drain or cellular data usage.
        </li>
      </ul>

      <h2 className="text-lg font-bold text-white mt-6">2. Web Landing Page Cookies</h2>
      <p>
        When you visit our web landing pages (hosted at <code>serviceworker-two.vercel.app/btd</code>), small text files (&ldquo;cookies&rdquo;) may be stored in your browser to maintain session integrity and anonymized traffic metrics. We do not use third-party cross-site behavioral tracking cookies on our web pages.
      </p>

      <h2 className="text-lg font-bold text-white mt-6">3. Managing and Clearing Storage</h2>
      <p>
        You have complete control over local data stored by {APP.name}:
      </p>
      <ul className="list-disc pl-6 space-y-2">
        <li>
          <strong>Clear App Cache:</strong> On Android, navigate to <em>Settings &gt; Apps &gt; {APP.name} &gt; Storage &gt; Clear Cache</em>.
        </li>
        <li>
          <strong>Reset Advertising ID:</strong> In your device settings under <em>Google &gt; Ads</em>, you can reset or delete your advertising identifier at any time.
        </li>
      </ul>

      <h2 className="text-lg font-bold text-white mt-6">4. Contact Us</h2>
      <p>
        If you have questions about how data is stored locally, contact us at{' '}
        <a href={`mailto:${APP.email}`} className="text-emerald-400 underline">{APP.email}</a>.
      </p>
    </article>
  );
}
