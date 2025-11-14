class BookingModel {
  final String id;
  final String serviceId;
  final String seekerId;
  final String providerId;
  final ServiceModel? service;
  final UserModel? provider;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final int duration;
  final double totalAmount;
  final String currency;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final String? serviceLocation;
  final String? specialInstructions;
  final String? providerNotes;
  final DateTime createdAt;

  const BookingModel({
    required this.id,
    required this.serviceId,
    required this.seekerId,
    required this.providerId,
    this.service,
    this.provider,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.totalAmount,
    required this.currency,
    required this.status,
    required this.paymentStatus,
    this.serviceLocation,
    this.specialInstructions,
    this.providerNotes,
    required this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id'] as String,
      serviceId: json['serviceId'] is String 
          ? json['serviceId'] as String
          : (json['serviceId'] as Map<String, dynamic>)['_id'] as String,
      seekerId: json['seekerId'] as String,
      providerId: json['providerId'] is String
          ? json['providerId'] as String
          : (json['providerId'] as Map<String, dynamic>)['_id'] as String,
      service: json['serviceId'] is Map<String, dynamic>
          ? ServiceModel.fromJson(json['serviceId'] as Map<String, dynamic>)
          : null,
      provider: json['providerId'] is Map<String, dynamic>
          ? UserModel.fromJson(json['providerId'] as Map<String, dynamic>)
          : null,
      bookingDate: DateTime.parse(json['bookingDate'] as String),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      duration: (json['duration'] as num).toInt(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'FCFA',
      status: BookingStatus.fromString(json['status'] as String),
      paymentStatus: PaymentStatus.fromString(json['paymentStatus'] as String),
      serviceLocation: json['serviceLocation'] as String?,
      specialInstructions: json['specialInstructions'] as String?,
      providerNotes: json['providerNotes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'serviceId': serviceId,
      'seekerId': seekerId,
      'providerId': providerId,
      'bookingDate': bookingDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'duration': duration,
      'totalAmount': totalAmount,
      'currency': currency,
      'status': status.value,
      'paymentStatus': paymentStatus.value,
      if (serviceLocation != null) 'serviceLocation': serviceLocation,
      if (specialInstructions != null) 'specialInstructions': specialInstructions,
      if (providerNotes != null) 'providerNotes': providerNotes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get displayDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final bookingDay = DateTime(bookingDate.year, bookingDate.month, bookingDate.day);
    
    if (bookingDay == today) {
      return 'Today, $startTime';
    } else if (bookingDay == today.add(const Duration(days: 1))) {
      return 'Tomorrow, $startTime';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[bookingDate.month - 1]} ${bookingDate.day}, ${bookingDate.year}';
    }
  }

  String get formattedAmount {
    return '${totalAmount.toStringAsFixed(0)} $currency';
  }

  bool get canBeCancelled {
    return status == BookingStatus.pending || status == BookingStatus.confirmed;
  }

  bool get canBeRated {
    return status == BookingStatus.completed && paymentStatus == PaymentStatus.paid;
  }

  BookingModel copyWith({
    String? id,
    String? serviceId,
    String? seekerId,
    String? providerId,
    ServiceModel? service,
    UserModel? provider,
    DateTime? bookingDate,
    String? startTime,
    String? endTime,
    int? duration,
    double? totalAmount,
    String? currency,
    BookingStatus? status,
    PaymentStatus? paymentStatus,
    String? serviceLocation,
    String? specialInstructions,
    String? providerNotes,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      seekerId: seekerId ?? this.seekerId,
      providerId: providerId ?? this.providerId,
      service: service ?? this.service,
      provider: provider ?? this.provider,
      bookingDate: bookingDate ?? this.bookingDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      serviceLocation: serviceLocation ?? this.serviceLocation,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      providerNotes: providerNotes ?? this.providerNotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum BookingStatus {
  pending,
  pendingAssignment,
  assigned,
  confirmed,
  inProgress,
  completed,
  cancelled,
  rejected;

  static BookingStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'pending_assignment':
        return BookingStatus.pendingAssignment;
      case 'assigned':
        return BookingStatus.assigned;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'in_progress':
        return BookingStatus.inProgress;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'rejected':
        return BookingStatus.rejected;
      default:
        return BookingStatus.pending;
    }
  }

  String get value {
    switch (this) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.pendingAssignment:
        return 'pending_assignment';
      case BookingStatus.assigned:
        return 'assigned';
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.inProgress:
        return 'in_progress';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.cancelled:
        return 'cancelled';
      case BookingStatus.rejected:
        return 'rejected';
    }
  }

  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.pendingAssignment:
        return 'Pending Assignment';
      case BookingStatus.assigned:
        return 'Assigned';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.rejected:
        return 'Rejected';
    }
  }

  bool get isActive {
    return this == BookingStatus.pending || 
           this == BookingStatus.pendingAssignment ||
           this == BookingStatus.assigned ||
           this == BookingStatus.confirmed || 
           this == BookingStatus.inProgress;
  }

  bool get canStartTracking {
    return this == BookingStatus.confirmed || this == BookingStatus.inProgress;
  }

  bool get showTrackingButton {
    return this == BookingStatus.confirmed || this == BookingStatus.inProgress;
  }
}

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

class ServiceModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final double pricePerHour;
  final String currency;
  final String location;
  final List<String> images;
  final List<String> tags;
  final bool isAvailable;
  final int minimumBookingHours;
  final int maximumBookingHours;
  final double averageRating;
  final int totalReviews;

  const ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.pricePerHour,
    required this.currency,
    required this.location,
    required this.images,
    required this.tags,
    required this.isAvailable,
    required this.minimumBookingHours,
    required this.maximumBookingHours,
    required this.averageRating,
    required this.totalReviews,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String,
      pricePerHour: (json['pricePerHour'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'FCFA',
      location: json['location'] as String? ?? '',
      images: List<String>.from(json['images'] as List? ?? []),
      tags: List<String>.from(json['tags'] as List? ?? []),
      isAvailable: json['isAvailable'] as bool? ?? true,
      minimumBookingHours: (json['minimumBookingHours'] as num?)?.toInt() ?? 1,
      maximumBookingHours: (json['maximumBookingHours'] as num?)?.toInt() ?? 8,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
    );
  }
}

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? role;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String? ?? '',
      role: json['role'] as String?,
    );
  }
}

// ============================================================================
// NEW BOOKING API MODELS (for /api/v1/bookings/initiate endpoint)
// ============================================================================

/// Payment details for booking initiation
class PaymentDetails {
  final String phone;
  final String medium;
  final String? name;
  final String? email;

  const PaymentDetails({
    required this.phone,
    required this.medium,
    this.name,
    this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'medium': medium,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
    };
  }

  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      phone: json['phone'] as String,
      medium: json['medium'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
    );
  }
}

/// Request model for initiating a booking
class InitiateBookingRequest {
  final String serviceId;
  final String sessionDate;
  final String startTime;
  final double duration;
  final String? notes;
  final PaymentDetails paymentDetails;
  final String? couponCode;

  const InitiateBookingRequest({
    required this.serviceId,
    required this.sessionDate,
    required this.startTime,
    required this.duration,
    required this.paymentDetails,
    this.notes,
    this.couponCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'sessionDate': sessionDate,
      'startTime': startTime,
      'duration': duration,
      if (notes != null) 'notes': notes,
      'paymentDetails': paymentDetails.toJson(),
      if (couponCode != null) 'couponCode': couponCode,
    };
  }
}

/// Response model for initiated booking
class InitiateBookingResponse {
  final String bookingId;
  final String paymentId;
  final String transId;
  final double amount;
  final double originalAmount;
  final double discountAmount;
  final String status;
  final String message;
  final DateTime expiresAt;
  final String? couponCode;

  const InitiateBookingResponse({
    required this.bookingId,
    required this.paymentId,
    required this.transId,
    required this.amount,
    required this.originalAmount,
    required this.discountAmount,
    required this.status,
    required this.message,
    required this.expiresAt,
    this.couponCode,
  });

  factory InitiateBookingResponse.fromJson(Map<String, dynamic> json) {
    return InitiateBookingResponse(
      bookingId: json['bookingId'] as String,
      paymentId: json['paymentId'] as String,
      transId: json['transId'] as String,
      amount: (json['amount'] as num).toDouble(),
      originalAmount: (json['originalAmount'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      status: json['status'] as String,
      message: json['message'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      couponCode: json['couponCode'] as String?,
    );
  }

  bool get hasDiscount => discountAmount > 0;
}

/// Booking status for payment flow
enum InitiateBookingStatus {
  paymentPending,
  completed,
  failed,
  expired;

  static InitiateBookingStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'payment_pending':
        return InitiateBookingStatus.paymentPending;
      case 'completed':
        return InitiateBookingStatus.completed;
      case 'failed':
        return InitiateBookingStatus.failed;
      case 'expired':
        return InitiateBookingStatus.expired;
      default:
        return InitiateBookingStatus.paymentPending;
    }
  }

  String get displayName {
    switch (this) {
      case InitiateBookingStatus.paymentPending:
        return 'Payment Pending';
      case InitiateBookingStatus.completed:
        return 'Completed';
      case InitiateBookingStatus.failed:
        return 'Failed';
      case InitiateBookingStatus.expired:
        return 'Expired';
    }
  }
}

/// Payment status for payment flow
enum InitiatePaymentStatus {
  processing,
  successful,
  failed,
  expired;

  static InitiatePaymentStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return InitiatePaymentStatus.processing;
      case 'successful':
        return InitiatePaymentStatus.successful;
      case 'failed':
        return InitiatePaymentStatus.failed;
      case 'expired':
        return InitiatePaymentStatus.expired;
      default:
        return InitiatePaymentStatus.processing;
    }
  }
}

/// Provider info in booking status
class BookingStatusProvider {
  final String id;
  final String name;

  const BookingStatusProvider({
    required this.id,
    required this.name,
  });

  factory BookingStatusProvider.fromJson(Map<String, dynamic> json) {
    return BookingStatusProvider(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

/// Session info in booking status
class BookingStatusSession {
  final String id;
  final String serviceName;
  final String sessionDate;
  final String startTime;
  final String endTime;
  final double totalAmount;
  final String status;
  final BookingStatusProvider provider;

  const BookingStatusSession({
    required this.id,
    required this.serviceName,
    required this.sessionDate,
    required this.startTime,
    required this.endTime,
    required this.totalAmount,
    required this.status,
    required this.provider,
  });

  factory BookingStatusSession.fromJson(Map<String, dynamic> json) {
    return BookingStatusSession(
      id: json['id'] as String,
      serviceName: json['serviceName'] as String,
      sessionDate: json['sessionDate'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] as String,
      provider: BookingStatusProvider.fromJson(json['provider'] as Map<String, dynamic>),
    );
  }
}

/// Response model for booking status check
class BookingStatusResponse {
  final String bookingId;
  final String paymentId;
  final InitiateBookingStatus status;
  final InitiatePaymentStatus paymentStatus;
  final String message;
  final String? sessionId;
  final BookingStatusSession? session;

  const BookingStatusResponse({
    required this.bookingId,
    required this.paymentId,
    required this.status,
    required this.paymentStatus,
    required this.message,
    this.sessionId,
    this.session,
  });

  factory BookingStatusResponse.fromJson(Map<String, dynamic> json) {
    return BookingStatusResponse(
      bookingId: json['bookingId'] as String,
      paymentId: json['paymentId'] as String,
      status: InitiateBookingStatus.fromString(json['status'] as String),
      paymentStatus: InitiatePaymentStatus.fromString(json['paymentStatus'] as String),
      message: json['message'] as String,
      sessionId: json['sessionId'] as String?,
      session: json['session'] != null
          ? BookingStatusSession.fromJson(json['session'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isCompleted => status == InitiateBookingStatus.completed;
  bool get isFailed => status == InitiateBookingStatus.failed;
  bool get isExpired => status == InitiateBookingStatus.expired;
  bool get isPending => status == InitiateBookingStatus.paymentPending;
}