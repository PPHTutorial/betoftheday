// web_landing/btd/legal/page.tsx
import React, { Suspense } from 'react';
import { Metadata } from 'next';
import { APP } from '../data';
import LegalView from './LegalView';

export const metadata: Metadata = {
  title: `Legal Terms & Privacy Policy | ${APP.name}`,
  description: `Official legal policies for ${APP.name} by ${APP.company}: Privacy Policy, Terms of Service, EULA, Cookie Policy, and Refund Policy.`,
};

export default function LegalPage() {
  return (
    <Suspense
      fallback={
        <div
          className="min-h-screen flex items-center justify-center text-slate-400"
          style={{ backgroundColor: APP.bg }}
        >
          Loading legal documents...
        </div>
      }
    >
      <LegalView />
    </Suspense>
  );
}
