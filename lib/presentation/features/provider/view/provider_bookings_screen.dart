import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/state/app_state.dart';
import '../../../../l10n/app_localizations.dart';

class ProviderBookingsScreen extends StatefulWidget {
  const ProviderBookingsScreen({super.key});

  @override
  State<ProviderBookingsScreen> createState() => _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState extends State<ProviderBookingsScreen>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _sessions = [];
  Map<String, dynamic> _summary = {};
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'all';

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSessions();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print(
        'Sessions: Loading ALL provider sessions (client-side filtering)...',
      );
      print(
        'Sessions: Current user role: Provider (viewing received bookings)',
      );
      print('Sessions: API endpoint: /api/v1/sessions/provider');

      // Debug: Check current user ID
      if (mounted) {
        final appState = Provider.of<AppState>(context, listen: false);
        final currentUser = appState.user;
        print('Sessions: Current logged user ID: ${currentUser?.id}');
        print(
          'Sessions: Expected to see bookings for provider: ${currentUser?.id}',
        );
      }
      final response = await _apiService.getSessionsAsProvider(
        page: 1,
        limit: 50, // Load more sessions
      );

      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        // Extract sessions from the response structure
        final sessionsList = response.data!['sessions'] as List<dynamic>? ?? [];
        final summary =
            response.data!['summary'] as Map<String, dynamic>? ?? {};
        final pagination =
            response.data!['pagination'] as Map<String, dynamic>? ?? {};

        setState(() {
          _sessions = sessionsList.whereType<Map<String, dynamic>>().toList();
          _summary = summary;
          _isLoading = false;
        });

        print('Sessions: Loaded ${_sessions.length} sessions');
        print('Sessions: Summary - $summary');
        print('Sessions: Pagination - $pagination');

        // Debug: Print first session structure
        if (_sessions.isNotEmpty) {
          print('Sessions: First session structure: ${_sessions.first}');
          print('Sessions: First session ID (_id): ${_sessions.first['_id']}');
          print('Sessions: First session ID (id): ${_sessions.first['id']}');
        }

        // Debug: Log expected provider ID from recent booking
        print(
          'Sessions: IMPORTANT - From your recent booking logs, you booked with provider ID: 6889f369ccc51961944515f9',
        );
        print(
          'Sessions: If these IDs don\'t match, that explains why you see no sessions!',
        );
      } else {
        setState(() {
          _errorMessage = response.error ?? 'Failed to load sessions';
          _isLoading = false;
        });
        print('Sessions: Load failed - $_errorMessage');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Network error: ${e.toString()}';
        _isLoading = false;
      });
      print('Sessions: Exception - $e');
    }
  }

  List<Map<String, dynamic>> get _filteredSessions {
    if (_selectedFilter == 'all') return _sessions;
    return _sessions.where((session) {
      final status = session['status']?.toString().toLowerCase() ?? '';
      return status == _selectedFilter;
    }).toList();
  }

  int _getStatusCount(String status) {
    if (status == 'all') return _sessions.length;

    return _sessions.where((session) {
      final sessionStatus = session['status']?.toString().toLowerCase() ?? '';
      return sessionStatus == status;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_sessions.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          await _loadSessions();
        },
        color: const Color(0xFF3B82F6),
        backgroundColor: Colors.white,
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height - 200,
              child: _buildEmptyState(),
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterTabs(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _loadSessions();
                },
                color: const Color(0xFF3B82F6),
                backgroundColor: Colors.white,
                child: _buildSessionsList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    // Use summary data from API response with safe parsing
    int _parseCount(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    final assignedCount = _parseCount(_summary['assigned']);
    final pendingCount = _parseCount(_summary['pending']);
    final confirmedCount = _parseCount(_summary['confirmed']);
    final completedCount = _parseCount(_summary['completed']);
    // final inProgressCount = _parseCount(_summary['inProgress']);
    // final totalEarnings = _parseEarnings(_summary['totalEarnings']);

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.book_online,
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
                      AppLocalizations.of(context)!.sessions,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.manageYourSessions,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildQuickStat(
                'Assigned',
                assignedCount.toString(),
                const Color(0xFF6366F1),
              ),
              const SizedBox(width: 8),
              _buildQuickStat(
                AppLocalizations.of(context)!.pending,
                pendingCount.toString(),
                const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 8),
              _buildQuickStat(
                AppLocalizations.of(context)!.confirmed,
                confirmedCount.toString(),
                const Color(0xFF3B82F6),
              ),
              const SizedBox(width: 8),
              _buildQuickStat(
                AppLocalizations.of(context)!.completed,
                completedCount.toString(),
                const Color(0xFF10B981),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              'all',
              AppLocalizations.of(context)!.all,
              Icons.list,
            ),
            const SizedBox(width: 8),
            _buildFilterChip('assigned', 'Assigned', Icons.assignment),
            const SizedBox(width: 8),
            _buildFilterChip(
              'pending',
              AppLocalizations.of(context)!.pending,
              Icons.hourglass_empty,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'confirmed',
              AppLocalizations.of(context)!.confirmed,
              Icons.check_circle,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'in_progress',
              AppLocalizations.of(context)!.inProgress,
              Icons.play_circle,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'completed',
              AppLocalizations.of(context)!.completed,
              Icons.check_circle_outline,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'cancelled',
              AppLocalizations.of(context)!.cancelled,
              Icons.cancel,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = _selectedFilter == value;
    final count = _getStatusCount(value);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedFilter = value);
        // Client-side filtering - no need to reload data
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.grey[200]!,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? Colors.white.withOpacity(0.2)
                          : const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFF3B82F6),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsList() {
    final filteredSessions = _filteredSessions;

    if (filteredSessions.isEmpty && _selectedFilter != 'all') {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height - 300,
            child: _buildEmptyFilterState(),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredSessions.length,
      itemBuilder: (context, index) {
        return _buildSessionCard(filteredSessions[index], index);
      },
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session, int index) {
    final status = session['status']?.toString().toLowerCase() ?? 'pending';

    // Extract seeker name from seekerId data
    String seekerName = 'Customer';
    final seekerVal = session['seekerId'];
    if (seekerVal is Map<String, dynamic>) {
      seekerName = (seekerVal['fullName'] as String?) ?? seekerName;
    } else if (seekerVal is String) {
      if (seekerVal.isNotEmpty && !seekerVal.startsWith('{')) {
        // If it's a plain string ID, keep the default
        seekerName = 'Customer';
      } else {
        // Handle malformed format: fullName: 'tambong slade'
        final match = RegExp(
          r"fullName:\s*'([^']+)'",
          multiLine: true,
        ).firstMatch(seekerVal);
        if (match != null) {
          seekerName = match.group(1)!;
        } else {
          // Try other patterns
          final patterns = [
            RegExp(r'fullName:\s*"([^"]+)"', multiLine: true),
            RegExp(r"fullName[:\s]*'([^']+)'", multiLine: true),
          ];

          for (final pattern in patterns) {
            final match2 = pattern.firstMatch(seekerVal);
            if (match2 != null) {
              seekerName = match2.group(1)!.trim();
              break;
            }
          }
        }
      }
    }

    // Add service location and address for better context
    final serviceLocation = session['serviceLocation'] ?? '';
    final serviceAddress = session['serviceAddress'] ?? '';
    final notes = session['notes'] ?? '';
    final assignmentNotes = session['assignmentNotes'] ?? '';
    final serviceTitle =
        session['serviceName'] ?? AppLocalizations.of(context)!.service;
    final category = session['category'] ?? '';
    final sessionDate = session['sessionDate'] ?? '';
    final startTime = session['startTime'] ?? '';
    final endTime = session['endTime'] ?? '';
    final duration = session['baseDuration'] ?? 4.0;
    final overtimeHours = session['overtimeHours'] ?? 0.0;
    final basePrice = session['basePrice'] ?? 3000;
    final overtimePrice = session['overtimePrice'] ?? 0;
    final totalAmount = session['totalAmount'] ?? basePrice;
    final currency = session['currency'] ?? 'FCFA';
    final paymentStatus = session['paymentStatus'] ?? 'pending';

    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${AppLocalizations.of(context)!.customer}: $seekerName',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),
                      if (category.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                category.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF3B82F6),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (paymentStatus != 'pending')
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      paymentStatus == 'paid'
                                          ? const Color(
                                            0xFF10B981,
                                          ).withOpacity(0.1)
                                          : const Color(
                                            0xFFF59E0B,
                                          ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  paymentStatus.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color:
                                        paymentStatus == 'paid'
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFFF59E0B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    status.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatDate(sessionDate),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$startTime - $endTime',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.monetization_on_outlined,
                          size: 16,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$totalAmount $currency',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          if (overtimeHours > 0) ...[
                            const SizedBox(height: 2),
                            Text(
                              AppLocalizations.of(context)!.basePlusOvertime(
                                basePrice.toString(),
                                overtimePrice.toString(),
                              ),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.schedule,
                          size: 16,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${duration + overtimeHours}h',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (serviceLocation.isNotEmpty ||
                notes.isNotEmpty ||
                assignmentNotes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (serviceLocation.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              serviceLocation,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (serviceAddress.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(left: 24),
                          child: Text(
                            serviceAddress,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ],
                    if (notes.isNotEmpty) ...[
                      if (serviceLocation.isNotEmpty) const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.note, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Notes: $notes',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (assignmentNotes.isNotEmpty && status == 'assigned') ...[
                      if (notes.isNotEmpty || serviceLocation.isNotEmpty)
                        const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 16,
                            color: const Color(0xFF6366F1),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Assignment: $assignmentNotes',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6366F1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (status == 'assigned' ||
                status == 'pending' ||
                status == 'confirmed' ||
                status == 'in_progress') ...[
              const SizedBox(height: 16),
              _buildActionButtons(session, status),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> session, String status) {
    print('Sessions: _buildActionButtons called with status: $status');
    print('Sessions: Session data: $session');
    print('Sessions: Session ID: ${session['id']}');

    if (status == 'assigned') {
      return Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEF4444)),
              ),
              child: TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _updateSessionStatus(session['id'] as String?, 'cancelled');
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  _localizations?.decline ?? 'Decline',
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _updateSessionStatus(session['id'] as String?, 'confirmed');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  _localizations?.accept ?? 'Accept',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEF4444)),
              ),
              child: TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _updateSessionStatus(session['id'] as String?, 'cancelled');
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  _localizations?.decline ?? 'Decline',
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _updateSessionStatus(session['id'] as String?, 'confirmed');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  _localizations?.accept ?? 'Accept',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (status == 'confirmed') {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ElevatedButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            _updateSessionStatus(session['id'] as String?, 'in_progress');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Text(
            _localizations?.startService ?? 'Start Service',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      );
    } else if (status == 'in_progress') {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ElevatedButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            _updateSessionStatus(session['id'] as String?, 'completed');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Text(
            _localizations?.markComplete ?? 'Mark Complete',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.loadingYourBookings,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.failedToLoadSessionsTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 16),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ElevatedButton(
                onPressed: _loadSessions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.retry,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.book_online_outlined,
                size: 64,
                color: Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              AppLocalizations.of(context)!.noSessionsYet,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.noSessionsYetDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFilterState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.noStatusSessions(
                _selectedFilter.replaceAll('_', ' ').toUpperCase(),
              ),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(
                context,
              )!.noStatusSessionsMessage(_selectedFilter.replaceAll('_', ' ')),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'assigned':
        return const Color(0xFF6366F1);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'confirmed':
        return const Color(0xFF3B82F6);
      case 'in_progress':
        return const Color(0xFF8B5CF6);
      case 'completed':
        return const Color(0xFF10B981);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'assigned':
        return Icons.assignment;
      case 'pending':
        return Icons.hourglass_empty;
      case 'confirmed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.play_circle;
      case 'completed':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _updateSessionStatus(String? sessionId, String newStatus) async {
    print(
      'Sessions: _updateSessionStatus called with sessionId: $sessionId, newStatus: $newStatus',
    );

    if (sessionId == null || sessionId.isEmpty) {
      print('Sessions: ERROR - Invalid session ID: $sessionId');
      _showErrorMessage('Invalid session ID: $sessionId');
      return;
    }

    try {
      print('Sessions: Updating session $sessionId to $newStatus');

      // Handle cancellation differently (uses cancel endpoint with reason)
      if (newStatus == 'cancelled') {
        final response = await _apiService.cancelSession(
          sessionId,
          'Declined by provider',
        );

        if (response.isSuccess) {
          if (mounted) {
            final localizations = AppLocalizations.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  localizations?.sessionDeclinedSuccess ??
                      'Session declined successfully',
                ),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
              ),
            );
            _loadSessions();
          }
        } else {
          final localizations = AppLocalizations.of(context);
          _showErrorMessage(
            localizations?.failedToDeclineSession(response.error ?? '') ??
                'Failed to decline session: ${response.error ?? 'Unknown error'}',
          );
        }
      } else {
        // Handle regular status updates
        final response = await _apiService.updateSession(sessionId, {
          'status': newStatus,
        });

        if (response.isSuccess) {
          if (mounted) {
            final localizations = AppLocalizations.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  localizations?.sessionUpdatedSuccess(
                        newStatus.replaceAll('_', ' '),
                      ) ??
                      'Session updated to ${newStatus.replaceAll('_', ' ')} successfully',
                ),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            _loadSessions();
          }
        } else {
          final localizations = AppLocalizations.of(context);
          _showErrorMessage(
            localizations?.failedToUpdateSession(response.error ?? '') ??
                'Failed to update session: ${response.error ?? 'Unknown error'}',
          );
        }
      }
    } catch (e) {
      final localizations = AppLocalizations.of(context);
      _showErrorMessage(
        localizations?.errorUpdatingSession(e.toString()) ??
            'Error updating session: ${e.toString()}',
      );
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  // Helper method to safely get localizations
  AppLocalizations? get _localizations => AppLocalizations.of(context);
}
