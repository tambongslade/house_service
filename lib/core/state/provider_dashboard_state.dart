import 'package:flutter/foundation.dart';
import '../models/provider_models.dart';
import '../services/api_service.dart';

class ProviderDashboardState extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _disposed = false;

  // Dashboard data
  DashboardSummary? _dashboardSummary;
  WalletInfo? _walletInfo;
  UpcomingBookingsResponse? _upcomingBookings;

  // Loading states
  bool _isLoadingDashboard = false;
  bool _isLoadingWallet = false;
  bool _isLoadingUpcomingBookings = false;
  bool _isLoadingWithdrawal = false;

  // Error states
  String? _dashboardError;
  String? _walletError;
  String? _upcomingBookingsError;
  String? _withdrawalError;

  // Getters
  DashboardSummary? get dashboardSummary => _dashboardSummary;
  WalletInfo? get walletInfo => _walletInfo;
  UpcomingBookingsResponse? get upcomingBookings => _upcomingBookings;

  bool get isLoadingDashboard => _isLoadingDashboard;
  bool get isLoadingWallet => _isLoadingWallet;
  bool get isLoadingUpcomingBookings => _isLoadingUpcomingBookings;
  bool get isLoadingWithdrawal => _isLoadingWithdrawal;

  String? get dashboardError => _dashboardError;
  String? get walletError => _walletError;
  String? get upcomingBookingsError => _upcomingBookingsError;
  String? get withdrawalError => _withdrawalError;

  // Computed getters for easy access to dashboard data
  ProviderInfo? get providerInfo => _dashboardSummary?.provider;
  DashboardStatistics? get statistics => _dashboardSummary?.statistics;
  NextBooking? get nextBooking => _dashboardSummary?.nextBooking;
  List<RecentActivity> get recentActivities =>
      _dashboardSummary?.recentActivities ?? [];

  WalletBalance? get walletBalance => _walletInfo?.balance;
  // Prefer wallet balance from dashboard provider info when wallet API is not used
  // Falls back to wallet API balance if available
  // Currency defaults to FCFA per app conventions
  WalletBalance? get walletBalanceOrDerived {
    if (_walletInfo?.balance != null) {
      return _walletInfo!.balance;
    }
    final provider = _dashboardSummary?.provider;
    if (provider != null) {
      return WalletBalance(
        available: provider.availableBalance,
        pending: provider.pendingBalance,
        total: provider.availableBalance + provider.pendingBalance,
        currency: 'FCFA',
      );
    }
    return null;
  }

  List<WalletTransaction> get recentTransactions =>
      _walletInfo?.recentTransactions ?? [];

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // Load dashboard summary
  Future<void> loadDashboardSummary() async {
    _isLoadingDashboard = true;
    _dashboardError = null;
    if (!_disposed) notifyListeners();

    try {
      final response = await _apiService.getProviderDashboardSummary();

      if (response.isSuccess && response.data != null) {
        _dashboardSummary = DashboardSummary.fromJson(response.data!);
        _dashboardError = null;
      } else {
        _dashboardError = response.error ?? 'Failed to load dashboard data';
      }
    } catch (e) {
      _dashboardError = 'Error loading dashboard: $e';
      print('Dashboard loading error: $e');
    } finally {
      _isLoadingDashboard = false;
      if (!_disposed) notifyListeners();
    }
  }

  // Load wallet information
  Future<void> loadWalletInfo() async {
    _isLoadingWallet = true;
    _walletError = null;
    if (!_disposed) notifyListeners();

    try {
      final response = await _apiService.getProviderWallet();

      if (response.isSuccess && response.data != null) {
        _walletInfo = WalletInfo.fromJson(response.data!);
        _walletError = null;
      } else {
        _walletError = response.error ?? 'Failed to load wallet data';
      }
    } catch (e) {
      _walletError = 'Error loading wallet: $e';
      print('Wallet loading error: $e');
    } finally {
      _isLoadingWallet = false;
      if (!_disposed) notifyListeners();
    }
  }

  // Load upcoming bookings
  Future<void> loadUpcomingBookings({int limit = 5, int days = 7}) async {
    _isLoadingUpcomingBookings = true;
    _upcomingBookingsError = null;
    if (!_disposed) notifyListeners();

    try {
      final response = await _apiService.getProviderUpcomingBookings(
        limit: limit,
        days: days,
      );

      if (response.isSuccess && response.data != null) {
        _upcomingBookings = UpcomingBookingsResponse.fromJson(response.data!);
        _upcomingBookingsError = null;
      } else {
        _upcomingBookingsError =
            response.error ?? 'Failed to load upcoming bookings';
      }
    } catch (e) {
      _upcomingBookingsError = 'Error loading upcoming bookings: $e';
      print('Upcoming bookings loading error: $e');
    } finally {
      _isLoadingUpcomingBookings = false;
      if (!_disposed) notifyListeners();
    }
  }

  // Request withdrawal
  Future<bool> requestWithdrawal({
    required int amount,
    required String withdrawalMethod,
    required Map<String, dynamic> paymentDetails,
    String? notes,
  }) async {
    _isLoadingWithdrawal = true;
    _withdrawalError = null;
    if (!_disposed) notifyListeners();

    try {
      final response = await _apiService.requestWithdrawal(
        amount: amount,
        withdrawalMethod: withdrawalMethod,
        paymentDetails: paymentDetails,
        notes: notes,
      );

      if (response.isSuccess) {
        // Reload wallet info to get updated balance
        await loadWalletInfo();
        _withdrawalError = null;
        return true;
      } else {
        _withdrawalError = response.error ?? 'Failed to request withdrawal';
        return false;
      }
    } catch (e) {
      _withdrawalError = 'Error requesting withdrawal: $e';
      print('Withdrawal request error: $e');
      return false;
    } finally {
      _isLoadingWithdrawal = false;
      if (!_disposed) notifyListeners();
    }
  }

  // Load all dashboard data at once
  Future<void> loadAllDashboardData() async {
    await Future.wait([
      loadDashboardSummary(),
      // Wallet info is derived from dashboard summary to avoid extra API calls
      loadUpcomingBookings(),
    ]);
  }

  // Refresh all data
  Future<void> refreshDashboard() async {
    await loadAllDashboardData();
  }

  // Clear errors
  void clearDashboardError() {
    _dashboardError = null;
    if (!_disposed) notifyListeners();
  }

  void clearWalletError() {
    _walletError = null;
    if (!_disposed) notifyListeners();
  }

  void clearUpcomingBookingsError() {
    _upcomingBookingsError = null;
    if (!_disposed) notifyListeners();
  }

  void clearWithdrawalError() {
    _withdrawalError = null;
    if (!_disposed) notifyListeners();
  }

  void clearAllErrors() {
    _dashboardError = null;
    _walletError = null;
    _upcomingBookingsError = null;
    _withdrawalError = null;
    if (!_disposed) notifyListeners();
  }

  // Format currency for display
  String formatCurrency(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} FCFA';
  }

  // Helper method to get earnings growth display
  String getEarningsGrowthDisplay() {
    final growth = statistics?.monthlyEarningsGrowth ?? 0.0;
    final sign = growth >= 0 ? '+' : '';
    return '$sign${growth.toStringAsFixed(1)}%';
  }

  // Helper method to get bookings growth display
  String getBookingsGrowthDisplay() {
    final growth = statistics?.weeklyBookingsGrowth ?? 0.0;
    final sign = growth >= 0 ? '+' : '';
    return '$sign${growth.toStringAsFixed(1)}%';
  }

  // Helper method to check if provider has any activity
  bool get hasRecentActivity => recentActivities.isNotEmpty;
  bool get hasNextBooking => nextBooking != null;
  bool get hasWalletBalance => (walletBalance?.available ?? 0) > 0;

  // Helper method to get time until next booking
  String getTimeUntilNextBooking() {
    if (nextBooking == null) return '';

    final now = DateTime.now();
    final bookingDateTime = DateTime(
      nextBooking!.bookingDate.year,
      nextBooking!.bookingDate.month,
      nextBooking!.bookingDate.day,
      int.parse(nextBooking!.startTime.split(':')[0]),
      int.parse(nextBooking!.startTime.split(':')[1]),
    );

    final difference = bookingDateTime.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'}';
    } else {
      return 'Now';
    }
  }
}
