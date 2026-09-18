// web_landing/btd/data.ts
// Single source of truth for all content conforming to Section 18.3 of CODEINK_APP_BLUEPRINT.md

export const APP = {
  id: 'btd',
  name: 'Bet Of The Day',
  shortName: 'BTD',
  tagline: 'AI-Powered Football Predictions, xG Stats & Daily Winning Tips',
  oneLiner: 'Actionable football analytics, Poisson simulations, and AI edge predictions in your pocket.',
  packageId: 'com.stsl.codeink.btd',
  playUrl: 'https://play.google.com/store/apps/details?id=com.stsl.codeink.btd',
  appStoreUrl: '', // Available on Android; iOS ready
  email: 'support@codeinktechnologies.com',
  company: 'Codeink Technologies',
  lastUpdated: 'September 2026',
  accent: '#10B981',
  accentDark: '#059669',
  accentLight: '#34D399',
  accentBg: '#064E3B',
  bg: '#08090D',
} as const;

export const NAV_LINKS = [
  { label: 'Home', href: '/btd' },
  { label: 'Features', href: '/btd/features' },
  { label: 'About', href: '/btd/about' },
  { label: 'Support', href: '/btd/support' },
  { label: 'Download', href: '/btd/download' },
] as const;

export const FEATURES = [
  {
    id: 'ai_predictions',
    title: 'AI Prediction Engine',
    desc: 'Deep neural models simulating 10,000+ match outcomes using Monte Carlo & Poisson algorithms.',
    tier: 'free',
    badge: 'Core AI',
    icon: 'BrainCircuit',
  },
  {
    id: 'xg_analytics',
    title: 'Expected Goals (xG) Intel',
    desc: 'True shot quality metrics, expected threat (xT), and offensive/defensive efficiency ratings.',
    tier: 'free',
    badge: 'Stats',
    icon: 'Activity',
  },
  {
    id: 'banker_tips',
    title: 'High-Confidence Bankers',
    desc: 'Daily curated accumulator picks with win probabilities exceeding 68% and mathematical value.',
    tier: 'pro',
    badge: 'PRO VIP',
    icon: 'ShieldCheck',
  },
  {
    id: 'live_telemetry',
    title: 'Real-Time Match Tracker',
    desc: 'Live minute-by-minute clock, in-play score tracking, and shifting match momentum indicators.',
    tier: 'free',
    badge: 'Live',
    icon: 'Radio',
  },
  {
    id: 'streak_trends',
    title: 'Winning Streak Analytics',
    desc: 'Comprehensive historical performance database, win/loss auditing, and hit-rate transparency.',
    tier: 'free',
    badge: 'History',
    icon: 'TrendingUp',
  },
  {
    id: 'instant_alerts',
    title: 'Kickoff & Value Alerts',
    desc: 'Instant push notifications for market odds drops, high-value opportunities, and kickoff reminders.',
    tier: 'free',
    badge: 'Alerts',
    icon: 'Bell',
  },
] as const;

export const HOW_IT_WORKS_STEPS = [
  {
    step: '01',
    title: 'Select Today’s Fixtures',
    desc: 'Browse hundreds of matches across Premier League, Champions League, La Liga, Serie A, Bundesliga, and 50+ global leagues.',
  },
  {
    step: '02',
    title: 'Inspect AI Probabilities & xG',
    desc: 'View comprehensive mathematical breakdown including Home/Draw/Away likelihood, expected goals, and head-to-head records.',
  },
  {
    step: '03',
    title: 'Lock In Smart Value Bets',
    desc: 'Combine high-conviction banker picks, safe bets, and long shots backed by algorithmic modeling.',
  },
] as const;

export const STATS = [
  { value: '78.4%', label: 'Top-Tier Pick Accuracy' },
  { value: '50+', label: 'Global Leagues Covered' },
  { value: '10K+', label: 'Daily Simulations Run' },
  { value: '24/7', label: 'Real-Time Live Updates' },
] as const;

export const PLANS = [
  {
    id: 'monthly',
    name: 'Monthly PRO',
    price: '$9.99',
    period: '/month',
    desc: 'Flexible access for active weekend bettors.',
    features: [
      'Unlimited match unlocks 24/7',
      'All VIP Banker & High-Value Picks',
      'Full xG and offensive/defensive metrics',
      'Completely Ad-Free experience',
      'Priority kickoff & tip notifications',
    ],
    popular: false,
    cta: 'Start 1 Month',
  },
  {
    id: 'yearly',
    name: 'Yearly PRO',
    price: '$59.99',
    period: '/year',
    savings: 'SAVE 50%',
    desc: 'Best value for serious football investors covering the entire season.',
    features: [
      'Everything in Monthly PRO',
      '50% discount vs monthly billing',
      'Full season & tournament coverage',
      'Access to exclusive accumulator bundles',
      'VIP community priority support',
    ],
    popular: true,
    cta: 'Claim 50% Off — Yearly',
  },
  {
    id: 'lifetime',
    name: 'Lifetime VIP',
    price: '$99.99',
    period: 'one-time',
    desc: 'Pay once, enjoy lifetime algorithmic tips and updates forever.',
    features: [
      'Permanent VIP status — zero recurring fees',
      'Every future update and AI model version',
      'All historical archive downloads',
      'Direct developer feedback channel',
    ],
    popular: false,
    cta: 'Get Lifetime Access',
  },
] as const;

export const FAQS = [
  {
    question: 'How does the Bet Of The Day AI prediction algorithm work?',
    answer:
      'BTD utilizes an ensemble of machine learning models trained on millions of historical football events. It factors in expected goals (xG), team form, injury reports, tactical formations, home advantage, and bookmaker odds drift to estimate the true mathematical probability of match outcomes.',
  },
  {
    question: 'Can I use Bet Of The Day for free?',
    answer:
      'Yes! BTD offers free access to daily match fixtures, live match scores, and a rolling daily free unlock slot that refreshes as matches are played. PRO subscriptions unlock unlimited simultaneous access and ad-free browsing.',
  },
  {
    question: 'Which football leagues are supported?',
    answer:
      'BTD covers all major world leagues including the English Premier League, UEFA Champions League, Spanish La Liga, Italian Serie A, German Bundesliga, French Ligue 1, MLS, plus domestic cups and over 45 other international competitions.',
  },
  {
    question: 'How do I cancel or manage my PRO subscription?',
    answer:
      'Subscriptions are managed securely via Google Play In-App Billing (powered by RevenueCat). You can cancel anytime from Google Play Store > Subscriptions with one tap.',
  },
  {
    question: 'Does BTD guarantee winning bets?',
    answer:
      'No prediction tool can guarantee outcomes in sports. BTD is an analytical advisory tool that provides probability distributions and statistical edge to help bettors make data-driven, informed decisions rather than emotional guesses.',
  },
] as const;

export const COMMUNITY_LINKS = [
  { kind: 'telegram', label: 'Telegram VIP Tips', url: 'https://t.me/codeink_btd', color: '#26A5E4' },
  { kind: 'discord', label: 'Discord Community', url: 'https://discord.gg/codeink', color: '#5865F2' },
  { kind: 'twitter', label: 'Twitter / X', url: 'https://x.com/codeinktech', color: '#000000' },
  { kind: 'whatsapp', label: 'WhatsApp Alerts', url: 'https://chat.whatsapp.com/codeink', color: '#25D366' },
] as const;

export const FOOTER_LINKS = {
  product: [
    { label: 'Download App', href: '/btd/download' },
    { label: 'Features', href: '/btd/features' },
    { label: 'Pricing & VIP', href: '/btd#pricing' },
    { label: 'Live Matches', href: '/btd/download' },
  ],
  company: [
    { label: 'About Codeink', href: '/btd/about' },
    { label: 'Support & FAQs', href: '/btd/support' },
    { label: 'Contact Us', href: '/btd/contact' },
  ],
  legal: [
    { label: 'Privacy Policy', href: '/btd/legal?tab=privacy' },
    { label: 'Terms of Service', href: '/btd/legal?tab=tos' },
    { label: 'EULA', href: '/btd/legal?tab=eula' },
    { label: 'Cookie Policy', href: '/btd/legal?tab=cookies' },
    { label: 'Refund Policy', href: '/btd/legal?tab=refund' },
  ],
} as const;
