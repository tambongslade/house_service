import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Find Quality Home Services'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDescription1.
  ///
  /// In en, this message translates to:
  /// **'Connect with trusted professionals for all your home maintenance and repair needs'**
  String get onboardingDescription1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Book With Confidence'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDescription2.
  ///
  /// In en, this message translates to:
  /// **'Verified service providers with ratings and reviews from real customers'**
  String get onboardingDescription2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Track Your Service'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDescription3.
  ///
  /// In en, this message translates to:
  /// **'Monitor your service progress in real-time and get notifications for updates'**
  String get onboardingDescription3;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginButton;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home Services'**
  String get homeTitle;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to House Service!'**
  String get homeWelcome;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Language'**
  String get chooseLanguage;

  /// No description provided for @languageSelection.
  ///
  /// In en, this message translates to:
  /// **'Language Selection'**
  String get languageSelection;

  /// No description provided for @selectLanguagePrompt.
  ///
  /// In en, this message translates to:
  /// **'Please select your preferred language'**
  String get selectLanguagePrompt;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed successfully'**
  String get languageChanged;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @resetApp.
  ///
  /// In en, this message translates to:
  /// **'Reset App'**
  String get resetApp;

  /// A welcome message with user name
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}!'**
  String welcomeBack(String name);

  /// No description provided for @readyToManage.
  ///
  /// In en, this message translates to:
  /// **'Ready to manage your services today?'**
  String get readyToManage;

  /// No description provided for @walletBalance.
  ///
  /// In en, this message translates to:
  /// **'Wallet Balance'**
  String get walletBalance;

  /// No description provided for @availableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get availableBalance;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @totalEarned.
  ///
  /// In en, this message translates to:
  /// **'Total Earned'**
  String get totalEarned;

  /// No description provided for @withdrawMoney.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Money'**
  String get withdrawMoney;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @activeServices.
  ///
  /// In en, this message translates to:
  /// **'Active Services'**
  String get activeServices;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @totalJobs.
  ///
  /// In en, this message translates to:
  /// **'total jobs'**
  String get totalJobs;

  /// No description provided for @bookings.
  ///
  /// In en, this message translates to:
  /// **'bookings'**
  String get bookings;

  /// No description provided for @nextBooking.
  ///
  /// In en, this message translates to:
  /// **'Next Booking'**
  String get nextBooking;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @withText.
  ///
  /// In en, this message translates to:
  /// **'with'**
  String get withText;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @locationNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'Location not specified'**
  String get locationNotSpecified;

  /// No description provided for @twoThisMonth.
  ///
  /// In en, this message translates to:
  /// **'+2 this month'**
  String get twoThisMonth;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @noRecentActivities.
  ///
  /// In en, this message translates to:
  /// **'No recent activities'**
  String get noRecentActivities;

  /// No description provided for @activitiesWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Your activities will appear here'**
  String get activitiesWillAppear;

  /// No description provided for @serviceCompleted.
  ///
  /// In en, this message translates to:
  /// **'Service completed'**
  String get serviceCompleted;

  /// No description provided for @newSessionConfirmed.
  ///
  /// In en, this message translates to:
  /// **'New session confirmed'**
  String get newSessionConfirmed;

  /// No description provided for @newFiveStarReview.
  ///
  /// In en, this message translates to:
  /// **'New 5-star review'**
  String get newFiveStarReview;

  /// No description provided for @newCustomer.
  ///
  /// In en, this message translates to:
  /// **'New customer'**
  String get newCustomer;

  /// Hours ago timestamp
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String hoursAgo(int hours);

  /// Days ago timestamp
  ///
  /// In en, this message translates to:
  /// **'{days} day ago'**
  String dayAgo(int days);

  /// Days ago timestamp
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(int days);

  /// No description provided for @amountToWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Amount to withdraw'**
  String get amountToWithdraw;

  /// No description provided for @enterAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Enter amount in FCFA'**
  String get enterAmountHint;

  /// No description provided for @withdrawalMethod.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Method'**
  String get withdrawalMethod;

  /// No description provided for @bankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get bankTransfer;

  /// No description provided for @mobileMoney.
  ///
  /// In en, this message translates to:
  /// **'Mobile Money'**
  String get mobileMoney;

  /// No description provided for @minimumWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Minimum withdrawal: 5,000 FCFA'**
  String get minimumWithdrawal;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @validAmountError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount (minimum 5,000 FCFA)'**
  String get validAmountError;

  /// No description provided for @insufficientBalance.
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance'**
  String get insufficientBalance;

  /// No description provided for @withdrawalSuccess.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal request submitted successfully!'**
  String get withdrawalSuccess;

  /// No description provided for @withdrawalFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit withdrawal request'**
  String get withdrawalFailed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @myServices.
  ///
  /// In en, this message translates to:
  /// **'My Services'**
  String get myServices;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @availabilityValidation.
  ///
  /// In en, this message translates to:
  /// **'Availability Validation'**
  String get availabilityValidation;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @setupProviderProfile.
  ///
  /// In en, this message translates to:
  /// **'Setup Provider Profile'**
  String get setupProviderProfile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @updatePersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Update your personal information'**
  String get updatePersonalInfo;

  /// No description provided for @securitySettings.
  ///
  /// In en, this message translates to:
  /// **'Security Settings'**
  String get securitySettings;

  /// No description provided for @passwordAndSecurity.
  ///
  /// In en, this message translates to:
  /// **'Password and account security'**
  String get passwordAndSecurity;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @manageNotifications.
  ///
  /// In en, this message translates to:
  /// **'Manage your notification preferences'**
  String get manageNotifications;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @getHelpOrContact.
  ///
  /// In en, this message translates to:
  /// **'Get help or contact support'**
  String get getHelpOrContact;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account'**
  String get signOut;

  /// Coming soon message
  ///
  /// In en, this message translates to:
  /// **'{feature} feature coming soon!'**
  String featureComingSoon(String feature);

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmMessage;

  /// No description provided for @loggedOutSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Logged out successfully'**
  String get loggedOutSuccessfully;

  /// Network error message during logout
  ///
  /// In en, this message translates to:
  /// **'Network error during logout: {error}'**
  String networkErrorDuringLogout(String error);

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get memberSince;

  /// No description provided for @notProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get notProvided;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @myAddresses.
  ///
  /// In en, this message translates to:
  /// **'My Addresses'**
  String get myAddresses;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createAccount;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @selectRole.
  ///
  /// In en, this message translates to:
  /// **'Select Your Role'**
  String get selectRole;

  /// No description provided for @selectRolePrompt.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to use our platform'**
  String get selectRolePrompt;

  /// No description provided for @serviceSeeker.
  ///
  /// In en, this message translates to:
  /// **'Service Seeker'**
  String get serviceSeeker;

  /// No description provided for @seekerDescription.
  ///
  /// In en, this message translates to:
  /// **'I need home services'**
  String get seekerDescription;

  /// No description provided for @serviceProvider.
  ///
  /// In en, this message translates to:
  /// **'Service Provider'**
  String get serviceProvider;

  /// No description provided for @providerDescription.
  ///
  /// In en, this message translates to:
  /// **'I provide home services'**
  String get providerDescription;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @serviceProviders.
  ///
  /// In en, this message translates to:
  /// **'Service Provider'**
  String get serviceProviders;

  /// No description provided for @specialOffers.
  ///
  /// In en, this message translates to:
  /// **'Special Offers'**
  String get specialOffers;

  /// No description provided for @searchForServices.
  ///
  /// In en, this message translates to:
  /// **'Search for services...'**
  String get searchForServices;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @searchProviders.
  ///
  /// In en, this message translates to:
  /// **'Search providers...'**
  String get searchProviders;

  /// No description provided for @providers.
  ///
  /// In en, this message translates to:
  /// **'providers'**
  String get providers;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'results'**
  String get results;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @failedToLoadProviders.
  ///
  /// In en, this message translates to:
  /// **'Failed to load providers'**
  String get failedToLoadProviders;

  /// No description provided for @noProvidersFound.
  ///
  /// In en, this message translates to:
  /// **'No providers found'**
  String get noProvidersFound;

  /// No description provided for @tryAdjustingSearch.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search terms'**
  String get tryAdjustingSearch;

  /// No description provided for @beFirstToBook.
  ///
  /// In en, this message translates to:
  /// **'Be the first to book when providers join this category!'**
  String get beFirstToBook;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @startingFrom.
  ///
  /// In en, this message translates to:
  /// **'Starting from'**
  String get startingFrom;

  /// No description provided for @viewProfileAndBook.
  ///
  /// In en, this message translates to:
  /// **'View Profile & Book'**
  String get viewProfileAndBook;

  /// No description provided for @moreServices.
  ///
  /// In en, this message translates to:
  /// **'more services'**
  String get moreServices;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'reviews'**
  String get reviews;

  /// No description provided for @failedToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to load provider profile'**
  String get failedToLoadProfile;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get networkError;

  /// No description provided for @providerProfile.
  ///
  /// In en, this message translates to:
  /// **'Provider Profile'**
  String get providerProfile;

  /// No description provided for @shareComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Share functionality coming soon!'**
  String get shareComingSoon;

  /// No description provided for @failedToLoadProfileMsg.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile'**
  String get failedToLoadProfileMsg;

  /// No description provided for @providerNotFound.
  ///
  /// In en, this message translates to:
  /// **'Provider not found'**
  String get providerNotFound;

  /// No description provided for @availableNow.
  ///
  /// In en, this message translates to:
  /// **'Available Now'**
  String get availableNow;

  /// No description provided for @calling.
  ///
  /// In en, this message translates to:
  /// **'Calling'**
  String get calling;

  /// No description provided for @openingEmail.
  ///
  /// In en, this message translates to:
  /// **'Opening email to'**
  String get openingEmail;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @fcfaBase.
  ///
  /// In en, this message translates to:
  /// **'FCFA base'**
  String get fcfaBase;

  /// No description provided for @noAvailabilitySchedule.
  ///
  /// In en, this message translates to:
  /// **'No availability schedule set'**
  String get noAvailabilitySchedule;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @noTimeSlotsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No time slots available'**
  String get noTimeSlotsAvailable;

  /// No description provided for @reviewsAndRatings.
  ///
  /// In en, this message translates to:
  /// **'Reviews & Ratings'**
  String get reviewsAndRatings;

  /// No description provided for @addReview.
  ///
  /// In en, this message translates to:
  /// **'Add Review'**
  String get addReview;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @beFirstToReview.
  ///
  /// In en, this message translates to:
  /// **'Be the first to leave a review for this provider!'**
  String get beFirstToReview;

  /// No description provided for @loadMoreReviews.
  ///
  /// In en, this message translates to:
  /// **'Load More Reviews'**
  String get loadMoreReviews;

  /// No description provided for @anonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymous;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @providerResponse.
  ///
  /// In en, this message translates to:
  /// **'Provider Response'**
  String get providerResponse;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @readyToBook.
  ///
  /// In en, this message translates to:
  /// **'Ready to book?'**
  String get readyToBook;

  /// No description provided for @selectServiceAndAvailability.
  ///
  /// In en, this message translates to:
  /// **'Select a service and check availability to get started.'**
  String get selectServiceAndAvailability;

  /// No description provided for @bookService.
  ///
  /// In en, this message translates to:
  /// **'Book Service'**
  String get bookService;

  /// No description provided for @bookWith.
  ///
  /// In en, this message translates to:
  /// **'Book with'**
  String get bookWith;

  /// No description provided for @selectService.
  ///
  /// In en, this message translates to:
  /// **'Select Service'**
  String get selectService;

  /// No description provided for @selectDay.
  ///
  /// In en, this message translates to:
  /// **'Select Day'**
  String get selectDay;

  /// No description provided for @selectAvailableTimeSlot.
  ///
  /// In en, this message translates to:
  /// **'Select Available Time Slot'**
  String get selectAvailableTimeSlot;

  /// No description provided for @chooseYourTimeRange.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Time Range'**
  String get chooseYourTimeRange;

  /// No description provided for @confirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get confirmBooking;

  /// No description provided for @selectTimeRange.
  ///
  /// In en, this message translates to:
  /// **'Select Time Range'**
  String get selectTimeRange;

  /// No description provided for @uniformPricing.
  ///
  /// In en, this message translates to:
  /// **'Uniform Pricing: 3,000 FCFA base (4h)'**
  String get uniformPricing;

  /// No description provided for @availableForBooking.
  ///
  /// In en, this message translates to:
  /// **'Available for booking'**
  String get availableForBooking;

  /// No description provided for @availableFromTo.
  ///
  /// In en, this message translates to:
  /// **'Available from {start} to {end}'**
  String availableFromTo(String start, String end);

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time *'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End Time:'**
  String get endTime;

  /// No description provided for @bookingSummary.
  ///
  /// In en, this message translates to:
  /// **'Booking Summary'**
  String get bookingSummary;

  /// No description provided for @service.
  ///
  /// In en, this message translates to:
  /// **'Service:'**
  String get service;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day:'**
  String get day;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @sessionPricing.
  ///
  /// In en, this message translates to:
  /// **'Session Pricing:'**
  String get sessionPricing;

  /// No description provided for @totalCost.
  ///
  /// In en, this message translates to:
  /// **'Total Cost:'**
  String get totalCost;

  /// No description provided for @providerNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Provider is not available at the selected time. Please choose a different time slot.'**
  String get providerNotAvailable;

  /// No description provided for @failedToCalculatePrice.
  ///
  /// In en, this message translates to:
  /// **'Failed to calculate session price. Please try again.'**
  String get failedToCalculatePrice;

  /// No description provided for @sessionBookedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Session Booked!'**
  String get sessionBookedSuccess;

  /// No description provided for @sessionId.
  ///
  /// In en, this message translates to:
  /// **'Session ID'**
  String get sessionId;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @bookingFailed.
  ///
  /// In en, this message translates to:
  /// **'Booking Failed'**
  String get bookingFailed;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @addReviewFor.
  ///
  /// In en, this message translates to:
  /// **'For {name}'**
  String addReviewFor(String name);

  /// No description provided for @serviceCategory.
  ///
  /// In en, this message translates to:
  /// **'Service Category'**
  String get serviceCategory;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @shareExperience.
  ///
  /// In en, this message translates to:
  /// **'Share your experience with this provider...'**
  String get shareExperience;

  /// No description provided for @pleaseEnterComment.
  ///
  /// In en, this message translates to:
  /// **'Please enter your comment'**
  String get pleaseEnterComment;

  /// No description provided for @commentTooShort.
  ///
  /// In en, this message translates to:
  /// **'Comment must be at least 10 characters long'**
  String get commentTooShort;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// No description provided for @reviewSubmittedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Review submitted successfully!'**
  String get reviewSubmittedSuccess;

  /// No description provided for @failedToSubmitReview.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit review'**
  String get failedToSubmitReview;

  /// No description provided for @timeSlotsAvailable.
  ///
  /// In en, this message translates to:
  /// **'time slots available'**
  String get timeSlotsAvailable;

  /// No description provided for @processingBooking.
  ///
  /// In en, this message translates to:
  /// **'Processing your booking...'**
  String get processingBooking;

  /// No description provided for @addService.
  ///
  /// In en, this message translates to:
  /// **'Add Service'**
  String get addService;

  /// No description provided for @manageYourServices.
  ///
  /// In en, this message translates to:
  /// **'Manage your services'**
  String get manageYourServices;

  /// No description provided for @allServices.
  ///
  /// In en, this message translates to:
  /// **'All Services'**
  String get allServices;

  /// No description provided for @untitledService.
  ///
  /// In en, this message translates to:
  /// **'Untitled Service'**
  String get untitledService;

  /// No description provided for @loadingYourServices.
  ///
  /// In en, this message translates to:
  /// **'Loading your services...'**
  String get loadingYourServices;

  /// No description provided for @failedToLoadServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Failed to Load Services'**
  String get failedToLoadServicesTitle;

  /// No description provided for @noServicesYet.
  ///
  /// In en, this message translates to:
  /// **'No Services Yet'**
  String get noServicesYet;

  /// No description provided for @addFirstServiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start by adding your first service to attract customers and grow your business'**
  String get addFirstServiceSubtitle;

  /// No description provided for @pullToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull down to refresh'**
  String get pullToRefresh;

  /// No description provided for @addYourFirstService.
  ///
  /// In en, this message translates to:
  /// **'Add Your First Service'**
  String get addYourFirstService;

  /// No description provided for @editService.
  ///
  /// In en, this message translates to:
  /// **'Edit Service'**
  String get editService;

  /// No description provided for @markUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Mark Unavailable'**
  String get markUnavailable;

  /// No description provided for @markAvailable.
  ///
  /// In en, this message translates to:
  /// **'Mark Available'**
  String get markAvailable;

  /// No description provided for @deleteService.
  ///
  /// In en, this message translates to:
  /// **'Delete Service'**
  String get deleteService;

  /// No description provided for @deleteServiceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"?\n\nThis action cannot be undone and will remove all associated bookings.'**
  String deleteServiceConfirm(Object title);

  /// No description provided for @serviceDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Service deleted successfully'**
  String get serviceDeletedSuccess;

  /// No description provided for @failedToDeleteService.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete service: {error}'**
  String failedToDeleteService(Object error);

  /// No description provided for @errorDeletingService.
  ///
  /// In en, this message translates to:
  /// **'Error deleting service: {error}'**
  String errorDeletingService(Object error);

  /// No description provided for @serviceMarkedAs.
  ///
  /// In en, this message translates to:
  /// **'Service marked as {status}'**
  String serviceMarkedAs(Object status);

  /// No description provided for @failedToUpdateService.
  ///
  /// In en, this message translates to:
  /// **'Failed to update service: {error}'**
  String failedToUpdateService(Object error);

  /// No description provided for @errorUpdatingService.
  ///
  /// In en, this message translates to:
  /// **'Error updating service: {error}'**
  String errorUpdatingService(Object error);

  /// No description provided for @navigationError.
  ///
  /// In en, this message translates to:
  /// **'Navigation error: {error}'**
  String navigationError(Object error);

  /// No description provided for @errorOpeningEditScreen.
  ///
  /// In en, this message translates to:
  /// **'Error opening edit screen: {error}'**
  String errorOpeningEditScreen(Object error);

  /// No description provided for @noStatusServices.
  ///
  /// In en, this message translates to:
  /// **'No {status} Services'**
  String noStatusServices(Object status);

  /// No description provided for @noStatusServicesMessage.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any {status} services at the moment.'**
  String noStatusServicesMessage(Object status);

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @findServiceProviders.
  ///
  /// In en, this message translates to:
  /// **'Find Service Providers'**
  String get findServiceProviders;

  /// No description provided for @yourLocation.
  ///
  /// In en, this message translates to:
  /// **'Your Location'**
  String get yourLocation;

  /// No description provided for @providersFound.
  ///
  /// In en, this message translates to:
  /// **'providers found'**
  String get providersFound;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @basePlusOvertime.
  ///
  /// In en, this message translates to:
  /// **'Base: {base} + Overtime: {overtime}'**
  String basePlusOvertime(Object base, Object overtime);

  /// No description provided for @startService.
  ///
  /// In en, this message translates to:
  /// **'Start Service'**
  String get startService;

  /// No description provided for @markComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark Complete'**
  String get markComplete;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @loadingYourBookings.
  ///
  /// In en, this message translates to:
  /// **'Loading your bookings...'**
  String get loadingYourBookings;

  /// No description provided for @failedToLoadSessionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Failed to Load Sessions'**
  String get failedToLoadSessionsTitle;

  /// No description provided for @noSessionsYet.
  ///
  /// In en, this message translates to:
  /// **'No Sessions Yet'**
  String get noSessionsYet;

  /// No description provided for @noSessionsYetDescription.
  ///
  /// In en, this message translates to:
  /// **'When customers book your services, they will appear here. Start by adding services to attract bookings!'**
  String get noSessionsYetDescription;

  /// No description provided for @noStatusSessions.
  ///
  /// In en, this message translates to:
  /// **'No {status} Sessions'**
  String noStatusSessions(Object status);

  /// No description provided for @noStatusSessionsMessage.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any {status} bookings at the moment.'**
  String noStatusSessionsMessage(Object status);

  /// No description provided for @sessionDeclinedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Session declined successfully'**
  String get sessionDeclinedSuccess;

  /// No description provided for @failedToDeclineSession.
  ///
  /// In en, this message translates to:
  /// **'Failed to decline session: {error}'**
  String failedToDeclineSession(Object error);

  /// No description provided for @sessionUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Session {status} successfully'**
  String sessionUpdatedSuccess(Object status);

  /// No description provided for @failedToUpdateSession.
  ///
  /// In en, this message translates to:
  /// **'Failed to update session: {error}'**
  String failedToUpdateSession(Object error);

  /// No description provided for @errorUpdatingSession.
  ///
  /// In en, this message translates to:
  /// **'Error updating session: {error}'**
  String errorUpdatingSession(Object error);

  /// No description provided for @manageYourSessions.
  ///
  /// In en, this message translates to:
  /// **'Manage your sessions'**
  String get manageYourSessions;

  /// No description provided for @loadingYourSchedule.
  ///
  /// In en, this message translates to:
  /// **'Loading your schedule...'**
  String get loadingYourSchedule;

  /// No description provided for @failedToLoadAvailabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Failed to Load Availability'**
  String get failedToLoadAvailabilityTitle;

  /// No description provided for @availabilityManager.
  ///
  /// In en, this message translates to:
  /// **'Availability Manager'**
  String get availabilityManager;

  /// No description provided for @setWeeklySchedule.
  ///
  /// In en, this message translates to:
  /// **'Set your weekly schedule with smart tools'**
  String get setWeeklySchedule;

  /// No description provided for @totalHours.
  ///
  /// In en, this message translates to:
  /// **'Total Hours'**
  String get totalHours;

  /// No description provided for @daysSet.
  ///
  /// In en, this message translates to:
  /// **'Days Set'**
  String get daysSet;

  /// No description provided for @weekView.
  ///
  /// In en, this message translates to:
  /// **'Week View'**
  String get weekView;

  /// No description provided for @timeGrid.
  ///
  /// In en, this message translates to:
  /// **'Time Grid'**
  String get timeGrid;

  /// No description provided for @quickSetup.
  ///
  /// In en, this message translates to:
  /// **'Quick Setup'**
  String get quickSetup;

  /// No description provided for @copyMonday.
  ///
  /// In en, this message translates to:
  /// **'Copy Monday'**
  String get copyMonday;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @businessHours.
  ///
  /// In en, this message translates to:
  /// **'Business Hours'**
  String get businessHours;

  /// No description provided for @weekendOnly.
  ///
  /// In en, this message translates to:
  /// **'Weekend Only'**
  String get weekendOnly;

  /// No description provided for @defaultNineToFive.
  ///
  /// In en, this message translates to:
  /// **'Default 9-5'**
  String get defaultNineToFive;

  /// No description provided for @addTimeSlot.
  ///
  /// In en, this message translates to:
  /// **'Add time slot'**
  String get addTimeSlot;

  /// No description provided for @timeSlotsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} time slot(s)'**
  String timeSlotsCount(Object count);

  /// No description provided for @noAvailabilitySet.
  ///
  /// In en, this message translates to:
  /// **'No availability set'**
  String get noAvailabilitySet;

  /// No description provided for @noTimeSlotsSet.
  ///
  /// In en, this message translates to:
  /// **'No time slots set'**
  String get noTimeSlotsSet;

  /// No description provided for @tapToAddFirstSlot.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first time slot'**
  String get tapToAddFirstSlot;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteTimeSlot.
  ///
  /// In en, this message translates to:
  /// **'Delete Time Slot'**
  String get deleteTimeSlot;

  /// No description provided for @deleteTimeSlotConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the time slot {start} - {end}?'**
  String deleteTimeSlotConfirm(Object end, Object start);

  /// No description provided for @deleteThisSlot.
  ///
  /// In en, this message translates to:
  /// **'Delete This Slot'**
  String get deleteThisSlot;

  /// No description provided for @deleteEntireDay.
  ///
  /// In en, this message translates to:
  /// **'Delete Entire Day'**
  String get deleteEntireDay;

  /// No description provided for @copyScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Copy Schedule'**
  String get copyScheduleTitle;

  /// No description provided for @copyScheduleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Copy {day}\'s schedule to all other days?'**
  String copyScheduleConfirm(Object day);

  /// No description provided for @scheduleCopiedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Schedule copied to all days successfully!'**
  String get scheduleCopiedSuccess;

  /// No description provided for @failedToCopySchedule.
  ///
  /// In en, this message translates to:
  /// **'Failed to copy schedule: {error}'**
  String failedToCopySchedule(Object error);

  /// No description provided for @clearAllAvailabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear All Availability'**
  String get clearAllAvailabilityTitle;

  /// No description provided for @clearAllAvailabilityConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will remove all your availability settings. Are you sure?'**
  String get clearAllAvailabilityConfirm;

  /// No description provided for @setDefaultAvailabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Default Availability'**
  String get setDefaultAvailabilityTitle;

  /// No description provided for @setDefaultAvailabilityConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will set Monday-Friday 9 AM to 5 PM availability. Any existing availability will be replaced.'**
  String get setDefaultAvailabilityConfirm;

  /// No description provided for @setDefault.
  ///
  /// In en, this message translates to:
  /// **'Set Default'**
  String get setDefault;

  /// No description provided for @defaultAvailabilitySetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Default availability set successfully!'**
  String get defaultAvailabilitySetSuccess;

  /// No description provided for @failedToSetDefaultAvailability.
  ///
  /// In en, this message translates to:
  /// **'Failed to set default availability: {error}'**
  String failedToSetDefaultAvailability(Object error);

  /// No description provided for @errorSettingDefaultAvailability.
  ///
  /// In en, this message translates to:
  /// **'Error setting default availability: {error}'**
  String errorSettingDefaultAvailability(Object error);

  /// No description provided for @pleaseSelectAtLeastOneDay.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one day'**
  String get pleaseSelectAtLeastOneDay;

  /// No description provided for @sourceDayHasNoAvailability.
  ///
  /// In en, this message translates to:
  /// **'Source day has no availability to copy'**
  String get sourceDayHasNoAvailability;

  /// No description provided for @allAvailabilityClearedSuccess.
  ///
  /// In en, this message translates to:
  /// **'All availability cleared successfully!'**
  String get allAvailabilityClearedSuccess;

  /// No description provided for @failedToClearAvailability.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear availability: {error}'**
  String failedToClearAvailability(String error);

  /// No description provided for @errorNoAvailabilityData.
  ///
  /// In en, this message translates to:
  /// **'Error: No availability data found for this day'**
  String get errorNoAvailabilityData;

  /// No description provided for @errorCannotFindAvailabilityId.
  ///
  /// In en, this message translates to:
  /// **'Error: Cannot find availability ID'**
  String get errorCannotFindAvailabilityId;

  /// No description provided for @deleteAllAvailabilityForDay.
  ///
  /// In en, this message translates to:
  /// **'Delete all availability for {day}?\\n\\nThis will remove all time slots for this day.'**
  String deleteAllAvailabilityForDay(String day);

  /// No description provided for @deleteEntireDayButton.
  ///
  /// In en, this message translates to:
  /// **'Delete Day'**
  String get deleteEntireDayButton;

  /// No description provided for @timeSlotDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Time slot deleted successfully'**
  String get timeSlotDeletedSuccess;

  /// No description provided for @failedToDeleteTimeSlot.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete time slot: {error}'**
  String failedToDeleteTimeSlot(String error);

  /// No description provided for @errorDeletingTimeSlot.
  ///
  /// In en, this message translates to:
  /// **'Error deleting time slot: {error}'**
  String errorDeletingTimeSlot(String error);

  /// No description provided for @dayAvailabilityDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Day availability deleted successfully'**
  String get dayAvailabilityDeletedSuccess;

  /// No description provided for @failedToDeleteDay.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete day: {error}'**
  String failedToDeleteDay(String error);

  /// No description provided for @errorDeletingDay.
  ///
  /// In en, this message translates to:
  /// **'Error deleting day: {error}'**
  String errorDeletingDay(String error);

  /// No description provided for @setViaQuickSetup.
  ///
  /// In en, this message translates to:
  /// **'Set via Quick Setup'**
  String get setViaQuickSetup;

  /// No description provided for @quickSetupCompletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Quick setup completed successfully!'**
  String get quickSetupCompletedSuccess;

  /// No description provided for @default95.
  ///
  /// In en, this message translates to:
  /// **'Default 9-5'**
  String get default95;

  /// No description provided for @deleteTimeSlotFor.
  ///
  /// In en, this message translates to:
  /// **'Delete time slot {start} - {end} for {day}?'**
  String deleteTimeSlotFor(String start, String end, String day);

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @selectDays.
  ///
  /// In en, this message translates to:
  /// **'Select Days'**
  String get selectDays;

  /// No description provided for @quickSetupCompleted.
  ///
  /// In en, this message translates to:
  /// **'Quick setup completed successfully!'**
  String get quickSetupCompleted;

  /// No description provided for @errorDuringSetup.
  ///
  /// In en, this message translates to:
  /// **'Error during setup: {error}'**
  String errorDuringSetup(Object error);

  /// No description provided for @enableLocation.
  ///
  /// In en, this message translates to:
  /// **'Enable Location'**
  String get enableLocation;

  /// No description provided for @locationPermissionDescription.
  ///
  /// In en, this message translates to:
  /// **'We need access to your location to show nearby service providers and enable GPS tracking when you book services.'**
  String get locationPermissionDescription;

  /// No description provided for @findNearbyProviders.
  ///
  /// In en, this message translates to:
  /// **'Find nearby service providers'**
  String get findNearbyProviders;

  /// No description provided for @realTimeTracking.
  ///
  /// In en, this message translates to:
  /// **'Real-time service tracking'**
  String get realTimeTracking;

  /// No description provided for @accurateDirections.
  ///
  /// In en, this message translates to:
  /// **'Accurate service locations'**
  String get accurateDirections;

  /// No description provided for @allowLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow Location Access'**
  String get allowLocation;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location Services Disabled'**
  String get locationServicesDisabled;

  /// No description provided for @enableLocationServices.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled. Please enable them in your device settings to use location features.'**
  String get enableLocationServices;

  /// No description provided for @locationPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Location access permanently denied. Please enable it in app settings.'**
  String get locationPermanentlyDenied;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location access denied. Some features may not work properly.'**
  String get locationDenied;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'re here to help!'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Find trusted service providers in your area'**
  String get welcomeDescription;

  /// No description provided for @homeAideServices.
  ///
  /// In en, this message translates to:
  /// **'HOME AIDE Services'**
  String get homeAideServices;

  /// No description provided for @iAm.
  ///
  /// In en, this message translates to:
  /// **'I am'**
  String get iAm;

  /// No description provided for @iOfferProfessionalServices.
  ///
  /// In en, this message translates to:
  /// **'I offer professional services.'**
  String get iOfferProfessionalServices;

  /// No description provided for @pricingInformation.
  ///
  /// In en, this message translates to:
  /// **'Pricing Information'**
  String get pricingInformation;

  /// No description provided for @deepCleaningAllRooms.
  ///
  /// In en, this message translates to:
  /// **'Deep cleaning of all rooms'**
  String get deepCleaningAllRooms;

  /// No description provided for @kitchenBathroomSanitization.
  ///
  /// In en, this message translates to:
  /// **'Kitchen and bathroom sanitization'**
  String get kitchenBathroomSanitization;

  /// No description provided for @floorMoppingVacuuming.
  ///
  /// In en, this message translates to:
  /// **'Floor mopping and vacuuming'**
  String get floorMoppingVacuuming;

  /// No description provided for @dustRemovalSurfaces.
  ///
  /// In en, this message translates to:
  /// **'Dust removal from surfaces'**
  String get dustRemovalSurfaces;

  /// No description provided for @trashRemoval.
  ///
  /// In en, this message translates to:
  /// **'Trash removal'**
  String get trashRemoval;

  /// No description provided for @leakDetectionRepair.
  ///
  /// In en, this message translates to:
  /// **'Leak detection and repair'**
  String get leakDetectionRepair;

  /// No description provided for @pipeInstallationReplacement.
  ///
  /// In en, this message translates to:
  /// **'Pipe installation and replacement'**
  String get pipeInstallationReplacement;

  /// No description provided for @toiletSinkRepairs.
  ///
  /// In en, this message translates to:
  /// **'Toilet and sink repairs'**
  String get toiletSinkRepairs;

  /// No description provided for @drainCleaningUnclogging.
  ///
  /// In en, this message translates to:
  /// **'Drain cleaning and unclogging'**
  String get drainCleaningUnclogging;

  /// No description provided for @waterHeaterMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Water heater maintenance'**
  String get waterHeaterMaintenance;

  /// No description provided for @emergencyPlumbingServices.
  ///
  /// In en, this message translates to:
  /// **'Emergency plumbing services'**
  String get emergencyPlumbingServices;

  /// No description provided for @wiringInstallationRepair.
  ///
  /// In en, this message translates to:
  /// **'Wiring installation and repair'**
  String get wiringInstallationRepair;

  /// No description provided for @lightFixtureInstallation.
  ///
  /// In en, this message translates to:
  /// **'Light fixture installation'**
  String get lightFixtureInstallation;

  /// No description provided for @socketSwitchReplacement.
  ///
  /// In en, this message translates to:
  /// **'Socket and switch replacement'**
  String get socketSwitchReplacement;

  /// No description provided for @circuitBreakerMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Circuit breaker maintenance'**
  String get circuitBreakerMaintenance;

  /// No description provided for @electricalSafetyInspections.
  ///
  /// In en, this message translates to:
  /// **'Electrical safety inspections'**
  String get electricalSafetyInspections;

  /// No description provided for @emergencyElectricalServices.
  ///
  /// In en, this message translates to:
  /// **'Emergency electrical services'**
  String get emergencyElectricalServices;

  /// No description provided for @surfacePreparationPriming.
  ///
  /// In en, this message translates to:
  /// **'Surface preparation and priming'**
  String get surfacePreparationPriming;

  /// No description provided for @interiorExteriorPainting.
  ///
  /// In en, this message translates to:
  /// **'Interior and exterior painting'**
  String get interiorExteriorPainting;

  /// No description provided for @wallTextureRepair.
  ///
  /// In en, this message translates to:
  /// **'Wall texture repair'**
  String get wallTextureRepair;

  /// No description provided for @paintColorConsultation.
  ///
  /// In en, this message translates to:
  /// **'Paint color consultation'**
  String get paintColorConsultation;

  /// No description provided for @qualityPaintMaterials.
  ///
  /// In en, this message translates to:
  /// **'Quality paint and materials'**
  String get qualityPaintMaterials;

  /// No description provided for @lawnMowingTrimming.
  ///
  /// In en, this message translates to:
  /// **'Lawn mowing and trimming'**
  String get lawnMowingTrimming;

  /// No description provided for @plantCareMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Plant care and maintenance'**
  String get plantCareMaintenance;

  /// No description provided for @gardenDesignLayout.
  ///
  /// In en, this message translates to:
  /// **'Garden design and layout'**
  String get gardenDesignLayout;

  /// No description provided for @pestControlPlants.
  ///
  /// In en, this message translates to:
  /// **'Pest control for plants'**
  String get pestControlPlants;

  /// No description provided for @seasonalPlanting.
  ///
  /// In en, this message translates to:
  /// **'Seasonal planting'**
  String get seasonalPlanting;

  /// No description provided for @gardenCleanupMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Garden cleanup and maintenance'**
  String get gardenCleanupMaintenance;

  /// No description provided for @customFurnitureCreation.
  ///
  /// In en, this message translates to:
  /// **'Custom furniture creation'**
  String get customFurnitureCreation;

  /// No description provided for @furnitureRepairRestoration.
  ///
  /// In en, this message translates to:
  /// **'Furniture repair and restoration'**
  String get furnitureRepairRestoration;

  /// No description provided for @cabinetInstallation.
  ///
  /// In en, this message translates to:
  /// **'Cabinet installation'**
  String get cabinetInstallation;

  /// No description provided for @doorWindowFrameWork.
  ///
  /// In en, this message translates to:
  /// **'Door and window frame work'**
  String get doorWindowFrameWork;

  /// No description provided for @shelvingStorageSolutions.
  ///
  /// In en, this message translates to:
  /// **'Shelving and storage solutions'**
  String get shelvingStorageSolutions;

  /// No description provided for @woodFinishingStaining.
  ///
  /// In en, this message translates to:
  /// **'Wood finishing and staining'**
  String get woodFinishingStaining;

  /// No description provided for @mealPlanningPreparation.
  ///
  /// In en, this message translates to:
  /// **'Meal planning and preparation'**
  String get mealPlanningPreparation;

  /// No description provided for @groceryShoppingShopping.
  ///
  /// In en, this message translates to:
  /// **'Grocery shopping for ingredients'**
  String get groceryShoppingShopping;

  /// No description provided for @cookingPresentation.
  ///
  /// In en, this message translates to:
  /// **'Cooking and presentation'**
  String get cookingPresentation;

  /// No description provided for @kitchenCleanupAfterService.
  ///
  /// In en, this message translates to:
  /// **'Kitchen cleanup after service'**
  String get kitchenCleanupAfterService;

  /// No description provided for @specialDietaryAccommodations.
  ///
  /// In en, this message translates to:
  /// **'Special dietary accommodations'**
  String get specialDietaryAccommodations;

  /// No description provided for @recipeConsultation.
  ///
  /// In en, this message translates to:
  /// **'Recipe consultation'**
  String get recipeConsultation;

  /// No description provided for @personalizedLessonPlanning.
  ///
  /// In en, this message translates to:
  /// **'Personalized lesson planning'**
  String get personalizedLessonPlanning;

  /// No description provided for @homeworkAssignmentHelp.
  ///
  /// In en, this message translates to:
  /// **'Homework and assignment help'**
  String get homeworkAssignmentHelp;

  /// No description provided for @examPreparation.
  ///
  /// In en, this message translates to:
  /// **'Exam preparation'**
  String get examPreparation;

  /// No description provided for @progressTrackingReports.
  ///
  /// In en, this message translates to:
  /// **'Progress tracking and reports'**
  String get progressTrackingReports;

  /// No description provided for @studyMaterialsResources.
  ///
  /// In en, this message translates to:
  /// **'Study materials and resources'**
  String get studyMaterialsResources;

  /// No description provided for @hairCuttingStyling.
  ///
  /// In en, this message translates to:
  /// **'Hair cutting and styling'**
  String get hairCuttingStyling;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactions;

  /// No description provided for @transactionHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your transaction history will appear here'**
  String get transactionHistoryEmpty;

  /// Shows available balance with amount
  ///
  /// In en, this message translates to:
  /// **'Available Balance: {amount}'**
  String availableBalanceLabel(String amount);

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// Title for service request form
  ///
  /// In en, this message translates to:
  /// **'Request {service}'**
  String requestService(String service);

  /// No description provided for @serviceDetails.
  ///
  /// In en, this message translates to:
  /// **'Service Details'**
  String get serviceDetails;

  /// No description provided for @serviceDate.
  ///
  /// In en, this message translates to:
  /// **'Service Date *'**
  String get serviceDate;

  /// No description provided for @selectDateForService.
  ///
  /// In en, this message translates to:
  /// **'Select date for service'**
  String get selectDateForService;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @selectStartTime.
  ///
  /// In en, this message translates to:
  /// **'Select start time'**
  String get selectStartTime;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get selectTime;

  /// Shows duration in hours
  ///
  /// In en, this message translates to:
  /// **'Duration: {duration} hours'**
  String durationLabel(String duration);

  /// No description provided for @minimumMaximumHours.
  ///
  /// In en, this message translates to:
  /// **'Minimum 0.5 hours, maximum 12 hours'**
  String get minimumMaximumHours;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @province.
  ///
  /// In en, this message translates to:
  /// **'Province *'**
  String get province;

  /// No description provided for @pleaseSelectProvince.
  ///
  /// In en, this message translates to:
  /// **'Please select a province'**
  String get pleaseSelectProvince;

  /// No description provided for @serviceLocation.
  ///
  /// In en, this message translates to:
  /// **'Service Location *'**
  String get serviceLocation;

  /// No description provided for @locationSelected.
  ///
  /// In en, this message translates to:
  /// **'Location selected'**
  String get locationSelected;

  /// No description provided for @gettingLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting location...'**
  String get gettingLocation;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get useCurrentLocation;

  /// No description provided for @selectOnMap.
  ///
  /// In en, this message translates to:
  /// **'Select on map'**
  String get selectOnMap;

  /// No description provided for @additionalInformation.
  ///
  /// In en, this message translates to:
  /// **'Additional Information'**
  String get additionalInformation;

  /// No description provided for @serviceDescription.
  ///
  /// In en, this message translates to:
  /// **'Service Description'**
  String get serviceDescription;

  /// No description provided for @brieflyDescribe.
  ///
  /// In en, this message translates to:
  /// **'Briefly describe what needs to be done'**
  String get brieflyDescribe;

  /// No description provided for @specialInstructions.
  ///
  /// In en, this message translates to:
  /// **'Special Instructions'**
  String get specialInstructions;

  /// No description provided for @anySpecialRequirements.
  ///
  /// In en, this message translates to:
  /// **'Any special requirements or notes'**
  String get anySpecialRequirements;

  /// No description provided for @couponCodeOptional.
  ///
  /// In en, this message translates to:
  /// **'Coupon Code (Optional)'**
  String get couponCodeOptional;

  /// No description provided for @enterCouponCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Coupon Code'**
  String get enterCouponCode;

  /// No description provided for @enterCouponOptional.
  ///
  /// In en, this message translates to:
  /// **'Enter coupon code (optional)'**
  String get enterCouponOptional;

  /// No description provided for @validate.
  ///
  /// In en, this message translates to:
  /// **'Validate'**
  String get validate;

  /// No description provided for @enterCouponDiscount.
  ///
  /// In en, this message translates to:
  /// **'Enter a coupon code to get a discount on your service'**
  String get enterCouponDiscount;

  /// No description provided for @estimatedCost.
  ///
  /// In en, this message translates to:
  /// **'Estimated Cost'**
  String get estimatedCost;

  /// No description provided for @originalAmount.
  ///
  /// In en, this message translates to:
  /// **'Original Amount:'**
  String get originalAmount;

  /// Discount with coupon code
  ///
  /// In en, this message translates to:
  /// **'Discount ({code}):'**
  String discount(String code);

  /// No description provided for @finalAmount.
  ///
  /// In en, this message translates to:
  /// **'Final Amount:'**
  String get finalAmount;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total:'**
  String get total;

  /// Shows hours of service
  ///
  /// In en, this message translates to:
  /// **'For {duration} hours of service'**
  String forHoursOfService(String duration);

  /// Base price information
  ///
  /// In en, this message translates to:
  /// **'Base price: {price} FCFA (4 hours)'**
  String basePriceInfo(int price);

  /// Overtime charges
  ///
  /// In en, this message translates to:
  /// **'Overtime: {amount} FCFA ({hours} extra hours)'**
  String overtimeInfo(int amount, String hours);

  /// No description provided for @noOvertimeCharges.
  ///
  /// In en, this message translates to:
  /// **'No overtime charges'**
  String get noOvertimeCharges;

  /// Coupon applied success message
  ///
  /// In en, this message translates to:
  /// **'Coupon \"{code}\" applied successfully!'**
  String couponAppliedSuccess(String code);

  /// No description provided for @submitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submitRequest;

  /// No description provided for @locationPermissionsDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are denied'**
  String get locationPermissionsDenied;

  /// No description provided for @locationPermissionsPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are permanently denied, we cannot request permissions.'**
  String get locationPermissionsPermanentlyDenied;

  /// Current location with coordinates
  ///
  /// In en, this message translates to:
  /// **'Current Location ({lat}, {lng})'**
  String currentLocationLabel(String lat, String lng);

  /// Current location with address
  ///
  /// In en, this message translates to:
  /// **'Current Location: {address}'**
  String currentLocationWithAddress(String address);

  /// No description provided for @currentLocationCaptured.
  ///
  /// In en, this message translates to:
  /// **'Current location captured successfully'**
  String get currentLocationCaptured;

  /// Error getting location
  ///
  /// In en, this message translates to:
  /// **'Failed to get current location: {error}'**
  String failedToGetLocation(String error);

  /// No description provided for @locationSelectedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Location selected successfully'**
  String get locationSelectedSuccess;

  /// Coupon savings message
  ///
  /// In en, this message translates to:
  /// **'Coupon applied! You save {amount} FCFA'**
  String couponSaveAmount(int amount);

  /// No description provided for @invalidCouponCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid coupon code'**
  String get invalidCouponCode;

  /// No description provided for @failedToValidateCoupon.
  ///
  /// In en, this message translates to:
  /// **'Failed to validate coupon'**
  String get failedToValidateCoupon;

  /// Coupon validation error
  ///
  /// In en, this message translates to:
  /// **'Error validating coupon: {error}'**
  String errorValidatingCoupon(String error);

  /// No description provided for @requestSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Request Submitted Successfully'**
  String get requestSubmittedSuccessfully;

  /// Request ID label
  ///
  /// In en, this message translates to:
  /// **'Request ID: {id}'**
  String requestId(String id);

  /// Estimated cost with amount
  ///
  /// In en, this message translates to:
  /// **'Estimated Cost: {amount} FCFA'**
  String estimatedCostAmount(int amount);

  /// No description provided for @adminWillAssignProvider.
  ///
  /// In en, this message translates to:
  /// **'An admin will assign a provider to your request.'**
  String get adminWillAssignProvider;

  /// No description provided for @failedToSubmitRequest.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit request'**
  String get failedToSubmitRequest;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorSubmitting(String error);

  /// No description provided for @myServiceRequests.
  ///
  /// In en, this message translates to:
  /// **'My Service Requests'**
  String get myServiceRequests;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @noServiceRequestsFound.
  ///
  /// In en, this message translates to:
  /// **'No service requests found'**
  String get noServiceRequestsFound;

  /// No description provided for @yourServiceRequestsWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Your service requests will appear here'**
  String get yourServiceRequestsWillAppear;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @trackProvider.
  ///
  /// In en, this message translates to:
  /// **'Track Provider'**
  String get trackProvider;

  /// Created date label
  ///
  /// In en, this message translates to:
  /// **'Created {date}'**
  String createdAt(String date);

  /// Request details dialog title
  ///
  /// In en, this message translates to:
  /// **'Request Details - {category}'**
  String requestDetailsTitle(String category);

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get cost;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @provider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get provider;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @updated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updated;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get cancelRequest;

  /// No description provided for @cancelServiceRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel Service Request'**
  String get cancelServiceRequest;

  /// No description provided for @cancelConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this service request?'**
  String get cancelConfirmation;

  /// No description provided for @reasonForCancellation.
  ///
  /// In en, this message translates to:
  /// **'Reason for cancellation'**
  String get reasonForCancellation;

  /// No description provided for @keepRequest.
  ///
  /// In en, this message translates to:
  /// **'Keep Request'**
  String get keepRequest;

  /// No description provided for @cancelledByUser.
  ///
  /// In en, this message translates to:
  /// **'Cancelled by user'**
  String get cancelledByUser;

  /// No description provided for @serviceRequestCancelledSuccess.
  ///
  /// In en, this message translates to:
  /// **'Service request cancelled successfully'**
  String get serviceRequestCancelledSuccess;

  /// No description provided for @failedToCancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel request'**
  String get failedToCancelRequest;

  /// Error cancelling request
  ///
  /// In en, this message translates to:
  /// **'Error cancelling request: {error}'**
  String errorCancellingRequest(String error);

  /// No description provided for @unableToTrack.
  ///
  /// In en, this message translates to:
  /// **'Unable to track: Invalid session ID'**
  String get unableToTrack;

  /// No description provided for @failedToLoadServiceRequests.
  ///
  /// In en, this message translates to:
  /// **'Failed to load service requests'**
  String get failedToLoadServiceRequests;

  /// Error loading requests
  ///
  /// In en, this message translates to:
  /// **'Error loading service requests: {error}'**
  String errorLoadingServiceRequests(String error);

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// No description provided for @tomorrowLabel.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrowLabel;

  /// No description provided for @yesterdayLabel.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterdayLabel;

  /// No description provided for @todayLowercase.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get todayLowercase;

  /// No description provided for @yesterdayLowercase.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get yesterdayLowercase;

  /// Days ago label
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgoLabel(int days);

  /// No description provided for @invalidDate.
  ///
  /// In en, this message translates to:
  /// **'Invalid Date'**
  String get invalidDate;

  /// No description provided for @dateNotSet.
  ///
  /// In en, this message translates to:
  /// **'Date not set'**
  String get dateNotSet;

  /// No description provided for @na.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get na;

  /// No description provided for @cleaning.
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get cleaning;

  /// No description provided for @plumbing.
  ///
  /// In en, this message translates to:
  /// **'Plumbing'**
  String get plumbing;

  /// No description provided for @electrical.
  ///
  /// In en, this message translates to:
  /// **'Electrical'**
  String get electrical;

  /// No description provided for @painting.
  ///
  /// In en, this message translates to:
  /// **'Painting'**
  String get painting;

  /// No description provided for @gardening.
  ///
  /// In en, this message translates to:
  /// **'Gardening'**
  String get gardening;

  /// No description provided for @carpentry.
  ///
  /// In en, this message translates to:
  /// **'Carpentry'**
  String get carpentry;

  /// No description provided for @cooking.
  ///
  /// In en, this message translates to:
  /// **'Cooking'**
  String get cooking;

  /// No description provided for @tutoring.
  ///
  /// In en, this message translates to:
  /// **'Tutoring'**
  String get tutoring;

  /// No description provided for @beauty.
  ///
  /// In en, this message translates to:
  /// **'Beauty'**
  String get beauty;

  /// No description provided for @maintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get maintenance;

  /// No description provided for @pullDownToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull down to refresh'**
  String get pullDownToRefresh;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
