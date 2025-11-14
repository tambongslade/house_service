import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/state/provider_dashboard_state.dart';
import '../../../features/onboarding/view/onboarding_screen.dart';
import 'provider_profile_screen.dart';
import '../../../../l10n/app_localizations.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context);

    return ChangeNotifierProvider<ProviderDashboardState>(
      create: (_) => ProviderDashboardState()..loadAllDashboardData(),
      child: Consumer<ProviderDashboardState>(
        builder: (context, dashboardState, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.dashboard),
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed:
                      dashboardState.isLoadingDashboard
                          ? null
                          : () => dashboardState.refreshDashboard(),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'profile') {
                      _navigateToProfile(context);
                    } else if (value == 'logout') {
                      await appState.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const OnboardingScreen(),
                          ),
                        );
                      }
                    } else if (value == 'reset') {
                      await appState.resetApp();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const OnboardingScreen(),
                          ),
                        );
                      }
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem<String>(
                        value: 'profile',
                        child: Text(AppLocalizations.of(context)!.myProfile),
                      ),
                      PopupMenuItem<String>(
                        value: 'logout',
                        child: Text(AppLocalizations.of(context)!.logout),
                      ),
                      PopupMenuItem<String>(
                        value: 'reset',
                        child: Text(AppLocalizations.of(context)!.resetApp),
                      ),
                    ];
                  },
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () => dashboardState.refreshDashboard(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dashboard Summary Cards
                    if (dashboardState.isLoadingDashboard)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (dashboardState.dashboardError != null)
                      _buildErrorCard(
                        context,
                        dashboardState.dashboardError!,
                        () => dashboardState.loadDashboardSummary(),
                      )
                    else if (dashboardState.dashboardSummary != null)
                      ..._buildDashboardContent(context, dashboardState),

                    const SizedBox(height: 24),

                    // Wallet Section
                    _buildWalletSection(context, dashboardState),

                    const SizedBox(height: 24),

                    // Recent Activities
                    _buildRecentActivitiesSection(context, dashboardState),

                    const SizedBox(height: 24),

                    // Next Booking
                    if (dashboardState.hasNextBooking)
                      _buildNextBookingSection(context, dashboardState),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildDashboardContent(
    BuildContext context,
    ProviderDashboardState dashboardState,
  ) {
    final theme = Theme.of(context);
    final provider = dashboardState.providerInfo!;
    final statistics = dashboardState.statistics!;

    return [
      // Welcome Header
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.primaryColor,
              theme.primaryColor.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.welcomeBack(provider.fullName),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${provider.averageRating.toStringAsFixed(1)} (${provider.totalReviews} ${AppLocalizations.of(context)!.reviews})',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    AppLocalizations.of(context)!.totalEarned,
                    dashboardState.formatCurrency(provider.totalEarnings),
                    Icons.monetization_on,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    AppLocalizations.of(context)!.thisMonth,
                    '${statistics.thisMonthBookings} ${AppLocalizations.of(context)!.bookings}',
                    Icons.calendar_month,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      const SizedBox(height: 24),

      // Statistics Cards
      Row(
        children: [
          Expanded(
            child: _buildMetricCard(
              context,
              AppLocalizations.of(context)!.activeServices,
              statistics.activeServices.toString(),
              Icons.design_services,
              Colors.purple,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetricCard(
              context,
              AppLocalizations.of(context)!.completed,
              statistics.completedBookings.toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetricCard(
              context,
              AppLocalizations.of(context)!.pending,
              statistics.pendingBookings.toString(),
              Icons.pending,
              Colors.orange,
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWalletSection(
    BuildContext context,
    ProviderDashboardState dashboardState,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.walletBalance,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        if (dashboardState.isLoadingWallet)
          const Center(child: CircularProgressIndicator())
        else if (dashboardState.walletError != null)
          _buildErrorCard(
            context,
            dashboardState.walletError!,
            () => dashboardState.loadWalletInfo(),
          )
        else if (dashboardState.walletBalance != null)
          ..._buildWalletContent(context, dashboardState),
      ],
    );
  }

  List<Widget> _buildWalletContent(
    BuildContext context,
    ProviderDashboardState dashboardState,
  ) {
    final theme = Theme.of(context);
    final balance = dashboardState.walletBalance!;

    return [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.green.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.availableBalance,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              dashboardState.formatCurrency(balance.available),
              style: theme.textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (balance.pending > 0) ...[
              const SizedBox(height: 8),
              Text(
                '${AppLocalizations.of(context)!.pending}: ${dashboardState.formatCurrency(balance.pending)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ],
        ),
      ),

      const SizedBox(height: 16),

      // Wallet Actions
      Row(
        children: [
          Expanded(
            child: _buildWalletActionCard(
              context,
              AppLocalizations.of(context)!.withdraw,
              Icons.account_balance,
              Colors.green,
              balance.available >= 5000
                  ? () => _showWithdrawDialog(context, dashboardState)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildWalletActionCard(
              context,
              AppLocalizations.of(context)!.history,
              Icons.history,
              Colors.blue,
              () => _showTransactionHistory(context, dashboardState),
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildWalletActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: onTap != null ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(
    BuildContext context,
    String error,
    VoidCallback onRetry,
  ) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
          const SizedBox(height: 12),
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red[700]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: Text(AppLocalizations.of(context)!.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitiesSection(
    BuildContext context,
    ProviderDashboardState dashboardState,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.recentActivity,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        if (!dashboardState.hasRecentActivity)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Icon(Icons.history, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.noRecentActivities,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.activitiesWillAppear,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          )
        else
          ...dashboardState.recentActivities
              .take(5)
              .map((activity) => _buildActivityItem(context, activity)),
      ],
    );
  }

  Widget _buildActivityItem(BuildContext context, dynamic activity) {
    final theme = Theme.of(context);

    IconData icon;
    Color color;

    switch (activity.type) {
      case 'booking_completed':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'review_received':
        icon = Icons.star;
        color = Colors.amber;
        break;
      case 'payment_received':
        icon = Icons.monetization_on;
        color = Colors.blue;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (activity.amount != null)
            Text(
              '+${activity.amount} FCFA',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNextBookingSection(
    BuildContext context,
    ProviderDashboardState dashboardState,
  ) {
    final theme = Theme.of(context);
    final booking = dashboardState.nextBooking!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.nextBooking,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.schedule,
                      color: theme.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.serviceTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${AppLocalizations.of(context)!.withText} ${booking.seekerName}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    dashboardState.getTimeUntilNextBooking(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      booking.serviceLocation,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    '${booking.startTime} - ${booking.endTime}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${booking.totalAmount} FCFA',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ProviderProfileScreen()),
    );
  }

  void _showWithdrawDialog(
    BuildContext context,
    ProviderDashboardState dashboardState,
  ) {
    final theme = Theme.of(context);
    final amountController = TextEditingController();
    String selectedMethod = 'bank_transfer';
    final availableBalance = dashboardState.walletBalance?.available ?? 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.account_balance, color: theme.primaryColor),
                  const SizedBox(width: 12),
                  Text(AppLocalizations.of(context)!.withdrawMoney),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.availableBalanceLabel(dashboardState.formatCurrency(availableBalance)),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.amountToWithdraw,
                      hintText: AppLocalizations.of(context)!.enterAmountHint,
                      prefixIcon: const Icon(Icons.money),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedMethod,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.withdrawalMethod,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'bank_transfer',
                        child: Text(AppLocalizations.of(context)!.bankTransfer),
                      ),
                      DropdownMenuItem(
                        value: 'mobile_money',
                        child: Text(AppLocalizations.of(context)!.mobileMoney),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedMethod = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.minimumWithdrawal,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  if (dashboardState.withdrawalError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      dashboardState.withdrawalError!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed:
                      dashboardState.isLoadingWithdrawal
                          ? null
                          : () => _processWithdrawal(
                            context,
                            dashboardState,
                            amountController.text,
                            selectedMethod,
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      dashboardState.isLoadingWithdrawal
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Text(AppLocalizations.of(context)!.withdraw),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _processWithdrawal(
    BuildContext context,
    ProviderDashboardState dashboardState,
    String amountStr,
    String method,
  ) async {
    final amount = int.tryParse(amountStr);

    if (amount == null || amount < 5000) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.validAmountError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // For demo purposes, using dummy payment details
    final paymentDetails = <String, dynamic>{
      if (method == 'bank_transfer')
        'bankDetails': {
          'accountName': 'John Doe',
          'accountNumber': '1234567890',
          'bankName': 'First Bank',
          'swiftCode': 'FBNBCMCX',
        }
      else if (method == 'mobile_money')
        'mobileMoneyDetails': {
          'mobileNumber': '+237123456789',
          'operator': 'MTN',
          'accountName': 'John Doe',
        },
    };

    final success = await dashboardState.requestWithdrawal(
      amount: amount,
      withdrawalMethod: method,
      paymentDetails: paymentDetails,
      notes: 'Dashboard withdrawal request',
    );

    if (context.mounted) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? AppLocalizations.of(context)!.withdrawalSuccess
                : dashboardState.withdrawalError ??
                    AppLocalizations.of(context)!.withdrawalFailed,
          ),
          backgroundColor: success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _showTransactionHistory(
    BuildContext context,
    ProviderDashboardState dashboardState,
  ) {
    final theme = Theme.of(context);
    final transactions = dashboardState.recentTransactions;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.history, color: theme.primaryColor),
                      const SizedBox(width: 12),
                      Text(
                        AppLocalizations.of(context)!.transactionHistory,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child:
                        transactions.isEmpty
                            ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.receipt_long,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    AppLocalizations.of(context)!.noTransactions,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    AppLocalizations.of(context)!.transactionHistoryEmpty,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[500],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              controller: scrollController,
                              itemCount: transactions.length,
                              itemBuilder: (context, index) {
                                final transaction = transactions[index];
                                return _buildTransactionItem(
                                  context,
                                  transaction,
                                );
                              },
                            ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTransactionItem(BuildContext context, dynamic transaction) {
    final theme = Theme.of(context);

    IconData icon;
    Color color;

    switch (transaction.type) {
      case 'earning':
        icon = Icons.add_circle;
        color = Colors.green;
        break;
      case 'withdrawal':
        icon = Icons.remove_circle;
        color = Colors.red;
        break;
      default:
        icon = Icons.monetization_on;
        color = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.status.toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        transaction.status == 'completed'
                            ? Colors.green
                            : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${transaction.type == 'earning' ? '+' : '-'}${transaction.amount} FCFA',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
