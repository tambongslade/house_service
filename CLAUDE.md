# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Core Commands
- **Run the app**: `flutter run`
- **Build for Android**: `flutter build apk`
- **Build for iOS**: `flutter build ios`
- **Get dependencies**: `flutter pub get`
- **Clean build**: `flutter clean`
- **Analyze code**: `flutter analyze`
- **Run tests**: `flutter test`

### Code Quality
- **Lint**: Uses `flutter_lints` package with standard Flutter linting rules
- **Format code**: `dart format .`

### Localization
- **Generate localizations**: The app uses `flutter_localizations` with ARB files
- Localization files are in `assets/translations/` and `lib/l10n/`
- Supported locales: English (en) and French (fr)

## Architecture Overview

### Project Structure
This is a Flutter house service platform with two user types: **Service Seekers** and **Service Providers**.

**Core Architecture:**
- **State Management**: Provider pattern using the `provider` package
- **Main State**: `AppState` class manages authentication, user role, and app navigation flow
- **API Integration**: RESTful API communication through `ApiService` class
- **Routing Logic**: Role-based navigation in `main.dart` determines which main screen to show

### Key Components

**Authentication Flow:**
1. Onboarding screen (first-time users)
2. Login/signup screens with role selection
3. Role-based main screen routing

**User Roles:**
- `UserRole.serviceSeeker`: Access to `SeekerMainScreen`
- `UserRole.serviceProvider`: Access to `ProviderMainScreen`

**Core Services:**
- `ApiService`: Handles HTTP requests to backend API
- `AppState`: Global state management for authentication and user data
- Network connectivity checking via `network_info.dart`

### API Integration
The app integrates with a comprehensive backend API documented in `API_DOCUMENTATION.md`:
- Services management (CRUD operations)
- Booking system with availability management
- Authentication with JWT tokens
- Role-based permissions (Seeker vs Provider)

### Asset Management
- **Images**: `assets/images/` (onboarding, icons, service categories)
- **Fonts**: Custom Averta font family in `assets/fonts/`
- **Translations**: ARB files in `assets/translations/`

### Dependencies
Key packages:
- `provider`: State management
- `http`: API communication  
- `shared_preferences`: Local storage
- `flutter_localizations`: Internationalization
- `geolocator` & `google_maps_flutter`: Location services
- `image_picker`: Media handling
- `flutter_svg`: SVG support

### Screen Organization
- **Auth**: Login, signup, role selection screens
- **Onboarding**: Welcome flow for new users
- **Seeker**: Service browsing, booking, profile management
- **Provider**: Service creation, booking management, availability setting
- **Home**: Role-specific dashboard screens

The app follows a clean separation between seekers and providers with distinct navigation flows and feature sets.