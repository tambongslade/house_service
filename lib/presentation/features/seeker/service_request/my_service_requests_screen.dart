import 'package:flutter/material.dart';
import '../../../../core/models/service_request_models.dart';
import '../../../../core/services/api_service.dart';
import '../tracking/seeker_tracking_screen.dart';

class MyServiceRequestsScreen extends StatefulWidget {
  const MyServiceRequestsScreen({super.key});

  @override
  State<MyServiceRequestsScreen> createState() =>
      _MyServiceRequestsScreenState();
}

class _MyServiceRequestsScreenState extends State<MyServiceRequestsScreen> {
  final _apiService = ApiService();
  List<ServiceRequestModel> _requests = [];
  bool _isLoading = true;
  String? _selectedStatusFilter;
  int _currentPage = 1;
  bool _hasMoreData = true;
  final _scrollController = ScrollController();

  final List<String> _statusFilters = [
    'All',
    'Pending',
    'Confirmed',
    'In Progress',
    'Completed',
    'Cancelled',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    _loadRequests();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (!_isLoading && _hasMoreData) {
        _loadMoreRequests();
      }
    }
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMoreData = true;
    });

    try {
      final statusParam =
          _selectedStatusFilter?.toLowerCase() == 'all'
              ? null
              : _selectedStatusFilter?.toLowerCase();

      final response = await _apiService.getMyServiceRequests(
        status: statusParam,
        page: _currentPage,
        limit: 20,
      );

      if (response.isSuccess && response.data != null) {
        final requestsResponse = ServiceRequestsResponse.fromJson(
          response.data!,
        );

        if (mounted) {
          setState(() {
            _requests = requestsResponse.requests;
            _hasMoreData = requestsResponse.requests.length >= 20;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        if (mounted) {
          _showError(response.error ?? 'Failed to load service requests');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showError('Error loading service requests: $e');
      }
    }
  }

  Future<void> _loadMoreRequests() async {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });

    try {
      _currentPage++;
      final statusParam =
          _selectedStatusFilter?.toLowerCase() == 'all'
              ? null
              : _selectedStatusFilter?.toLowerCase();

      final response = await _apiService.getMyServiceRequests(
        status: statusParam,
        page: _currentPage,
        limit: 20,
      );

      if (response.isSuccess && response.data != null) {
        final requestsResponse = ServiceRequestsResponse.fromJson(
          response.data!,
        );

        if (mounted) {
          setState(() {
            _requests.addAll(requestsResponse.requests);
            _hasMoreData = requestsResponse.requests.length >= 20;
            _isLoading = false;
          });
        }
      } else {
        _currentPage--; // Revert page increment on failure
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      _currentPage--; // Revert page increment on failure
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Color _getStatusColor(ServiceRequestStatus status) {
    switch (status) {
      case ServiceRequestStatus.pending:
        return Colors.orange;
      case ServiceRequestStatus.confirmed:
        return Colors.blue;
      case ServiceRequestStatus.inProgress:
        return Colors.purple;
      case ServiceRequestStatus.completed:
        return Colors.green;
      case ServiceRequestStatus.cancelled:
        return Colors.red;
      case ServiceRequestStatus.rejected:
        return Colors.red.shade800;
    }
  }

  IconData _getStatusIcon(ServiceRequestStatus status) {
    switch (status) {
      case ServiceRequestStatus.pending:
        return Icons.pending;
      case ServiceRequestStatus.confirmed:
        return Icons.check_circle;
      case ServiceRequestStatus.inProgress:
        return Icons.work;
      case ServiceRequestStatus.completed:
        return Icons.done_all;
      case ServiceRequestStatus.cancelled:
        return Icons.cancel;
      case ServiceRequestStatus.rejected:
        return Icons.block;
    }
  }

  String _getCategoryDisplayName(String category) {
    switch (category.toLowerCase()) {
      case 'cleaning':
        return 'Cleaning';
      case 'plumbing':
        return 'Plumbing';
      case 'electrical':
        return 'Electrical';
      case 'painting':
        return 'Painting';
      case 'gardening':
        return 'Gardening';
      case 'carpentry':
        return 'Carpentry';
      case 'cooking':
        return 'Cooking';
      case 'tutoring':
        return 'Tutoring';
      case 'beauty':
        return 'Beauty';
      case 'maintenance':
        return 'Maintenance';
      default:
        return category;
    }
  }

  Future<void> _refreshRequests() async {
    await _loadRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Service Requests',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshRequests,
          ),
        ],
      ),
      body: Column(
        children: [
          // Status filter
          Container(
            height: 50,
            margin: const EdgeInsets.all(16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _statusFilters.length,
              itemBuilder: (context, index) {
                final status = _statusFilters[index];
                final isSelected = _selectedStatusFilter == status;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatusFilter = selected ? status : null;
                      });
                      _loadRequests();
                    },
                    selectedColor: Colors.blue.shade100,
                    backgroundColor: Colors.grey.shade100,
                    side: BorderSide.none,
                  ),
                );
              },
            ),
          ),

          // Requests list
          Expanded(
            child:
                _isLoading && _requests.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _requests.isEmpty
                    ? RefreshIndicator(
                      onRefresh: _refreshRequests,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          height: MediaQuery.of(context).size.height - 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.request_page,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No service requests found',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Your service requests will appear here',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey.shade500),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Pull down to refresh',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey.shade400),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _refreshRequests,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount:
                            _requests.length +
                            (_isLoading && _requests.isNotEmpty ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _requests.length && _isLoading) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final request = _requests[index];
                          return _buildRequestCard(request);
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(ServiceRequestModel request) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(request.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1), width: 1),
      ),
      child: GestureDetector(
        onTap: () => _showRequestDetails(request),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status and cost
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(request.status),
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          request.statusDisplayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Cost
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Text(
                      '${request.estimatedCost.round()} FCFA',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Service category with icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(request.category),
                      size: 20,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getCategoryDisplayName(request.category),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        if (request.description != null)
                          Text(
                            request.description!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Date, time, and duration row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Date
                    Expanded(
                      child: _buildInfoItem(
                        Icons.calendar_today,
                        'Date',
                        request.serviceDate.isNotEmpty
                            ? _formatDisplayDate(request.serviceDate)
                            : 'N/A',
                        Colors.blue.shade600,
                      ),
                    ),
                    Container(
                      height: 30,
                      width: 1,
                      color: Colors.grey.shade300,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    // Time
                    Expanded(
                      child: _buildInfoItem(
                        Icons.access_time,
                        'Time',
                        request.startTime.isNotEmpty
                            ? request.startTime
                            : 'N/A',
                        Colors.orange.shade600,
                      ),
                    ),
                    Container(
                      height: 30,
                      width: 1,
                      color: Colors.grey.shade300,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    // Duration
                    Expanded(
                      child: _buildInfoItem(
                        Icons.timelapse,
                        'Duration',
                        request.duration > 0
                            ? '${request.duration.toStringAsFixed(request.duration == request.duration.roundToDouble() ? 0 : 1)}h'
                            : 'N/A',
                        Colors.purple.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Footer with location and created date
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    request.province,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Created ${_formatDate(request.createdAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons for In Progress requests
            if (request.status == ServiceRequestStatus.inProgress) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showRequestDetails(request),
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToTracking(request),
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
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'cleaning':
        return Icons.cleaning_services;
      case 'plumbing':
        return Icons.plumbing;
      case 'electrical':
        return Icons.electrical_services;
      case 'painting':
        return Icons.format_paint;
      case 'gardening':
        return Icons.local_florist;
      case 'carpentry':
        return Icons.build;
      case 'cooking':
        return Icons.restaurant;
      case 'tutoring':
        return Icons.school;
      case 'beauty':
        return Icons.face;
      case 'maintenance':
        return Icons.build_circle;
      default:
        return Icons.home_repair_service;
    }
  }

  String _formatDisplayDate(String dateString) {
    if (dateString.isEmpty) return 'N/A';

    try {
      // Handle different date formats
      DateTime date;
      if (dateString.contains('-')) {
        // YYYY-MM-DD format
        date = DateTime.parse(dateString);
      } else {
        // Try other formats or return the original string if can't parse
        return dateString;
      }

      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      final yesterday = now.subtract(const Duration(days: 1));

      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        return 'Today';
      } else if (date.year == tomorrow.year &&
          date.month == tomorrow.month &&
          date.day == tomorrow.day) {
        return 'Tomorrow';
      } else if (date.year == yesterday.year &&
          date.month == yesterday.month &&
          date.day == yesterday.day) {
        return 'Yesterday';
      } else {
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      // If parsing fails, return the original string or a fallback
      return dateString.isNotEmpty ? dateString : 'Invalid Date';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showRequestDetails(ServiceRequestModel request) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Request Details - ${_getCategoryDisplayName(request.category)}',
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('Status', request.statusDisplayName),
                  _buildDetailRow('Date', request.serviceDate),
                  _buildDetailRow('Time', request.startTime),
                  _buildDetailRow('Duration', '${request.duration} hours'),
                  _buildDetailRow('Province', request.province),
                  _buildDetailRow(
                    'Cost',
                    '${request.estimatedCost.round()} FCFA',
                  ),
                  if (request.description != null)
                    _buildDetailRow('Description', request.description!),
                  if (request.specialInstructions != null)
                    _buildDetailRow(
                      'Special Instructions',
                      request.specialInstructions!,
                    ),
                  if (request.providerName != null)
                    _buildDetailRow('Provider', request.providerName!),
                  _buildDetailRow('Created', request.createdAt.toString()),
                  if (request.updatedAt != null)
                    _buildDetailRow('Updated', request.updatedAt.toString()),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              if (request.status == ServiceRequestStatus.pending)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showCancelDialog(request);
                  },
                  child: const Text(
                    'Cancel Request',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value),
        ],
      ),
    );
  }

  void _showCancelDialog(ServiceRequestModel request) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel Service Request'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Are you sure you want to cancel this service request?',
                ),
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
                child: const Text('Keep Request'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _cancelRequest(
                    request.id,
                    reasonController.text.trim().isEmpty
                        ? 'Cancelled by user'
                        : reasonController.text.trim(),
                  );
                },
                child: const Text(
                  'Cancel Request',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _cancelRequest(String requestId, String reason) async {
    try {
      final response = await _apiService.cancelServiceRequest(
        requestId,
        reason,
      );

      if (response.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Service request cancelled successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _refreshRequests();
        }
      } else {
        _showError(response.error ?? 'Failed to cancel request');
      }
    } catch (e) {
      _showError('Error cancelling request: $e');
    }
  }

  void _navigateToTracking(ServiceRequestModel request) {
    // For service requests, we need to get the session ID from the request
    // Since service requests might not have a direct session ID, we'll use the request ID
    final sessionId = request.id;
    final providerName = request.providerName ?? 'Provider';
    final serviceName = _getCategoryDisplayName(request.category);

    if (sessionId.isEmpty) {
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
}
