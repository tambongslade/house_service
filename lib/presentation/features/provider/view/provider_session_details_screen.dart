import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ProviderSessionDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> session;

  const ProviderSessionDetailsScreen({
    super.key,
    required this.session,
  });

  @override
  State<ProviderSessionDetailsScreen> createState() => _ProviderSessionDetailsScreenState();
}

class _ProviderSessionDetailsScreenState extends State<ProviderSessionDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Map<String, dynamic> _parsedSeekerData = {};
  Map<String, dynamic> _parsedServiceData = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _parseSessionData();
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

  void _parseSessionData() {
    // Parse seeker data
    final seekerData = widget.session['seekerId'];
    if (seekerData is String && seekerData.isNotEmpty) {
      // Extract values using regex with simpler patterns
      final namePattern = RegExp(r"fullName:\s*'([^']+)'");
      final emailPattern = RegExp(r"email:\s*'([^']+)'");
      final phonePattern = RegExp(r"phoneNumber:\s*'([^']+)'");

      final nameMatch = namePattern.firstMatch(seekerData);
      final emailMatch = emailPattern.firstMatch(seekerData);
      final phoneMatch = phonePattern.firstMatch(seekerData);

      _parsedSeekerData = {
        'fullName': nameMatch?.group(1) ?? 'Unknown Customer',
        'email': emailMatch?.group(1) ?? 'No email provided',
        'phoneNumber': phoneMatch?.group(1) ?? 'No phone provided',
      };
    } else if (seekerData is Map<String, dynamic>) {
      _parsedSeekerData = seekerData;
    } else {
      _parsedSeekerData = {
        'fullName': 'Unknown Customer',
        'email': 'No email provided',
        'phoneNumber': 'No phone provided',
      };
    }

    // Parse service data
    final serviceData = widget.session['serviceId'];
    if (serviceData is String && serviceData.isNotEmpty) {
      // Extract service information using regex with simpler patterns
      final titlePattern = RegExp(r"title:\s*'([^']+)'");
      final categoryPattern = RegExp(r"category:\s*'([^']+)'");

      final titleMatch = titlePattern.firstMatch(serviceData);
      final categoryMatch = categoryPattern.firstMatch(serviceData);

      _parsedServiceData = {
        'title': titleMatch?.group(1) ?? widget.session['serviceName'] ?? 'Unknown Service',
        'category': categoryMatch?.group(1) ?? widget.session['category'] ?? 'other',
        'images': [],
      };
    } else if (serviceData is Map<String, dynamic>) {
      _parsedServiceData = serviceData;
    } else {
      _parsedServiceData = {
        'title': widget.session['serviceName'] ?? 'Unknown Service',
        'category': widget.session['category'] ?? 'other',
        'images': [],
      };
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1E293B),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Session Details',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: _shareSessionDetails,
        ),
      ],
    );
  }

  Widget _buildBody() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusHeader(),
              const SizedBox(height: 24),
              _buildCustomerInfo(),
              const SizedBox(height: 24),
              _buildServiceInfo(),
              const SizedBox(height: 24),
              _buildDateTimeInfo(),
              const SizedBox(height: 24),
              _buildLocationInfo(),
              const SizedBox(height: 24),
              _buildPricingInfo(),
              const SizedBox(height: 24),
              _buildNotesInfo(),
              const SizedBox(height: 24),
              _buildActionButtons(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    final status = widget.session['status']?.toString().toLowerCase() ?? 'pending';
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'pending_assignment':
        statusColor = const Color(0xFF6B7280);
        statusIcon = Icons.search;
        statusText = 'Looking for Provider';
        break;
      case 'pending':
        statusColor = const Color(0xFF8B5CF6);
        statusIcon = Icons.schedule;
        statusText = 'Pending';
        break;
      case 'confirmed':
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.check_circle;
        statusText = 'Confirmed';
        break;
      case 'completed':
        statusColor = const Color(0xFF3B82F6);
        statusIcon = Icons.task_alt;
        statusText = 'Completed';
        break;
      case 'cancelled':
        statusColor = const Color(0xFFEF4444);
        statusIcon = Icons.cancel;
        statusText = 'Cancelled';
        break;
      case 'in_progress':
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.hourglass_empty;
        statusText = 'In Progress';
        break;
      default:
        statusColor = const Color(0xFF6B7280);
        statusIcon = Icons.search;
        statusText = 'Looking for Provider';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withValues(alpha: 0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              statusIcon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          if (widget.session['cancellationReason'] != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.session['cancellationReason'],
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return _buildInfoCard(
      title: 'Customer Information',
      icon: Icons.person_outline,
      iconColor: const Color(0xFF3B82F6),
      children: [
        _buildInfoRow(
          'Name',
          _parsedSeekerData['fullName'] ?? 'Unknown Customer',
          Icons.badge_outlined,
        ),
        _buildInfoRow(
          'Email',
          _parsedSeekerData['email'] ?? 'No email provided',
          Icons.email_outlined,
        ),
        _buildInfoRow(
          'Phone',
          _parsedSeekerData['phoneNumber'] ?? 'No phone provided',
          Icons.phone_outlined,
          isPhone: true,
        ),
      ],
    );
  }

  Widget _buildServiceInfo() {
    return _buildInfoCard(
      title: 'Service Information',
      icon: Icons.build_outlined,
      iconColor: const Color(0xFF10B981),
      children: [
        _buildInfoRow(
          'Service',
          _parsedServiceData['title'] ?? widget.session['serviceName'] ?? 'Unknown Service',
          Icons.construction_outlined,
        ),
        _buildInfoRow(
          'Category',
          _formatCategory(_parsedServiceData['category'] ?? widget.session['category'] ?? 'other'),
          Icons.category_outlined,
        ),
        _buildInfoRow(
          'Service ID',
          widget.session['serviceId']?.toString().substring(0, 8) ?? 'N/A',
          Icons.fingerprint_outlined,
        ),
      ],
    );
  }

  Widget _buildDateTimeInfo() {
    final sessionDate = widget.session['sessionDate'] ?? '';
    final startTime = widget.session['startTime'] ?? '';
    final endTime = widget.session['endTime'] ?? '';
    final baseDuration = widget.session['baseDuration'] ?? 0;
    final overtimeHours = widget.session['overtimeHours'] ?? 0;

    return _buildInfoCard(
      title: 'Date & Time',
      icon: Icons.schedule_outlined,
      iconColor: const Color(0xFFF59E0B),
      children: [
        _buildInfoRow(
          'Date',
          _formatDate(sessionDate),
          Icons.calendar_today_outlined,
        ),
        _buildInfoRow(
          'Time',
          '$startTime - $endTime',
          Icons.access_time_outlined,
        ),
        _buildInfoRow(
          'Base Duration',
          '${baseDuration}h',
          Icons.timelapse_outlined,
        ),
        if (overtimeHours > 0)
          _buildInfoRow(
            'Overtime',
            '${overtimeHours}h',
            Icons.schedule_outlined,
          ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    // Note: The session data doesn't include location info, but we'll prepare for it
    final location = widget.session['serviceLocation'] ?? widget.session['location'] ?? 'Not specified';
    final address = widget.session['serviceAddress'] ?? widget.session['address'] ?? 'Address not provided';

    return _buildInfoCard(
      title: 'Location Information',
      icon: Icons.location_on_outlined,
      iconColor: const Color(0xFFEF4444),
      children: [
        _buildInfoRow(
          'Location',
          location,
          Icons.place_outlined,
        ),
        _buildInfoRow(
          'Address',
          address,
          Icons.home_outlined,
        ),
        const SizedBox(height: 16),
        _buildNavigationButton(address),
      ],
    );
  }

  Widget _buildPricingInfo() {
    final basePrice = widget.session['basePrice'] ?? 0;
    final overtimePrice = widget.session['overtimePrice'] ?? 0;
    final totalAmount = widget.session['totalAmount'] ?? 0;
    final currency = widget.session['currency'] ?? 'FCFA';
    final paymentStatus = widget.session['paymentStatus'] ?? 'pending';

    return _buildInfoCard(
      title: 'Pricing Information',
      icon: Icons.payments_outlined,
      iconColor: const Color(0xFF8B5CF6),
      children: [
        _buildInfoRow(
          'Base Price',
          '$basePrice $currency',
          Icons.attach_money_outlined,
        ),
        if (overtimePrice > 0)
          _buildInfoRow(
            'Overtime Price',
            '$overtimePrice $currency',
            Icons.schedule_outlined,
          ),
        _buildInfoRow(
          'Total Amount',
          '$totalAmount $currency',
          Icons.account_balance_wallet_outlined,
          isBold: true,
        ),
        _buildInfoRow(
          'Payment Status',
          _formatPaymentStatus(paymentStatus),
          Icons.payment_outlined,
          statusColor: _getPaymentStatusColor(paymentStatus),
        ),
      ],
    );
  }

  Widget _buildNotesInfo() {
    final notes = widget.session['notes'] ?? '';
    final assignmentNotes = widget.session['assignmentNotes'] ?? '';

    if (notes.isEmpty && assignmentNotes.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildInfoCard(
      title: 'Additional Notes',
      icon: Icons.note_outlined,
      iconColor: const Color(0xFF64748B),
      children: [
        if (notes.isNotEmpty)
          _buildNoteSection('Customer Notes', notes),
        if (assignmentNotes.isNotEmpty) ...[
          if (notes.isNotEmpty) const SizedBox(height: 12),
          _buildNoteSection('Assignment Notes', assignmentNotes),
        ],
      ],
    );
  }

  Widget _buildNoteSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButton(String address) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: address != 'Address not provided' ? () => _openGoogleMaps(address) : null,
        icon: const Icon(Icons.directions_outlined, size: 20),
        label: const Text('Navigate with Google Maps'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4285F4),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final status = widget.session['status']?.toString().toLowerCase() ?? 'pending';
    
    return Column(
      children: [
        if (status == 'pending_assignment') ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF6B7280).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF6B7280).withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  color: const Color(0xFF6B7280),
                  size: 20,
                ),
                const SizedBox(height: 8),
                const Text(
                  'This service request is looking for an available provider',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ] else if (status == 'pending') ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _declineSession,
                  icon: const Icon(Icons.close, size: 20),
                  label: const Text('Decline'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _acceptSession,
                  icon: const Icon(Icons.check, size: 20),
                  label: const Text('Accept'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ] else if (status == 'confirmed') ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _startSession,
              icon: const Icon(Icons.play_arrow, size: 20),
              label: const Text('Start Session'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            ),
          ),
        ] else if (status == 'in_progress') ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _completeSession,
              icon: const Icon(Icons.check_circle, size: 20),
              label: const Text('Mark as Complete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, 
    IconData icon, {
    bool isBold = false,
    bool isPhone = false,
    Color? statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Flexible(
                  child: GestureDetector(
                    onTap: isPhone && value != 'No phone provided' ? () => _callPhoneNumber(value) : null,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        color: statusColor ?? (isPhone && value != 'No phone provided' ? const Color(0xFF3B82F6) : const Color(0xFF1E293B)),
                        fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                        decoration: isPhone && value != 'No phone provided' ? TextDecoration.underline : null,
                      ),
                      textAlign: TextAlign.end,
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

  // Utility methods
  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'Not specified';
    try {
      final date = DateTime.parse(dateString);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatCategory(String category) {
    return category.substring(0, 1).toUpperCase() + category.substring(1);
  }

  String _formatPaymentStatus(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Paid';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      default:
        return status;
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'failed':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }

  // Action methods
  Future<void> _openGoogleMaps(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$encodedAddress';
    
    try {
      final uri = Uri.parse(googleMapsUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Could not open Google Maps');
      }
    } catch (e) {
      _showErrorSnackBar('Error opening Google Maps: ${e.toString()}');
    }
  }

  Future<void> _callPhoneNumber(String phoneNumber) async {
    try {
      final uri = Uri.parse('tel:$phoneNumber');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showErrorSnackBar('Could not open phone app');
      }
    } catch (e) {
      _showErrorSnackBar('Error opening phone app: ${e.toString()}');
    }
  }

  void _shareSessionDetails() {
    final sessionId = widget.session['id'] ?? 'Unknown';
    final serviceName = _parsedServiceData['title'] ?? widget.session['serviceName'] ?? 'Unknown Service';
    final customerName = _parsedSeekerData['fullName'] ?? 'Unknown Customer';
    final sessionDate = _formatDate(widget.session['sessionDate'] ?? '');
    final status = widget.session['status'] ?? 'pending';

    final shareText = '''
Session Details:
ID: $sessionId
Service: $serviceName
Customer: $customerName
Date: $sessionDate
Status: $status
Amount: ${widget.session['totalAmount']} ${widget.session['currency']}
''';

    Clipboard.setData(ClipboardData(text: shareText));
    _showSuccessSnackBar('Session details copied to clipboard');
  }

  void _acceptSession() {
    // TODO: Implement accept session API call
    _showSuccessSnackBar('Session accepted successfully');
  }

  void _declineSession() {
    // TODO: Implement decline session API call
    _showErrorSnackBar('Session declined');
  }

  void _startSession() {
    // TODO: Implement start session API call
    _showSuccessSnackBar('Session started');
  }

  void _completeSession() {
    // TODO: Implement complete session API call
    _showSuccessSnackBar('Session completed');
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}