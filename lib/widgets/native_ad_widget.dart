import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';
import '../utils/responsive.dart';

/// Native Ad Widget for displaying native ads
class NativeAdWidget extends StatefulWidget {
  final double? height;
  final EdgeInsets? margin;

  const NativeAdWidget({
    super.key,
    this.height,
    this.margin,
  });

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNativeAd();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  Future<void> _loadNativeAd() async {
    if (_isLoading) return;

    final shouldShow = await AdService.instance.shouldShowAds();
    if (!shouldShow) {
      debugPrint('Native ad: User is premium, skipping ad');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final adUnitId = AdService.nativeAdUnitId;
      debugPrint('Loading native ad: $adUnitId');

      _nativeAd = NativeAd(
        adUnitId: adUnitId,
        request: const AdRequest(),
        nativeTemplateStyle: NativeTemplateStyle(
          templateType: TemplateType.medium,
          mainBackgroundColor: Colors.white,
          cornerRadius: 12.0,
        ),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            debugPrint('Native ad loaded successfully');
            setState(() {
              _isLoaded = true;
              _isLoading = false;
            });
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint(
                'Native ad failed to load: ${error.code} - ${error.message}');
            ad.dispose();
            setState(() {
              _isLoaded = false;
              _isLoading = false;
            });

            // Retry after delay
            Future.delayed(const Duration(seconds: 5), () {
              if (mounted) _loadNativeAd();
            });
          },
          onAdOpened: (ad) {
            debugPrint('Native ad opened');
          },
          onAdClosed: (ad) {
            debugPrint('Native ad closed');
          },
        ),
        nativeAdOptions: NativeAdOptions(
          videoOptions: VideoOptions(
            startMuted: true,
          ),
          adChoicesPlacement: AdChoicesPlacement.topRightCorner,
        ),
      );

      await _nativeAd!.load();
    } catch (e) {
      debugPrint('Exception loading native ad: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    if (!_isLoaded || _nativeAd == null) {
      return const SizedBox.shrink();
    }

    final height = widget.height ?? Responsive.height(300);

    return Container(
      margin: widget.margin ?? EdgeInsets.zero,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.radius(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Responsive.radius(12)),
        child: AdWidget(ad: _nativeAd!),
      ),
    );
  }
}
