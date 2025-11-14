import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class AppState extends ChangeNotifier {
  bool _isOnboardingCompleted = false;
  bool _isLoggedIn = false;
  bool _isLoading = true;
  bool _isLanguageSelected = false;
  bool _isLocationPermissionGranted = false;
  Locale _selectedLocale = const Locale('en'); // Default to English
  UserModel? _user;
  final ApiService _apiService = ApiService();

  bool get isOnboardingCompleted => _isOnboardingCompleted;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  bool get isLanguageSelected => _isLanguageSelected;
  bool get isLocationPermissionGranted => _isLocationPermissionGranted;
  Locale get selectedLocale => _selectedLocale;
  UserRole? get userRole => _user?.role;
  UserModel? get user => _user;
  ApiService get apiService => _apiService;

  AppState() {
    _initialize();
    _setupAuthenticationFailureHandler();
  }

  Future<void> _initialize() async {
    try {
      // Initialize API service
      await _apiService.initialize();

      // Load app state from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      _isOnboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
      _isLoggedIn = prefs.getBool('user_logged_in') ?? false;
      _isLanguageSelected = prefs.getBool('language_selected') ?? false;
      _isLocationPermissionGranted = prefs.getBool('location_permission_granted') ?? false;
      
      // Load selected language (default to English)
      final languageCode = prefs.getString('selected_language') ?? 'en';
      _selectedLocale = Locale(languageCode);

      // If user is logged in and has token, try to get profile
      if (_isLoggedIn && _apiService.isAuthenticated) {
        await _loadUserProfile();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final response = await _apiService.getProfile();
      if (response.isSuccess && response.data != null) {
        _user = response.data;
      } else {
        // If profile fetch fails, user might need to re-login
        await logout();
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      _isOnboardingCompleted = true;
      notifyListeners();
    } catch (e) {
      // Handle error silently or show message
    }
  }

  // Real authentication methods using API
  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);

      if (response.isSuccess && response.data != null) {
        await _apiService.setToken(response.data!.accessToken);
        _user = response.data!.user;
        _isLoggedIn = true;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('user_logged_in', true);

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<({bool success, String? error})> register(
    String fullName,
    String email,
    String password,
    String phoneNumber, {
    String? role,
    Map<String, dynamic>? providerSetupData,
  }) async {
    try {
      print('Attempting registration for: $email');
      final response = await _apiService.register(
        fullName,
        email,
        password,
        phoneNumber,
        role: role,
        providerSetupData: providerSetupData,
      );

      print(
        'Registration response - Success: ${response.isSuccess}, Error: ${response.error}',
      );

      if (response.isSuccess && response.data != null) {
        // For providers with setup data, the API returns PENDING_APPROVAL status
        // so we don't want to log them in automatically
        if (role == 'provider' && providerSetupData != null) {
          // Provider with complete setup - account is pending approval
          // Don't set login state or tokens
          print('Provider registration with setup data successful - pending approval');
          return (success: true, error: null);
        } else {
          // Regular registration or seeker registration
          await _apiService.setToken(response.data!.accessToken);
          _user = response.data!.user;
          _isLoggedIn = true;

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('user_logged_in', true);

          notifyListeners();
          return (success: true, error: null);
        }
      }

      // Return the specific error message from the API
      final errorMessage =
          response.error ??
          'Registration failed. Please check your details and try again.';
      print('Registration failed: $errorMessage');
      return (success: false, error: errorMessage);
    } catch (e) {
      final errorMessage = 'Network error: ${e.toString()}';
      print('Registration exception: $errorMessage');
      return (success: false, error: errorMessage);
    }
  }

  Future<void> logout() async {
    try {
      print('AppState: Starting logout process');
      print('AppState: Current isLoggedIn before logout: $_isLoggedIn');
      
      // Call API logout if authenticated
      if (_apiService.isAuthenticated) {
        print('AppState: Calling API logout');
        await _apiService.logout();
      }

      // Clear local state
      print('AppState: Clearing tokens and local state');
      await _apiService.clearTokens();
      _user = null;
      _isLoggedIn = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('user_logged_in', false);

      print('AppState: State cleared, calling notifyListeners()');
      print('AppState: isLoggedIn after logout: $_isLoggedIn');
      notifyListeners();
      print('AppState: notifyListeners() called successfully');
    } catch (e) {
      print('Logout error: $e');
    }
  }

  Future<({bool success, String? error})> setUserRole(UserRole role) async {
    try {
      print('AppState: Setting user role to: ${role.value}');
      print('AppState: Current user logged in: $_isLoggedIn');
      print(
        'AppState: API service authenticated: ${_apiService.isAuthenticated}',
      );

      final response = await _apiService.setUserRole(role.value);

      print(
        'AppState: Role update response - Success: ${response.isSuccess}, Error: ${response.error}',
      );

      if (response.isSuccess && response.data != null) {
        _user = response.data!.user;
        notifyListeners();
        print(
          'AppState: User role updated successfully to: ${_user?.role?.value}',
        );
        return (success: true, error: null);
      }

      final errorMessage =
          response.error ?? 'Failed to update user role. Please try again.';
      print('AppState: Role update failed: $errorMessage');
      return (success: false, error: errorMessage);
    } catch (e) {
      final errorMessage = 'Network error: ${e.toString()}';
      print('AppState: Role update exception: $errorMessage');
      return (success: false, error: errorMessage);
    }
  }

  void _setupAuthenticationFailureHandler() {
    _apiService.setAuthenticationFailedCallback(() {
      print('Authentication failed - automatically logging out user');
      _handleAuthenticationFailure();
    });
  }

  Future<void> _handleAuthenticationFailure() async {
    try {
      // Clear local state immediately
      _user = null;
      _isLoggedIn = false;

      // Clear stored preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('user_logged_in', false);

      // Notify listeners to trigger UI update and redirect to login
      notifyListeners();
      
      print('User logged out due to authentication failure');
    } catch (e) {
      print('Error handling authentication failure: $e');
    }
  }

  Future<void> resetApp() async {
    try {
      await _apiService.clearTokens();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _isOnboardingCompleted = false;
      _isLoggedIn = false;
      _isLanguageSelected = false;
      _selectedLocale = const Locale('en');
      _user = null;
      notifyListeners();
    } catch (e) {
      print('Reset app error: $e');
    }
  }

  // Language management methods
  Future<void> setLanguage(String languageCode) async {
    try {
      _selectedLocale = Locale(languageCode);
      _isLanguageSelected = true;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_language', languageCode);
      await prefs.setBool('language_selected', true);
      
      notifyListeners();
    } catch (e) {
      print('Set language error: $e');
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    try {
      _selectedLocale = Locale(languageCode);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_language', languageCode);
      
      notifyListeners();
    } catch (e) {
      print('Change language error: $e');
    }
  }

  String get currentLanguageCode => _selectedLocale.languageCode;

  // Location permission management
  Future<void> setLocationPermissionGranted() async {
    try {
      _isLocationPermissionGranted = true;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('location_permission_granted', true);
      
      notifyListeners();
    } catch (e) {
      print('Set location permission error: $e');
    }
  }
  
  bool get isEnglish => _selectedLocale.languageCode == 'en';
  bool get isFrench => _selectedLocale.languageCode == 'fr';
}
