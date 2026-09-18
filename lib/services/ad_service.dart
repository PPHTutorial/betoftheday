import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import 'iap_service.dart';

class AdService {
  static AdService? _instance;
  static AdService get instance {
    _instance ??= AdService._();
    return _instance!;
  }

  AdService._();

  // AdMob App ID
  static const appId = "ca-app-pub-1777613531225133~5189073412";

  // Production Ad Unit IDs (Android)
  static const String _interstitialAdUnitIdAndroid =
      "ca-app-pub-1777613531225133/5209254712";
  static const String _rewardedAdUnitIdAndroid =
      "ca-app-pub-1777613531225133/5332990758";
  static const String _rewardedInterstitialAdUnitIdAndroid =
      "ca-app-pub-1777613531225133/9336201989";

  // Production Ad Unit IDs (iOS)
  static const String _interstitialAdUnitIdIOS =
      "ca-app-pub-9043208558525567/5458613802";
  static const String _rewardedAdUnitIdIOS =
      "ca-app-pub-9043208558525567/7701633764";
  static const String _rewardedInterstitialAdUnitIdIOS =
      "ca-app-pub-9043208558525567/6580123782";

  // Use test ad units only in non-release builds (debug/profile)
  static bool get _useTestAds => !kReleaseMode;

  // Test Ad Unit IDs (Android)
  static const String _testInterstitialAdUnitIdAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedAdUnitIdAndroid =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedInterstitialAdUnitIdAndroid =
      'ca-app-pub-3940256099942544/5354025313';

  // Test Ad Unit IDs (iOS)
  static const String _testInterstitialAdUnitIdIOS =
      'ca-app-pub-3940256099942544/4411468910';
  static const String _testRewardedAdUnitIdIOS =
      'ca-app-pub-3940256099942544/1712485313';
  static const String _testRewardedInterstitialAdUnitIdIOS =
      'ca-app-pub-3940256099942544/6978759866';

  static String get interstitialAdUnitId {
    if (_useTestAds) {
      return defaultTargetPlatform == TargetPlatform.iOS
          ? _testInterstitialAdUnitIdIOS
          : _testInterstitialAdUnitIdAndroid;
    }
    return defaultTargetPlatform == TargetPlatform.iOS
        ? _interstitialAdUnitIdIOS
        : _interstitialAdUnitIdAndroid;
  }

  static String get rewardedAdUnitId {
    if (_useTestAds) {
      return defaultTargetPlatform == TargetPlatform.iOS
          ? _testRewardedAdUnitIdIOS
          : _testRewardedAdUnitIdAndroid;
    }
    return defaultTargetPlatform == TargetPlatform.iOS
        ? _rewardedAdUnitIdIOS
        : _rewardedAdUnitIdAndroid;
  }

  static String get rewardedInterstitialAdUnitId {
    if (_useTestAds) {
      return defaultTargetPlatform == TargetPlatform.iOS
          ? _testRewardedInterstitialAdUnitIdIOS
          : _testRewardedInterstitialAdUnitIdAndroid;
    }
    return defaultTargetPlatform == TargetPlatform.iOS
        ? _rewardedInterstitialAdUnitIdIOS
        : _rewardedInterstitialAdUnitIdAndroid;
  }

  RewardedAd? _rewardedAd;
  RewardedInterstitialAd? _rewardedInterstitialAd;
  InterstitialAd? _interstitialAd;
  int _rewardAdWatchCount = 0;
  bool _isInitialized = false;

  // Frequency capping - prevent ads from showing too frequently (AdMob policy)
  DateTime? _lastInterstitialAdShown;
  DateTime? _lastImageClickAdShown;

  static const Duration _minInterstitialInterval =
      Duration(seconds: 60); // 1 minute minimum
  static const Duration _minImageClickAdInterval =
      Duration(seconds: 30); // 30 seconds for image clicks

  /// Check if user is a premium user (should not see ads)
  Future<bool> isPremiumUser() async {
    try {
      // Check via IAPService or direct storage
      return IAPService().isSubscribed;
    } catch (e) {
      debugPrint('Error checking premium status in AdService: $e');
      return false;
    }
  }

  /// Check if ads should be shown (not premium user)
  Future<bool> shouldShowAds() async {
    return !(await isPremiumUser());
  }

  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('AdService already initialized');
      return;
    }

    try {
      debugPrint('Initializing AdMob...');
      debugPrint('Using ${_useTestAds ? "TEST" : "PRODUCTION"} ad units');

      final initResponse = await MobileAds.instance.initialize();

      debugPrint(
          'AdMob initialization status: ${initResponse.adapterStatuses}');

      // Request configuration for test devices (only in debug mode)
      if (_useTestAds) {
        final requestConfig = RequestConfiguration(
          testDeviceIds: [
            'FDB6404EE2DF76ABCA39527BDAFAB242', // User's test device
          ],
        );
        MobileAds.instance.updateRequestConfiguration(requestConfig);
        debugPrint(
            'Test device configuration set: FDB6404EE2DF76ABCA39527BDAFAB242');
      }

      _isInitialized = true;
      debugPrint('AdMob initialized successfully');

      // Preload ads after initialization
      debugPrint('Preloading ads...');
      await Future.wait([
        loadRewardedAd(),
        loadInterstitialAd(),
        loadRewardedInterstitialAd(),
        //loadAppOpenAd(),
      ]);
      debugPrint('Ads preloaded');
    } catch (e) {
      debugPrint('Error initializing AdMob: $e');
      _isInitialized = false;
    }
  }

  Future<void> loadRewardedAd() async {
    // Don't load if premium user
    if (await isPremiumUser()) return;

    try {
      debugPrint('Loading rewarded ad: $rewardedAdUnitId');
      await RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('Rewarded ad loaded successfully');
            _rewardedAd = ad;
          },
          onAdFailedToLoad: (error) {
            debugPrint(
                'Rewarded ad failed to load: ${error.code} - ${error.message}');
            _rewardedAd = null;
          },
        ),
      );
    } catch (e) {
      debugPrint('Exception loading rewarded ad: $e');
    }
  }

  Future<void> loadRewardedInterstitialAd() async {
    // Don't load if premium user
    if (await isPremiumUser()) return;

    try {
      debugPrint(
          'Loading rewarded interstitial ad: $rewardedInterstitialAdUnitId');
      await RewardedInterstitialAd.load(
        adUnitId: rewardedInterstitialAdUnitId,
        request: const AdRequest(),
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('Rewarded interstitial ad loaded successfully');
            _rewardedInterstitialAd = ad;
          },
          onAdFailedToLoad: (error) {
            debugPrint(
                'Rewarded interstitial ad failed to load: ${error.code} - ${error.message}');
            _rewardedInterstitialAd = null;
          },
        ),
      );
    } catch (e) {
      debugPrint('Exception loading rewarded interstitial ad: $e');
    }
  }

  Future<void> loadInterstitialAd() async {
    // Don't load if premium user
    if (await isPremiumUser()) return;

    try {
      debugPrint('Loading interstitial ad: $interstitialAdUnitId');
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('Interstitial ad loaded successfully');
            _interstitialAd = ad;
          },
          onAdFailedToLoad: (error) {
            debugPrint(
                'Interstitial ad failed to load: ${error.code} - ${error.message}');
            _interstitialAd = null;
          },
        ),
      );
    } catch (e) {
      debugPrint('Exception loading interstitial ad: $e');
    }
  }



  Future<bool> showRewardedAd({
    required Function() onRewarded,
    Function(String)? onError,
  }) async {
    // Skip if premium user
    if (await isPremiumUser()) {
      onRewarded();
      return true;
    }

    if (_rewardedAd == null) {
      debugPrint('Rewarded ad not loaded, attempting to load...');
      await loadRewardedAd();
      // Wait a bit for ad to load
      await Future.delayed(const Duration(seconds: 2));
    }

    if (_rewardedAd == null) {
      debugPrint('Rewarded ad still not available');
      onError?.call('Ad not loaded. Please try again.');
      return false;
    }

    bool rewarded = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('Rewarded ad dismissed');
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint(
            'Rewarded ad failed to show: ${error.code} - ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        onError?.call(error.message);
        loadRewardedAd();
      },
    );

    try {
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) async {
          debugPrint('User earned reward: ${reward.type} - ${reward.amount}');
          rewarded = true;
          _rewardAdWatchCount++;
          onRewarded();
        },
      );
      debugPrint('Rewarded ad shown successfully');
    } catch (e) {
      debugPrint('Exception showing rewarded ad: $e');
      onError?.call(e.toString());
      return false;
    }

    return rewarded;
  }

  Future<bool> showRewardedInterstitialAd({
    required Function() onRewarded,
    Function(String)? onError,
  }) async {
    // Skip if premium user
    if (await isPremiumUser()) {
      onRewarded();
      return true;
    }

    if (_rewardedInterstitialAd == null) {
      debugPrint('Rewarded interstitial ad not loaded, attempting to load...');
      await loadRewardedInterstitialAd();
      await Future.delayed(const Duration(seconds: 2));
    }

    if (_rewardedInterstitialAd == null) {
      debugPrint(
          'Rewarded interstitial ad not available, falling back to rewarded ad');
      // Fallback to regular rewarded ad
      return await showRewardedAd(onRewarded: onRewarded, onError: onError);
    }

    bool rewarded = false;

    _rewardedInterstitialAd!.fullScreenContentCallback =
        FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('Rewarded interstitial ad dismissed');
        ad.dispose();
        _rewardedInterstitialAd = null;
        loadRewardedInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint(
            'Rewarded interstitial ad failed to show: ${error.code} - ${error.message}');
        ad.dispose();
        _rewardedInterstitialAd = null;
        onError?.call(error.message);
        loadRewardedInterstitialAd();
      },
    );

    try {
      await _rewardedInterstitialAd!.show(
        onUserEarnedReward: (ad, reward) async {
          debugPrint(
              'User earned reward from interstitial: ${reward.type} - ${reward.amount}');
          rewarded = true;
          _rewardAdWatchCount++;
          onRewarded();
        },
      );
      debugPrint('Rewarded interstitial ad shown successfully');
    } catch (e) {
      debugPrint('Exception showing rewarded interstitial ad: $e');
      onError?.call(e.toString());
      return false;
    }

    return rewarded;
  }

  Future<bool> showInterstitialAd({
    Function()? onAdClosed,
    Function(String)? onError,
    bool respectFrequencyCap = true,
  }) async {
    // Skip if premium user
    if (await isPremiumUser()) {
      onAdClosed?.call();
      return true;
    }

    // Frequency capping check
    if (respectFrequencyCap && _lastInterstitialAdShown != null) {
      final timeSinceLastAd =
          DateTime.now().difference(_lastInterstitialAdShown!);
      if (timeSinceLastAd < _minInterstitialInterval) {
        debugPrint(
            'Interstitial ad frequency cap: ${_minInterstitialInterval.inSeconds - timeSinceLastAd.inSeconds}s remaining');
        onAdClosed?.call(); // Continue without showing ad
        return false;
      }
    }

    if (_interstitialAd == null) {
      debugPrint('Interstitial ad not loaded, attempting to load...');
      await loadInterstitialAd();
      await Future.delayed(const Duration(seconds: 2));
    }

    if (_interstitialAd == null) {
      debugPrint('Interstitial ad not available');
      onError?.call('Ad not loaded');
      onAdClosed?.call(); // Continue even if ad fails
      return false;
    }

    bool shown = false;
    _lastInterstitialAdShown = DateTime.now();

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('Interstitial ad dismissed');
        ad.dispose();
        _interstitialAd = null;
        shown = true;
        onAdClosed?.call();
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint(
            'Interstitial ad failed to show: ${error.code} - ${error.message}');
        ad.dispose();
        _interstitialAd = null;
        onError?.call(error.message);
        onAdClosed?.call(); // Continue even if ad fails
        loadInterstitialAd();
      },
    );

    try {
      await _interstitialAd!.show();
      debugPrint('Interstitial ad shown successfully');
    } catch (e) {
      debugPrint('Exception showing interstitial ad: $e');
      onError?.call(e.toString());
      onAdClosed?.call();
      return false;
    }

    return shown;
  }

  /// Show interstitial ad on image click with frequency capping (30 seconds minimum)
  Future<bool> showInterstitialAdOnImageClick({
    Function()? onAdClosed,
    Function(String)? onError,
  }) async {
    // Skip if premium user
    if (await isPremiumUser()) {
      onAdClosed?.call();
      return true;
    }

    // Stricter frequency cap for image clicks (30 seconds)
    if (_lastImageClickAdShown != null) {
      final timeSinceLastAd =
          DateTime.now().difference(_lastImageClickAdShown!);
      if (timeSinceLastAd < _minImageClickAdInterval) {
        debugPrint(
            'Image click ad frequency cap: ${_minImageClickAdInterval.inSeconds - timeSinceLastAd.inSeconds}s remaining');
        onAdClosed?.call(); // Continue without showing ad
        return false;
      }
    }

    if (_interstitialAd == null) {
      await loadInterstitialAd();
      await Future.delayed(const Duration(seconds: 2));
    }

    if (_interstitialAd == null) {
      onAdClosed?.call(); // Continue even if ad fails
      return false;
    }

    bool shown = false;
    _lastImageClickAdShown = DateTime.now();

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('Image click ad dismissed');
        ad.dispose();
        _interstitialAd = null;
        shown = true;
        onAdClosed?.call();
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint(
            'Image click ad failed to show: ${error.code} - ${error.message}');
        ad.dispose();
        _interstitialAd = null;
        onError?.call(error.message);
        onAdClosed?.call();
        loadInterstitialAd();
      },
    );

    try {
      await _interstitialAd!.show();
      debugPrint('Image click ad shown successfully');
    } catch (e) {
      debugPrint('Exception showing image click ad: $e');
      onError?.call(e.toString());
      onAdClosed?.call();
      return false;
    }

    return shown;
  }

  Future<bool> showAppOpenAd() async => false;

  /// Show a random ad (rewarded or rewarded interstitial) for freemium features
  Future<bool> showRandomAd({
    required Function() onRewarded,
    Function(String)? onError,
  }) async {
    // Skip if premium user
    if (await isPremiumUser()) {
      onRewarded();
      return true;
    }

    final random = Random();
    if (random.nextBool()) {
      return await showRewardedInterstitialAd(
          onRewarded: onRewarded, onError: onError);
    } else {
      return await showRewardedAd(onRewarded: onRewarded, onError: onError);
    }
  }

  int get rewardAdWatchCount => _rewardAdWatchCount;

  void resetRewardCount() {
    _rewardAdWatchCount = 0;
  }

  bool get isAppOpenAdReady => false;

  bool get isInitialized => _isInitialized;
}
