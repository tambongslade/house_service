import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Service request status enum
enum ServiceRequestStatus {
  pendingAssignment,
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  rejected;

  String get displayName {
    switch (this) {
      case ServiceRequestStatus.pendingAssignment:
        return 'Looking for Provider';
      case ServiceRequestStatus.pending:
        return 'Pending';
      case ServiceRequestStatus.confirmed:
        return 'Confirmed';
      case ServiceRequestStatus.inProgress:
        return 'In Progress';
      case ServiceRequestStatus.completed:
        return 'Completed';
      case ServiceRequestStatus.cancelled:
        return 'Cancelled';
      case ServiceRequestStatus.rejected:
        return 'Rejected';
    }
  }

  static ServiceRequestStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending_assignment':
        return ServiceRequestStatus.pendingAssignment;
      case 'pending':
        return ServiceRequestStatus.pending;
      case 'confirmed':
        return ServiceRequestStatus.confirmed;
      case 'in_progress':
      case 'inprogress':
        return ServiceRequestStatus.inProgress;
      case 'completed':
        return ServiceRequestStatus.completed;
      case 'cancelled':
        return ServiceRequestStatus.cancelled;
      case 'rejected':
        return ServiceRequestStatus.rejected;
      default:
        return ServiceRequestStatus.pendingAssignment;
    }
  }
}

/// Service request model for creating new service requests with location
class ServiceRequestModel {
  final String id;
  final String category;
  final DateTime serviceDate;
  final String startTime;
  final int duration;
  final ServiceLocation location;
  final String province;
  final String? specialInstructions;
  final String? description;
  final ServiceRequestStatus status;
  final double estimatedCost;
  final String? providerName;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ServiceRequestModel({
    required this.id,
    required this.category,
    required this.serviceDate,
    required this.startTime,
    required this.duration,
    required this.location,
    required this.province,
    required this.status,
    required this.estimatedCost,
    required this.createdAt,
    this.specialInstructions,
    this.description,
    this.providerName,
    this.updatedAt,
  });

  String get statusDisplayName => status.displayName;

  bool get isExpired {
    try {
      final now = DateTime.now();
      
      // Calculate service end time by adding duration to start time
      final startParts = startTime.split(':');
      final startHour = int.parse(startParts[0]);
      final startMinute = int.parse(startParts[1]);
      
      final serviceEndDateTime = DateTime(
        serviceDate.year,
        serviceDate.month,
        serviceDate.day,
        startHour + duration, // Add duration hours to start time
        startMinute,
      );
      
      // Only expire "pending" requests (assigned to provider), not "pending_assignment" (still looking for provider)
      final expired = now.isAfter(serviceEndDateTime) && 
             (status == ServiceRequestStatus.pending);
      
      print('ServiceRequest ${id.substring(0, 8)}: serviceDate=$serviceDate, startTime=$startTime, duration=$duration, endTime=$serviceEndDateTime, now=$now, expired=$expired, status=$status');
      
      return expired;
    } catch (e) {
      print('Error calculating expiry for request ${id}: $e');
      return false; // Don't expire if we can't calculate
    }
  }

  bool get shouldShowInList {
    // Don't show expired pending requests
    final shouldShow = !isExpired;
    print('ServiceRequest ${id.substring(0, 8)}: shouldShowInList=$shouldShow (expired=${isExpired})');
    return shouldShow;
  }

  String get displayStatus {
    if (isExpired) {
      return 'Expired';
    }
    return status.displayName;
  }

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle flexible location parsing
      ServiceLocation location;
      if (json['location'] != null && json['location'] is Map<String, dynamic>) {
        location = ServiceLocation.fromJson(json['location'] as Map<String, dynamic>);
      } else {
        // Create location from serviceLocation/serviceAddress fields
        final locationStr = json['serviceLocation'] as String? ?? json['province'] as String? ?? 'Unknown';
        final addressStr = json['serviceAddress'] as String? ?? 'Address not provided';
        location = ServiceLocation(
          latitude: 0.0,
          longitude: 0.0,
          address: addressStr,
          province: locationStr,
        );
      }
      
      // Calculate duration from startTime and endTime if available
      int calculatedDuration = json['duration'] as int? ?? json['baseDuration'] as int? ?? 1;
      if (json['startTime'] != null && json['endTime'] != null) {
        try {
          final startParts = (json['startTime'] as String).split(':');
          final endParts = (json['endTime'] as String).split(':');
          final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
          final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
          calculatedDuration = ((endMinutes - startMinutes) / 60).round();
        } catch (e) {
          // Keep the default duration if parsing fails
        }
      }

      final parsedModel = ServiceRequestModel(
        id: json['id'] as String? ?? json['_id'] as String? ?? '',
        category: json['category'] as String? ?? 'other',
        serviceDate: json['serviceDate'] != null || json['sessionDate'] != null 
            ? DateTime.parse((json['serviceDate'] ?? json['sessionDate']) as String)
            : DateTime.now(),
        startTime: json['startTime'] as String? ?? '09:00',
        duration: calculatedDuration,
        location: location,
        province: json['province'] as String? ?? json['serviceLocation'] as String? ?? 'Unknown',
        status: ServiceRequestStatus.fromString(json['status'] as String? ?? 'pending_assignment'),
        estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 
                      (json['totalAmount'] as num?)?.toDouble() ?? 
                      (json['basePrice'] as num?)?.toDouble() ?? 0.0,
        createdAt: json['createdAt'] != null 
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        specialInstructions: json['specialInstructions'] as String? ?? json['notes'] as String?,
        description: json['description'] as String? ?? json['serviceName'] as String?,
        providerName: json['providerName'] as String?,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      );
      
      print('ServiceRequest parsed: id=${parsedModel.id}, status=${parsedModel.status}, serviceDate=${parsedModel.serviceDate}, duration=${parsedModel.duration}');
      
      return parsedModel;
    } catch (e) {
      print('Error parsing ServiceRequestModel from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'serviceDate': serviceDate.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'startTime': startTime,
      'duration': duration,
      'location': location.toJson(),
      'province': province,
      'status': status.name,
      'estimatedCost': estimatedCost,
      'createdAt': createdAt.toIso8601String(),
      if (specialInstructions != null) 'specialInstructions': specialInstructions,
      if (description != null) 'description': description,
      if (providerName != null) 'providerName': providerName,
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  ServiceRequestModel copyWith({
    String? id,
    String? category,
    DateTime? serviceDate,
    String? startTime,
    int? duration,
    ServiceLocation? location,
    String? province,
    ServiceRequestStatus? status,
    double? estimatedCost,
    DateTime? createdAt,
    String? specialInstructions,
    String? description,
    String? providerName,
    DateTime? updatedAt,
  }) {
    return ServiceRequestModel(
      id: id ?? this.id,
      category: category ?? this.category,
      serviceDate: serviceDate ?? this.serviceDate,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      location: location ?? this.location,
      province: province ?? this.province,
      status: status ?? this.status,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      createdAt: createdAt ?? this.createdAt,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      description: description ?? this.description,
      providerName: providerName ?? this.providerName,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Service requests response model
class ServiceRequestsResponse {
  final List<ServiceRequestModel> requests;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const ServiceRequestsResponse({
    required this.requests,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory ServiceRequestsResponse.fromJson(Map<String, dynamic> json) {
    final requestsList = (json['requests'] as List<dynamic>? ?? json['data'] as List<dynamic>? ?? [])
        .map((item) => ServiceRequestModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return ServiceRequestsResponse(
      requests: requestsList,
      totalCount: json['totalCount'] as int? ?? json['total'] as int? ?? requestsList.length,
      currentPage: json['currentPage'] as int? ?? json['page'] as int? ?? 1,
      totalPages: json['totalPages'] as int? ?? json['pages'] as int? ?? 1,
      hasNextPage: json['hasNextPage'] as bool? ?? json['hasNext'] as bool? ?? false,
      hasPreviousPage: json['hasPreviousPage'] as bool? ?? json['hasPrevious'] as bool? ?? false,
    );
  }
}

/// Service request response model for creation
class ServiceRequestResponse {
  final String requestId;
  final String message;
  final double estimatedCost;
  final ServiceRequestStatus status;

  const ServiceRequestResponse({
    required this.requestId,
    required this.message,
    required this.estimatedCost,
    required this.status,
  });

  factory ServiceRequestResponse.fromJson(Map<String, dynamic> json) {
    return ServiceRequestResponse(
      requestId: json['requestId'] as String? ?? json['id'] as String? ?? json['_id'] as String? ?? '',
      message: json['message'] as String? ?? 'Service request created successfully',
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 0.0,
      status: ServiceRequestStatus.fromString(json['status'] as String? ?? 'pending'),
    );
  }
}

/// Create service request model for form submission
class CreateServiceRequestModel {
  final String category;
  final String serviceDate; // YYYY-MM-DD format
  final String startTime; // HH:mm format
  final double duration;
  final ServiceRequestLocation location;
  final String province;
  final String? specialInstructions;
  final String? description;
  final String? couponCode;

  const CreateServiceRequestModel({
    required this.category,
    required this.serviceDate,
    required this.startTime,
    required this.duration,
    required this.location,
    required this.province,
    this.specialInstructions,
    this.description,
    this.couponCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'serviceDate': serviceDate,
      'startTime': startTime,
      'duration': duration,
      'location': location.toJson(),
      'province': province,
      if (specialInstructions != null) 'specialInstructions': specialInstructions,
      if (description != null) 'description': description,
      if (couponCode != null && couponCode!.isNotEmpty) 'couponCode': couponCode,
    };
  }
}

/// Service request location model for form submission
class ServiceRequestLocation {
  final double latitude;
  final double longitude;
  final String? address;

  const ServiceRequestLocation({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  factory ServiceRequestLocation.fromJson(Map<String, dynamic> json) {
    return ServiceRequestLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (address != null) 'address': address,
    };
  }

  LatLng get latLng => LatLng(latitude, longitude);
}

/// Service location for requests (reused from session models)
class ServiceLocation {
  final double latitude;
  final double longitude;
  final String address;
  final String? province;

  const ServiceLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.province,
  });

  factory ServiceLocation.fromJson(Map<String, dynamic> json) {
    return ServiceLocation(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String? ?? 'Address not provided',
      province: json['province'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      if (province != null) 'province': province,
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

/// Service categories enum
enum ServiceCategory {
  cleaning,
  plumbing,
  electrical,
  painting,
  babysitting,
  electronics,
  other;

  static ServiceCategory fromString(String category) {
    switch (category.toLowerCase()) {
      case 'cleaning':
        return ServiceCategory.cleaning;
      case 'plumbing':
        return ServiceCategory.plumbing;
      case 'electrical':
        return ServiceCategory.electrical;
      case 'painting':
        return ServiceCategory.painting;
      case 'babysitting':
        return ServiceCategory.babysitting;
      case 'electronics':
        return ServiceCategory.electronics;
      case 'other':
        return ServiceCategory.other;
      default:
        return ServiceCategory.other;
    }
  }

  String get value {
    switch (this) {
      case ServiceCategory.cleaning:
        return 'CLEANING';
      case ServiceCategory.plumbing:
        return 'PLUMBING';
      case ServiceCategory.electrical:
        return 'ELECTRICAL';
      case ServiceCategory.painting:
        return 'PAINTING';
      case ServiceCategory.babysitting:
        return 'BABYSITTING';
      case ServiceCategory.electronics:
        return 'ELECTRONICS';
      case ServiceCategory.other:
        return 'OTHER';
    }
  }

  String get displayName {
    switch (this) {
      case ServiceCategory.cleaning:
        return 'House Cleaning';
      case ServiceCategory.plumbing:
        return 'Plumbing';
      case ServiceCategory.electrical:
        return 'Electrical';
      case ServiceCategory.painting:
        return 'Painting';
      case ServiceCategory.babysitting:
        return 'Babysitting';
      case ServiceCategory.electronics:
        return 'Electronics';
      case ServiceCategory.other:
        return 'Other';
    }
  }
}