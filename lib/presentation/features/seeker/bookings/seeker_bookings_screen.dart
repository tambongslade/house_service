import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:house_service/core/state/app_state.dart';
import '../tracking/seeker_tracking_screen.dart';

class SeekerBookingsScreen extends StatefulWidget {
  const SeekerBookingsScreen({super.key});

  @override
  State<SeekerBookingsScreen> createState() => _SeekerBookingsScreenState();
}

class _SeekerBookingsScreenState extends State<SeekerBookingsScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _bookings = [];
  Map<String, dynamic> _summary = {};
  bool _loading = true;
  String _error = '';
  String _selectedFilter = '';
  late TabController _tabController;

  final List<Map<String, String>> _statusFilters = [
    {'key': '', 'label': 'All', 'color': '0xFF64748B'},
    {'key': 'pending', 'label': 'Pending', 'color': '0xFFF59E0B'},
    {'key': 'confirmed', 'label': 'Confirmed', 'color': '0xFF3B82F6'},
    {'key': 'in_progress', 'label': 'In Progress', 'color': '0xFF8B5CF6'},
    {'key': 'completed', 'label': 'Completed', 'color': '0xFF10B981'},
    {'key': 'cancelled', 'label': 'Cancelled', 'color': '0xFFEF4444'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusFilters.length, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings({String? status}) async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final response = await appState.apiService.getSessionsAsSeeker(
        status: status,
        page: 1,
        limit: 50,
      );

      if (response.isSuccess && response.data != null) {
        setState(() {
          final rawSessions = response.data!['sessions'] ?? [];
          _bookings = _sanitizeSessionData(rawSessions);
          _summary = response.data!['summary'] ?? {};
          _loading = false;
        });
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load bookings';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error: ${e.toString()}';
        _loading = false;
      });
    }
  }

  Future<void> _cancelBooking(String bookingId, String reason) async {
    if (!mounted) return;

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final response = await appState.apiService.cancelBooking(
        bookingId,
        reason,
      );

      if (!mounted) return;

      if (response.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadBookings(status: _selectedFilter.isEmpty ? null : _selectedFilter);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error ?? 'Failed to cancel booking'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'My Bookings',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:
                () => _loadBookings(
                  status: _selectedFilter.isEmpty ? null : _selectedFilter,
                ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCards(),
          _buildTabBar(),
          Expanded(child: _buildBookingsList()),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    if (_summary.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Bookings',
              '${_summary['totalBookings'] ?? 0}',
              Icons.calendar_today,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Completed',
              '${_summary['completed'] ?? 0}',
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Pending',
              '${_summary['pending'] ?? 0}',
              Icons.pending,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    MaterialColor color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color.shade600, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: Colors.blue.shade600,
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: Colors.blue.shade600,
        onTap: (index) {
          final filter = _statusFilters[index]['key']!;
          setState(() {
            _selectedFilter = filter;
          });
          _loadBookings(status: filter.isEmpty ? null : filter);
        },
        tabs:
            _statusFilters.map((filter) {
              final count = _getStatusCount(filter['key']!);
              return Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(filter['label']!),
                    if (count > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Color(int.parse(filter['color']!)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  int _getStatusCount(String status) {
    if (status.isEmpty) return _summary['totalBookings'] ?? 0;
    return _summary[status] ?? 0;
  }

  Widget _buildBookingsList() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading your bookings...'),
          ],
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Failed to load bookings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error,
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed:
                  () => _loadBookings(
                    status: _selectedFilter.isEmpty ? null : _selectedFilter,
                  ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No bookings found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter.isEmpty
                  ? 'You haven\'t made any bookings yet'
                  : 'No $_selectedFilter bookings found',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh:
          () => _loadBookings(
            status: _selectedFilter.isEmpty ? null : _selectedFilter,
          ),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          final booking = _bookings[index];
          return _buildBookingCard(booking);
        },
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final dynamic serviceVal = booking['serviceId'];
    final dynamic providerVal = booking['providerId'];
    final status = booking['status'] as String? ?? 'unknown';
    final bookingDate =
        (booking['sessionDate'] ?? booking['bookingDate']) as String?;
    final startTime = booking['startTime'] as String?;
    final endTime = booking['endTime'] as String?;
    final totalAmount = booking['totalAmount'] as num? ?? 0;
    final currency = booking['currency'] as String? ?? 'FCFA';

    String serviceTitle = 'Unknown Service';
    if (serviceVal is Map<String, dynamic>) {
      serviceTitle =
          (serviceVal['title'] as String?) ??
          (booking['serviceName'] as String?) ??
          'Unknown Service';
    } else {
      serviceTitle = (booking['serviceName'] as String?) ?? 'Unknown Service';
    }

    String providerName = 'Unknown Provider';
    if (providerVal is Map<String, dynamic>) {
      providerName = (providerVal['fullName'] as String?) ?? 'Unknown Provider';
    } else if (providerVal is String) {
      print('DEBUG: Raw provider string: $providerVal');
      // Handle the malformed format with newlines and spaces: \n  fullName: 'slade tambong'
      final match = RegExp(
        r"fullName:\s*'([^']+)'",
        multiLine: true,
      ).firstMatch(providerVal);
      if (match != null) {
        providerName = match.group(1)!;
        print('DEBUG: Extracted provider name: $providerName');
      } else {
        // Fallback: try other possible formats including quotes and newlines
        final patterns = [
          RegExp(r'fullName:\s*"([^"]+)"', multiLine: true),
          RegExp(r"fullName[:\s]*'([^']+)'", multiLine: true),
          RegExp(r'fullName[:\s]*"([^"]+)"', multiLine: true),
          RegExp(r'fullName[:\s]*([^,\n}]+)', multiLine: true),
        ];

        for (final pattern in patterns) {
          final match2 = pattern.firstMatch(providerVal);
          if (match2 != null) {
            providerName = match2
                .group(1)!
                .trim()
                .replaceAll(RegExp('[\'\"]'), '');
            print(
              'DEBUG: Extracted provider name (pattern match): $providerName',
            );
            break;
          }
        }

        if (providerName == 'Unknown Provider') {
          print('DEBUG: Could not extract provider name from: $providerVal');
        }
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with service and status
            Row(
              children: [
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
                        providerName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(status),
              ],
            ),
            const SizedBox(height: 16),

            // Booking details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Date',
                    _formatDate(bookingDate),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    Icons.access_time,
                    'Time',
                    '$startTime - $endTime',
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    Icons.attach_money,
                    'Amount',
                    '$totalAmount $currency',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showBookingDetails(booking),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blue.shade600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'View Details',
                      style: TextStyle(color: Colors.blue.shade600),
                    ),
                  ),
                ),
                if (status == 'in_progress') ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateToTracking(booking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.location_on, size: 18),
                      label: const Text('Track Provider'),
                    ),
                  ),
                ] else if (status == 'pending' || status == 'confirmed') ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showCancelDialog(booking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'confirmed':
        color = Colors.blue;
        label = 'Confirmed';
        break;
      case 'in_progress':
        color = Colors.purple;
        label = 'In Progress';
        break;
      case 'completed':
        color = Colors.green;
        label = 'Completed';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Cancelled';
        break;
      case 'rejected':
        color = Colors.red.shade800;
        label = 'Rejected';
        break;
      default:
        color = Colors.grey;
        label = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color is MaterialColor ? color.shade700 : color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';

    try {
      final date = DateTime.parse(dateString);
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
      return dateString;
    }
  }

  void _showBookingDetails(Map<String, dynamic> booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => BookingDetailsSheet(booking: booking),
    );
  }

  void _navigateToTracking(Map<String, dynamic> booking) {
    final sessionId = booking['id'] as String? ?? booking['_id'] as String?;
    final providerName = _getProviderName(booking);
    final serviceName = _getServiceName(booking);

    if (sessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to track: Invalid session ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SeekerTrackingScreen(
              sessionId: sessionId,
              providerName: providerName,
              serviceName: serviceName,
            ),
      ),
    );
  }

  String _getProviderName(Map<String, dynamic> booking) {
    final dynamic providerVal = booking['providerId'];
    if (providerVal is Map<String, dynamic>) {
      return (providerVal['fullName'] as String?) ?? 'Provider';
    }
    return 'Provider';
  }

  String _getServiceName(Map<String, dynamic> booking) {
    final dynamic serviceVal = booking['serviceId'];
    if (serviceVal is Map<String, dynamic>) {
      return (serviceVal['title'] as String?) ??
          (booking['serviceName'] as String?) ??
          'Service';
    }
    return (booking['serviceName'] as String?) ?? 'Service';
  }

  void _showCancelDialog(Map<String, dynamic> booking) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel Booking'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Are you sure you want to cancel this booking?'),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason for cancellation',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Keep Booking'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  final bookingId =
                      (booking['id'] ?? booking['_id'])?.toString();
                  if (bookingId == null || bookingId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Unable to cancel: missing booking ID'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  _cancelBooking(
                    bookingId,
                    reasonController.text.trim().isEmpty
                        ? 'Cancelled by user'
                        : reasonController.text.trim(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Cancel Booking'),
              ),
            ],
          ),
    );
  }

  List<Map<String, dynamic>> _sanitizeSessionData(List<dynamic> rawSessions) {
    return rawSessions.map((session) {
      if (session is Map<String, dynamic>) {
        final sanitized = Map<String, dynamic>.from(session);

        // Fix malformed providerId - preserve the original if it contains provider details
        final providerRaw = sanitized['providerId'];
        if (providerRaw is String) {
          // If the string contains provider details (like fullName), keep it as is
          if (providerRaw.contains('fullName') ||
              providerRaw.contains('email')) {
            // Keep the original string with provider details
            sanitized['providerId'] = providerRaw;
          } else {
            // Otherwise, try to extract just the ObjectId
            try {
              final idMatch = RegExp(
                r"ObjectId\('([^']+)'\)",
              ).firstMatch(providerRaw);
              sanitized['providerId'] =
                  idMatch != null ? idMatch.group(1) : 'unknown';
            } catch (_) {
              sanitized['providerId'] = 'unknown';
            }
          }
        } else if (providerRaw == null) {
          sanitized['providerId'] = 'unknown';
        }

        // Fix malformed serviceId when it comes as a string like ObjectId('...')
        final serviceRaw = sanitized['serviceId'];
        if (serviceRaw is String) {
          try {
            final idMatch = RegExp(
              r"ObjectId\('([^']+)'\)",
            ).firstMatch(serviceRaw);
            sanitized['serviceId'] =
                idMatch != null ? idMatch.group(1) : 'unknown';
          } catch (_) {
            sanitized['serviceId'] = 'unknown';
          }
        } else if (serviceRaw == null) {
          sanitized['serviceId'] = 'unknown';
        }

        // Safe defaults
        sanitized['status'] = sanitized['status'] ?? 'unknown';
        sanitized['serviceName'] =
            sanitized['serviceName'] ?? 'Unknown Service';
        sanitized['category'] = sanitized['category'] ?? 'general';
        sanitized['totalAmount'] = sanitized['totalAmount'] ?? 0;

        return sanitized;
      }
      return <String, dynamic>{};
    }).toList();
  }
}

class BookingDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingDetailsSheet({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final dynamic serviceVal = booking['serviceId'];
    final dynamic providerVal = booking['providerId'];
    String serviceTitle = 'Unknown';
    String serviceCategory = 'Unknown';
    String providerName = 'Unknown';
    String providerEmail = 'Unknown';
    String providerPhone = 'Unknown';

    if (serviceVal is Map<String, dynamic>) {
      serviceTitle = serviceVal['title'] as String? ?? 'Unknown';
      serviceCategory = serviceVal['category'] as String? ?? 'Unknown';
    } else if (serviceVal is String) {
      final titleMatch = RegExp(r"title:\s*'([^']+)'").firstMatch(serviceVal);
      final categoryMatch = RegExp(
        r"category:\s*'([^']+)'",
      ).firstMatch(serviceVal);
      serviceTitle =
          titleMatch?.group(1) ??
          (booking['serviceName'] as String? ?? 'Unknown');
      serviceCategory =
          categoryMatch?.group(1) ??
          (booking['category'] as String? ?? 'Unknown');
    }

    if (providerVal is Map<String, dynamic>) {
      providerName = providerVal['fullName'] as String? ?? 'Unknown';
      providerEmail = providerVal['email'] as String? ?? 'Unknown';
      providerPhone = providerVal['phoneNumber'] as String? ?? 'Unknown';
    } else if (providerVal is String) {
      providerName =
          RegExp(r"fullName:\s*'([^']+)'").firstMatch(providerVal)?.group(1) ??
          'Unknown';
      providerEmail =
          RegExp(r"email:\s*'([^']+)'").firstMatch(providerVal)?.group(1) ??
          'Unknown';
      providerPhone =
          RegExp(
            r"phoneNumber:\s*'([^']+)'",
          ).firstMatch(providerVal)?.group(1) ??
          'Unknown';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Booking Details',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Service details
          _buildDetailSection('Service Information', [
            _buildDetailItem('Service', serviceTitle),
            _buildDetailItem('Category', serviceCategory),
          ]),

          const SizedBox(height: 16),

          // Provider details
          _buildDetailSection('Provider Information', [
            _buildDetailItem('Name', providerName),
            _buildDetailItem('Email', providerEmail),
            _buildDetailItem('Phone', providerPhone),
          ]),

          const SizedBox(height: 16),

          // Booking details
          _buildDetailSection('Booking Information', [
            _buildDetailItem(
              'Date',
              _formatDate(
                (booking['sessionDate'] ?? booking['bookingDate']) as String?,
              ),
            ),
            _buildDetailItem(
              'Time',
              '${booking['startTime']} - ${booking['endTime']}',
            ),
            _buildDetailItem('Duration', '${booking['duration']} hours'),
            _buildDetailItem(
              'Total Amount',
              '${booking['totalAmount']} ${booking['currency']}',
            ),
            _buildDetailItem('Status', booking['status'] ?? 'Unknown'),
            _buildDetailItem(
              'Payment Status',
              booking['paymentStatus'] ?? 'Unknown',
            ),
          ]),

          if (booking['specialInstructions'] != null) ...[
            const SizedBox(height: 16),
            _buildDetailSection('Special Instructions', [
              Text(
                booking['specialInstructions'] as String,
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ]),
          ],

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Close'),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';

    try {
      final date = DateTime.parse(dateString);
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
      return dateString;
    }
  }
}
