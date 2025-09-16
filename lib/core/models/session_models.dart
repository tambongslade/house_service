import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Enhanced session model with location and seeker information
class SessionModel {
  final String id;
  final String seekerId;
  final String? providerId;
  final String serviceId;
  final String serviceName;
  final String category;
  final DateTime sessionDate;
  final String startTime;
  final String endTime;
  final int baseDuration;
  final double overtimeHours;
  final double basePrice;
  final double overtimePrice;
  final double totalAmount;
  final String currency;
  final SessionStatus status;
  final PaymentStatus paymentStatus;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // NEW: Location where provider needs to go
  final ServiceLocation? serviceLocation;
  
  // NEW: Client contact information
  final SeekerInfo? seeker;

  const SessionModel({
    required this.id,
    required this.seekerId,
    this.providerId,
    required this.serviceId,
    required this.serviceName,
    required this.category,
    required this.sessionDate,
    required this.startTime,
    required this.endTime,
    required this.baseDuration,
    required this.overtimeHours,
    required this.basePrice,
    required this.overtimePrice,
    required this.totalAmount,
    required this.currency,
    required this.status,
    required this.paymentStatus,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.serviceLocation,
    this.seeker,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle both _id (MongoDB) and id formats - with null safety
      final sessionId = json['_id'] as String? ?? json['id'] as String? ?? '';
      if (sessionId.isEmpty) {
        throw FormatException('Session ID is required but not provided');
      }
      
      // Handle missing providerId (for pending_assignment status)
      final providerId = json['providerId'] as String? ?? '';
      
      // Handle serviceLocation - can be string or object
      ServiceLocation? serviceLocation;
      if (json['serviceLocation'] != null) {
        if (json['serviceLocation'] is Map<String, dynamic>) {
          serviceLocation = ServiceLocation.fromJson(json['serviceLocation'] as Map<String, dynamic>);
        } else if (json['serviceLocation'] is String) {
          // Create ServiceLocation from string location and separate address field
          final locationStr = json['serviceLocation'] as String;
          final addressStr = json['serviceAddress'] as String? ?? 'Address not provided';
          
          serviceLocation = ServiceLocation(
            latitude: 0.0, // Default coordinates for string-based locations
            longitude: 0.0,
            address: addressStr,
            province: locationStr,
          );
        }
      }
      
      return SessionModel(
        id: sessionId,
        seekerId: json['seekerId'] as String? ?? '',
        providerId: providerId.isEmpty ? null : providerId,
        serviceId: json['serviceId'] as String? ?? '',
        serviceName: json['serviceName'] as String? ?? 'Unknown Service',
        category: json['category'] as String? ?? 'other',
        sessionDate: json['sessionDate'] != null 
            ? DateTime.parse(json['sessionDate'] as String)
            : DateTime.now(),
        startTime: json['startTime'] as String? ?? '09:00',
        endTime: json['endTime'] as String? ?? '17:00',
        baseDuration: (json['baseDuration'] as num?)?.toInt() ?? 1,
        overtimeHours: (json['overtimeHours'] as num?)?.toDouble() ?? 0.0,
        basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
        overtimePrice: (json['overtimePrice'] as num?)?.toDouble() ?? 0.0,
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
        currency: json['currency'] as String? ?? 'FCFA',
        status: SessionStatus.fromString(json['status'] as String? ?? 'pending_assignment'),
        paymentStatus: PaymentStatus.fromString(json['paymentStatus'] as String? ?? 'pending'),
        notes: json['notes'] as String?,
        createdAt: json['createdAt'] != null 
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null 
            ? DateTime.parse(json['updatedAt'] as String)
            : DateTime.now(),
        serviceLocation: serviceLocation,
        seeker: json['seeker'] != null && json['seeker'] is Map<String, dynamic>
            ? SeekerInfo.fromJson(json['seeker'] as Map<String, dynamic>)
            : null,
      );
    } catch (e) {
      print('Error parsing SessionModel from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seekerId': seekerId,
      if (providerId != null) 'providerId': providerId,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'category': category,
      'sessionDate': sessionDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'baseDuration': baseDuration,
      'overtimeHours': overtimeHours,
      'basePrice': basePrice,
      'overtimePrice': overtimePrice,
      'totalAmount': totalAmount,
      'currency': currency,
      'status': status.value,
      'paymentStatus': paymentStatus.value,
      if (notes != null) 'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (serviceLocation != null) 'serviceLocation': serviceLocation!.toJson(),
      if (seeker != null) 'seeker': seeker!.toJson(),
    };
  }

  String get displayDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDay = DateTime(sessionDate.year, sessionDate.month, sessionDate.day);
    
    if (sessionDay == today) {
      return 'Today, $startTime';
    } else if (sessionDay == today.add(const Duration(days: 1))) {
      return 'Tomorrow, $startTime';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[sessionDate.month - 1]} ${sessionDate.day}, ${sessionDate.year}';
    }
  }

  String get formattedAmount {
    return '${totalAmount.toStringAsFixed(0)} $currency';
  }

  String get formattedDuration {
    if (overtimeHours > 0) {
      return '${baseDuration}h + ${overtimeHours}h overtime';
    }
    return '${baseDuration}h';
  }

  bool get canBeCancelled {
    return status == SessionStatus.pendingAssignment || 
           status == SessionStatus.pending || 
           status == SessionStatus.confirmed;
  }

  bool get canBeRated {
    return status == SessionStatus.completed && paymentStatus == PaymentStatus.paid;
  }

  bool get canStartTracking {
    return status == SessionStatus.confirmed || status == SessionStatus.inProgress;
  }

  bool get canAcceptOrDecline {
    return status == SessionStatus.pending;
  }

  bool get isAwaitingProvider {
    return status == SessionStatus.pendingAssignment;
  }

  bool get isExpired {
    final now = DateTime.now();
    final sessionDateTime = DateTime(
      sessionDate.year,
      sessionDate.month, 
      sessionDate.day,
      int.parse(endTime.split(':')[0]),
      int.parse(endTime.split(':')[1]),
    );
    return now.isAfter(sessionDateTime) && 
           (status == SessionStatus.pendingAssignment || status == SessionStatus.pending);
  }

  bool get shouldShowInList {
    // Don't show expired pending sessions
    if (isExpired) return false;
    return true;
  }

  String get displayStatus {
    if (isExpired) {
      return 'Expired';
    }
    return status.displayName;
  }

  LatLng? get serviceLocationLatLng {
    if (serviceLocation == null) return null;
    return LatLng(serviceLocation!.latitude, serviceLocation!.longitude);
  }

  SessionModel copyWith({
    String? id,
    String? seekerId,
    String? providerId,
    String? serviceId,
    String? serviceName,
    String? category,
    DateTime? sessionDate,
    String? startTime,
    String? endTime,
    int? baseDuration,
    double? overtimeHours,
    double? basePrice,
    double? overtimePrice,
    double? totalAmount,
    String? currency,
    SessionStatus? status,
    PaymentStatus? paymentStatus,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    ServiceLocation? serviceLocation,
    SeekerInfo? seeker,
  }) {
    return SessionModel(
      id: id ?? this.id,
      seekerId: seekerId ?? this.seekerId,
      providerId: providerId ?? this.providerId,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      category: category ?? this.category,
      sessionDate: sessionDate ?? this.sessionDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      baseDuration: baseDuration ?? this.baseDuration,
      overtimeHours: overtimeHours ?? this.overtimeHours,
      basePrice: basePrice ?? this.basePrice,
      overtimePrice: overtimePrice ?? this.overtimePrice,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serviceLocation: serviceLocation ?? this.serviceLocation,
      seeker: seeker ?? this.seeker,
    );
  }
}

/// Service location information
class ServiceLocation {
  final double latitude;
  final double longitude;
  final String address;
  final String province;

  const ServiceLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.province,
  });

  factory ServiceLocation.fromJson(Map<String, dynamic> json) {
    return ServiceLocation(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String? ?? 'Address not provided',
      province: json['province'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'province': province,
    };
  }

  LatLng get latLng => LatLng(latitude, longitude);

  ServiceLocation copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? province,
  }) {
    return ServiceLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      province: province ?? this.province,
    );
  }
}

/// Seeker information for sessions
class SeekerInfo {
  final String fullName;
  final String phoneNumber;
  final String email;

  const SeekerInfo({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
  });

  factory SeekerInfo.fromJson(Map<String, dynamic> json) {
    return SeekerInfo(
      fullName: json['fullName'] as String? ?? 'Unknown User',
      phoneNumber: json['phoneNumber'] as String? ?? 'No phone provided',
      email: json['email'] as String? ?? 'No email provided',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }

  SeekerInfo copyWith({
    String? fullName,
    String? phoneNumber,
    String? email,
  }) {
    return SeekerInfo(
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
    );
  }
}

/// Session status enum
enum SessionStatus {
  pendingAssignment,
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  rejected;

  static SessionStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending_assignment':
        return SessionStatus.pendingAssignment;
      case 'pending':
        return SessionStatus.pending;
      case 'confirmed':
        return SessionStatus.confirmed;
      case 'in_progress':
        return SessionStatus.inProgress;
      case 'completed':
        return SessionStatus.completed;
      case 'cancelled':
        return SessionStatus.cancelled;
      case 'rejected':
        return SessionStatus.rejected;
      default:
        return SessionStatus.pendingAssignment;
    }
  }

  String get value {
    switch (this) {
      case SessionStatus.pendingAssignment:
        return 'pending_assignment';
      case SessionStatus.pending:
        return 'pending';
      case SessionStatus.confirmed:
        return 'confirmed';
      case SessionStatus.inProgress:
        return 'in_progress';
      case SessionStatus.completed:
        return 'completed';
      case SessionStatus.cancelled:
        return 'cancelled';
      case SessionStatus.rejected:
        return 'rejected';
    }
  }

  String get displayName {
    switch (this) {
      case SessionStatus.pendingAssignment:
        return 'Looking for Provider';
      case SessionStatus.pending:
        return 'Pending';
      case SessionStatus.confirmed:
        return 'Confirmed';
      case SessionStatus.inProgress:
        return 'In Progress';
      case SessionStatus.completed:
        return 'Completed';
      case SessionStatus.cancelled:
        return 'Cancelled';
      case SessionStatus.rejected:
        return 'Rejected';
    }
  }

  bool get isActive {
    return this == SessionStatus.pendingAssignment ||
           this == SessionStatus.pending || 
           this == SessionStatus.confirmed || 
           this == SessionStatus.inProgress;
  }
}

/// Payment status enum (reused from existing models)
enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded;

  static PaymentStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'paid':
        return PaymentStatus.paid;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }

  String get value {
    switch (this) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.paid:
        return 'paid';
      case PaymentStatus.failed:
        return 'failed';
      case PaymentStatus.refunded:
        return 'refunded';
    }
  }

  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }
}

/// Session list response with pagination and summary
class SessionListResponse {
  final List<SessionModel> sessions;
  final PaginationInfo pagination;
  final SessionSummary summary;

  const SessionListResponse({
    required this.sessions,
    required this.pagination,
    required this.summary,
  });

  factory SessionListResponse.fromJson(Map<String, dynamic> json) {
    return SessionListResponse(
      sessions: (json['sessions'] as List<dynamic>)
          .map((item) => SessionModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: PaginationInfo.fromJson(json['pagination'] as Map<String, dynamic>),
      summary: SessionSummary.fromJson(json['summary'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessions': sessions.map((session) => session.toJson()).toList(),
      'pagination': pagination.toJson(),
      'summary': summary.toJson(),
    };
  }
}

/// Pagination information
class PaginationInfo {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const PaginationInfo({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
    };
  }
}

/// Session summary statistics
class SessionSummary {
  final int pending;
  final int confirmed;
  final int inProgress;
  final int completed;
  final int cancelled;

  const SessionSummary({
    required this.pending,
    required this.confirmed,
    required this.inProgress,
    required this.completed,
    required this.cancelled,
  });

  factory SessionSummary.fromJson(Map<String, dynamic> json) {
    int _extractCount(dynamic value) {
      if (value is num) {
        return value.toInt();
      } else if (value is Map<String, dynamic> && value.containsKey('count')) {
        return (value['count'] as num).toInt();
      }
      return 0;
    }

    return SessionSummary(
      pending: _extractCount(json['pending']),
      confirmed: _extractCount(json['confirmed']),
      inProgress: _extractCount(json['inProgress']),
      completed: _extractCount(json['completed']),
      cancelled: _extractCount(json['cancelled']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pending': pending,
      'confirmed': confirmed,
      'inProgress': inProgress,
      'completed': completed,
      'cancelled': cancelled,
    };
  }

  int get total => pending + confirmed + inProgress + completed + cancelled;
}
