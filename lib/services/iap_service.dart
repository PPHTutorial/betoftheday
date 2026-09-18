import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'storage_service.dart';
import '../config/app_config.dart';

/// App Subscription Model bridging RevenueCat packages with UI
class AppSubscriptionProduct {
  final String id;
  final String title;
  final String price;
  final String period;
  final bool isYearly;
  final bool isLifetime;
  final Package? rcPackage;

  const AppSubscriptionProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.period,
    required this.isYearly,
    this.isLifetime = false,
    this.rcPackage,
  });
}

class IAPService extends ChangeNotifier {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  final bool _isAvailable = true;
  bool _isSubscribed = false;
  List<AppSubscriptionProduct> _products = [];
  Offerings? _offerings;
  String? _errorMessage;
  bool _isLoading = false;

  bool get isAvailable => _isAvailable;
  bool get isSubscribed => _isSubscribed;
  List<AppSubscriptionProduct> get products => _products;
  Offerings? get offerings => _offerings;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    // 1. Initial local status check
    final savedStatus = await StorageService().getIsPremium();
    _isSubscribed = savedStatus ?? false;
    notifyListeners();

    // Only configure RevenueCat on mobile platforms (Android & iOS)
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      _loadFallbackProducts();
      return;
    }

    try {
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      final apiKey = Platform.isAndroid
          ? AppConfig.revenueCatAndroidApiKey
          : AppConfig.revenueCatIosApiKey;

      if (apiKey.isEmpty) {
        debugPrint('RevenueCat API key is not configured for this platform.');
        _loadFallbackProducts();
        return;
      }

      final configuration = PurchasesConfiguration(apiKey);
      await Purchases.configure(configuration);

      // Listen to customer info updates
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        _handleCustomerInfoUpdate(customerInfo);
      });

      // Load initial customer info & offerings
      await _checkSubscriptionStatus();
      await loadOfferings();
    } catch (e) {
      debugPrint('RevenueCat initialization notice: $e');
      _loadFallbackProducts();
    }
  }

  Future<void> _checkSubscriptionStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _handleCustomerInfoUpdate(customerInfo);
    } catch (e) {
      debugPrint('Error getting CustomerInfo from RevenueCat: $e');
    }
  }

  void _handleCustomerInfoUpdate(CustomerInfo customerInfo) {
    // Check specific entitlement or any active entitlement
    final entitlement =
        customerInfo.entitlements.all[AppConfig.revenueCatEntitlementId];
    final bool hasEntitlement = entitlement?.isActive ?? false;
    final bool anyActive = customerInfo.entitlements.active.isNotEmpty;

    _isSubscribed = hasEntitlement || anyActive;
    StorageService().setIsPremium(_isSubscribed);
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadOfferings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final offerings = await Purchases.getOfferings();
      _offerings = offerings;

      final activeOffering = offerings.current ??
          offerings.all[AppConfig.revenueCatOfferingId];

      if (activeOffering != null &&
          activeOffering.availablePackages.isNotEmpty) {
        final List<AppSubscriptionProduct> mapped = [];
        for (final pkg in activeOffering.availablePackages) {
          final isLifetime = pkg.packageType == PackageType.lifetime ||
              pkg.identifier.toLowerCase().contains('lifetime') ||
              pkg.storeProduct.identifier == AppConfig.premiumLifetimeId;
          final isYearly = !isLifetime &&
              (pkg.packageType == PackageType.annual ||
                  pkg.identifier.toLowerCase().contains('year') ||
                  pkg.storeProduct.identifier == AppConfig.premiumYearlyId);

          mapped.add(
            AppSubscriptionProduct(
              id: pkg.storeProduct.identifier,
              title: pkg.storeProduct.title.split('(').first.trim(),
              price: pkg.storeProduct.priceString,
              period: isLifetime
                  ? 'once'
                  : isYearly
                      ? '/year'
                      : '/month',
              isYearly: isYearly,
              isLifetime: isLifetime,
              rcPackage: pkg,
            ),
          );
        }

        // Sort: Yearly first (best value), Monthly second, Lifetime third
        mapped.sort((a, b) {
          if (a.isYearly && !b.isYearly) return -1;
          if (!a.isYearly && b.isYearly) return 1;
          if (a.isLifetime && !b.isLifetime) return 1;
          if (!a.isLifetime && b.isLifetime) return -1;
          return 0;
        });

        _products = mapped;
        _errorMessage = null;
      } else {
        _loadFallbackProducts();
      }
    } catch (e) {
      debugPrint('Error loading RevenueCat offerings: $e');
      _loadFallbackProducts();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadFallbackProducts() {
    _products = [
      const AppSubscriptionProduct(
        id: AppConfig.premiumYearlyId,
        title: 'Annual VIP Pass',
        price: AppConfig.yearlyPrice,
        period: '/year',
        isYearly: true,
        isLifetime: false,
      ),
      const AppSubscriptionProduct(
        id: AppConfig.premiumMonthlyId,
        title: 'Monthly VIP Access',
        price: AppConfig.monthlyPrice,
        period: '/month',
        isYearly: false,
        isLifetime: false,
      ),
      const AppSubscriptionProduct(
        id: AppConfig.premiumLifetimeId,
        title: 'Lifetime VIP Pass',
        price: AppConfig.lifetimePrice,
        period: 'once',
        isYearly: false,
        isLifetime: true,
      ),
    ];
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> clearDevPro() async {
    _isSubscribed = false;
    await StorageService().setIsPremium(false);
    notifyListeners();
  }

  Future<void> grantPromoProAccess() async {
    _isSubscribed = true;
    await StorageService().setIsPremium(true);
    notifyListeners();
  }

  Future<bool> buySubscription(AppSubscriptionProduct product) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (product.rcPackage != null) {
        final customerInfo =
            await Purchases.purchasePackage(product.rcPackage!);
        _handleCustomerInfoUpdate(customerInfo);
        _isLoading = false;
        notifyListeners();
        return _isSubscribed;
      } else {
        // Mock / Sandbox fallback for testing without configured Google Play Store product
        await Future.delayed(const Duration(seconds: 1));
        _isSubscribed = true;
        await StorageService().setIsPremium(true);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _isLoading = false;
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('cancel') || errorStr.contains('user_cancelled')) {
        _errorMessage = null;
      } else {
        _errorMessage = 'Purchase could not be completed. Please try again.';
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        final customerInfo = await Purchases.restorePurchases();
        _handleCustomerInfoUpdate(customerInfo);
      } else {
        await Future.delayed(const Duration(seconds: 1));
      }
      _isLoading = false;
      notifyListeners();
      return _isSubscribed;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Restore request failed. Please check your Google Play account.';
      notifyListeners();
      return false;
    }
  }
}
