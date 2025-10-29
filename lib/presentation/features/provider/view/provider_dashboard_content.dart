import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/provider_dashboard_state.dart';
import '../../../../core/state/app_state.dart';
import '../../../../l10n/app_localizations.dart';

// Dashboard content without AppBar (to avoid double AppBars)
class ProviderDashboardContent extends StatefulWidget {
  const ProviderDashboardContent({super.key});

  @override
  State<ProviderDashboardContent> createState() =>
      _ProviderDashboardContentState();
}

class _ProviderDashboardContentState extends State<ProviderDashboardContent> 
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;
  ProviderDashboardState? _dashboardState;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _dashboardState = ProviderDashboardState();
    _dashboardState!.loadAllDashboardData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController!, curve: Curves.easeOutCubic));
    
    _animationController!.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _dashboardState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_dashboardState == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return ChangeNotifierProvider<ProviderDashboardState>.value(
      value: _dashboardState!,
      child: Consumer<ProviderDashboardState>(
        builder: (context, dashboardState, child) {
          if (dashboardState.isLoadingDashboard) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (dashboardState.dashboardError != null) {
            final l10n = AppLocalizations.of(context)!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(dashboardState.dashboardError!, style: TextStyle(color: Colors.red[600])),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => dashboardState.loadDashboardSummary(),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          final provider = dashboardState.providerInfo;
          final statistics = dashboardState.statistics;
          final nextBooking = dashboardState.nextBooking;
          final l10n = AppLocalizations.of(context)!;

          final content = RefreshIndicator(
            onRefresh: () => dashboardState.refreshDashboard(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Message
                  if (provider != null)
                    _buildWelcomeMessage(provider.fullName, l10n),
                  const SizedBox(height: 24),

                  // Wallet/Balance Card
                  if (provider != null)
                    _buildWalletCard(dashboardState, l10n),
                  const SizedBox(height: 32),

                  // Overview Section
                  if (statistics != null)
                    _buildOverviewSection(statistics, l10n),
                  const SizedBox(height: 32),

                  // Next Booking Section
                  if (nextBooking != null) ...[
                    _buildNextBookingSection(nextBooking, dashboardState, l10n),
                    const SizedBox(height: 32),
                  ],

                  // Recent Activity
                  _buildActivitySection(dashboardState, l10n),
                ],
              ),
            ),
          );

          // Return animated content if animations are available, otherwise return content directly
          if (_fadeAnimation != null && _slideAnimation != null) {
            return FadeTransition(
              opacity: _fadeAnimation!,
              child: SlideTransition(
                position: _slideAnimation!,
                child: content,
              ),
            );
          } else {
            return content;
          }
        },
      ),
    );
  }

  Widget _buildWelcomeMessage(String providerName, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.waving_hand,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.welcomeBack(providerName),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.readyToManage,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard(ProviderDashboardState dashboardState, AppLocalizations l10n) {
    final provider = dashboardState.providerInfo!;
    final availableBalance = provider.availableBalance;
    final pendingBalance = provider.pendingBalance;
    final totalEarnings = provider.totalEarnings;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.walletBalance,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        dashboardState.formatCurrency(availableBalance),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.pending,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        Text(
                          dashboardState.formatCurrency(pendingBalance),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l10n.totalEarned,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        Text(
                          dashboardState.formatCurrency(totalEarnings),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showWithdrawalDialog(context, dashboardState, l10n),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF667EEA),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.account_balance, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          l10n.withdrawMoney,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(dynamic statistics, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.overview,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: l10n.activeServices,
                value: '${statistics.activeServices ?? 0}',
                icon: Icons.work_outline,
                color: const Color(0xFF3B82F6),
                change: l10n.twoThisMonth,
                isPositive: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: l10n.thisWeek,
                value: '${statistics.thisWeekBookings ?? 0}',
                icon: Icons.calendar_today_outlined,
                color: const Color(0xFF10B981),
                change: '+${((statistics.monthlyEarningsGrowth ?? 0) / 4).toStringAsFixed(1)}%',
                isPositive: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: l10n.thisMonth,
                value: '${statistics.thisMonthBookings ?? 0}',
                icon: Icons.book_online,
                color: const Color(0xFF8B5CF6),
                change: l10n.bookings,
                isPositive: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: l10n.completed,
                value: '${statistics.completedBookings ?? 0}',
                icon: Icons.check_circle_outline,
                color: const Color(0xFF10B981),
                change: l10n.totalJobs,
                isPositive: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String change,
    required bool isPositive,
    String? currency,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                size: 16,
                color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              if (currency != null) ...[
                const SizedBox(width: 4),
                Text(
                  currency,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            change,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextBookingSection(dynamic nextBooking, ProviderDashboardState dashboardState, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.nextBooking,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                // Navigate to bookings screen
              },
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text(l10n.viewAll),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3B82F6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[100]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.schedule,
                      color: Color(0xFF3B82F6),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nextBooking.serviceTitle ?? l10n.service,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${l10n.withText} ${nextBooking.seekerName ?? l10n.customer}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l10n.confirmed,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Text(
                                _formatBookingDate(nextBooking.bookingDate.toIso8601String(), l10n),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Text(
                                '${nextBooking.startTime} - ${nextBooking.endTime}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  nextBooking.serviceLocation ?? l10n.locationNotSpecified,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l10n.earnings,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          dashboardState.formatCurrency(nextBooking.totalAmount ?? 0),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivitySection(ProviderDashboardState dashboardState, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.recentActivity,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                l10n.viewAll,
                style: const TextStyle(
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildRecentActivity(dashboardState, l10n),
      ],
    );
  }

  Widget _buildRecentActivity(ProviderDashboardState dashboardState, AppLocalizations l10n) {
    if (!dashboardState.hasRecentActivity) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.history, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                l10n.noRecentActivities,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.activitiesWillAppear,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildActivityItem(
            icon: Icons.check_circle_outline,
            title: 'Service completed',
            subtitle: 'House cleaning for Sarah Johnson',
            time: '2 hours ago',
            color: const Color(0xFF10B981),
            amount: '+2,500 FCFA',
          ),
          _buildDivider(),
          _buildActivityItem(
            icon: Icons.schedule_outlined,
            title: 'New session confirmed',
            subtitle: 'Plumbing service scheduled for tomorrow',
            time: '5 hours ago',
            color: const Color(0xFF3B82F6),
          ),
          _buildDivider(),
          _buildActivityItem(
            icon: Icons.star_outline,
            title: 'New 5-star review',
            subtitle: '"Excellent service, very professional!"',
            time: '1 day ago',
            color: const Color(0xFFF59E0B),
          ),
          _buildDivider(),
          _buildActivityItem(
            icon: Icons.person_add_outlined,
            title: 'New customer',
            subtitle: 'Mike Anderson joined your services',
            time: '2 days ago',
            color: const Color(0xFF8B5CF6),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: Colors.grey[100],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
    String? amount,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    if (amount != null)
                      Text(
                        amount,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF10B981),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatBookingDate(String? dateStr, AppLocalizations l10n) {
    if (dateStr == null) return l10n.dateNotSet;
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      final bookingDay = DateTime(date.year, date.month, date.day);

      if (bookingDay == DateTime(now.year, now.month, now.day)) {
        return l10n.today;
      } else if (bookingDay == tomorrow) {
        return l10n.tomorrow;
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return l10n.invalidDate;
    }
  }

  void _showWithdrawalDialog(BuildContext context, ProviderDashboardState dashboardState, AppLocalizations l10n) {
    final amountController = TextEditingController();
    String selectedMethod = 'bank_transfer';
    final availableBalance = dashboardState.providerInfo?.availableBalance ?? 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.account_balance,
                        color: Color(0xFF3B82F6),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.withdrawMoney,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.availableBalance,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        dashboardState.formatCurrency(availableBalance),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.amountToWithdraw,
                    hintText: l10n.enterAmountHint,
                    prefixIcon: const Icon(Icons.money),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedMethod,
                  decoration: InputDecoration(
                    labelText: l10n.withdrawalMethod,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'bank_transfer',
                      child: Text(l10n.bankTransfer),
                    ),
                    DropdownMenuItem(
                      value: 'mobile_money',
                      child: Text(l10n.mobileMoney),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedMethod = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.minimumWithdrawal,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                if (dashboardState.withdrawalError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    dashboardState.withdrawalError!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: dashboardState.isLoadingWithdrawal
                            ? null
                            : () => _processWithdrawal(
                                context,
                                dashboardState,
                                amountController.text,
                                selectedMethod,
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: dashboardState.isLoadingWithdrawal
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                l10n.withdraw,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _processWithdrawal(
    BuildContext context,
    ProviderDashboardState dashboardState,
    String amountStr,
    String method,
  ) async {
    final amount = int.tryParse(amountStr);
    final availableBalance = dashboardState.providerInfo?.availableBalance ?? 0;

    if (amount == null || amount < 5000) {
      _showSnackBar(context, 'Please enter a valid amount (minimum 5,000 FCFA)', Colors.red);
      return;
    }

    if (amount > availableBalance) {
      _showSnackBar(context, 'Insufficient balance', Colors.red);
      return;
    }

    // Get actual user data for payment details
    final appState = Provider.of<AppState>(context, listen: false);
    final userName = appState.user?.fullName ?? 'Provider';

    final paymentDetails = <String, dynamic>{
      if (method == 'bank_transfer')
        'bankDetails': {
          'accountName': userName,
          'accountNumber': '1234567890',
          'bankName': 'First Bank',
          'swiftCode': 'FBNBCMCX',
        }
      else if (method == 'mobile_money')
        'mobileMoneyDetails': {
          'mobileNumber': '+237123456789',
          'operator': 'MTN',
          'accountName': userName,
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
      _showSnackBar(
        context,
        success
            ? 'Withdrawal request submitted successfully!'
            : dashboardState.withdrawalError ?? 'Failed to submit withdrawal request',
        success ? Colors.green : Colors.red,
      );
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
