import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../models/campaign_model.dart';
import 'storage_service.dart';

enum PromoWindowState { open, closed, exhausted, unknown }

/// Fetches and caches the Codeink campaign for [AppConfig.campaignSlug]
/// Handles community links, offers gating, and promo-window state.
class CampaignService {
  CampaignService._({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 20),
              ),
            );

  static final CampaignService instance = CampaignService._();

  static const _cacheKey = 'codeink_campaign_v2';
  static const _cacheTsKey = 'codeink_campaign_ts_v2';
  static const _exhaustedKey = 'codeink_campaign_exhausted_v2';
  static const _ttl = Duration(hours: 6);

  final Dio _dio;

  Campaign? _cached;
  Campaign? get cached => _cached;

  PromoWindowState _windowState = PromoWindowState.unknown;
  PromoWindowState get windowState => _windowState;

  Future<Campaign?> fetch({bool forceRefresh = false}) async {
    if (!forceRefresh && _cached != null) return _cached;

    final storage = StorageService();

    if (!forceRefresh) {
      final tsStr = await storage.getCustomString(_cacheTsKey);
      if (tsStr != null) {
        final ts = int.tryParse(tsStr);
        if (ts != null) {
          final age =
              DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ts));
          if (age < _ttl) {
            final hit = await _fromStorage(storage);
            if (hit != null) {
              _cached = hit;
              await _deriveWindowState(storage);
              return _cached;
            }
          }
        }
      }
    }

    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '${AppConfig.campaignBaseUrl}/${AppConfig.campaignSlug}',
      );
      if (res.statusCode == 200 && res.data != null) {
        _cached = Campaign.fromJson(res.data!);
        await storage.saveCustomString(_cacheKey, jsonEncode(res.data));
        await storage.saveCustomString(
            _cacheTsKey, DateTime.now().millisecondsSinceEpoch.toString());
        await storage.removeCustomString(_exhaustedKey);
        await _deriveWindowState(storage);
        return _cached;
      }
    } catch (e) {
      debugPrint('CampaignService.fetch failed, falling back to cache: $e');
    }

    final stale = await _fromStorage(storage);
    if (stale != null) {
      _cached = stale;
      await _deriveWindowState(storage);
      return _cached;
    }

    _windowState = PromoWindowState.unknown;
    return null;
  }

  Future<void> refreshWindowState() => fetch(forceRefresh: true);

  Future<void> markExhausted() async {
    _windowState = PromoWindowState.exhausted;
    await StorageService().saveCustomString(_exhaustedKey, 'true');
  }

  Future<void> _deriveWindowState(StorageService storage) async {
    final isExhausted = await storage.getCustomString(_exhaustedKey);
    if (isExhausted == 'true') {
      _windowState = PromoWindowState.exhausted;
    } else if (_cached == null) {
      _windowState = PromoWindowState.unknown;
    } else if (!_cached!.active) {
      _windowState = PromoWindowState.closed;
    } else {
      _windowState = PromoWindowState.open;
    }
  }

  Future<Campaign?> _fromStorage(StorageService storage) async {
    final raw = await storage.getCustomString(_cacheKey);
    if (raw == null) return null;
    try {
      return Campaign.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
