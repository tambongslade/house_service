import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'core/state/app_state.dart';
import 'core/models/user_model.dart';
import 'presentation/features/language/view/language_selection_screen.dart';
import 'presentation/features/permissions/location_permission_screen.dart';
import 'presentation/features/onboarding/view/onboarding_screen.dart';
import 'presentation/features/auth/view/login_screen.dart';
import 'presentation/features/provider/view/provider_main_screen.dart';
import 'presentation/features/seeker/navigation/seeker_main_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          return MaterialApp(
            title: 'House Service',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              primaryColor: const Color(0xFF2196F3),
              colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2196F3)),
              useMaterial3: true,
              fontFamily: 'Averta',
              textTheme: const TextTheme(
                displayLarge: TextStyle(fontFamily: 'Averta'),
                displayMedium: TextStyle(fontFamily: 'Averta'),
                displaySmall: TextStyle(fontFamily: 'Averta'),
                headlineLarge: TextStyle(fontFamily: 'Averta'),
                headlineMedium: TextStyle(fontFamily: 'Averta'),
                headlineSmall: TextStyle(fontFamily: 'Averta'),
                titleLarge: TextStyle(fontFamily: 'Averta'),
                titleMedium: TextStyle(fontFamily: 'Averta'),
                titleSmall: TextStyle(fontFamily: 'Averta'),
                bodyLarge: TextStyle(fontFamily: 'Averta'),
                bodyMedium: TextStyle(fontFamily: 'Averta'),
                bodySmall: TextStyle(fontFamily: 'Averta'),
                labelLarge: TextStyle(fontFamily: 'Averta'),
                labelMedium: TextStyle(fontFamily: 'Averta'),
                labelSmall: TextStyle(fontFamily: 'Averta'),
              ),
            ),
            locale: appState.selectedLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // English
              Locale('fr', ''), // French
            ],
            // Add named routes
            routes: {
              '/': (context) => const AppWrapper(),
              '/language': (context) => const LanguageSelectionScreen(),
              '/login': (context) => const LoginScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        
        // Show loading screen while checking app state
        if (appState.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Show language selection if not selected yet
        if (!appState.isLanguageSelected) {
          return const LanguageSelectionScreen();
        }

        // Show location permission screen if not granted yet
        if (!appState.isLocationPermissionGranted) {
          return const LocationPermissionScreen();
        }

        // Show onboarding if not completed
        if (!appState.isOnboardingCompleted) {
          return const OnboardingScreen();
        }

        // Show login screen if not logged in
        if (!appState.isLoggedIn) {
          return const LoginScreen();
        }

        // Show appropriate main screen based on user role
        if (appState.userRole == UserRole.serviceSeeker) {
          return const SeekerMainScreen();
        } else {
          return const ProviderMainScreen();
        }
      },
    );
  }
}
