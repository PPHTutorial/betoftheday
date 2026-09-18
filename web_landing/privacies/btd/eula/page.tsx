// web_landing/privacies/btd/eula/page.tsx
import React from 'react';
import { Metadata } from 'next';
import { APP } from '../../../btd/data';

export const metadata: Metadata = {
  title: `End User License Agreement (EULA) | ${APP.name}`,
  description: `End User License Agreement for ${APP.name} by ${APP.company}. Software licensing, device restrictions, and Google Play Store compliance.`,
};

export default function EulaPage() {
  return (
    <article className="prose prose-invert max-w-none space-y-6 text-slate-300 text-sm leading-relaxed">
      <div className="border-b border-white/10 pb-4 mb-6">
        <h1 className="text-2xl md:text-3xl font-black text-white">End User License Agreement</h1>
        <p className="text-xs text-slate-400 mt-1">Last Updated: {APP.lastUpdated} | Effective Immediately</p>
      </div>

      <p>
        This End User License Agreement (&ldquo;EULA&rdquo;) constitutes a binding legal agreement between you (&ldquo;End User&rdquo;) and <strong>{APP.company}</strong> regarding your usage of the <strong>{APP.name}</strong> mobile software application.
      </p>

      <h2 className="text-lg font-bold text-white mt-6">1. Grant of License</h2>
      <p>
        Subject to your compliance with this Agreement, {APP.company} grants you a revocable, non-exclusive, non-transferable, limited license to download, install, and execute one copy of the Application on a personal Android device that you own or control, solely for your personal, non-commercial purposes.
      </p>

      <h2 className="text-lg font-bold text-white mt-6">2. Restrictions on Use</h2>
      <p>You agree that you will not, and will not permit any third party to:</p>
      <ul className="list-disc pl-6 space-y-2">
        <li>Decompile, reverse-engineer, disassemble, or attempt to derive the source code or proprietary predictive models of the Application.</li>
        <li>Modify, translate, adapt, or create derivative works based upon the Application.</li>
        <li>Bypass, disable, or circumvent any digital rights management or in-app billing security features controlling access to PRO or VIP tiers.</li>
        <li>Use automated scripts, bots, scrapers, or crawlers to extract data, probabilities, or match fixtures from the Application.</li>
      </ul>

      <h2 className="text-lg font-bold text-white mt-6">3. Application Store Terms</h2>
      <p>
        You acknowledge that this Agreement is between you and {APP.company} only, and not with Google LLC or Alphabet Inc. Google has no obligation whatsoever to furnish any maintenance or support services with respect to the Application.
      </p>

      <h2 className="text-lg font-bold text-white mt-6">4. Termination</h2>
      <p>
        This EULA is effective until terminated. Your rights under this license will terminate automatically without notice from {APP.company} if you fail to comply with any of its terms. Upon termination, you must cease all use of the Application and delete all copies from your devices.
      </p>

      <h2 className="text-lg font-bold text-white mt-6">5. Contact</h2>
      <p>
        For inquiries regarding this EULA, please contact{' '}
        <a href={`mailto:${APP.email}`} className="text-emerald-400 underline">{APP.email}</a>.
      </p>
    </article>
  );
}
