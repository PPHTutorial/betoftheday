import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import 'campaign_service.dart';
import 'iap_service.dart';
import 'storage_service.dart';

enum CouponError { alreadyRedeemed, invalid, expired, network }

class CouponResult {
  const CouponResult._({required this.success, this.error});
  factory CouponResult.ok() => const CouponResult._(success: true);
  factory CouponResult.fail(CouponError error) =>
      CouponResult._(success: false, error: error);

  final bool success;
  final CouponError? error;
}

enum ClaimFailure { windowClosed, exhausted, unavailable, error }

class ClaimResult {
  const ClaimResult._({required this.success, this.code, this.failure});
  factory ClaimResult.ok(String code) =>
      ClaimResult._(success: true, code: code);
  factory ClaimResult.fail(ClaimFailure failure) =>
      ClaimResult._(success: false, failure: failure);

  final bool success;
  final String? code;
  final ClaimFailure? failure;
}

/// Coupon redemption and campaign code-claiming per Blueprint specifications.
class CouponService {
  CouponService._({Dio? dio, CampaignService? campaignService})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 20),
              ),
            ),
        _campaignService = campaignService ?? CampaignService.instance;

  static final CouponService instance = CouponService._();

  static const _deviceIdKey = 'codeink_device_id_btd_v1';

  final Dio _dio;
  final CampaignService _campaignService;

  /// A stable per-install identifier used for coupon rate limiting
  Future<String> _deviceId() async {
    final storage = StorageService();
    final cached = await storage.getCustomString(_deviceIdKey);
    if (cached != null && cached.isNotEmpty) return cached;

    // Generate random pseudo UUID
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    values[6] = (values[6] & 0x0f) | 0x40; // Version 4
    values[8] = (values[8] & 0x3f) | 0x80; // Variant 10

    final buffer = StringBuffer();
    for (var i = 0; i < 16; i++) {
      if (i == 4 || i == 6 || i == 8 || i == 10) {
        buffer.write('-');
      }
      buffer.write(values[i].toRadixString(16).padLeft(2, '0'));
    }
    final id = buffer.toString();
    await storage.saveCustomString(_deviceIdKey, id);
    return id;
  }

  /// Redeems a promo code the user has entered
  Future<CouponResult> redeem(String code) async {
    try {
      final deviceId = await _deviceId();
      final res = await _dio.post<Map<String, dynamic>>(
        '${AppConfig.parentBackendBaseUrl}/redeem',
        data: {
          'code': code.trim(),
          'deviceId': deviceId,
          'appId': AppConfig.appId,
        },
      );

      if (res.statusCode == 200) {
        // Unlock Pro privileges immediately
        await IAPService().grantPromoProAccess();
        return CouponResult.ok();
      }

      final reason = res.data?['error'] as String?;
      return CouponResult.fail(_mapError(reason));
    } on DioException catch (e) {
      if (e.response != null) {
        final reason = e.response?.data is Map
            ? e.response?.data['error'] as String?
            : null;
        return CouponResult.fail(_mapError(reason));
      }
      debugPrint('CouponService.redeem network error: $e');
      return CouponResult.fail(CouponError.network);
    } catch (e) {
      debugPrint('CouponService.redeem unexpected error: $e');
      return CouponResult.fail(CouponError.network);
    }
  }

  CouponError _mapError(String? reason) => switch (reason) {
        'already_redeemed' => CouponError.alreadyRedeemed,
        'expired' => CouponError.expired,
        _ => CouponError.invalid,
      };

  /// Claims a fresh code from the active campaign
  Future<ClaimResult> claimCampaignCode() async {
    await _campaignService.refreshWindowState();

    switch (_campaignService.windowState) {
      case PromoWindowState.closed:
        return ClaimResult.fail(ClaimFailure.windowClosed);
      case PromoWindowState.exhausted:
        return ClaimResult.fail(ClaimFailure.exhausted);
      case PromoWindowState.unknown:
        return ClaimResult.fail(ClaimFailure.unavailable);
      case PromoWindowState.open:
        break;
    }

    try {
      final deviceId = await _deviceId();
      final campaign = _campaignService.cached;
      final res = await _dio.post<Map<String, dynamic>>(
        AppConfig.promoClaimUrl,
        data: {
          'slug': AppConfig.campaignSlug,
          'campaignId': campaign?.id ?? '',
          'deviceId': deviceId,
          'appId': AppConfig.appId,
        },
      );

      final code = res.data?['code'] as String?;
      if (res.statusCode == 200 && code != null && code.isNotEmpty) {
        return ClaimResult.ok(code);
      }

      final errorOrStatus = res.data?['error'] ?? res.data?['status'];
      if (errorOrStatus == 'exhausted') {
        await _campaignService.markExhausted();
        return ClaimResult.fail(ClaimFailure.exhausted);
      }
      if (errorOrStatus == 'closed') {
        return ClaimResult.fail(ClaimFailure.windowClosed);
      }
      return ClaimResult.fail(ClaimFailure.error);
    } catch (e) {
      debugPrint('CouponService.claimCampaignCode: $e');
      return ClaimResult.fail(ClaimFailure.error);
    }
  }
}
