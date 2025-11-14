import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:house_service/core/state/app_state.dart';
import 'package:house_service/core/models/booking_models.dart';

class SeekerOrdersScreen extends StatefulWidget {
  const SeekerOrdersScreen({super.key});

  @override
  State<SeekerOrdersScreen> createState() => _SeekerOrdersScreenState();
}

class _SeekerOrdersScreenState extends State<SeekerOrdersScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<BookingModel> _bookings = [];
  Map<String, dynamic> _summary = {};
  bool _loading = true;
  String _error = '';
  String _selectedFilter = '';

  final List<Map<String, String>> _statusFilters = [
    {'key': 'active', 'label': 'Active'},
    {'key': 'completed', 'label': 'Completed'},
    {'key': 'cancelled', 'label': 'Cancelled'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedFilter = 'active';
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

      // Convert our filter to API status
      String? apiStatus = _mapFilterToApiStatus(status ?? _selectedFilter);

      final response = await appState.apiService.getSessionsAsSeeker(
        status: apiStatus,
        page: 1,
        limit: 50,
      );

      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        final bookingsData = response.data!['sessions'] as List? ?? [];
        final sanitizedData = _sanitizeSessionData(bookingsData);
        final bookings =
            sanitizedData.map((json) => BookingModel.fromJson(json)).toList();

        setState(() {
          _bookings = bookings;
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
      if (!mounted) return;
      setState(() {
        _error = 'Network error: ${e.toString()}';
        _loading = false;
      });
    }
  }

  String? _mapFilterToApiStatus(String filter) {
    switch (filter) {
      case 'active':
        return null; // Return all active statuses (pending, confirmed, in_progress)
      case 'completed':
        return 'completed';
      case 'cancelled':
        return 'cancelled';
      default:
        return null;
    }
  }

  List<BookingModel> _getFilteredBookings(String status) {
    switch (status) {
      case 'active':
        return _bookings.where((booking) => booking.status.isActive).toList();
      case 'completed':
        return _bookings
            .where((booking) => booking.status == BookingStatus.completed)
            .toList();
      case 'cancelled':
        return _bookings
            .where((booking) => booking.status == BookingStatus.cancelled)
            .toList();
      default:
        return _bookings;
    }
  }

  Future<void> _cancelBooking(BookingModel booking, String reason) async {
    if (!mounted) return;

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final response = await appState.apiService.cancelBooking(
        booking.id,
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
        if (!mounted) return;
        _loadBookings(status: _selectedFilter);
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
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Orders',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Averta',
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2B6CB0),
          unselectedLabelColor: const Color(0xFF718096),
          labelStyle: const TextStyle(
            fontFamily: 'Averta',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Averta',
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          indicatorColor: const Color(0xFF2B6CB0),
          indicatorWeight: 3,
          onTap: (index) {
            final filter = _statusFilters[index]['key']!;
            setState(() {
              _selectedFilter = filter;
            });
            _loadBookings(status: filter);
          },
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadBookings(status: _selectedFilter),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList('active'),
          _buildOrdersList('completed'),
          _buildOrdersList('cancelled'),
        ],
      ),
    );
  }

  Widget _buildOrdersList(String status) {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading your bookings...',
              style: TextStyle(fontFamily: 'Averta', color: Color(0xFF718096)),
            ),
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
            const Text(
              'Failed to load bookings',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Averta',
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Averta',
                color: Color(0xFF718096),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadBookings(status: _selectedFilter),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B6CB0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontFamily: 'Averta',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final filteredBookings = _getFilteredBookings(status);

    if (filteredBookings.isEmpty) {
      return _buildEmptyState(status);
    }

    return RefreshIndicator(
      onRefresh: () => _loadBookings(status: _selectedFilter),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: filteredBookings.length,
        itemBuilder: (context, index) {
          final booking = filteredBookings[index];
          return _buildOrderCard(booking);
        },
      ),
    );
  }

  Widget _buildEmptyState(String status) {
    String message;
    IconData icon;

    switch (status) {
      case 'active':
        message = 'No active orders\nBook a service to get started!';
        icon = Icons.pending_actions;
        break;
      case 'completed':
        message =
            'No completed orders yet\nYour order history will appear here';
        icon = Icons.check_circle_outline;
        break;
      case 'cancelled':
        message = 'No cancelled orders\nGreat! Keep it that way';
        icon = Icons.cancel_outlined;
        break;
      default:
        message = 'No orders found';
        icon = Icons.inbox;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: const Color(0xFF718096)),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Averta',
              color: Color(0xFF718096),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (status == 'active') ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to home tab
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B6CB0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Book a Service',
                style: TextStyle(
                  fontFamily: 'Averta',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderCard(BookingModel booking) {
    Color statusColor;
    IconData statusIcon;
    String displayStatus;

    if (booking.status.isActive) {
      statusColor = const Color(0xFFED8936);
      statusIcon = Icons.pending;
      displayStatus = 'ACTIVE';
    } else {
      switch (booking.status) {
        case BookingStatus.completed:
          statusColor = const Color(0xFF48BB78);
          statusIcon = Icons.check_circle;
          displayStatus = 'COMPLETED';
          break;
        case BookingStatus.cancelled:
          statusColor = const Color(0xFFE53E3E);
          statusIcon = Icons.cancel;
          displayStatus = 'CANCELLED';
          break;
        default:
          statusColor = const Color(0xFF718096);
          statusIcon = Icons.help;
          displayStatus = booking.status.displayName.toUpperCase();
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with service name and status
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.service?.title ?? 'Unknown Service',
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'Averta',
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 16, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      displayStatus,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Averta',
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Order details
          Row(
            children: [
              Icon(Icons.person, size: 16, color: const Color(0xFF718096)),
              const SizedBox(width: 8),
              Text(
                booking.provider?.fullName ?? 'Unknown Provider',
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Averta',
                  color: Color(0xFF718096),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: const Color(0xFF718096),
              ),
              const SizedBox(width: 8),
              Text(
                booking.displayDate,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Averta',
                  color: Color(0xFF718096),
                ),
              ),
              const Spacer(),
              Text(
                booking.formattedAmount,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Averta',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              if (booking.status.isActive) ...[
                if (booking.canBeCancelled) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showCancelDialog(booking),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE53E3E)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Averta',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE53E3E),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showBookingDetails(booking),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2B6CB0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(
                        fontFamily: 'Averta',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ] else if (booking.status == BookingStatus.completed) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showBookingDetails(booking),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2B6CB0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(
                        fontFamily: 'Averta',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2B6CB0),
                      ),
                    ),
                  ),
                ),
                if (booking.canBeRated) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Rate service
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF48BB78),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Rate',
                        style: TextStyle(
                          fontFamily: 'Averta',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ] else if (booking.status == BookingStatus.cancelled) ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showBookingDetails(booking),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2B6CB0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(
                        fontFamily: 'Averta',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showBookingDetails(BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => BookingDetailsSheet(booking: booking),
    );
  }

  void _showCancelDialog(BookingModel booking) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Cancel Booking',
              style: TextStyle(
                fontFamily: 'Averta',
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Are you sure you want to cancel this booking?',
                  style: const TextStyle(
                    fontFamily: 'Averta',
                    color: Color(0xFF718096),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason for cancellation',
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(fontFamily: 'Averta'),
                  ),
                  style: const TextStyle(fontFamily: 'Averta'),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Keep Booking',
                  style: TextStyle(
                    fontFamily: 'Averta',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _cancelBooking(
                    booking,
                    reasonController.text.trim().isEmpty
                        ? 'Cancelled by user'
                        : reasonController.text.trim(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Cancel Booking',
                  style: TextStyle(
                    fontFamily: 'Averta',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  List<Map<String, dynamic>> _sanitizeSessionData(List<dynamic> rawSessions) {
    return rawSessions.map((session) {
      if (session is Map<String, dynamic>) {
        final sanitized = Map<String, dynamic>.from(session);

        // Normalize id field expected by BookingModel
        if (sanitized['_id'] == null && sanitized['id'] != null) {
          sanitized['_id'] = sanitized['id'];
        }

        // Normalize bookingDate key from sessionDate
        if (sanitized['bookingDate'] == null &&
            sanitized['sessionDate'] != null) {
          sanitized['bookingDate'] = sanitized['sessionDate'];
        }

        // Compute duration if missing (baseDuration + overtimeHours)
        if (sanitized['duration'] == null) {
          final base = (sanitized['baseDuration'] as num?)?.toInt() ?? 0;
          final overtime = (sanitized['overtimeHours'] as num?)?.toInt() ?? 0;
          sanitized['duration'] = base + overtime;
        }

        // Fix malformed providerId
        final providerRaw = sanitized['providerId'];
        if (providerRaw is String) {
          try {
            final idMatch = RegExp(
              r"ObjectId\('([^']+)'\)",
            ).firstMatch(providerRaw);
            sanitized['providerId'] =
                idMatch != null ? idMatch.group(1) : 'unknown';
          } catch (_) {
            sanitized['providerId'] = 'unknown';
          }
        } else if (providerRaw == null) {
          sanitized['providerId'] = 'unknown';
        }

        // Fix malformed serviceId and synthesize minimal service object
        final serviceRaw = sanitized['serviceId'];
        if (serviceRaw is String) {
          String extractedId = 'unknown';
          String? extractedTitle;
          String? extractedCategory;
          try {
            final idMatch = RegExp(
              r"ObjectId\('([^']+)'\)",
            ).firstMatch(serviceRaw);
            if (idMatch != null) extractedId = idMatch.group(1)!;
            extractedTitle = RegExp(
              r"title:\s*'([^']+)'",
            ).firstMatch(serviceRaw)?.group(1);
            extractedCategory = RegExp(
              r"category:\s*'([^']+)'",
            ).firstMatch(serviceRaw)?.group(1);
          } catch (_) {}

          sanitized['serviceId'] = {
            '_id': extractedId,
            'title':
                extractedTitle ?? sanitized['serviceName'] ?? 'Unknown Service',
            'category': extractedCategory ?? sanitized['category'] ?? 'general',
            'pricePerHour':
                (sanitized['basePrice'] as num?)?.toDouble() ??
                (sanitized['totalAmount'] as num?)?.toDouble() ??
                0.0,
            'currency': sanitized['currency'] ?? 'FCFA',
            // Optional fields with safe defaults for ServiceModel
            'description': sanitized['description'] ?? '',
            'location': sanitized['location'] ?? '',
            'images': sanitized['images'] ?? <String>[],
            'tags': sanitized['tags'] ?? <String>[],
            'isAvailable': sanitized['isAvailable'] ?? true,
            'minimumBookingHours': sanitized['minimumBookingHours'] ?? 1,
            'maximumBookingHours': sanitized['maximumBookingHours'] ?? 8,
            'averageRating': sanitized['averageRating'] ?? 0.0,
            'totalReviews': sanitized['totalReviews'] ?? 0,
          };
        } else if (serviceRaw == null) {
          sanitized['serviceId'] = {
            '_id': 'unknown',
            'title': sanitized['serviceName'] ?? 'Unknown Service',
            'category': sanitized['category'] ?? 'general',
            'pricePerHour':
                (sanitized['basePrice'] as num?)?.toDouble() ??
                (sanitized['totalAmount'] as num?)?.toDouble() ??
                0.0,
            'currency': sanitized['currency'] ?? 'FCFA',
            'description': '',
            'location': '',
            'images': <String>[],
            'tags': <String>[],
            'isAvailable': true,
            'minimumBookingHours': 1,
            'maximumBookingHours': 8,
            'averageRating': 0.0,
            'totalReviews': 0,
          };
        }

        // Ensure all required fields have safe defaults
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
  final BookingModel booking;

  const BookingDetailsSheet({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
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
            style: const TextStyle(
              fontSize: 24,
              fontFamily: 'Averta',
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 20),

          // Service details
          _buildDetailSection('Service Information', [
            _buildDetailItem(
              'Service',
              booking.service?.title ?? 'Unknown Service',
            ),
            _buildDetailItem(
              'Category',
              booking.service?.category ?? 'Unknown',
            ),
            if (booking.service?.pricePerHour != null)
              _buildDetailItem(
                'Price per Hour',
                '${booking.service!.pricePerHour.toStringAsFixed(0)} ${booking.currency}',
              ),
          ]),

          const SizedBox(height: 16),

          // Provider details
          _buildDetailSection('Provider Information', [
            _buildDetailItem(
              'Name',
              booking.provider?.fullName ?? 'Unknown Provider',
            ),
            if (booking.provider?.email != null)
              _buildDetailItem('Email', booking.provider!.email),
            if (booking.provider?.phoneNumber != null)
              _buildDetailItem('Phone', booking.provider!.phoneNumber),
          ]),

          const SizedBox(height: 16),

          // Booking details
          _buildDetailSection('Booking Information', [
            _buildDetailItem('Date', _formatDate(booking.bookingDate)),
            _buildDetailItem(
              'Time',
              '${booking.startTime} - ${booking.endTime}',
            ),
            _buildDetailItem('Duration', '${booking.duration} hours'),
            _buildDetailItem('Total Amount', booking.formattedAmount),
            _buildDetailItem('Status', booking.status.displayName),
            _buildDetailItem(
              'Payment Status',
              booking.paymentStatus.displayName,
            ),
            if (booking.serviceLocation != null)
              _buildDetailItem('Location', booking.serviceLocation!),
          ]),

          if (booking.specialInstructions != null &&
              booking.specialInstructions!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildDetailSection('Special Instructions', [
              Text(
                booking.specialInstructions!,
                style: const TextStyle(
                  fontFamily: 'Averta',
                  color: Color(0xFF718096),
                ),
              ),
            ]),
          ],

          if (booking.providerNotes != null &&
              booking.providerNotes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildDetailSection('Provider Notes', [
              Text(
                booking.providerNotes!,
                style: const TextStyle(
                  fontFamily: 'Averta',
                  color: Color(0xFF718096),
                ),
              ),
            ]),
          ],

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B6CB0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Close',
                style: TextStyle(
                  fontFamily: 'Averta',
                  fontWeight: FontWeight.w600,
                ),
              ),
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
            fontFamily: 'Averta',
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAFC),
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
              style: const TextStyle(
                fontFamily: 'Averta',
                fontWeight: FontWeight.w500,
                color: Color(0xFF718096),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Averta',
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
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
  }
}
