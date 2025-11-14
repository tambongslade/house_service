import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';
import '../models/auth_models.dart';
import '../models/user_model.dart' as user_models;
import '../models/session_models.dart';
import '../models/service_request_models.dart';
import '../models/coupon_models.dart';
import '../models/booking_models.dart';

class ApiService {
  // Local development base URL
  static String get baseUrl {
    // Cloudflare tunnel server
    return 'https://api.homeaideservice.com/api';
  }

  static const String apiVersion = 'v1';

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Token management
  String? _accessToken;

  // Callback for authentication failures
  void Function()? _onAuthenticationFailed;

  // Headers
  Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, String> get _authHeaders => {
    ..._defaultHeaders,
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  // Initialize service with stored tokens
  Future<void> initialize() async {
    await _loadTokens();
    debugPrint('API Service initialized with base URL: $baseUrl');
  }

  // Test connectivity to the server
  Future<bool> testConnection() async {
    try {
      debugPrint('Testing connection to: $baseUrl');
      final uri = Uri.parse('$baseUrl/health'); // Try a health check endpoint
      final response = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint('Connection test timed out after 10 seconds');
              throw TimeoutException(
                'Connection timeout',
                const Duration(seconds: 10),
              );
            },
          );
      debugPrint('Connection test - Status: ${response.statusCode}');
      return response.statusCode <
          500; // Any response under 500 means server is reachable
    } catch (e) {
      debugPrint('Connection test failed: $e');
      return false;
    }
  }

  // Token management methods
  Future<void> _loadTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString('access_token');
    } catch (e) {
      debugPrint('Error loading tokens: $e');
    }
  }

  Future<void> _saveToken(String accessToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);
      _accessToken = accessToken;
      debugPrint('Token saved successfully. Length: ${accessToken.length}');
    } catch (e) {
      debugPrint('Error saving token: $e');
    }
  }

  // Public method to set token (for debugging/testing)
  Future<void> setToken(String accessToken) async {
    await _saveToken(accessToken);
  }

  Future<void> clearTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      _accessToken = null;
    } catch (e) {
      debugPrint('Error clearing tokens: $e');
    }
  }

  // Set authentication failure callback
  void setAuthenticationFailedCallback(void Function() callback) {
    _onAuthenticationFailed = callback;
  }

  // Since your API doesn't seem to use refresh tokens, we'll handle 401s differently
  Future<bool> _handleUnauthorized() async {
    // Clear tokens and force re-login
    await clearTokens();

    // Trigger authentication failure callback if set
    _onAuthenticationFailed?.call();

    return false;
  }

  // Generic HTTP methods for List responses
  Future<ApiResponse<T>> _makeRequestForList<T>(
    String method,
    String endpoint,
    Map<String, dynamic>? body,
    T Function(dynamic) fromJson, {
    bool requiresAuth = true,
    bool isRetry = false,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/$apiVersion/$endpoint');
      final headers = requiresAuth ? _authHeaders : _defaultHeaders;

      // Debug logging for authentication
      debugPrint('API Request - Method: $method');
      debugPrint('API Request - URI: $uri');
      debugPrint('API Request - Requires Auth: $requiresAuth');
      if (requiresAuth) {
        debugPrint(
          'API Request - Auth Header Present: ${headers.containsKey('Authorization')}',
        );
        if (headers.containsKey('Authorization')) {
          final authHeader = headers['Authorization']!;
          final preview = authHeader.length > 20 
              ? '${authHeader.substring(0, 20)}...' 
              : authHeader;
          debugPrint('API Request - Auth Header: $preview (length: ${authHeader.length})');
        }
      }

      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PATCH':
          response = await http.patch(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      debugPrint('API Response - Status: ${response.statusCode}');
      debugPrint('API Response - Body: ${response.body}');

      // Handle token expiration
      if (response.statusCode == 401 && requiresAuth && !isRetry) {
        await _handleUnauthorized();
        return ApiResponse.error('Authentication failed. Please login again.');
      }

      dynamic responseData;
      try {
        responseData = jsonDecode(response.body);
        debugPrint('API Response - Parsed Data Type: ${responseData.runtimeType}');
        if (responseData is List) {
          debugPrint('API Response - Array Length: ${responseData.length}');
        }
      } catch (e) {
        debugPrint('API Error: Failed to parse response JSON: $e');
        return ApiResponse.error('Invalid server response format');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(fromJson(responseData));
      } else {
        // Extract detailed error information
        String errorMessage;
        if (responseData is Map && responseData.containsKey('message')) {
          final message = responseData['message'];
          if (message is List) {
            errorMessage = message.join(', ');
          } else {
            errorMessage = message.toString();
          }
        } else if (responseData is Map && responseData.containsKey('error')) {
          errorMessage = responseData['error'].toString();
        } else if (responseData is Map && responseData.containsKey('errors')) {
          // Handle validation errors (array of error objects)
          final errors = responseData['errors'];
          if (errors is List && errors.isNotEmpty) {
            errorMessage = errors
                .map((e) => e['message'] ?? e.toString())
                .join(', ');
          } else {
            errorMessage = errors.toString();
          }
        } else {
          errorMessage = 'Request failed with status ${response.statusCode}';
        }

        debugPrint('API Error: $errorMessage');
        return ApiResponse.error(errorMessage);
      }
    } on SocketException catch (e) {
      debugPrint('SocketException details: ${e.toString()}');
      if (e.toString().contains('Connection refused') ||
          e.toString().contains('Connection timed out')) {
        return ApiResponse.error(
          'Cannot connect to server. Make sure your backend is running on the correct address.',
        );
      } else if (e.toString().contains('Network is unreachable')) {
        return ApiResponse.error(
          'Network unreachable. Check your internet connection.',
        );
      } else {
        return ApiResponse.error('Connection failed: ${e.message}');
      }
    } on FormatException catch (e) {
      debugPrint('FormatException details: ${e.toString()}');
      return ApiResponse.error('Invalid response format from server');
    } catch (e) {
      debugPrint('Unexpected error details: ${e.toString()}');
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Generic HTTP methods for Map responses
  Future<ApiResponse<T>> _makeRequest<T>(
    String method,
    String endpoint,
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>) fromJson, {
    bool requiresAuth = true,
    bool isRetry = false,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/$apiVersion/$endpoint');
      final headers = requiresAuth ? _authHeaders : _defaultHeaders;

      // Debug logging for authentication
      debugPrint('API Request - Method: $method');
      debugPrint('API Request - URI: $uri');
      debugPrint('API Request - Requires Auth: $requiresAuth');
      if (requiresAuth) {
        debugPrint(
          'API Request - Auth Header Present: ${headers.containsKey('Authorization')}',
        );
        if (headers.containsKey('Authorization')) {
          final authHeader = headers['Authorization']!;
          final preview = authHeader.length > 20 
              ? '${authHeader.substring(0, 20)}...' 
              : authHeader;
          debugPrint('API Request - Auth Header: $preview (length: ${authHeader.length})');
        }
      }

      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PATCH':
          response = await http.patch(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      debugPrint('API Response - Status: ${response.statusCode}');
      debugPrint('API Response - Body: ${response.body}');

      // Handle token expiration
      if (response.statusCode == 401 && requiresAuth && !isRetry) {
        await _handleUnauthorized();
        return ApiResponse.error('Authentication failed. Please login again.');
      }

      dynamic responseData;
      try {
        responseData = jsonDecode(response.body);
        debugPrint('API Response - Parsed Data Type: ${responseData.runtimeType}');
        if (responseData is List) {
          debugPrint('API Response - Array Length: ${responseData.length}');
        }
      } catch (e) {
        debugPrint('API Error: Failed to parse response JSON: $e');
        return ApiResponse.error('Invalid server response format');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Handle the case where API returns an array but fromJson expects a Map
        if (responseData is List) {
          // For endpoints that expect a Map but get an array, handle it gracefully
          if (responseData.isEmpty) {
            // Empty array - convert to empty map for compatibility
            responseData = <String, dynamic>{};
          } else {
            // Non-empty array - this should be handled by specific parsing functions
            // For now, wrap it in a map structure
            final Map<String, dynamic> wrappedData = {'data': responseData};
            responseData = wrappedData;
          }
        }

        return ApiResponse.success(
          fromJson(responseData as Map<String, dynamic>),
        );
      } else {
        // Extract detailed error information
        String errorMessage;
        if (responseData is Map && responseData.containsKey('message')) {
          final message = responseData['message'];
          if (message is List) {
            errorMessage = message.join(', ');
          } else {
            errorMessage = message.toString();
          }
        } else if (responseData is Map && responseData.containsKey('error')) {
          errorMessage = responseData['error'].toString();
        } else if (responseData is Map && responseData.containsKey('errors')) {
          // Handle validation errors (array of error objects)
          final errors = responseData['errors'];
          if (errors is List && errors.isNotEmpty) {
            errorMessage = errors
                .map((e) => e['message'] ?? e.toString())
                .join(', ');
          } else {
            errorMessage = errors.toString();
          }
        } else {
          errorMessage = 'Request failed with status ${response.statusCode}';
        }

        debugPrint('API Error: $errorMessage');
        return ApiResponse.error(errorMessage);
      }
    } on SocketException catch (e) {
      debugPrint('SocketException details: ${e.toString()}');
      if (e.toString().contains('Connection refused') ||
          e.toString().contains('Connection timed out')) {
        return ApiResponse.error(
          'Cannot connect to server. Make sure your backend is running on the correct address.',
        );
      } else if (e.toString().contains('Network is unreachable')) {
        return ApiResponse.error(
          'Network unreachable. Check your internet connection.',
        );
      } else {
        return ApiResponse.error('Connection failed: ${e.message}');
      }
    } on FormatException catch (e) {
      debugPrint('FormatException details: ${e.toString()}');
      return ApiResponse.error('Invalid response format from server');
    } catch (e) {
      debugPrint('Unexpected error details: ${e.toString()}');
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Authentication endpoints
  Future<ApiResponse<AuthResponse>> login(String email, String password) async {
    return _makeRequest(
      'POST',
      'auth/login',
      {'email': email, 'password': password},
      (data) => AuthResponse.fromJson(data),
      requiresAuth: false,
    );
  }

  Future<ApiResponse<AuthResponse>> register(
    String fullName,
    String email,
    String password,
    String phoneNumber, {
    String? role,
    Map<String, dynamic>? providerSetupData,
  }) async {
    debugPrint('API: Starting registration request');
    debugPrint('API: Base URL: $baseUrl (auto-detected)');
    debugPrint(
      'API: Full endpoint: ${Uri.parse('$baseUrl/$apiVersion/auth/register')}',
    );
    debugPrint(
      'API: Request data: {fullName: $fullName, email: $email, phoneNumber: $phoneNumber, role: $role}',
    );

    final requestData = <String, dynamic>{
      'fullName': fullName,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
    };

    // Add role if specified
    if (role != null) {
      requestData['role'] = role;
    }

    // Add provider setup data if provided
    if (providerSetupData != null && role == 'provider') {
      requestData.addAll(providerSetupData);
      debugPrint('API: Including provider setup data: ${providerSetupData.keys}');
    }

    return _makeRequest(
      'POST',
      'auth/register',
      requestData,
      (data) => AuthResponse.fromJson(data),
      requiresAuth: false,
    );
  }

  Future<ApiResponse<void>> logout() async {
    final response = await _makeRequest('POST', 'auth/logout', null, (data) {});

    if (response.isSuccess) {
      await clearTokens();
    }

    return response;
  }

  Future<ApiResponse<AuthResponse>> setUserRole(String role) async {
    debugPrint('API: Setting user role to: $role');
    debugPrint('API: Current access token exists: ${_accessToken != null}');
    debugPrint('API: Is authenticated: $isAuthenticated');
    if (_accessToken != null) {
      final tokenPreview = _accessToken!.length > 20 
          ? '${_accessToken!.substring(0, 20)}...' 
          : _accessToken!;
      debugPrint(
        'API: Access token: $tokenPreview (length: ${_accessToken!.length})',
      );
    }
    debugPrint('API: Role endpoint: ${Uri.parse('$baseUrl/$apiVersion/auth/role')}');

    return _makeRequest(
      'PATCH', // Changed from PUT to PATCH
      'auth/role',
      {'role': role},
      (data) => AuthResponse.fromJson(data),
      requiresAuth: true, // Explicitly set to ensure auth headers are included
    );
  }

  // User endpoints
  Future<ApiResponse<user_models.UserModel>> getProfile() async {
    debugPrint('API: Getting user profile');
    debugPrint(
      'API: Profile endpoint: ${Uri.parse('$baseUrl/$apiVersion/auth/profile')}',
    );
    return _makeRequest(
      'GET',
      'auth/profile',
      null,
      (data) => user_models.UserModel.fromJson(data),
      requiresAuth: true,
    );
  }

  // Services endpoints
  Future<ApiResponse<Map<String, dynamic>>> getServiceCategories() async {
    debugPrint('API: Getting service categories');
    return _makeRequest(
      'GET',
      'services/categories',
      null,
      (data) => data,
      requiresAuth: false,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> createService(
    Map<String, dynamic> serviceData,
  ) async {
    debugPrint('API: Creating service: ${serviceData['title']}');
    return _makeRequest(
      'POST',
      'services',
      serviceData,
      _parseServiceData,
      requiresAuth: true,
    );
  }

  Map<String, dynamic> _parseServiceData(Map<String, dynamic> data) {
    debugPrint('DEBUG: _parseServiceData received data type: ${data.runtimeType}');
    debugPrint('DEBUG: _parseServiceData received data: $data');

    try {
      // Handle various response formats from the server
      if (data.containsKey('data') && data['data'] is Map) {
        // Response wrapped in a 'data' field
        debugPrint('DEBUG: Using data.data path');
        return Map<String, dynamic>.from(data['data']);
      } else if (data.containsKey('service') && data['service'] is Map) {
        // Response wrapped in a 'service' field
        debugPrint('DEBUG: Using data.service path');
        return Map<String, dynamic>.from(data['service']);
      } else if (data.containsKey('data') && data['data'] is List) {
        // Server returned an array wrapped in 'data'
        debugPrint('DEBUG: Server returned array in data field');
        final list = data['data'] as List;
        if (list.isNotEmpty && list.first is Map) {
          return Map<String, dynamic>.from(list.first);
        }
        return {'message': 'Service created successfully'};
      } else {
        // Direct response object
        debugPrint('DEBUG: Using direct response path');
        return Map<String, dynamic>.from(data);
      }
    } catch (e, stackTrace) {
      debugPrint('DEBUG: Error in _parseServiceData: $e');
      debugPrint('DEBUG: Stack trace: $stackTrace');
      // Return a safe default response
      return {
        'message': 'Service created successfully',
        'error': 'Response parsing error',
      };
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getMyServices() async {
    debugPrint('API: Getting my services');
    return _makeRequestForList(
      'GET',
      'services/my-services',
      null,
      _parseServicesData,
      requiresAuth: true,
    );
  }

  List<Map<String, dynamic>> _parseServicesData(dynamic data) {
    debugPrint('DEBUG: _parseServicesData received data type: ${data.runtimeType}');
    debugPrint('DEBUG: _parseServicesData received data: $data');

    if (data is List) {
      debugPrint('DEBUG: Data is a List with ${data.length} items');
      final result = data.whereType<Map<String, dynamic>>().toList();
      debugPrint('DEBUG: Parsed ${result.length} services from list');
      return result;
    } else if (data is Map) {
      debugPrint('DEBUG: Data is a Map with keys: ${data.keys}');
      if (data['services'] is List) {
        final services = data['services'] as List;
        debugPrint('DEBUG: Found services array with ${services.length} items');
        final result = services.whereType<Map<String, dynamic>>().toList();
        debugPrint('DEBUG: Parsed ${result.length} services from services array');
        return result;
      } else if (data['data'] is List) {
        final services = data['data'] as List;
        debugPrint('DEBUG: Found data array with ${services.length} items');
        final result = services.whereType<Map<String, dynamic>>().toList();
        debugPrint('DEBUG: Parsed ${result.length} services from data array');
        return result;
      }
    }
    debugPrint('DEBUG: No valid services found, returning empty list');
    return <Map<String, dynamic>>[];
  }

  // Availability endpoints (Updated to use new v2 API)
  Future<ApiResponse<Map<String, dynamic>>> createAvailability(
    Map<String, dynamic> availabilityData,
  ) async {
    debugPrint('API: Creating availability for ${availabilityData['dayOfWeek']}');
    return _makeRequest(
      'POST',
      'availability',
      availabilityData,
      (data) => data,
      requiresAuth: true,
    );
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getMyAvailability() async {
    debugPrint('API: Getting my availability schedule');
    return _makeRequestForList(
      'GET',
      'availability',
      null,
      _parseAvailabilityData,
      requiresAuth: true,
    );
  }

  List<Map<String, dynamic>> _parseAvailabilityData(dynamic data) {
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    } else if (data is Map && data['availability'] is List) {
      final availability = data['availability'] as List;
      return availability.whereType<Map<String, dynamic>>().toList();
    }
    return <Map<String, dynamic>>[];
  }

  Future<ApiResponse<user_models.UserModel>> updateProfile(
    Map<String, dynamic> profileData,
  ) async {
    return _makeRequest(
      'PUT',
      'user/profile',
      profileData,
      (data) => user_models.UserModel.fromJson(data),
    );
  }

  // Service endpoints (for seekers)
  Future<ApiResponse<List<dynamic>>> getServices({
    String? category,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (category != null) 'category': category,
      if (search != null) 'search': search,
    };

    final uri = Uri.parse(
      '$baseUrl/$apiVersion/services',
    ).replace(queryParameters: queryParams);

    return _makeRequest(
      'GET',
      'services?${uri.query}',
      null,
      (data) => data['services'] ?? [],
    );
  }

  // Order endpoints
  Future<ApiResponse<dynamic>> createOrder(
    Map<String, dynamic> orderData,
  ) async {
    return _makeRequest('POST', 'orders', orderData, (data) => data);
  }

  Future<ApiResponse<List<dynamic>>> getOrders({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (status != null) 'status': status,
    };

    final uri = Uri.parse(
      '$baseUrl/$apiVersion/orders',
    ).replace(queryParameters: queryParams);

    return _makeRequest(
      'GET',
      'orders?${uri.query}',
      null,
      (data) => data['orders'] ?? [],
    );
  }

  Future<ApiResponse<dynamic>> updateOrderStatus(
    String orderId,
    String status,
  ) async {
    return _makeRequest('PUT', 'orders/$orderId/status', {
      'status': status,
    }, (data) => data);
  }

  // Provider-specific endpoints
  Future<ApiResponse<dynamic>> getProviderDashboard() async {
    return _makeRequest('GET', 'providers/dashboard', null, (data) => data);
  }

  Future<ApiResponse<List<dynamic>>> getProviderOrders({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (status != null) 'status': status,
    };

    final uri = Uri.parse(
      '$baseUrl/$apiVersion/provider/orders',
    ).replace(queryParameters: queryParams);

    return _makeRequest(
      'GET',
      'provider/orders?${uri.query}',
      null,
      (data) => data['orders'] ?? [],
    );
  }

  // Additional services endpoints
  Future<ApiResponse<Map<String, dynamic>>> updateService(
    String serviceId,
    Map<String, dynamic> serviceData,
  ) async {
    debugPrint('API: Updating service $serviceId');
    return _makeRequest(
      'PATCH',
      'services/$serviceId',
      serviceData,
      (data) => data,
      requiresAuth: true,
    );
  }

  Future<ApiResponse<void>> deleteService(String serviceId) async {
    debugPrint('API: Deleting service $serviceId');
    return _makeRequest(
      'DELETE',
      'services/$serviceId',
      null,
      (data) {},
      requiresAuth: true,
    );
  }

  // Bookings endpoints for seekers
  Future<ApiResponse<Map<String, dynamic>>> getMyBookings({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    debugPrint('API: Getting my bookings');

    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final uri = Uri.parse(
      '$baseUrl/$apiVersion/bookings/my-bookings',
    ).replace(queryParameters: queryParams);

    return _makeRequest(
      'GET',
      'bookings/my-bookings?${uri.query}',
      null,
      (data) => data,
      requiresAuth: true,
    );
  }

  // Get specific booking details
  Future<ApiResponse<Map<String, dynamic>>> getBookingDetails(
    String bookingId,
  ) async {
    debugPrint('API: Getting booking details for $bookingId');
    return _makeRequest(
      'GET',
      'bookings/$bookingId',
      null,
      (data) => data,
      requiresAuth: true,
    );
  }

  // Create a new booking
  Future<ApiResponse<Map<String, dynamic>>> createBooking(
    Map<String, dynamic> bookingData,
  ) async {
    debugPrint('API: Creating booking');
    return _makeRequest(
      'POST',
      'bookings',
      bookingData,
      (data) => data,
      requiresAuth: true,
    );
  }

  // Cancel booking
  Future<ApiResponse<Map<String, dynamic>>> cancelBooking(
    String bookingId,
    String reason,
  ) async {
    debugPrint('API: Cancelling booking $bookingId');
    return _makeRequest(
      'PATCH',
      'bookings/$bookingId/cancel',
      {'reason': reason},
      (data) => data,
      requiresAuth: true,
    );
  }

  // Bookings endpoints for providers
  Future<ApiResponse<List<Map<String, dynamic>>>> getProviderBookings() async {
    debugPrint('API: Getting provider bookings');
    return _makeRequestForList(
      'GET',
      'bookings/provider-bookings',
      null,
      _parseBookingsData,
      requiresAuth: true,
    );
  }

  List<Map<String, dynamic>> _parseBookingsData(dynamic data) {
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    } else if (data is Map && data['bookings'] is List) {
      final bookings = data['bookings'] as List;
      return bookings.whereType<Map<String, dynamic>>().toList();
    }
    return <Map<String, dynamic>>[];
  }

  Future<ApiResponse<Map<String, dynamic>>> updateBookingStatus(
    String bookingId,
    Map<String, dynamic> statusData,
  ) async {
    debugPrint('API: Updating booking status $bookingId');
    return _makeRequest(
      'PATCH',
      'bookings/$bookingId',
      statusData,
      (data) => data,
      requiresAuth: true,
    );
  }

  // Availability management endpoints (Updated to use new v2 API)
  Future<ApiResponse<Map<String, dynamic>>> updateAvailability(
    String availabilityId,
    Map<String, dynamic> availabilityData,
  ) async {
    debugPrint('API: Updating availability $availabilityId');
    debugPrint('DEBUG API: availabilityId = $availabilityId');
    debugPrint('DEBUG API: availabilityId type = ${availabilityId.runtimeType}');
    debugPrint('DEBUG API: availabilityData = $availabilityData');
    debugPrint('DEBUG API: availabilityData keys = ${availabilityData.keys}');

    for (final entry in availabilityData.entries) {
      debugPrint(
        'DEBUG API: ${entry.key} = ${entry.value} (${entry.value.runtimeType})',
      );
    }

    return _makeRequest(
      'PUT',
      'availability/$availabilityId',
      availabilityData,
      (data) => data,
      requiresAuth: true,
    );
  }

  // Update availability by ObjectId (original method)
  Future<ApiResponse<Map<String, dynamic>>> updateDayAvailability(
    String dayId,
    String dayOfWeek,
    List<Map<String, dynamic>> timeSlots, {
    String? notes,
    bool isActive = true,
  }) async {
    final availabilityData = <String, dynamic>{
      'timeSlots': timeSlots,
      'isActive': isActive,
    };

    if (notes != null) {
      availabilityData['notes'] = notes;
    }

    debugPrint(
      'API: Updating day availability by ID $dayId for $dayOfWeek with ${timeSlots.length} time slots',
    );
    return _makeRequest(
      'PATCH',
      'bookings/availability/$dayId',
      availabilityData,
      (data) => data,
      requiresAuth: true,
    );
  }

  // CUSTOM: Update availability by day name (not in official API docs)
  Future<ApiResponse<Map<String, dynamic>>> updateAvailabilityByDay(
    String dayOfWeek,
    List<Map<String, dynamic>> timeSlots, {
    String? notes,
    bool isActive = true,
  }) async {
    final availabilityData = <String, dynamic>{
      'timeSlots': timeSlots,
      'isActive': isActive,
    };

    if (notes != null) {
      availabilityData['notes'] = notes;
    }

    debugPrint(
      'API: Updating availability by day name for $dayOfWeek with ${timeSlots.length} time slots',
    );
    debugPrint('API: Using new route - availability/day/${dayOfWeek.toLowerCase()}');
    return _makeRequest(
      'PATCH',
      'availability/day/${dayOfWeek.toLowerCase()}',
      availabilityData,
      (data) => data,
      requiresAuth: true,
    );
  }

  // CUSTOM: Create/Update day availability using PATCH (not in official API docs)
  Future<ApiResponse<Map<String, dynamic>>> createDayAvailability(
    String dayOfWeek,
    List<Map<String, dynamic>> timeSlots, {
    String? notes,
    bool isActive = true,
  }) async {
    final availabilityData = <String, dynamic>{
      'timeSlots': timeSlots,
      'isActive': isActive,
    };

    if (notes != null) {
      availabilityData['notes'] = notes;
    }

    debugPrint(
      'API: Creating/updating day availability for $dayOfWeek with ${timeSlots.length} time slots',
    );
    debugPrint('API: Using new route - availability/day/${dayOfWeek.toLowerCase()}');
    return _makeRequest(
      'PATCH',
      'availability/day/${dayOfWeek.toLowerCase()}',
      availabilityData,
      (data) => data,
      requiresAuth: true,
    );
  }

  Future<ApiResponse<void>> deleteAvailability(String availabilityId) async {
    debugPrint('API: Deleting availability $availabilityId');
    return _makeRequest(
      'DELETE',
      'availability/$availabilityId',
      null,
      (data) {},
      requiresAuth: true,
    );
  }

  // Check availability for session booking (Updated to use new v2 API)
  Future<ApiResponse<Map<String, dynamic>>> checkAvailability({
    required String providerId,
    required String date, // YYYY-MM-DD format
    required String startTime, // HH:mm format
    required String endTime, // HH:mm format
  }) async {
    debugPrint(
      'API: Checking availability for provider $providerId on $date from $startTime to $endTime',
    );

    return _makeRequest(
      'GET',
      'availability/check?providerId=$providerId&date=$date&startTime=$startTime&endTime=$endTime',
      null,
      (data) => data,
      requiresAuth: false, // Public endpoint
    );
  }

  // Get provider availability (public endpoint for session booking)
  Future<ApiResponse<List<Map<String, dynamic>>>> getProviderAvailability(
    String providerId,
  ) async {
    debugPrint('API: Getting provider availability for $providerId');
    return _makeRequestForList(
      'GET',
      'availability/provider/$providerId',
      null,
      _parseAvailabilityData,
      requiresAuth: false, // Public endpoint
    );
  }

  // Set default availability (Monday-Friday 9-5) - Updated to use new v2 API
  Future<ApiResponse<Map<String, dynamic>>> setDefaultAvailability() async {
    debugPrint('API: Setting default availability (Mon-Fri 9-5)');
    return _makeRequest(
      'POST',
      'availability/default',
      null,
      (data) => data,
      requiresAuth: true,
    );
  }

  // ============== SESSION MANAGEMENT ENDPOINTS ==============

  // Create a new session (book a service)
  Future<ApiResponse<Map<String, dynamic>>> createSession(
    Map<String, dynamic> sessionData,
  ) async {
    debugPrint('API: Creating session');
    debugPrint('API: Session data: $sessionData');
    return _makeRequest(
      'POST',
      'sessions',
      sessionData,
      (data) => data,
      requiresAuth: true,
    );
  }

  // ============== ENHANCED SESSION ENDPOINTS WITH LOCATION ==============

  // Get provider sessions with location and seeker information
  Future<ApiResponse<Map<String, dynamic>>> getProviderSessionsWithLocation({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    debugPrint('API: Getting provider sessions with location (status: $status)');

    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final query = queryParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    return _makeRequest(
      'GET',
      'sessions/provider?$query',
      null,
      (data) => data,
      requiresAuth: true,
    );
  }

  // Create service request with location
  Future<ApiResponse<Map<String, dynamic>>> createServiceRequestWithLocation(
    Map<String, dynamic> requestData,
  ) async {
    debugPrint('API: Creating service request with location');
    debugPrint('API: Request data: $requestData');
    return _makeRequest(
      'POST',
      'service-requests',
      requestData,
      (data) => data,
      requiresAuth: true,
    );
  }

  // ============== TYPED SESSION METHODS ==============

  // Get provider sessions with typed response
  Future<ApiResponse<SessionListResponse>> getProviderSessionsTyped({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    // Use the correct bookings endpoint instead of sessions/provider
    final response = await getProviderBookings();

    if (response.isSuccess && response.data != null) {
      try {
        // getProviderBookings returns List<Map<String, dynamic>>
        final bookingsList = response.data!;
        debugPrint('API Response: ${bookingsList.length} bookings received');
        
        List<SessionModel> sessions = [];
        
        // Convert bookings to SessionModel
        for (final booking in bookingsList) {
          try {
            final session = SessionModel.fromJson(booking);
            sessions.add(session);
          } catch (e) {
            debugPrint('Error parsing booking: $e');
            debugPrint('Booking data: $booking');
            // Continue with other bookings even if one fails
          }
        }
        
        // Create summary from sessions
        final summary = SessionSummary(
          pending: sessions.where((s) => s.status.value == 'pending').length,
          confirmed: sessions.where((s) => s.status.value == 'confirmed').length,
          inProgress: sessions.where((s) => s.status.value == 'in_progress').length,
          completed: sessions.where((s) => s.status.value == 'completed').length,
          cancelled: sessions.where((s) => s.status.value == 'cancelled').length,
        );
        
        // Create pagination info
        final pagination = PaginationInfo(
          total: sessions.length,
          page: page,
          limit: limit,
          totalPages: (sessions.length / limit).ceil(),
        );
        
        final sessionListResponse = SessionListResponse(
          sessions: sessions,
          summary: summary,
          pagination: pagination,
        );
        
        return ApiResponse<SessionListResponse>.success(sessionListResponse);
      } catch (e) {
        debugPrint('Error parsing session list response: $e');
        debugPrint('Response data: ${response.data}');
        return ApiResponse<SessionListResponse>.error('Failed to parse session data: $e');
      }
    }

    return ApiResponse<SessionListResponse>.error(response.error ?? 'Failed to load sessions');
  }

  // Create service request with typed response
  Future<ApiResponse<Map<String, dynamic>>> createServiceRequestTyped(
    CreateServiceRequestModel request,
  ) async {
    return createServiceRequestWithLocation(request.toJson());
  }

  // ============== HELPER METHODS FOR LOCATION-BASED SESSIONS ==============

  // Example method showing how to create a service request with location
  Future<ApiResponse<Map<String, dynamic>>> createServiceRequestExample({
    required String category,
    required DateTime serviceDate,
    required String startTime,
    required int duration,
    required double latitude,
    required double longitude,
    required String address,
    required String province,
    String? specialInstructions,
    String? description,
  }) async {
    final serviceRequest = CreateServiceRequestModel(
      category: category,
      serviceDate: serviceDate.toIso8601String().split('T')[0], // Convert DateTime to YYYY-MM-DD
      startTime: startTime,
      duration: duration.toDouble(), // Convert int to double
      location: ServiceRequestLocation(
        latitude: latitude,
        longitude: longitude,
        address: address,
      ),
      province: province,
      specialInstructions: specialInstructions,
      description: description,
    );

    return createServiceRequestTyped(serviceRequest);
  }

  // Example method showing how to get provider sessions with location data
  Future<ApiResponse<SessionListResponse>> getProviderSessionsExample({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await getProviderSessionsTyped(
      status: status,
      page: page,
      limit: limit,
    );

    if (response.isSuccess && response.data != null) {
      // Log location and client information for each session
      for (final session in response.data!.sessions) {
        debugPrint('Session ${session.id}:');
        debugPrint('  Service: ${session.serviceName}');
        debugPrint('  Client: ${session.seeker?.fullName ?? 'Unknown'}');
        debugPrint('  Phone: ${session.seeker?.phoneNumber ?? 'N/A'}');
        debugPrint('  Location: ${session.serviceLocation?.address ?? 'N/A'}');
        debugPrint('  Province: ${session.serviceLocation?.province ?? 'N/A'}');
        debugPrint('  GPS: ${session.serviceLocation?.latitude}, ${session.serviceLocation?.longitude}');
        debugPrint('  Status: ${session.status.displayName}');
        debugPrint('  Payment: ${session.paymentStatus.displayName}');
        debugPrint('  Amount: ${session.formattedAmount}');
        debugPrint('  Date: ${session.displayDate}');
        debugPrint('  Duration: ${session.formattedDuration}');
        debugPrint('---');
      }
    }

    return response;
  }

  // Get my sessions (both as seeker and provider)
  Future<ApiResponse<Map<String, dynamic>>> getMySessions({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    debugPrint(
      'API: Getting my sessions (status: $status, page: $page, limit: $limit)',
    );

    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final query = queryParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    return _makeRequest(
      'GET',
      'sessions/my-sessions?$query',
      null,
      (data) => data,
      requiresAuth: true,
    );
  }

  // Get sessions as seeker
  Future<ApiResponse<Map<String, dynamic>>> getSessionsAsSeeker({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    debugPrint('API: Getting sessions as seeker (status: $status)');

    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final query = queryParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    return _makeRequest(
      'GET',
      'sessions/seeker?$query',
      null,
      (data) => data,
      requiresAuth: true,
    );
  }

  // Get sessions as provider
  Future<ApiResponse<Map<String, dynamic>>> getSessionsAsProvider({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    debugPrint('API: Getting sessions as provider (status: $status)');

    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final query = queryParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    return _makeRequest(
      'GET',
      'sessions/provider?$query',
      null,
      (data) => data,
      requiresAuth: true,
    );
  }

  // Get session details
  Future<ApiResponse<Map<String, dynamic>>> getSessionDetails(
    String sessionId,
  ) async {
    debugPrint('API: Getting session details for $sessionId');
    return _makeRequest(
      'GET',
      'sessions/$sessionId',
      null,
      (data) => data,
      requiresAuth: true,
    );
  }

  // Update session
  Future<ApiResponse<Map<String, dynamic>>> updateSession(
    String sessionId,
    Map<String, dynamic> updateData,
  ) async {
    debugPrint('API: Updating session $sessionId');
    debugPrint('API: Update data: $updateData');
    return _makeRequest(
      'PUT',
      'sessions/$sessionId',
      updateData,
      (data) => data,
      requiresAuth: true,
    );
  }

  // Cancel session
  Future<ApiResponse<Map<String, dynamic>>> cancelSession(
    String sessionId,
    String reason,
  ) async {
    debugPrint('API: Cancelling session $sessionId with reason: $reason');
    return _makeRequest(
      'PUT',
      'sessions/$sessionId/cancel',
      {'reason': reason},
      (data) => data,
      requiresAuth: true,
    );
  }

  // Get category pricing
  Future<ApiResponse<List<Map<String, dynamic>>>> getCategoryPricing() async {
    debugPrint('API: Getting category pricing');
    return _makeRequestForList(
      'GET',
      'admin/session-config/category-pricing',
      null,
      (data) => (data as List).whereType<Map<String, dynamic>>().toList(),
      requiresAuth: false, // Public endpoint
    );
  }

  // Calculate session price
  Future<ApiResponse<Map<String, dynamic>>> calculateSessionPrice(
    String category,
    double duration,
  ) async {
    // API: Calculating session price for $category ($duration hours)
    return _makeRequest(
      'GET',
      'admin/session-config/calculate-price/$category/$duration',
      null,
      (data) => data,
      requiresAuth: true, // Requires authentication
    );
  }

  // Helper method for local price calculation (uniform pricing)
  static Map<String, dynamic> calculateUniformSessionPrice(double duration) {
    const int basePrice = 3000; // Base price for 4 hours
    const double baseDuration = 4.0;
    const int overtimeRate = 375; // Per 30-minute block

    int totalPrice = basePrice;
    int overtimePrice = 0;
    double overtimeHours = 0;

    if (duration > baseDuration) {
      overtimeHours = duration - baseDuration;
      final overtimeBlocks = (overtimeHours * 2).ceil(); // 30-minute blocks
      overtimePrice = overtimeBlocks * overtimeRate;
      totalPrice = basePrice + overtimePrice;
    }

    return {
      'basePrice': basePrice,
      'overtimePrice': overtimePrice,
      'totalPrice': totalPrice,
      'baseDuration': baseDuration,
      'overtimeHours': overtimeHours,
    };
  }

  // Helper method for session booking - validate availability with duration
  Future<ApiResponse<bool>> validateSessionAvailability({
    required String providerId,
    required DateTime sessionDate,
    required String startTime, // HH:mm format
    required double durationHours,
  }) async {
    debugPrint(
      'API: Validating session availability for $durationHours hours starting at $startTime',
    );

    // Calculate end time from start time + duration
    final startParts = startTime.split(':');
    final startHour = int.parse(startParts[0]);
    final startMinute = int.parse(startParts[1]);

    final startDateTime = DateTime(2000, 1, 1, startHour, startMinute);
    final endDateTime = startDateTime.add(
      Duration(
        hours: durationHours.floor(),
        minutes: ((durationHours - durationHours.floor()) * 60).round(),
      ),
    );

    final endTime =
        '${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}';
    final dateStr =
        '${sessionDate.year}-${sessionDate.month.toString().padLeft(2, '0')}-${sessionDate.day.toString().padLeft(2, '0')}';

    try {
      final response = await checkAvailability(
        providerId: providerId,
        date: dateStr,
        startTime: startTime,
        endTime: endTime,
      );

      if (response.isSuccess && response.data != null) {
        final isAvailable = response.data!['available'] as bool? ?? false;
        return ApiResponse.success(isAvailable);
      } else {
        return ApiResponse.error(
          response.error ?? 'Failed to check availability',
        );
      }
    } catch (e) {
      return ApiResponse.error('Error validating availability: $e');
    }
  }

  // Helper method to make HTTP requests with timeout

  // Provider browsing endpoints
  Future<ApiResponse<Map<String, dynamic>>> getAllProviders({
    String? search,
    int page = 1,
    int limit = 20,
    bool includeStats = true,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
      if (includeStats) 'includeStats': 'true',
    };

    final uri = Uri.parse(
      '$baseUrl/$apiVersion/users/provider/all',
    ).replace(queryParameters: queryParams);

    return _makeRequest(
      'GET',
      'users/provider/all?${uri.query}',
      null,
      (data) => data,
      requiresAuth: false,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getProvidersByCategory(
    String category, {
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final uri = Uri.parse(
      '$baseUrl/$apiVersion/services/providers/category/$category',
    ).replace(queryParameters: queryParams);

    return _makeRequest(
      'GET',
      'services/providers/category/$category?${uri.query}',
      null,
      (data) => data,
      requiresAuth: false,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getProviderProfile(
    String providerId,
  ) async {
    return _makeRequest(
      'GET',
      'users/provider/$providerId/profile',
      null,
      (data) => data,
      requiresAuth: false,
    );
  }

  // ============== GPS TRACKING ENDPOINTS ==============

  // Start location tracking for a session
  Future<ApiResponse<Map<String, dynamic>>> startLocationTracking(
    String sessionId,
  ) async {
    debugPrint('API: Starting location tracking for session $sessionId');
    return _makeRequest(
      'POST',
      'sessions/$sessionId/tracking/start',
      null,
      (data) => data,
      requiresAuth: true,
    );
  }

  // Update provider location
  Future<ApiResponse<Map<String, dynamic>>> updateProviderLocation(
    String sessionId,
    Map<String, dynamic> locationData,
  ) async {
    debugPrint('API: Updating provider location for session $sessionId');
    return _makeRequest(
      'PUT',
      'sessions/$sessionId/tracking/location',
      locationData,
      (data) => data,
      requiresAuth: true,
    );
  }

  // Get seeker view of provider location
  Future<ApiResponse<Map<String, dynamic>>> getProviderLocation(
    String sessionId,
  ) async {
    debugPrint('API: Getting provider location for session $sessionId');
    return _makeRequest(
      'GET',
      'sessions/$sessionId/tracking/location',
      null,
      (data) => data,
      requiresAuth: true,
    );
  }

  // ============== PROVIDER DASHBOARD ENDPOINTS ==============

  // Get upcoming bookings
  Future<ApiResponse<Map<String, dynamic>>> getUpcomingBookings({
    int limit = 5,
    int days = 7,
  }) async {
    debugPrint('API: Getting upcoming bookings (limit: $limit, days: $days)');
    return _makeRequest(
      'GET',
      'providers/bookings/upcoming?limit=$limit&days=$days',
      null,
      (data) => data,
      requiresAuth: true,
    );
  }

  // ============== UPDATED AVAILABILITY ENDPOINTS ==============

  // Create availability (updated to match new API structure)
  Future<ApiResponse<Map<String, dynamic>>> createAvailabilityV2(
    Map<String, dynamic> availabilityData,
  ) async {
    debugPrint('API: Creating availability (v2)');
    return _makeRequest(
      'POST',
      'availability',
      availabilityData,
      (data) => data,
      requiresAuth: true,
    );
  }

  // Get my availability schedule (updated)
  Future<ApiResponse<List<Map<String, dynamic>>>> getMyAvailabilityV2() async {
    debugPrint('API: Getting my availability schedule (v2)');
    return _makeRequestForList(
      'GET',
      'availability',
      null,
      _parseAvailabilityData,
      requiresAuth: true,
    );
  }

  // Get provider availability (updated)
  Future<ApiResponse<List<Map<String, dynamic>>>> getProviderAvailabilityV2(
    String providerId,
  ) async {
    debugPrint('API: Getting provider availability (v2) for $providerId');
    return _makeRequestForList(
      'GET',
      'availability/provider/$providerId',
      null,
      _parseAvailabilityData,
      requiresAuth: false, // Public endpoint
    );
  }

  // Update availability (updated)
  Future<ApiResponse<Map<String, dynamic>>> updateAvailabilityV2(
    String availabilityId,
    Map<String, dynamic> availabilityData,
  ) async {
    debugPrint('API: Updating availability (v2) $availabilityId');
    return _makeRequest(
      'PUT',
      'availability/$availabilityId',
      availabilityData,
      (data) => data,
      requiresAuth: true,
    );
  }

  // Delete availability (updated)
  Future<ApiResponse<void>> deleteAvailabilityV2(String availabilityId) async {
    debugPrint('API: Deleting availability (v2) $availabilityId');
    return _makeRequest(
      'DELETE',
      'availability/$availabilityId',
      null,
      (data) {},
      requiresAuth: true,
    );
  }

  // Set default availability (updated)
  Future<ApiResponse<Map<String, dynamic>>> setDefaultAvailabilityV2() async {
    debugPrint('API: Setting default availability (v2)');
    return _makeRequest(
      'POST',
      'availability/default',
      null,
      (data) => data,
      requiresAuth: true,
    );
  }

  // Check availability (updated)
  Future<ApiResponse<Map<String, dynamic>>> checkAvailabilityV2({
    required String providerId,
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    debugPrint('API: Checking availability (v2) for provider $providerId');
    return _makeRequest(
      'GET',
      'availability/check?providerId=$providerId&date=$date&startTime=$startTime&endTime=$endTime',
      null,
      (data) => data,
      requiresAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getSeekerTrackingView(
    String sessionId,
  ) async {
    debugPrint('API: Getting seeker tracking view for session $sessionId');
    return _makeRequest(
      'GET',
      'sessions/$sessionId/tracking/seeker',
      null,
      (data) => data,
      requiresAuth: true,
    );
  }

  // Complete service tracking
  Future<ApiResponse<Map<String, dynamic>>> completeServiceTracking(
    String sessionId,
  ) async {
    debugPrint('API: Completing service tracking for session $sessionId');
    return _makeRequest(
      'PUT',
      'sessions/$sessionId/tracking/complete',
      null,
      (data) => data,
      requiresAuth: true,
    );
  }

  // Send tracking heartbeat
  Future<ApiResponse<Map<String, dynamic>>> sendTrackingHeartbeat(
    String sessionId,
  ) async {
    return _makeRequest(
      'POST',
      'sessions/$sessionId/tracking/heartbeat',
      {'timestamp': DateTime.now().toIso8601String()},
      (data) => data,
      requiresAuth: true,
    );
  }

  // Report emergency stop
  Future<ApiResponse<Map<String, dynamic>>> reportEmergencyStop(
    String sessionId,
    Map<String, dynamic> emergencyData,
  ) async {
    debugPrint('API: Reporting emergency stop for session $sessionId');
    return _makeRequest(
      'POST',
      'sessions/$sessionId/tracking/emergency',
      emergencyData,
      (data) => data,
      requiresAuth: true,
    );
  }

  // Get tracking history for a session
  Future<ApiResponse<List<Map<String, dynamic>>>> getTrackingHistory(
    String sessionId,
  ) async {
    debugPrint('API: Getting tracking history for session $sessionId');
    return _makeRequestForList(
      'GET',
      'sessions/$sessionId/tracking/history',
      null,
      (data) => (data as List).whereType<Map<String, dynamic>>().toList(),
      requiresAuth: true,
    );
  }

  // Get live tracking data for session
  Future<ApiResponse<Map<String, dynamic>>> getLiveTrackingData(
    String sessionId,
  ) async {
    return _makeRequest(
      'GET',
      'sessions/$sessionId/tracking/live',
      null,
      (data) => data,
      requiresAuth: true,
    );
  }

  // Provider Dashboard endpoints
  Future<ApiResponse<Map<String, dynamic>>>
  getProviderDashboardSummary() async {
    debugPrint('API: Getting provider dashboard summary');
    return _makeRequest(
      'GET',
      'providers/dashboard',
      null,
      (data) => data,
      requiresAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getProviderEarnings({
    String period = 'month',
    String? startDate,
    String? endDate,
  }) async {
    debugPrint('API: Getting provider earnings (period: $period)');

    final queryParams = <String, String>{'period': period};

    if (startDate != null && endDate != null) {
      queryParams['startDate'] = startDate;
      queryParams['endDate'] = endDate;
    }

    final query = queryParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    return _makeRequest(
      'GET',
      'providers/earnings?$query',
      null,
      (data) => data,
      requiresAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getProviderAnalytics({
    String period = 'month',
  }) async {
    debugPrint('API: Getting provider analytics (period: $period)');
    return _makeRequest(
      'GET',
      'providers/analytics?period=$period',
      null,
      (data) => data,
      requiresAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getProviderWallet() async {
    debugPrint('API: Getting provider wallet information');
    return _makeRequest(
      'GET',
      'providers/wallet',
      null,
      (data) => data,
      requiresAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> requestWithdrawal({
    required int amount,
    required String withdrawalMethod,
    required Map<String, dynamic> paymentDetails,
    String? notes,
  }) async {
    debugPrint('API: Requesting withdrawal of $amount FCFA via $withdrawalMethod');

    final requestData = <String, dynamic>{
      'amount': amount,
      'withdrawalMethod': withdrawalMethod,
    };

    // Add the appropriate payment details based on withdrawal method
    if (withdrawalMethod == 'bank_transfer' &&
        paymentDetails.containsKey('bankDetails')) {
      requestData['bankDetails'] = paymentDetails['bankDetails'];
    } else if (withdrawalMethod == 'mobile_money' &&
        paymentDetails.containsKey('mobileMoneyDetails')) {
      requestData['mobileMoneyDetails'] = paymentDetails['mobileMoneyDetails'];
    } else if (withdrawalMethod == 'paypal' &&
        paymentDetails.containsKey('paypalDetails')) {
      requestData['paypalDetails'] = paymentDetails['paypalDetails'];
    }

    if (notes != null) {
      requestData['notes'] = notes;
    }

    return _makeRequest(
      'POST',
      'providers/withdrawals',
      requestData,
      (data) => data,
      requiresAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getWithdrawalHistory({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    debugPrint('API: Getting withdrawal history (status: $status, page: $page)');

    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final query = queryParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    return _makeRequest(
      'GET',
      'providers/withdrawals?$query',
      null,
      (data) => data,
      requiresAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getProviderUpcomingBookings({
    int limit = 5,
    int days = 7,
  }) async {
    debugPrint(
      'API: Getting provider upcoming bookings (limit: $limit, days: $days)',
    );
    return _makeRequest(
      'GET',
      'providers/bookings/upcoming?limit=$limit&days=$days',
      null,
      (data) => data,
      requiresAuth: true,
    );
  }

  // Review API methods
  Future<ApiResponse<Map<String, dynamic>>> getProviderReviews(
    String providerId, {
    int page = 1,
    int limit = 20,
  }) async {
    debugPrint('API: Getting provider reviews for $providerId (page: $page)');
    return _makeRequest(
      'GET',
      'users/provider/$providerId/reviews?page=$page&limit=$limit',
      null,
      (data) => data,
      requiresAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> createProviderReview(
    String providerId,
    Map<String, dynamic> reviewData,
  ) async {
    debugPrint('API: Creating review for provider $providerId');
    debugPrint('API: Review data: $reviewData');
    return _makeRequest(
      'POST',
      'users/provider/$providerId/reviews',
      reviewData,
      (data) => data,
      requiresAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> respondToReview(
    String reviewId,
    Map<String, dynamic> responseData,
  ) async {
    debugPrint('API: Responding to review $reviewId');
    debugPrint('API: Response data: $responseData');
    return _makeRequest(
      'POST',
      'users/provider/reviews/$reviewId/respond',
      responseData,
      (data) => data,
      requiresAuth: true,
    );
  }

  // Helper methods
  bool get isAuthenticated => _accessToken != null;

  String? get accessToken => _accessToken;

  // ============== SERVICE REQUEST ENDPOINTS ==============

  // Create service request
  Future<ApiResponse<Map<String, dynamic>>> createServiceRequest(
    Map<String, dynamic> requestData,
  ) async {
    debugPrint('API: Creating service request for ${requestData['category']}');
    debugPrint('API: Request data: $requestData');
    return _makeRequest(
      'POST',
      'service-requests',
      requestData,
      (data) => data,
      requiresAuth: true,
    );
  }

  // Get my service requests
  Future<ApiResponse<Map<String, dynamic>>> getMyServiceRequests({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    debugPrint('API: Getting my service requests (status: $status, page: $page)');

    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final query = queryParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    return _makeRequest(
      'GET',
      'service-requests/my-requests?$query',
      null,
      (data) => data,
      requiresAuth: true,
    );
  }

  // Get service request details
  Future<ApiResponse<Map<String, dynamic>>> getServiceRequestDetails(
    String requestId,
  ) async {
    debugPrint('API: Getting service request details for $requestId');
    return _makeRequest(
      'GET',
      'service-requests/$requestId',
      null,
      (data) => data,
      requiresAuth: true,
    );
  }

  // Cancel service request
  Future<ApiResponse<Map<String, dynamic>>> cancelServiceRequest(
    String requestId,
    String reason,
  ) async {
    debugPrint('API: Cancelling service request $requestId');
    return _makeRequest(
      'PATCH',
      'service-requests/$requestId/cancel',
      {'reason': reason},
      (data) => data,
      requiresAuth: true,
    );
  }

  // ============== PROVIDER PROFILE SETUP ENDPOINTS ==============

  // Setup provider profile
  Future<ApiResponse<Map<String, dynamic>>> setupProviderProfile(
    Map<String, dynamic> profileData,
  ) async {
    debugPrint('API: Setting up provider profile');
    return _makeRequest(
      'PATCH',
      'users/profile/setup',
      profileData,
      (data) => data,
      requiresAuth: true,
    );
  }

  // Check profile status
  Future<ApiResponse<Map<String, dynamic>>> checkProfileStatus() async {
    debugPrint('API: Checking profile status');
    return _makeRequest(
      'GET',
      'users/profile/status',
      null,
      (data) => data,
      requiresAuth: true,
    );
  }

  // ============== COUPON ENDPOINTS ==============

  // Validate coupon code
  Future<ApiResponse<CouponValidationResponse>> validateCoupon(
    CouponValidationRequest request,
  ) async {
    debugPrint('API: Validating coupon ${request.code} for amount ${request.orderAmount}');

    try {
      final response = await _makeRequest(
        'POST',
        'coupons/validate',
        request.toJson(),
        (data) => data,
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        final couponResponse = CouponValidationResponse.fromJson(response.data!);
        debugPrint('API: Coupon validation result - isValid: ${couponResponse.isValid}, discount: ${couponResponse.discountAmount}');
        return ApiResponse<CouponValidationResponse>.success(couponResponse);
      } else {
        final errorMessage = response.error ?? 'Failed to validate coupon';
        debugPrint('API: Coupon validation failed - $errorMessage');
        return ApiResponse<CouponValidationResponse>.success(
          CouponValidationResponse.error(errorMessage),
        );
      }
    } catch (e) {
      debugPrint('API: Coupon validation error - $e');
      return ApiResponse<CouponValidationResponse>.success(
        CouponValidationResponse.error('Network error: $e'),
      );
    }
  }

  // ============================================================================
  // NEW BOOKING ENDPOINTS (Payment Flow)
  // ============================================================================

  /// Initiate a booking with payment
  /// POST /api/v1/bookings/initiate
  Future<ApiResponse<InitiateBookingResponse>> initiateBooking(
    InitiateBookingRequest request,
  ) async {
    debugPrint('API: Initiating booking for category ${request.category}');
    debugPrint('API: Session date: ${request.sessionDate}, time: ${request.startTime}, duration: ${request.duration}h');
    debugPrint('API: Phone: ${request.paymentDetails.phone}, Medium: ${request.paymentDetails.medium}');
    if (request.couponCode != null) {
      debugPrint('API: Applying coupon: ${request.couponCode}');
    }

    try {
      final response = await _makeRequest(
        'POST',
        'bookings/initiate',
        request.toJson(),
        (data) => InitiateBookingResponse.fromJson(data),
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        debugPrint('API: Booking initiated successfully - ID: ${response.data!.bookingId}');
        debugPrint('API: Amount: ${response.data!.amount} FCFA, Original: ${response.data!.originalAmount} FCFA');
        if (response.data!.hasDiscount) {
          debugPrint('API: Discount applied: ${response.data!.discountAmount} FCFA');
        }
        debugPrint('API: ${response.data!.message}');
      } else {
        debugPrint('API: Booking initiation failed - ${response.error}');
      }

      return response;
    } catch (e) {
      debugPrint('API: Booking initiation error - $e');
      return ApiResponse.error('Failed to initiate booking: $e');
    }
  }

  /// Check booking status (for polling)
  /// GET /api/v1/bookings/status/:bookingId
  Future<ApiResponse<BookingStatusResponse>> checkBookingStatus(
    String bookingId,
  ) async {
    debugPrint('API: Checking booking status for $bookingId');

    try {
      final response = await _makeRequest(
        'GET',
        'bookings/status/$bookingId',
        null,
        (data) => BookingStatusResponse.fromJson(data),
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        final status = response.data!;
        debugPrint('API: Booking status: ${status.status.displayName}, Payment: ${status.paymentStatus}');

        if (status.isCompleted && status.session != null) {
          debugPrint('API: Session created - ID: ${status.sessionId}');
          debugPrint('API: Service: ${status.session!.serviceName}, Provider: ${status.session!.provider.name}');
        } else if (status.isFailed) {
          debugPrint('API: Payment failed');
        } else if (status.isExpired) {
          debugPrint('API: Payment expired');
        }
      }

      return response;
    } catch (e) {
      debugPrint('API: Booking status check error - $e');
      return ApiResponse.error('Failed to check booking status: $e');
    }
  }

  /// Poll booking status with automatic retry
  /// Polls every 3 seconds for up to 3 minutes (60 attempts)
  Stream<BookingStatusResponse> pollBookingStatus(
    String bookingId, {
    int maxAttempts = 60,
    Duration interval = const Duration(seconds: 3),
  }) async* {
    debugPrint('API: Starting booking status polling for $bookingId');
    int attempts = 0;

    while (attempts < maxAttempts) {
      attempts++;
      debugPrint('API: Polling attempt $attempts/$maxAttempts');

      final response = await checkBookingStatus(bookingId);

      if (response.isSuccess && response.data != null) {
        final status = response.data!;
        yield status;

        // Stop polling if payment is complete, failed, or expired
        if (status.isCompleted || status.isFailed || status.isExpired) {
          debugPrint('API: Polling stopped - final status: ${status.status.displayName}');
          break;
        }
      } else {
        debugPrint('API: Polling error (will retry): ${response.error}');
      }

      // Wait before next poll (except on last attempt or final status)
      if (attempts < maxAttempts) {
        await Future.delayed(interval);
      }
    }

    if (attempts >= maxAttempts) {
      debugPrint('API: Polling timeout after $maxAttempts attempts');
    }
  }
}
