class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'https://warned-disclaimers-chelsea-give.trycloudflare.com/api';
  static const String apiVersion = 'v1';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String userLoggedInKey = 'user_logged_in';
  static const String onboardingCompletedKey = 'onboarding_completed';

  // App Configuration
  static const int requestTimeoutDuration = 30; // seconds
  static const int maxRetryAttempts = 3;

  // Currency
  static const String defaultCurrency = 'FCFA';

  // Phone number regex for Cameroon
  static const String phoneRegex = r'^\+237[0-9]{9}$';

  // User roles
  static const String seekerRole = 'seeker';
  static const String providerRole = 'provider';
}
