// web_landing/privacies/btd/layout.tsx
import React from 'react';
import Link from 'next/link';
import { APP } from '../../btd/data';
import { Shield, ArrowLeft } from 'lucide-react';

export default function PrivaciesLayout({ children }: { children: React.ReactNode }) {
  return (
    <div
      className="min-h-screen text-slate-100 flex flex-col selection:bg-emerald-500 selection:text-white"
      style={{ backgroundColor: APP.bg }}
    >
      {/* Legal Header */}
      <header
        className="fixed top-0 inset-x-0 z-50 backdrop-blur-xl border-b"
        style={{
          backgroundColor: `${APP.bg}cc`,
          borderColor: 'rgba(255,255,255,0.06)',
        }}
      >
        <div className="max-w-4xl mx-auto px-6 h-16 flex items-center justify-between">
          <Link href="/btd" className="flex items-center gap-2 text-slate-300 hover:text-white text-xs font-semibold">
            <ArrowLeft className="w-4 h-4" />
            <span>Back to {APP.name}</span>
          </Link>
          <div className="flex items-center gap-4 text-xs">
            <Link href="/privacies/btd" className="text-slate-400 hover:text-emerald-400">Privacy</Link>
            <Link href="/privacies/btd/tos" className="text-slate-400 hover:text-emerald-400">Terms</Link>
            <Link href="/privacies/btd/eula" className="text-slate-400 hover:text-emerald-400">EULA</Link>
            <Link href="/privacies/btd/cookies" className="text-slate-400 hover:text-emerald-400">Cookies</Link>
            <Link href="/privacies/btd/refund" className="text-slate-400 hover:text-emerald-400">Refund</Link>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-1 max-w-4xl mx-auto px-6 pt-28 pb-20 w-full">
        <div className="p-8 md:p-12 rounded-3xl border bg-white/[0.02] border-white/10 backdrop-blur-xl">
          {children}
        </div>
      </main>

      {/* Legal Footer */}
      <footer className="border-t border-white/5 py-8 text-center text-xs text-slate-500">
        <p>© {new Date().getFullYear()} {APP.company}. All rights reserved.</p>
        <p className="mt-1">
          Support:{' '}
          <a href={`mailto:${APP.email}`} className="text-emerald-400 hover:underline">
            {APP.email}
          </a>
        </p>
      </footer>
    </div>
  );
}
