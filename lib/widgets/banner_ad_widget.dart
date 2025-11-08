import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import '../services/ad_service.dart';
import '../utils/responsive.dart';

/// Banner Ad Widget for displaying ads at the bottom of screens
class BannerAdWidget extends StatefulWidget {
  final AdSize? adSize;
  final EdgeInsets? margin;

  const BannerAdWidget({
    super.key,
    this.adSize,
    this.margin,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _loadBannerAd() async {
    if (_isLoading) return;

    // Check if premium user
    final shouldShow = await AdService.instance.shouldShowAds();
    if (!shouldShow) {
      debugPrint('Banner ad: User is premium, skipping ad');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final adSize = widget.adSize ?? AdSize.banner;
      final adUnitId = AdService.bannerAdUnitId;

      debugPrint('Loading banner ad: $adUnitId');

      _bannerAd = BannerAd(
        adUnitId: adUnitId,
        size: adSize,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint('Banner ad loaded successfully');
            setState(() {
              _isLoaded = true;
              _isLoading = false;
            });
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint(
                'Banner ad failed to load: ${error.code} - ${error.message}');
            ad.dispose();
            setState(() {
              _isLoaded = false;
              _isLoading = false;
            });

            // Retry after delay
            Future.delayed(const Duration(seconds: 5), () {
              if (mounted) _loadBannerAd();
            });
          },
          onAdOpened: (ad) {
            debugPrint('Banner ad opened');
          },
          onAdClosed: (ad) {
            debugPrint('Banner ad closed');
          },
        ),
      );

      await _bannerAd!.load();
    } catch (e) {
      debugPrint('Exception loading banner ad: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    // Don't show ad if premium user or not loaded
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: widget.margin ?? EdgeInsets.zero,
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

/// Adaptive Banner Ad Widget that adjusts size based on screen width
class AdaptiveBannerAdWidget extends StatefulWidget {
  final EdgeInsets? margin;

  const AdaptiveBannerAdWidget({
    super.key,
    this.margin,
  });

  @override
  State<AdaptiveBannerAdWidget> createState() => _AdaptiveBannerAdWidgetState();
}

class _AdaptiveBannerAdWidgetState extends State<AdaptiveBannerAdWidget> {
  AdSize? _adSize;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdSize();
  }

  Future<void> _loadAdSize() async {
    try {
      final adSize = await AdSize.getAnchoredAdaptiveBannerAdSize(
        Orientation.portrait,
        MediaQuery.of(context).size.width.toInt(),
      );

      if (mounted) {
        setState(() {
          _adSize = adSize ?? AdSize.banner;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error getting adaptive ad size: $e');
      if (mounted) {
        setState(() {
          _adSize = AdSize.banner;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    if (_isLoading) {
      return const SizedBox.shrink();
    }

    return BannerAdWidget(
      adSize: _adSize ?? AdSize.banner,
      margin: widget.margin,
    );
  }
}
