// web_landing/btd/shared.tsx
// Shared components conforming to Section 18.5 of CODEINK_APP_BLUEPRINT.md

import React, { useState } from 'react';
import Link from 'next/link';
import { APP, NAV_LINKS, FOOTER_LINKS, COMMUNITY_LINKS } from './data';
import {
  Menu,
  X,
  ShieldCheck,
  Smartphone,
  ExternalLink,
  Image as ImageIcon,
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

export function Glow() {
  return (
    <div className="fixed inset-0 overflow-hidden pointer-events-none z-0">
      <div
        className="absolute top-[-10%] left-[-10%] w-[50%] h-[50%] blur-[140px] rounded-full pointer-events-none"
        style={{ background: `${APP.accent}14` }}
      />
      <div
        className="absolute bottom-[-10%] right-[-10%] w-[45%] h-[45%] blur-[140px] rounded-full pointer-events-none"
        style={{ background: `${APP.accent}0A` }}
      />
    </div>
  );
}

export function BrandLogo({ size = 36 }: { size?: number }) {
  return (
    <Link href="/btd" className="flex items-center gap-3 group">
      <div
        className="w-10 h-10 rounded-2xl flex items-center justify-center font-black text-white text-lg tracking-wider transition-transform group-hover:scale-105"
        style={{
          background: `linear-gradient(135deg, ${APP.accent}, ${APP.accentDark})`,
          boxShadow: `0 8px 24px ${APP.accent}33`,
        }}
      >
        ⚽
      </div>
      <div className="flex flex-col">
        <span className="font-extrabold text-white text-base tracking-tight leading-none">
          {APP.name}
        </span>
        <span
          className="text-[10px] font-bold tracking-widest uppercase mt-1"
          style={{ color: APP.accentLight }}
        >
          AI Predictions
        </span>
      </div>
    </Link>
  );
}

export function PlayBadge() {
  return (
    <a
      href={APP.playUrl}
      target="_blank"
      rel="noopener noreferrer"
      className="inline-flex items-center gap-3 px-6 py-3 rounded-full text-white font-semibold text-sm transition-all hover:scale-[1.03] active:scale-[0.98]"
      style={{
        background: '#111827',
        border: '1px solid rgba(255,255,255,0.12)',
        boxShadow: '0 4px 20px rgba(0,0,0,0.5)',
      }}
    >
      <svg className="w-5 h-5 fill-current" viewBox="0 0 24 24">
        <path d="M3.609 1.814L13.793 12 3.61 22.186a2.41 2.41 0 0 1-.61-.92L3 21.03V2.97c0-.447.123-.88.35-1.256l.26.1zM15.207 13.414l2.793 2.793-11.45 6.61 8.657-9.403zm0-2.828L6.55 1.183l11.45 6.61-2.793 2.793zm1.414 1.414l3.77-2.176a1.5 1.5 0 0 1 0 2.6l-3.77 2.176v-2.6z" />
      </svg>
      <div className="flex flex-col text-left">
        <span className="text-[10px] uppercase tracking-wider text-gray-400 leading-none">
          GET IT ON
        </span>
        <span className="font-bold text-sm leading-none mt-1">Google Play</span>
      </div>
    </a>
  );
}

export function ImgPlaceholder({
  label,
  aspect = 'aspect-[9/19]',
}: {
  label: string;
  aspect?: string;
}) {
  return (
    <div
      className={`w-full ${aspect} rounded-3xl flex flex-col items-center justify-center gap-3 p-6 text-center border border-white/5`}
      style={{ background: 'rgba(255,255,255,0.03)' }}
    >
      <div
        className="w-12 h-12 rounded-2xl flex items-center justify-center"
        style={{ background: `${APP.accent}14` }}
      >
        <Smartphone className="w-6 h-6" style={{ color: APP.accentLight }} />
      </div>
      <span className="text-xs text-white/50 font-medium px-4">{label}</span>
    </div>
  );
}

export function NavBar() {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <header
      className="fixed top-0 inset-x-0 z-50 backdrop-blur-xl border-b transition-colors"
      style={{
        background: `${APP.bg}cc`,
        borderColor: 'rgba(255,255,255,0.06)',
      }}
    >
      <div className="max-w-7xl mx-auto px-6 h-20 flex items-center justify-between">
        <BrandLogo />

        <nav className="hidden md:flex items-center gap-8">
          {NAV_LINKS.map((link) => (
            <Link
              key={link.label}
              href={link.href}
              className="text-sm font-medium text-gray-300 hover:text-white transition-colors"
            >
              {link.label}
            </Link>
          ))}
        </nav>

        <div className="hidden md:flex items-center gap-4">
          <Link
            href="/btd/download"
            className="px-6 py-2.5 rounded-full text-sm font-bold text-black transition-all hover:scale-105 active:scale-95"
            style={{
              background: APP.accent,
              boxShadow: `0 4px 18px ${APP.accent}4D`,
            }}
          >
            Download Free
          </Link>
        </div>

        <button
          onClick={() => setIsOpen(!isOpen)}
          className="md:hidden p-2 rounded-xl text-gray-300 hover:text-white bg-white/5 border border-white/10"
          aria-label="Toggle menu"
        >
          {isOpen ? <X size={20} /> : <Menu size={20} />}
        </button>
      </div>

      {isOpen && (
        <div
          className="md:hidden border-b px-6 py-6 space-y-4"
          style={{
            background: APP.bg,
            borderColor: 'rgba(255,255,255,0.06)',
          }}
        >
          {NAV_LINKS.map((link) => (
            <Link
              key={link.label}
              href={link.href}
              onClick={() => setIsOpen(false)}
              className="block text-base font-semibold text-gray-300 hover:text-white"
            >
              {link.label}
            </Link>
          ))}
          <div className="pt-4 border-t border-white/10">
            <Link
              href="/btd/download"
              onClick={() => setIsOpen(false)}
              className="block w-full py-3 text-center rounded-full text-sm font-bold text-black"
              style={{ background: APP.accent }}
            >
              Download App
            </Link>
          </div>
        </div>
      )}
    </header>
  );
}

export function Footer() {
  return (
    <footer
      className="border-t relative z-10 pt-20 pb-12"
      style={{
        background: '#050608',
        borderColor: 'rgba(255,255,255,0.06)',
      }}
    >
      <div className="max-w-7xl mx-auto px-6">
        <div className="grid grid-cols-1 md:grid-cols-5 gap-12 pb-16 border-b border-white/5">
          <div className="md:col-span-2 space-y-6">
            <BrandLogo />
            <p className="text-sm text-gray-400 max-w-sm leading-relaxed">
              {APP.oneLiner}
            </p>
            <div className="flex flex-wrap gap-2.5 pt-2">
              {COMMUNITY_LINKS.map((link) => {
                const Icon = COMMUNITY_ICONS[link.kind] || ExternalLink;
                return (
                  <a
                    key={link.label}
                    href={link.url}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center gap-2 px-3.5 py-1.5 rounded-full text-xs font-semibold text-white transition-opacity hover:opacity-85"
                    style={{ background: link.color }}
                  >
                    <Icon size={12} /> {link.label}
                  </a>
                );
              })}
            </div>
          </div>

          <div>
            <h4 className="text-xs font-bold uppercase tracking-widest text-white/50 mb-5">
              Product
            </h4>
            <ul className="space-y-3">
              {FOOTER_LINKS.product.map((l) => (
                <li key={l.label}>
                  <Link
                    href={l.href}
                    className="text-sm text-gray-400 hover:text-white transition-colors"
                  >
                    {l.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h4 className="text-xs font-bold uppercase tracking-widest text-white/50 mb-5">
              Company
            </h4>
            <ul className="space-y-3">
              {FOOTER_LINKS.company.map((l) => (
                <li key={l.label}>
                  <Link
                    href={l.href}
                    className="text-sm text-gray-400 hover:text-white transition-colors"
                  >
                    {l.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h4 className="text-xs font-bold uppercase tracking-widest text-white/50 mb-5">
              Legal & Safety
            </h4>
            <ul className="space-y-3">
              {FOOTER_LINKS.legal.map((l) => (
                <li key={l.label}>
                  <Link
                    href={l.href}
                    className="text-sm text-gray-400 hover:text-white transition-colors"
                  >
                    {l.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>
        </div>

        <div className="pt-8 flex flex-col md:flex-row items-center justify-between gap-4 text-xs text-gray-500">
          <p>© {new Date().getFullYear()} {APP.company}. All rights reserved.</p>
          <p className="flex items-center gap-1.5">
            <ShieldCheck size={14} style={{ color: APP.accent }} /> 18+ Responsible Betting Analytics Only.
          </p>
        </div>
      </div>
    </footer>
  );
}
