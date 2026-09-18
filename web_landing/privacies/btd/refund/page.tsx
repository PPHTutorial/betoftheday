// web_landing/privacies/btd/refund/page.tsx
import React from 'react';
import { Metadata } from 'next';
import { APP } from '../../../btd/data';

export const metadata: Metadata = {
  title: `Refund Policy | ${APP.name}`,
  description: `Refund and cancellation policies for ${APP.name} by ${APP.company}. Google Play Store billing rules and support contacts.`,
};

export default function RefundPage() {
  return (
    <article className="prose prose-invert max-w-none space-y-6 text-slate-300 text-sm leading-relaxed">
      <div className="border-b border-white/10 pb-4 mb-6">
        <h1 className="text-2xl md:text-3xl font-black text-white">Refund &amp; Cancellation Policy</h1>
        <p className="text-xs text-slate-400 mt-1">Last Updated: {APP.lastUpdated} | Effective Immediately</p>
      </div>

      <p>
        At <strong>{APP.company}</strong>, we are committed to delivering reliable, data-backed football intelligence with <strong>{APP.name}</strong>. Because all in-app purchases and subscriptions are executed through <strong>Google Play In-App Billing</strong>, refund eligibility and processing are governed by Google Play&rsquo;s standard consumer policies.
      </p>

      <h2 className="text-lg font-bold text-white mt-6">1. Google Play 48-Hour Direct Refund</h2>
      <p>
        If fewer than 48 hours have elapsed since you purchased a subscription or VIP entitlement, you can request an instant refund directly from Google:
      </p>
      <ol className="list-decimal pl-6 space-y-2">
        <li>Visit the Google Play Refund portal at <code>support.google.com/googleplay/workflow/9813244</code>.</li>
        <li>Sign in with the Google Account used to download and purchase {APP.name}.</li>
        <li>Select the order corresponding to {APP.name} and choose <strong>Request a refund</strong>.</li>
        <li>Google will typically evaluate the request and provide a decision within 1 to 4 business hours.</li>
      </ol>

      <h2 className="text-lg font-bold text-white mt-6">2. Subscription Cancellations</h2>
      <p>
        You may cancel your auto-renewing subscription (Monthly PRO or Yearly PRO) at any time prior to the renewal date:
      </p>
      <ul className="list-disc pl-6 space-y-2">
        <li>Open the <strong>Google Play Store</strong> app on your Android device.</li>
        <li>Tap your profile icon in the top right &gt; <strong>Payments &amp; subscriptions &gt; Subscriptions</strong>.</li>
        <li>Select <strong>{APP.name}</strong> and tap <strong>Cancel subscription</strong>.</li>
        <li>Your VIP privileges will remain active until the end of your prepaid period. No further renewals will be billed.</li>
      </ul>

      <h2 className="text-lg font-bold text-white mt-6">3. Erroneous Charges &amp; Technical Support</h2>
      <p>
        If you encounter a billing glitch, such as payment being charged without your account receiving VIP entitlement, or if you require assistance with purchase restoration:
      </p>
      <p>
        Please email our engineering support team directly at{' '}
        <a href={`mailto:${APP.email}`} className="text-emerald-400 underline">{APP.email}</a>. Include your Google Play Order GPA number (e.g., <code>GPA.3312-XXXX-XXXX-XXXXX</code>) and our team will resolve your access or initiate a manual refund request with Google Play on your behalf.
      </p>
    </article>
  );
}
