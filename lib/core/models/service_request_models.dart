class ServiceRequestLocation {
  final double latitude;
  final double longitude;
  final String? address;

  const ServiceRequestLocation({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (address != null) 'address': address,
    };
  }

  factory ServiceRequestLocation.fromJson(Map<String, dynamic> json) {
    return ServiceRequestLocation(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      address: json['address'],
    );
  }
}

class CreateServiceRequestModel {
  final String category;
  final String serviceDate;
  final String startTime;
  final double duration;
  final ServiceRequestLocation location;
  final String province;
  final String? specialInstructions;
  final String? description;

  const CreateServiceRequestModel({
    required this.category,
    required this.serviceDate,
    required this.startTime,
    required this.duration,
    required this.location,
    required this.province,
    this.specialInstructions,
    this.description,
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
    };
  }
}

class ServiceRequestResponse {
  final String message;
  final String requestId;
  final double estimatedCost;

  const ServiceRequestResponse({
    required this.message,
    required this.requestId,
    required this.estimatedCost,
  });

  factory ServiceRequestResponse.fromJson(Map<String, dynamic> json) {
    return ServiceRequestResponse(
      message: json['message'] ?? '',
      requestId: json['requestId'] ?? '',
      estimatedCost: json['estimatedCost']?.toDouble() ?? 0.0,
    );
  }
}

enum ServiceRequestStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  rejected,
}

class ServiceRequestModel {
  final String id;
  final String category;
  final String serviceDate;
  final String startTime;
  final double duration;
  final ServiceRequestLocation location;
  final String province;
  final String? specialInstructions;
  final String? description;
  final ServiceRequestStatus status;
  final double estimatedCost;
  final String? providerId;
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
    this.specialInstructions,
    this.description,
    required this.status,
    required this.estimatedCost,
    this.providerId,
    this.providerName,
    required this.createdAt,
    this.updatedAt,
  });

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    // Debug print to see what data we're getting
    print('ServiceRequestModel.fromJson: $json');
    
    return ServiceRequestModel(
      id: json['_id'] ?? json['id'] ?? '',
      category: json['category'] ?? '',
      serviceDate: json['serviceDate'] ?? json['date'] ?? '',
      startTime: json['startTime'] ?? json['time'] ?? '',
      duration: _parseDuration(json['duration']),
      location: ServiceRequestLocation.fromJson(json['location'] ?? {}),
      province: json['province'] ?? '',
      specialInstructions: json['specialInstructions'],
      description: json['description'],
      status: _parseStatus(json['status']),
      estimatedCost: json['estimatedCost']?.toDouble() ?? 0.0,
      providerId: json['providerId'],
      providerName: json['providerName'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  static double _parseDuration(dynamic duration) {
    if (duration == null) return 0.0;
    if (duration is double) return duration;
    if (duration is int) return duration.toDouble();
    if (duration is String) {
      final parsed = double.tryParse(duration);
      return parsed ?? 0.0;
    }
    return 0.0;
  }

  static ServiceRequestStatus _parseStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'PENDING':
        return ServiceRequestStatus.pending;
      case 'CONFIRMED':
        return ServiceRequestStatus.confirmed;
      case 'IN_PROGRESS':
        return ServiceRequestStatus.inProgress;
      case 'COMPLETED':
        return ServiceRequestStatus.completed;
      case 'CANCELLED':
        return ServiceRequestStatus.cancelled;
      case 'REJECTED':
        return ServiceRequestStatus.rejected;
      default:
        return ServiceRequestStatus.pending;
    }
  }

  String get statusDisplayName {
    switch (status) {
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
}

class ServiceRequestsResponse {
  final List<ServiceRequestModel> requests;
  final int totalCount;
  final int currentPage;
  final int totalPages;

  const ServiceRequestsResponse({
    required this.requests,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
  });

  factory ServiceRequestsResponse.fromJson(Map<String, dynamic> json) {
    final requestsData = json['requests'] as List<dynamic>? ?? [];
    final requests = requestsData
        .map((item) => ServiceRequestModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return ServiceRequestsResponse(
      requests: requests,
      totalCount: json['totalCount'] ?? requests.length,
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}