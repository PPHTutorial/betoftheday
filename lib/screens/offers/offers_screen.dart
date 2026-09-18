import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/campaign_model.dart';
import '../../services/campaign_service.dart';
import '../../services/coupon_service.dart';
import '../../utils/responsive.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  final _codeController = TextEditingController();
  Campaign? _campaign;
  bool _loadingCampaign = true;
  bool _redeeming = false;
  bool _claiming = false;

  @override
  void initState() {
    super.initState();
    _loadCampaign();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadCampaign({bool forceRefresh = false}) async {
    setState(() => _loadingCampaign = true);
    final campaign = await CampaignService.instance.fetch(
      forceRefresh: forceRefresh,
    );
    if (!mounted) return;
    setState(() {
      _campaign = campaign;
      _loadingCampaign = false;
    });
  }

  bool get _canClaim =>
      (_campaign?.canClaimCodes ?? false) &&
      CampaignService.instance.windowState == PromoWindowState.open;

  Future<void> _redeem() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() => _redeeming = true);
    final result = await CouponService.instance.redeem(code);
    if (!mounted) return;
    setState(() => _redeeming = false);

    if (result.success) {
      _codeController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Promo Code Redeemed! You now have VIP Pro Access!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_redeemErrorCopy(result.error)),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  String _redeemErrorCopy(CouponError? error) => switch (error) {
        CouponError.alreadyRedeemed =>
          'This code has already been redeemed on this device.',
        CouponError.expired => 'This promo code has expired.',
        CouponError.network => 'Network error. Please check your connection.',
        CouponError.invalid || null => 'Invalid promo code. Please try again.',
      };

  Future<void> _claim() async {
    setState(() => _claiming = true);
    final result = await CouponService.instance.claimCampaignCode();
    if (!mounted) return;
    setState(() => _claiming = false);

    if (result.success) {
      _codeController.text = result.code!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Code Claimed: ${result.code!}! Tap Redeem to activate.'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_claimErrorCopy(result.failure)),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  String _claimErrorCopy(ClaimFailure? failure) => switch (failure) {
        ClaimFailure.windowClosed =>
          'The promo code claim window is currently closed.',
        ClaimFailure.exhausted =>
          'All available promo codes have been claimed for today.',
        ClaimFailure.unavailable =>
          'Promo codes are currently unavailable. Check back soon.',
        ClaimFailure.error || null => 'Failed to claim code. Please try again.',
      };

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  IconData _iconForKind(String kind) {
    switch (kind.toLowerCase()) {
      case 'telegram':
        return Icons.send_rounded;
      case 'discord':
        return Icons.forum_rounded;
      case 'whatsapp':
        return Icons.chat_rounded;
      case 'twitter':
      case 'x':
        return Icons.tag_rounded;
      case 'youtube':
        return Icons.play_circle_fill_rounded;
      default:
        return Icons.public_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final windowState = CampaignService.instance.windowState;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'OFFERS & PROMOS',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.spacing(20),
          vertical: Responsive.spacing(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header card
            Container(
              padding: EdgeInsets.all(Responsive.spacing(20)),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.confirmation_num_rounded,
                        color: theme.colorScheme.primary, size: 28),
                  ),
                  SizedBox(width: Responsive.spacing(16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Redeem VIP Pass',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Have a promotional code? Enter it below to unlock all AI predictions.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.spacing(24)),

            // Promo status banner if not open
            if (!_loadingCampaign && windowState != PromoWindowState.open) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      windowState == PromoWindowState.exhausted
                          ? Icons.hourglass_bottom_rounded
                          : Icons.info_outline_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        windowState == PromoWindowState.exhausted
                            ? 'Today\'s free promo code pool is currently exhausted.'
                            : 'Campaign claim window is currently closed.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : const Color(0xFF334155),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _loadCampaign(forceRefresh: true),
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Responsive.spacing(20)),
            ],

            // Code input section
            Text(
              'PROMO CODE',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: Responsive.spacing(8)),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Enter code (e.g. BTDVIP2026)',
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: Responsive.spacing(12)),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _redeeming ? null : _redeem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: _redeeming
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Redeem',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.spacing(30)),

            // Or separator
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: theme.colorScheme.outline.withValues(alpha: 0.15),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: theme.colorScheme.outline.withValues(alpha: 0.15),
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.spacing(30)),

            // Claim Code card
            Container(
              padding: EdgeInsets.all(Responsive.spacing(20)),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Don\'t have a promo code?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'We occasionally release free trial and promotional access codes to our community during major football tournaments.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: !_loadingCampaign && _canClaim && !_claiming
                          ? _claim
                          : null,
                      icon: const Icon(Icons.redeem_rounded, size: 20),
                      label: Text(
                        _claiming
                            ? 'Checking...'
                            : _canClaim
                                ? 'Claim Instant Code'
                                : 'No Fresh Codes Available',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: _canClaim
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                        foregroundColor: _canClaim
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.spacing(32)),

            // Community Links section
            if (_campaign != null && _campaign!.communityLinks.isNotEmpty) ...[
              Text(
                'COMMUNITY & GIVEAWAYS',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              SizedBox(height: Responsive.spacing(12)),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _campaign!.communityLinks.map((link) {
                  return ActionChip(
                    avatar: Icon(_iconForKind(link.kind),
                        size: 18, color: theme.colorScheme.primary),
                    label: Text(link.label.isNotEmpty ? link.label : link.kind),
                    onPressed: () => _launchUrl(link.url),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.35),
                    elevation: 0,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
