import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';
import '../../../../l10n/app_localizations.dart';
import 'time_slot_dialog.dart';

class ProviderAvailabilityScreen extends StatefulWidget {
  const ProviderAvailabilityScreen({super.key});

  @override
  State<ProviderAvailabilityScreen> createState() =>
      _ProviderAvailabilityScreenState();
}

class _ProviderAvailabilityScreenState extends State<ProviderAvailabilityScreen>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  Map<String, List<Map<String, dynamic>>> _weeklyAvailability = {};
  bool _isLoading = true;
  String? _errorMessage;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // UI State
  String _selectedView = 'week'; // 'week' or 'day'

  final List<String> _weekDays = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  // Helper methods to get localized day names
  String _getDayShortName(BuildContext context, String day) {
    final l10n = AppLocalizations.of(context)!;
    switch (day.toLowerCase()) {
      case 'monday':
        return l10n.mon;
      case 'tuesday':
        return l10n.tue;
      case 'wednesday':
        return l10n.wed;
      case 'thursday':
        return l10n.thu;
      case 'friday':
        return l10n.fri;
      case 'saturday':
        return l10n.sat;
      case 'sunday':
        return l10n.sun;
      default:
        return day;
    }
  }

  String _getDayFullName(BuildContext context, String day) {
    final l10n = AppLocalizations.of(context)!;
    switch (day.toLowerCase()) {
      case 'monday':
        return l10n.monday;
      case 'tuesday':
        return l10n.tuesday;
      case 'wednesday':
        return l10n.wednesday;
      case 'thursday':
        return l10n.thursday;
      case 'friday':
        return l10n.friday;
      case 'saturday':
        return l10n.saturday;
      case 'sunday':
        return l10n.sunday;
      default:
        return day;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadAvailability();
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

  Future<void> _loadAvailability() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Availability: Loading my availability...');
      final response = await _apiService.getMyAvailability();

      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        setState(() {
          _weeklyAvailability = _organizeAvailabilityByDay(response.data!);
          _isLoading = false;
        });
        print(
          'Availability: Loaded availability for ${_weeklyAvailability.length} days',
        );
      } else {
        setState(() {
          _errorMessage = response.error ?? 'Failed to load availability';
          _isLoading = false;
        });
        print('Availability: Load failed - $_errorMessage');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Network error: ${e.toString()}';
          _isLoading = false;
        });
      }
      print('Availability: Exception - $e');
    }
  }

  Map<String, List<Map<String, dynamic>>> _organizeAvailabilityByDay(
    List<Map<String, dynamic>> availability,
  ) {
    final organized = <String, List<Map<String, dynamic>>>{};

    // Initialize all days with empty lists
    for (final day in _weekDays) {
      organized[day] = [];
    }

    // Group availability by day - each item represents a day with timeSlots
    for (final item in availability) {
      final dayOfWeek = item['dayOfWeek']?.toString();
      final day = dayOfWeek?.toLowerCase();

      if (day != null && organized.containsKey(day)) {
        // Add the entire availability item for this day
        // This includes the day's timeSlots, notes, and other metadata
        organized[day]!.add(item);
      }
    }
    return organized;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: RefreshIndicator(
          onRefresh: _loadAvailability,
          child: CustomScrollView(
            slivers: [
              _buildModernHeader(),
              _buildQuickActions(),
              _buildTimeGridView(),
            ],
          ),
        ),
      ),
    );
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
            AppLocalizations.of(context)!.loadingYourSchedule,
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

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _showQuickSetupDialog(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: Text(
          AppLocalizations.of(context)!.quickSetup,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.failedToLoadAvailabilityTitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadAvailability,
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667EEA).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
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
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.schedule,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.availabilityManager,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.setWeeklySchedule,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildAvailabilityStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityStats() {
    int availableSlots = 0;
    int totalHours = 0;

    for (final dayAvailability in _weeklyAvailability.values) {
      for (final availability in dayAvailability) {
        final timeSlots = availability['timeSlots'] as List<dynamic>? ?? [];

        for (final slot in timeSlots) {
          if (slot is Map<String, dynamic>) {
            if (slot['isAvailable'] == true) {
              availableSlots++;
            }

            // Calculate hours from time slots
            final startTime = slot['startTime'] ?? '';
            final endTime = slot['endTime'] ?? '';
            if (startTime.isNotEmpty && endTime.isNotEmpty) {
              final startParts = startTime.split(':');
              final endParts = endTime.split(':');
              if (startParts.length == 2 && endParts.length == 2) {
                final startHour = int.tryParse(startParts[0]) ?? 0;
                final endHour = int.tryParse(endParts[0]) ?? 0;
                totalHours += (endHour - startHour);
              }
            }
          }
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          _buildStatItem('Total Hours', '${totalHours}h', Icons.access_time),
          const SizedBox(width: 20),
          _buildStatItem('Available', '$availableSlots', Icons.check_circle),
          const SizedBox(width: 20),
          _buildStatItem(
            'Days Set',
            '${_weeklyAvailability.values.where((list) => list.isNotEmpty).length}',
            Icons.calendar_today,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // View Toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildViewToggle('week', 'Week View', Icons.view_week),
                  _buildViewToggle('grid', 'Time Grid', Icons.grid_view),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick Actions Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickActionChip(
                    'Copy Monday',
                    Icons.content_copy,
                    Colors.blue,
                    () => _copyDayToAll('monday'),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickActionChip(
                    'Clear All',
                    Icons.clear_all,
                    Colors.red,
                    () => _clearAllAvailability(),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickActionChip(
                    'Set Default',
                    Icons.schedule,
                    Colors.green,
                    () => _setDefaultAvailability(),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickActionChip(
                    'Business Hours',
                    Icons.business,
                    Colors.green,
                    () => _setBusinessHours(),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickActionChip(
                    'Weekend Only',
                    Icons.weekend,
                    Colors.purple,
                    () => _setWeekendOnly(),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickActionChip(
                    'Default 9-5',
                    Icons.business_center,
                    Colors.indigo,
                    () => _setDefaultAvailability(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggle(String view, String label, IconData icon) {
    final isSelected = _selectedView == view;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedView = view),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionChip(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeGridView() {
    if (_selectedView == 'week') {
      return _buildWeeklyCalendar();
    } else {
      return _buildHorizontalTimeGrid();
    }
  }

  Widget _buildHorizontalTimeGrid() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        height: 600,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Time Grid Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 60), // Space for time labels
                  ...List.generate(7, (index) {
                    final day = _weekDays[index];
                    return Expanded(
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              _getDayShortName(context, day),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color:
                                    _weeklyAvailability[day]?.isNotEmpty == true
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFE5E7EB),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Time Grid Body
            Expanded(child: _buildTimeGridBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeGridBody() {
    final hours = List.generate(12, (index) => index + 8); // 8 AM to 7 PM

    return SingleChildScrollView(
      child: Column(
        children:
            hours.map((hour) {
              return SizedBox(
                height: 40,
                child: Row(
                  children: [
                    // Time label
                    Container(
                      width: 60,
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        '${hour.toString().padLeft(2, '0')}:00',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),

                    // Day slots
                    ...List.generate(7, (dayIndex) {
                      final day = _weekDays[dayIndex];
                      final hasSlotAtHour = _hasTimeSlotAtHour(day, hour);

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _addTimeSlotAtHour(day, hour),
                          child: Container(
                            margin: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color:
                                  hasSlotAtHour
                                      ? const Color(0xFF3B82F6).withOpacity(0.2)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                                width: 0.5,
                              ),
                            ),
                            child:
                                hasSlotAtHour
                                    ? const Center(
                                      child: Icon(
                                        Icons.check,
                                        size: 12,
                                        color: Color(0xFF3B82F6),
                                      ),
                                    )
                                    : null,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildWeeklyCalendar() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final day = _weekDays[index];
          final dayAvailability = _weeklyAvailability[day] ?? [];
          return _buildDayCard(day, dayAvailability);
        }, childCount: _weekDays.length),
      ),
    );
  }

  Widget _buildDayCard(String day, List<Map<String, dynamic>> dayAvailability) {
    final hasAvailability = dayAvailability.isNotEmpty;
    final allTimeSlots = <Map<String, dynamic>>[];

    // Collect all time slots from all availability entries for this day
    for (final availability in dayAvailability) {
      final timeSlots = availability['timeSlots'] as List<dynamic>? ?? [];

      for (final slot in timeSlots) {
        if (slot is Map<String, dynamic>) {
          allTimeSlots.add({
            ...slot,
            'notes': availability['notes'] ?? '',
            'availabilityId': availability['id'] ?? availability['_id'] ?? '',
            'dayOfWeek': day,
          });
        }
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Day Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: hasAvailability ? Colors.blue[50] : Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color:
                        hasAvailability ? Colors.blue[100] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      _getDayShortName(context, day),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color:
                            hasAvailability
                                ? Colors.blue[700]
                                : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getDayFullName(context, day),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              hasAvailability
                                  ? Colors.blue[800]
                                  : Colors.grey[700],
                        ),
                      ),
                      Text(
                        hasAvailability
                            ? AppLocalizations.of(
                              context,
                            )!.timeSlotsCount(allTimeSlots.length.toString())
                            : AppLocalizations.of(context)!.noAvailabilitySet,
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              hasAvailability
                                  ? Colors.blue[600]
                                  : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showTimeSlotDialog(day),
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: Colors.blue[600],
                    size: 24,
                  ),
                  tooltip: AppLocalizations.of(context)!.addTimeSlot,
                ),
              ],
            ),
          ),

          // Time Slots
          if (hasAvailability) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children:
                    allTimeSlots.asMap().entries.map((entry) {
                      final index = entry.key;
                      final slot = entry.value;
                      return _buildTimeSlot(day, slot, index);
                    }).toList(),
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildEmptyDayState(day),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeSlot(String day, Map<String, dynamic> slot, int index) {
    final isAvailable = slot['isAvailable'] == true;
    final startTime = slot['startTime'] ?? '';
    final endTime = slot['endTime'] ?? '';
    final notes = slot['notes'] ?? '';

    return Dismissible(
      key: Key('${day}_${index}_${startTime}_${endTime}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.only(right: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.delete,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Delete Time Slot'),
                    content: Text(
                      'Are you sure you want to delete the time slot $startTime - $endTime?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
            ) ??
            false;
      },
      onDismissed: (direction) {
        _performDeleteTimeSlot(day, slot);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isAvailable ? Colors.green[50] : Colors.red[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAvailable ? Colors.green[200]! : Colors.red[200]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isAvailable ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.access_time,
                size: 16,
                color: isAvailable ? Colors.green[700] : Colors.red[700],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$startTime - $endTime',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isAvailable ? Colors.green[800] : Colors.red[800],
                    ),
                  ),
                  if (notes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      notes,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            isAvailable ? Colors.green[600] : Colors.red[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isAvailable ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isAvailable ? 'Available' : 'Unavailable',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isAvailable ? Colors.green[700] : Colors.red[700],
                ),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _editTimeSlot(day, slot);
                } else if (value == 'delete_slot') {
                  _deleteIndividualTimeSlot(day, slot);
                } else if (value == 'delete_day') {
                  _deleteEntireDay(day);
                }
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.deleteTimeSlot),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete_slot',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: Colors.orange,
                          ),
                          SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.deleteThisSlot),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete_day',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_forever,
                            size: 16,
                            color: Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.deleteEntireDay,
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
              child: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDayState(String day) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.schedule_outlined, size: 32, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'No time slots set',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap + to add your first time slot',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showTimeSlotDialog(String day) {
    final daySlots = _weeklyAvailability[day] ?? [];
    String? dayId;

    // Find the day ID from existing slots - use _id field
    if (daySlots.isNotEmpty) {
      dayId = daySlots.first['_id']?.toString();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TimeSlotDialog(
          day: day,
          existingTimeSlots:
              daySlots.isNotEmpty
                  ? (daySlots.first['timeSlots'] as List<dynamic>? ?? [])
                      .whereType<Map<String, dynamic>>()
                      .map(
                        (slot) => {
                          'startTime': slot['startTime'],
                          'endTime': slot['endTime'],
                          'isAvailable': slot['isAvailable'] ?? true,
                        },
                      )
                      .toList()
                  : [],
          dayId: dayId,
          onTimeSlotAdded: _loadAvailability,
          apiService: _apiService,
        );
      },
    );
  }

  void _editTimeSlot(String day, Map<String, dynamic> slot) {
    final daySlots = _weeklyAvailability[day] ?? [];
    String? dayId;

    // Find the day ID from existing slots - use _id field
    if (daySlots.isNotEmpty) {
      dayId = daySlots.first['_id']?.toString();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TimeSlotDialog(
          day: day,
          existingSlot: slot,
          existingTimeSlots:
              daySlots.isNotEmpty
                  ? (daySlots.first['timeSlots'] as List<dynamic>? ?? [])
                      .whereType<Map<String, dynamic>>()
                      .map(
                        (s) => {
                          'startTime': s['startTime'],
                          'endTime': s['endTime'],
                          'isAvailable': s['isAvailable'] ?? true,
                        },
                      )
                      .toList()
                  : [],
          dayId: dayId,
          onTimeSlotAdded: _loadAvailability,
          apiService: _apiService,
        );
      },
    );
  }

  // Helper methods for time grid functionality
  bool _hasTimeSlotAtHour(String day, int hour) {
    final dayAvailability = _weeklyAvailability[day] ?? [];

    for (final availability in dayAvailability) {
      final timeSlots = availability['timeSlots'] as List<dynamic>? ?? [];

      for (final slot in timeSlots) {
        if (slot is Map<String, dynamic>) {
          final startTime = slot['startTime'] ?? '';
          final endTime = slot['endTime'] ?? '';

          if (startTime.isNotEmpty && endTime.isNotEmpty) {
            final startHour = int.tryParse(startTime.split(':')[0]) ?? 0;
            final endHour = int.tryParse(endTime.split(':')[0]) ?? 0;

            if (hour >= startHour && hour < endHour) {
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  void _addTimeSlotAtHour(String day, int hour) {
    final daySlots = _weeklyAvailability[day] ?? [];
    String? dayId;

    // Find the day ID from existing slots - use id or _id field
    if (daySlots.isNotEmpty) {
      dayId =
          daySlots.first['id']?.toString() ?? daySlots.first['_id']?.toString();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TimeSlotDialog(
          day: day,
          existingTimeSlots:
              daySlots.isNotEmpty
                  ? (daySlots.first['timeSlots'] as List<dynamic>? ?? [])
                      .whereType<Map<String, dynamic>>()
                      .map(
                        (slot) => {
                          'startTime': slot['startTime'],
                          'endTime': slot['endTime'],
                          'isAvailable': slot['isAvailable'] ?? true,
                        },
                      )
                      .toList()
                  : [],
          dayId: dayId,
          onTimeSlotAdded: _loadAvailability,
          apiService: _apiService,
          presetStartTime: TimeOfDay(hour: hour, minute: 0),
          presetEndTime: TimeOfDay(hour: hour + 1, minute: 0),
        );
      },
    );
  }

  // Quick action methods
  void _showQuickSetupDialog({String? preset}) {
    showDialog(
      context: context,
      builder:
          (context) => _QuickSetupDialog(
            onSetupComplete: _loadAvailability,
            apiService: _apiService,
            preset: preset,
          ),
    );
  }

  void _copyDayToAll(String sourceDay) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.copyScheduleTitle),
            content: Text(
              AppLocalizations.of(
                context,
              )!.copyScheduleConfirm(_getDayFullName(context, sourceDay)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _performCopyDayToAll(sourceDay);
                },
                child: Text(AppLocalizations.of(context)!.copyMonday),
              ),
            ],
          ),
    );
  }

  Future<void> _performCopyDayToAll(String sourceDay) async {
    if (!mounted) return;

    try {
      final sourceAvailability = _weeklyAvailability[sourceDay] ?? [];

      if (sourceAvailability.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Source day has no availability to copy'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      for (final day in _weekDays) {
        if (!mounted) return; // Check before each day

        if (day != sourceDay) {
          // Clear existing availability for this day first
          await _clearDayAvailability(day);

          if (!mounted) return; // Check after clearing

          // Copy each availability from source day
          for (final availability in sourceAvailability) {
            if (!mounted) return; // Check before each availability

            final availabilityData = {
              'dayOfWeek': day.toLowerCase(),
              'timeSlots': availability['timeSlots'],
              'notes': availability['notes'] ?? '',
            };

            await _apiService.createAvailability(availabilityData);
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.scheduleCopiedSuccess),
            backgroundColor: Colors.green,
          ),
        );
        _loadAvailability();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.failedToCopySchedule(e.toString()),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearDayAvailability(String day) async {
    if (!mounted) return;

    final dayAvailability = _weeklyAvailability[day] ?? [];
    for (final availability in dayAvailability) {
      if (!mounted) return; // Check before each async operation

      final id = availability['id'] ?? availability['_id'];
      if (id != null) {
        await _apiService.deleteAvailability(id);
      }
    }
  }

  Future<void> _performClearAll() async {
    if (!mounted) return;

    try {
      for (final dayAvailability in _weeklyAvailability.values) {
        if (!mounted) return; // Check before each day

        for (final availability in dayAvailability) {
          if (!mounted) return; // Check before each availability

          final id = availability['id'] ?? availability['_id'];
          if (id != null) {
            await _apiService.deleteAvailability(id);
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All availability cleared successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadAvailability();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear availability: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearAllAvailability() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              AppLocalizations.of(context)!.clearAllAvailabilityTitle,
            ),
            content: Text(
              AppLocalizations.of(context)!.clearAllAvailabilityConfirm,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  _performClearAll();
                },
                child: Text(AppLocalizations.of(context)!.clearAll),
              ),
            ],
          ),
    );
  }

  void _setBusinessHours() {
    _showQuickSetupDialog(preset: 'business');
  }

  void _setWeekendOnly() {
    _showQuickSetupDialog(preset: 'weekend');
  }

  Future<void> _setDefaultAvailability() async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              AppLocalizations.of(context)!.setDefaultAvailabilityTitle,
            ),
            content: Text(
              AppLocalizations.of(context)!.setDefaultAvailabilityConfirm,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _performSetDefaultAvailability();
                },
                child: Text(AppLocalizations.of(context)!.setDefault),
              ),
            ],
          ),
    );
  }

  Future<void> _performSetDefaultAvailability() async {
    if (!mounted) return;

    try {
      print('Availability: Setting default Mon-Fri 9-5 availability');
      final response = await _apiService.setDefaultAvailability();

      if (response.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.defaultAvailabilitySetSuccess,
              ),
              backgroundColor: Colors.green,
            ),
          );
          _loadAvailability();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(
                  context,
                )!.failedToSetDefaultAvailability(response.error ?? ''),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!.errorSettingDefaultAvailability(e.toString()),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // New methods for proper delete functionality
  void _deleteIndividualTimeSlot(String day, Map<String, dynamic> slot) {
    // Check if we have availability data for this day
    final dayAvailability = _weeklyAvailability[day] ?? [];
    if (dayAvailability.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No availability data found for this day'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.deleteTimeSlot),
            content: Text(
              AppLocalizations.of(context)!.deleteTimeSlotFor(
                slot['startTime'],
                slot['endTime'],
                _getDayFullName(context, day),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  _performDeleteTimeSlot(day, slot);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _deleteEntireDay(String day) {
    final dayAvailability = _weeklyAvailability[day] ?? [];
    if (dayAvailability.isEmpty) return;

    // Get the availability ID - handle both _id and id fields
    final availabilityId =
        dayAvailability.first['_id']?.toString() ??
        dayAvailability.first['id']?.toString() ??
        '';
    if (availabilityId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Cannot find availability ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.deleteEntireDay),
            content: Text(
              AppLocalizations.of(context)!.deleteAllAvailabilityForDay(
                _getDayFullName(context, day),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  _performDeleteEntireDay(availabilityId);
                },
                child: const Text('Delete Day'),
              ),
            ],
          ),
    );
  }

  Future<void> _performDeleteTimeSlot(
    String day,
    Map<String, dynamic> slotToDelete,
  ) async {
    try {
      print('DEBUG: _performDeleteTimeSlot called');
      print('DEBUG: day = $day');
      print('DEBUG: slotToDelete = $slotToDelete');

      final dayAvailability = _weeklyAvailability[day] ?? [];
      print('DEBUG: dayAvailability length = ${dayAvailability.length}');
      if (dayAvailability.isEmpty) return;

      final availabilityRecord = dayAvailability.first;
      print('DEBUG: availabilityRecord = $availabilityRecord');

      // Get the availability ID - handle both _id and id fields
      final availabilityId =
          availabilityRecord['_id']?.toString() ??
          availabilityRecord['id']?.toString() ??
          '';
      print('DEBUG: availabilityId = $availabilityId');
      print('DEBUG: availabilityId type = ${availabilityId.runtimeType}');

      if (availabilityId.isEmpty) {
        print('DEBUG: No availability ID found in record');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Cannot find availability ID'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final currentTimeSlots = List<Map<String, dynamic>>.from(
        availabilityRecord['timeSlots'] as List<dynamic>? ?? [],
      );
      print('DEBUG: currentTimeSlots before removal = $currentTimeSlots');

      // Remove the specific time slot
      currentTimeSlots.removeWhere(
        (slot) =>
            slot['startTime'] == slotToDelete['startTime'] &&
            slot['endTime'] == slotToDelete['endTime'],
      );
      print('DEBUG: currentTimeSlots after removal = $currentTimeSlots');

      if (currentTimeSlots.isEmpty) {
        print('DEBUG: No time slots left, deleting entire day');
        // If no time slots left, delete the entire day
        await _performDeleteEntireDay(availabilityId);
      } else {
        print('DEBUG: Updating availability with remaining time slots');
        // Update the availability with remaining time slots
        final updateData = {'timeSlots': currentTimeSlots};
        print('DEBUG: updateData = $updateData');

        // Use the new day-based route if availabilityId is not a valid ObjectId
        final isObjectId = RegExp(
          r'^[0-9a-fA-F]{24}$',
        ).hasMatch(availabilityId);
        final response =
            isObjectId
                ? await _apiService.updateAvailability(
                  availabilityId,
                  updateData,
                )
                : await _apiService.updateAvailabilityByDay(
                  day,
                  currentTimeSlots,
                );
        print('DEBUG: updateAvailability response = ${response.isSuccess}');
        print('DEBUG: updateAvailability error = ${response.error}');

        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Time slot deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
            _loadAvailability();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete time slot: ${response.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e, stackTrace) {
      print('DEBUG: Exception in _performDeleteTimeSlot: $e');
      print('DEBUG: Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting time slot: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _performDeleteEntireDay(String availabilityId) async {
    try {
      print('Availability: Deleting entire day $availabilityId');

      if (availabilityId.isEmpty) {
        print('DEBUG: Empty availability ID provided');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Cannot find availability ID'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final response = await _apiService.deleteAvailability(availabilityId);

      if (response.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Day availability deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadAvailability();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete day: ${response.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting day: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Quick Setup Dialog for bulk operations
class _QuickSetupDialog extends StatefulWidget {
  final VoidCallback onSetupComplete;
  final ApiService apiService;
  final String? preset;

  const _QuickSetupDialog({
    required this.onSetupComplete,
    required this.apiService,
    this.preset,
  });

  @override
  State<_QuickSetupDialog> createState() => _QuickSetupDialogState();
}

class _QuickSetupDialogState extends State<_QuickSetupDialog> {
  final List<String> _weekDays = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  final Map<String, String> _dayNames = {
    'monday': 'Monday',
    'tuesday': 'Tuesday',
    'wednesday': 'Wednesday',
    'thursday': 'Thursday',
    'friday': 'Friday',
    'saturday': 'Saturday',
    'sunday': 'Sunday',
  };

  Set<String> _selectedDays = {};
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _applyPreset();
  }

  void _applyPreset() {
    switch (widget.preset) {
      case 'business':
        _selectedDays = {
          'monday',
          'tuesday',
          'wednesday',
          'thursday',
          'friday',
        };
        _startTime = const TimeOfDay(hour: 9, minute: 0);
        _endTime = const TimeOfDay(hour: 17, minute: 0);
        break;
      case 'weekend':
        _selectedDays = {'saturday', 'sunday'};
        _startTime = const TimeOfDay(hour: 10, minute: 0);
        _endTime = const TimeOfDay(hour: 16, minute: 0);
        break;
      default:
        _selectedDays = Set.from(_weekDays);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Quick Setup',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Day Selection
            const Text(
              'Select Days',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _weekDays.map((day) {
                    final isSelected = _selectedDays.contains(day);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedDays.remove(day);
                          } else {
                            _selectedDays.add(day);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? const Color(0xFF3B82F6)
                                  : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          _dayNames[day]!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.grey[700],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 24),

            // Time Selection
            Row(
              children: [
                Expanded(
                  child: _buildTimeSelector('Start Time', _startTime, (time) {
                    setState(() => _startTime = time);
                  }),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimeSelector('End Time', _endTime, (time) {
                    setState(() => _endTime = time);
                  }),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                    ),
                    onPressed: _isLoading ? null : _performQuickSetup,
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : Text(AppLocalizations.of(context)!.apply),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector(
    String label,
    TimeOfDay time,
    Function(TimeOfDay) onChanged,
  ) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time.format(context),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performQuickSetup() async {
    if (_selectedDays.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one day')),
        );
      }
      return;
    }

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      for (final day in _selectedDays) {
        if (!mounted) return; // Check before each day

        final availabilityData = {
          'dayOfWeek': day,
          'timeSlots': [
            {
              'startTime':
                  '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
              'endTime':
                  '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
              'isAvailable': true,
            },
          ],
          'notes': 'Set via Quick Setup',
        };

        await widget.apiService.createAvailability(availabilityData);
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSetupComplete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quick setup completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during setup: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
