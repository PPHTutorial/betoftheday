import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Directory;
import '../config/app_config.dart';
import '../models/user_model.dart';
import '../models/prediction_model.dart';
import '../models/subscription_model.dart';
import '../models/payment_model.dart';
import '../models/pricing_model.dart';
import '../models/blog_model.dart';
import '../models/notification_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  late CookieJar _cookieJar;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize cookie jar for persistent cookie storage
    if (kIsWeb) {
      _cookieJar = CookieJar();
    } else {
      try {
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final cookiePath = '${appDocDir.path}/.cookies/';
        _cookieJar = PersistCookieJar(
          storage: FileStorage(cookiePath),
        );
      } catch (e) {
        debugPrint('Error initializing cookie jar, using default: $e');
        _cookieJar = CookieJar();
      }
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Add cookie manager to handle cookies automatically
    _dio.interceptors.add(CookieManager(_cookieJar));

    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('API Request: ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
              'API Response: ${response.statusCode} ${response.requestOptions.uri}');
          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint(
              'API Error: ${error.response?.statusCode} ${error.requestOptions.uri}');
          debugPrint('Error data: ${error.response?.data}');
          if (error.response?.statusCode == 401 ||
              error.response?.statusCode == 403) {
            // Handle unauthorized - clear cookies
            _clearCookies();
          }
          return handler.next(error);
        },
      ),
    );

    _initialized = true;
  }

  Future<void> _clearCookies() async {
    try {
      await _cookieJar.delete(Uri.parse(AppConfig.apiBaseUrl));
      debugPrint('Cookies cleared');
    } catch (e) {
      debugPrint('Error clearing cookies: $e');
    }
  }

  // Cookies are now handled automatically by CookieManager
  // No need for manual token management

  // ========== AUTH ==========

  Future<UserModel> signup({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      debugPrint('Attempting signup for: $email');
      var response = await _dio.post(
        AppConfig.signupEndpoint,
        data: {
          'email': email,
          'password': password,
          'username': username,
        },
      );

      response = await _followRedirectIfNeeded(response);

      debugPrint('Signup response status: ${response.statusCode}');
      debugPrint('Signup response data: ${response.data}');

      // Cookies are automatically handled by CookieManager
      // No need to manually extract or save cookies

      final data = _normalizeResponseBody(response.data);

      if (data is String) {
        throw data;
      }

      if (data is Map<String, dynamic>) {
        if (data.containsKey('error')) {
          throw data['error']?.toString() ?? 'Signup failed';
        }

        final userMap = _extractUserMap(data);
        if (userMap != null) {
          return UserModel.fromJson(userMap);
        }
      }

      debugPrint('Signup: Invalid response format: ${response.data}');
      throw 'Invalid response format: expected user object';
    } catch (e) {
      debugPrint('Signup error: $e');
      throw _handleError(e);
    }
  }

  Future<UserModel> signin({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('Attempting signin for: $email');
      var response = await _dio.post(
        AppConfig.signinEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );

      response = await _followRedirectIfNeeded(response);

      debugPrint('Signin response status: ${response.statusCode}');
      debugPrint('Signin response data: ${response.data}');

      // Cookies are automatically handled by CookieManager
      // The httpOnly cookie will be stored and sent automatically with future requests

      final data = _normalizeResponseBody(response.data);

      debugPrint('Signin parsed data: $data');

      if (data is String) {
        throw data;
      }

      if (data is Map<String, dynamic>) {
        if (data.containsKey('error')) {
          throw data['error']?.toString() ?? 'Signin failed';
        }

        final userMap = _extractUserMap(data);
        if (userMap != null) {
          debugPrint('Signin parsed user successfully');
          return UserModel.fromJson(userMap);
        }
      }

      debugPrint('Invalid response format: ${response.data}');
      throw 'Invalid response format: expected user object';
    } catch (e) {
      debugPrint('Signin error: $e');
      throw _handleError(e);
    }
  }

  Future<void> signout() async {
    try {
      await _dio.post(AppConfig.signoutEndpoint);
    } catch (e) {
      debugPrint('Signout error: $e');
    } finally {
      // Always clear cookies on signout
      await _clearCookies();
    }
  }

  Future<void> verifyEmail(String token, String email) async {
    try {
      await _dio.post(
        AppConfig.verifyEmailEndpoint,
        queryParameters: {
          'token': token,
          'email': email,
        },
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> resendVerification() async {
    try {
      await _dio.post(AppConfig.resendVerificationEndpoint);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _dio.post(
        AppConfig.resetPasswordEndpoint,
        data: {'email': email},
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserModel?> checkAuth() async {
    try {
      var response = await _dio.get(AppConfig.authCheckEndpoint);
      response = await _followRedirectIfNeeded(response);

      final data = _normalizeResponseBody(response.data);

      if (data is String) {
        debugPrint('checkAuth string response: $data');
        return null;
      }

      if (data is Map<String, dynamic>) {
        if (data.containsKey('error')) {
          debugPrint('checkAuth error message: ${data['error']}');
          return null;
        }

        final userMap = _extractUserMap(data);
        if (userMap != null) {
          debugPrint('checkAuth: User authenticated');
          return UserModel.fromJson(userMap);
        }
      }

      debugPrint('checkAuth: Invalid response format: ${response.data}');
      return null;
    } catch (e) {
      debugPrint('checkAuth error: $e');
      // If it's a 401/403, clear cookies
      if (e is DioException &&
          (e.response?.statusCode == 401 || e.response?.statusCode == 403)) {
        await _clearCookies();
      }
      return null;
    }
  }

  // ========== PREDICTIONS ==========

  Future<List<PredictionModel>> getPredictions({
    String? userId,
    String? gameType,
    String? result,
    String? league,
  }) async {
    try {
      // Ensure initialized
      if (!_initialized) {
        await initialize();
      }

      // Fetch all predictions - no query parameters
      // Enable redirects for predictions endpoint (www vs non-www)
      final response = await _dio.get(
        AppConfig.predictionsEndpoint,
        options: Options(
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      debugPrint('Predictions API Response Status: ${response.statusCode}');
      debugPrint('Response data type: ${response.data.runtimeType}');
      debugPrint('Final URL after redirects: ${response.realUri}');

      dynamic data = response.data;

      // Handle if response is wrapped in a 'data' property
      if (data is Map && data.containsKey('data')) {
        data = data['data'];
      }

      // Handle if response is wrapped in a 'predictions' property
      if (data is Map && data.containsKey('predictions')) {
        data = data['predictions'];
      }

      if (data is List) {
        debugPrint('Received ${data.length} predictions from API');

        final predictions = data
            .map((json) {
              try {
                if (json is Map<String, dynamic>) {
                  return PredictionModel.fromJson(json);
                }
                return null;
              } catch (e) {
                debugPrint('Error parsing prediction: $e');
                return null;
              }
            })
            .whereType<PredictionModel>()
            .toList();

        debugPrint('Successfully parsed ${predictions.length} predictions');
        return predictions;
      }

      debugPrint('WARNING: Response is not a List. Type: ${data.runtimeType}');
      return [];
    } catch (e) {
      debugPrint('Error fetching predictions: $e');
      throw _handleError(e);
    }
  }

  Future<PredictionModel> getPredictionById(String id) async {
    try {
      final response = await _dio.get('${AppConfig.predictionsEndpoint}/$id');
      return PredictionModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<PredictionModel> createPrediction(Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.post(AppConfig.predictionsEndpoint, data: data);
      return PredictionModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<PredictionModel> updatePrediction(
      String id, Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.put('${AppConfig.predictionsEndpoint}/$id', data: data);
      return PredictionModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deletePrediction(String id) async {
    try {
      await _dio.delete('${AppConfig.predictionsEndpoint}/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ========== SUBSCRIPTIONS ==========

  Future<List<SubscriptionModel>> getSubscriptions({String? userId}) async {
    try {
      Map<String, dynamic>? queryParams;
      if (userId != null) {
        queryParams = {
          'include': jsonEncode({'userId': userId})
        };
      }

      final response = await _dio.get(
        '/subscription',
        queryParameters: queryParams,
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => SubscriptionModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<SubscriptionModel?> getActiveSubscription(String userId) async {
    try {
      final subscriptions = await getSubscriptions(userId: userId);
      return subscriptions.firstWhere(
        (sub) => sub.isActive,
        orElse: () => subscriptions.isNotEmpty
            ? subscriptions.first
            : throw StateError('No subscription'),
      );
    } catch (e) {
      return null;
    }
  }

  // ========== PAYMENTS ==========

  Future<List<PaymentModel>> getPayments({String? userId}) async {
    try {
      Map<String, dynamic>? queryParams;
      if (userId != null) {
        queryParams = {
          'include': jsonEncode({'userId': userId})
        };
      }

      final response = await _dio.get(
        '/payment',
        queryParameters: queryParams,
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => PaymentModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> verifyPayment(String txRef) async {
    try {
      final response = await _dio.post(
        AppConfig.paymentVerifyEndpoint,
        data: {
          'tx_ref': txRef,
          'provider': 'flutterwave',
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ========== PRICING ==========

  Future<List<PricingPlanModel>> getPricingPlans() async {
    try {
      final response = await _dio.get('/pricing');
      if (response.data is List) {
        return (response.data as List)
            .map((json) => PricingPlanModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ========== BLOGS ==========

  Future<List<BlogPostModel>> getBlogs({String? authorId}) async {
    try {
      Map<String, dynamic>? queryParams;
      if (authorId != null) {
        queryParams = {
          'include': jsonEncode({'authorId': authorId})
        };
      }

      final response = await _dio.get(
        '/blogPost',
        queryParameters: queryParams,
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => BlogPostModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<BlogPostModel> getBlogById(String id) async {
    try {
      final response = await _dio.get('/blogPost/$id');
      return BlogPostModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ========== NOTIFICATIONS ==========

  Future<List<NotificationModel>> getNotifications(
      {String? userId, bool? read}) async {
    try {
      Map<String, dynamic> queryParams = {};
      if (userId != null) {
        queryParams['include'] = jsonEncode({'userId': userId});
      }
      if (read != null) {
        queryParams['read'] = read.toString();
      }

      final response = await _dio.get(
        '/notification',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> markNotificationAsRead(String id) async {
    try {
      await _dio.put('/notification/$id', data: {'read': true});
    } catch (e) {
      throw _handleError(e);
    }
  }

  static const Set<int> _redirectStatusCodes = {301, 302, 303, 307, 308};

  Future<Response> _followRedirectIfNeeded(Response response) async {
    var current = response;
    var redirectCount = 0;

    while (_redirectStatusCodes.contains(current.statusCode) &&
        redirectCount < 5) {
      final location = current.headers.value('location');
      if (location == null) {
        break;
      }

      final uri = _resolveRedirectUri(current.requestOptions.uri, location);
      debugPrint('Following redirect (${current.statusCode}) to: $uri');

      final requestOptions = current.requestOptions;
      final options = Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
        contentType: requestOptions.contentType,
        responseType: requestOptions.responseType,
        followRedirects: false,
        validateStatus: requestOptions.validateStatus,
      );

      if (requestOptions.method.toUpperCase() == 'GET') {
        current = await _dio.getUri(
          uri,
          options: options,
        );
      } else if (requestOptions.method.toUpperCase() == 'POST') {
        current = await _dio.postUri(
          uri,
          data: requestOptions.data,
          options: options,
        );
      } else if (requestOptions.method.toUpperCase() == 'PUT') {
        current = await _dio.putUri(
          uri,
          data: requestOptions.data,
          options: options,
        );
      } else if (requestOptions.method.toUpperCase() == 'DELETE') {
        current = await _dio.deleteUri(
          uri,
          data: requestOptions.data,
          options: options,
        );
      } else {
        current = await _dio.requestUri(
          uri,
          data: requestOptions.data,
          options: options,
        );
      }

      redirectCount++;
    }

    return current;
  }

  Uri _resolveRedirectUri(Uri baseUri, String location) {
    try {
      if (location.startsWith('http')) {
        return Uri.parse(location);
      }
      return baseUri.resolve(location);
    } catch (_) {
      return Uri.parse('${AppConfig.baseUrl}$location');
    }
  }

  /// Normalize response body (handles string JSON responses)
  dynamic _normalizeResponseBody(dynamic body) {
    if (body == null) return null;
    if (body is String) {
      final trimmed = body.trim();
      if (trimmed.isEmpty) return null;
      try {
        return jsonDecode(trimmed);
      } catch (_) {
        return trimmed;
      }
    }
    return body;
  }

  /// Extract user map from API response
  Map<String, dynamic>? _extractUserMap(Map<String, dynamic> data) {
    if (data['user'] is Map) {
      return Map<String, dynamic>.from(data['user'] as Map);
    }

    const requiredKeys = ['id', 'email', 'username'];
    if (requiredKeys.every((key) => data.containsKey(key))) {
      return Map<String, dynamic>.from(data);
    }

    return null;
  }

  // ========== ERROR HANDLING ==========

  String _handleError(dynamic error) {
    debugPrint('Error handler called with: $error');
    if (error is DioException) {
      debugPrint('DioException type: ${error.type}');
      debugPrint('DioException response: ${error.response?.data}');
      debugPrint('DioException status: ${error.response?.statusCode}');

      if (error.response != null) {
        final data = error.response?.data;
        if (data is Map) {
          // Check for error field
          if (data.containsKey('error')) {
            final errorMsg = data['error'].toString();
            debugPrint('Extracted error message: $errorMsg');
            return errorMsg;
          }
          // Check for message field
          if (data.containsKey('message')) {
            return data['message'].toString();
          }
        }
        // If response is a string
        if (data is String) {
          return data;
        }
        // Status code based error
        final statusCode = error.response?.statusCode;
        if (statusCode == 403) {
          return 'Access denied. Please check your credentials.';
        } else if (statusCode == 404) {
          return 'Endpoint not found. Please try again.';
        } else if (statusCode == 500) {
          return 'Server error. Please try again later.';
        }
        return 'Server error (${statusCode ?? 'unknown'})';
      } else if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'Connection timeout. Please check your internet connection.';
      } else if (error.type == DioExceptionType.connectionError) {
        return 'No internet connection. Please check your network.';
      } else if (error.type == DioExceptionType.badResponse) {
        return 'Invalid server response. Please try again.';
      }
      return error.message ?? 'Network error occurred. Please try again.';
    }
    return error.toString();
  }
}
