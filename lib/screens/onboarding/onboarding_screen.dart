import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../services/iap_service.dart';
import '../../services/storage_service.dart';
import '../../utils/responsive.dart';
import '../main_navigation_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 6;

  int _selectedPlan = 0; // 0: Yearly (Best Value), 1: Monthly, 2: Lifetime
  bool _purchasing = false;

  @override
  void initState() {
    super.initState();
    // Warm up IAP offerings
    Provider.of<IAPService>(context, listen: false).loadOfferings();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    await StorageService().setOnboardingComplete(true);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      (route) => false,
    );
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _handlePurchase() async {
    final iap = Provider.of<IAPService>(context, listen: false);
    if (iap.products.isEmpty) {
      _nextPage();
      return;
    }

    setState(() => _purchasing = true);
    try {
      // Find package corresponding to selected plan
      AppSubscriptionProduct? target;
      if (_selectedPlan == 0) {
        target = iap.products.firstWhere((p) => p.isYearly,
            orElse: () => iap.products.first);
      } else if (_selectedPlan == 1) {
        target = iap.products.firstWhere((p) => !p.isYearly && !p.isLifetime,
            orElse: () => iap.products.first);
      } else {
        target = iap.products.firstWhere((p) => p.isLifetime,
            orElse: () => iap.products.last);
      }

      final success = await iap.buySubscription(target);
      if (success && mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Welcome to VIP Pro! Full Access Unlocked.'),
            backgroundColor: Colors.green,
          ),
        );
        await _finishOnboarding();
      }
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.sports_soccer_rounded,
                            size: 20, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppConfig.appName.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 1.5,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  if (_currentPage < _totalPages - 1)
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Page View Content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildSlidePain(theme, isDark),
                  _buildSlideTransformation(theme, isDark),
                  _buildSlideTrust(theme, isDark),
                  _buildSlideLossAversion(theme, isDark),
                  _buildSlideSubscription(theme, isDark),
                  _buildSlideActivation(theme, isDark),
                ],
              ),
            ),

            // Bottom controls: Indicators & CTA Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Column(
                children: [
                  // Dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_totalPages, (i) {
                      final active = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 24 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: active
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _purchasing
                          ? null
                          : _currentPage == 4
                              ? _handlePurchase
                              : _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _purchasing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              _currentPage == 4
                                  ? 'Get Instant VIP Access'
                                  : _currentPage == _totalPages - 1
                                      ? 'Start Winning Now'
                                      : 'Continue',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                    ),
                  ),

                  // Skip option on paywall slide
                  if (_currentPage == 4) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _nextPage,
                      child: Text(
                        'Continue with 2 Free Daily Picks',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Slide 1: Emotional Pain & Frustration
  Widget _buildSlidePain(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(Icons.heart_broken_rounded,
                size: 48, color: Colors.redAccent),
          ),
          const SizedBox(height: 24),
          _buildBadge(theme, 'TIRED OF LOSING ACCUMULATORS?'),
          const SizedBox(height: 14),
          Text(
            'Stop Guessing.\nBeat the Bookmakers.',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.2,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Over 92% of sports punters lose money because they bet with emotion, hunches, or biased media hype. Bookmakers set their margins knowing you don\'t have defensive data or expected goals analytics.\n\nEvery weekend, a single careless leg ruins your slip. It’s time to stop giving money to the bookies.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  // Slide 2: Transformation & Algorithmic Edge
  Widget _buildSlideTransformation(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(Icons.analytics_rounded,
                size: 48, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 24),
          _buildBadge(theme, 'AI PREDICTION SIMULATOR'),
          const SizedBox(height: 14),
          Text(
            'The Mathematical Edge\nIn Your Pocket',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.2,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Our machine learning models simulate thousands of match iterations before kickoff. We analyze expected goals (xG), shot quality, defensive counter vulnerabilities, squad rotation, and historical odds mismatches.\n\nYou don\'t just get a prediction — you get verified win probabilities and value edge percentages.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  // Slide 3: Proven Trust & Accuracy
  Widget _buildSlideTrust(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(Icons.verified_rounded,
                size: 48, color: Colors.green),
          ),
          const SizedBox(height: 24),
          _buildBadge(theme, 'PROVEN TRACK RECORD'),
          const SizedBox(height: 14),
          Text(
            'Complete Transparency.\nZero Guesswork.',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.2,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No shady Telegram tipsters or deleted lost tickets. Every single fixture is logged with real results in our historical database across Premier League, Champions League, LaLiga, Serie A, and Bundesliga.\n\nGain full visibility into team trends, clean sheet frequencies, and actual return-on-investment metrics.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  // Slide 4: Loss Aversion & FOMO (Free vs. PRO)
  Widget _buildSlideLossAversion(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          _buildBadge(theme, 'WHY BETTING BLIND COSTS YOU'),
          const SizedBox(height: 12),
          Text(
            'What You Lose Without PRO',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A single smart bet pays for an entire year of PRO access.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),

          // Comparison container
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _buildCompareRow(
                  title: 'Daily Prediction Access',
                  freeText: 'Only 2 matches per day',
                  proText: 'UNLIMITED all matches',
                  isProHighlight: true,
                  isDark: isDark,
                  theme: theme,
                ),
                Divider(color: theme.colorScheme.outline.withValues(alpha: 0.1), height: 22),
                _buildCompareRow(
                  title: 'Deep xG & Model Data',
                  freeText: 'Locked behind paywall',
                  proText: 'Full xG, fatigue & trends',
                  isProHighlight: true,
                  isDark: isDark,
                  theme: theme,
                ),
                Divider(color: theme.colorScheme.outline.withValues(alpha: 0.1), height: 22),
                _buildCompareRow(
                  title: 'High-Value Underdog Alerts',
                  freeText: 'Missed odds value',
                  proText: 'Instant value edge signals',
                  isProHighlight: true,
                  isDark: isDark,
                  theme: theme,
                ),
                Divider(color: theme.colorScheme.outline.withValues(alpha: 0.1), height: 22),
                _buildCompareRow(
                  title: 'User Experience',
                  freeText: 'Interstitial & banner ads',
                  proText: '100% Ad-Free experience',
                  isProHighlight: true,
                  isDark: isDark,
                  theme: theme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Slide 5: Subscription Plans (Monthly, Yearly Best Value, Lifetime)
  Widget _buildSlideSubscription(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          _buildBadge(theme, 'INVEST IN YOUR EDGE'),
          const SizedBox(height: 10),
          Text(
            'Unlock Complete VIP Access',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Select your plan. Cancel anytime via Google Play.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 18),

          // Plan 0: Yearly (Best Value)
          _buildPlanOption(
            index: 0,
            title: 'Annual VIP Pass',
            price: AppConfig.yearlyPrice,
            subtitle: '\$4.99/mo • Billed annually',
            badge: 'BEST VALUE (SAVE 50%)',
            isHighlight: true,
            theme: theme,
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // Plan 1: Monthly
          _buildPlanOption(
            index: 1,
            title: 'Monthly VIP Access',
            price: AppConfig.monthlyPrice,
            subtitle: 'Flexible monthly billing',
            theme: theme,
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // Plan 2: Lifetime
          _buildPlanOption(
            index: 2,
            title: 'Lifetime VIP Pass',
            price: AppConfig.lifetimePrice,
            subtitle: 'Pay once, keep forever • Never bill again',
            badge: 'LIFETIME ACCESS',
            theme: theme,
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shield_outlined, size: 16, color: Colors.green),
              const SizedBox(width: 6),
              Text(
                'Secured with Google Play • 100% Satisfaction',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Slide 6: Activation & Getting Started
  Widget _buildSlideActivation(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(Icons.sports_rounded,
                size: 48, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 24),
          _buildBadge(theme, 'READY TO DOMINATE'),
          const SizedBox(height: 14),
          Text(
            'Your Winning Strategy\nStarts Right Now',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.2,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Explore today\'s top fixtures, dive into expected goals statistics, track bookmarked games, and let our predictive models guide your decisions.\n\nTap below to explore today\'s match analysis.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(ThemeData theme, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCompareRow({
    required String title,
    required String freeText,
    required String proText,
    required bool isProHighlight,
    required bool isDark,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(Icons.close_rounded, size: 16, color: Colors.redAccent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      freeText,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      proText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlanOption({
    required int index,
    required String title,
    required String price,
    required String subtitle,
    String? badge,
    bool isHighlight = false,
    required ThemeData theme,
    required bool isDark,
  }) {
    final selected = _selectedPlan == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.3),
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (badge != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: selected
                    ? theme.colorScheme.primary
                    : (isDark ? Colors.white : const Color(0xFF0F172A)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
