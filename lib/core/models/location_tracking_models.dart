import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Location tracking status progression
enum LocationTrackingStatus {
  notStarted('not_started'),
  onRoute('on_route'),
  atLocation('at_location'),  
  serviceComplete('service_complete'),
  emergency('emergency');

  const LocationTrackingStatus(this.value);
  final String value;

  static LocationTrackingStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'not_started':
        return LocationTrackingStatus.notStarted;
      case 'on_route':
        return LocationTrackingStatus.onRoute;
      case 'at_location':
        return LocationTrackingStatus.atLocation;
      case 'service_complete':
        return LocationTrackingStatus.serviceComplete;
      case 'emergency':
        return LocationTrackingStatus.emergency;
      default:
        return LocationTrackingStatus.notStarted;
    }
  }

  String get displayName {
    switch (this) {
      case LocationTrackingStatus.notStarted:
        return 'Not Started';
      case LocationTrackingStatus.onRoute:
        return 'On Route';
      case LocationTrackingStatus.atLocation:
        return 'At Location';
      case LocationTrackingStatus.serviceComplete:
        return 'Service Complete';
      case LocationTrackingStatus.emergency:
        return 'Emergency';
    }
  }

  String get description {
    switch (this) {
      case LocationTrackingStatus.notStarted:
        return 'Provider has not started tracking yet';
      case LocationTrackingStatus.onRoute:
        return 'Provider is on the way to your location';
      case LocationTrackingStatus.atLocation:
        return 'Provider has arrived at your location';
      case LocationTrackingStatus.serviceComplete:
        return 'Service has been completed';
      case LocationTrackingStatus.emergency:
        return 'Emergency stop activated';
    }
  }

  bool get isActive {
    return this != LocationTrackingStatus.notStarted && 
           this != LocationTrackingStatus.serviceComplete;
  }
}

/// Real-time location data model
class LocationTrackingModel {
  final String sessionId;
  final String providerId;
  final double latitude;
  final double longitude;
  final LocationTrackingStatus status;
  final double? accuracy;
  final double? bearing;
  final double? speed;
  final DateTime timestamp;
  final String? notes;
  final double? distanceToDestination;
  final int? estimatedArrivalTime; // minutes
  final bool isEmergency;

  const LocationTrackingModel({
    required this.sessionId,
    required this.providerId,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.accuracy,
    this.bearing,
    this.speed,
    required this.timestamp,
    this.notes,
    this.distanceToDestination,
    this.estimatedArrivalTime,
    this.isEmergency = false,
  });

  factory LocationTrackingModel.fromJson(Map<String, dynamic> json) {
    return LocationTrackingModel(
      sessionId: json['sessionId'] as String,
      providerId: json['providerId'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      status: LocationTrackingStatus.fromString(json['status'] as String),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      bearing: (json['bearing'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      notes: json['notes'] as String?,
      distanceToDestination: (json['distanceToDestination'] as num?)?.toDouble(),
      estimatedArrivalTime: json['estimatedArrivalTime'] as int?,
      isEmergency: json['isEmergency'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'providerId': providerId,
      'latitude': latitude,
      'longitude': longitude,
      'status': status.value,
      if (accuracy != null) 'accuracy': accuracy,
      if (bearing != null) 'bearing': bearing,
      if (speed != null) 'speed': speed,
      'timestamp': timestamp.toIso8601String(),
      if (notes != null) 'notes': notes,
      if (distanceToDestination != null) 'distanceToDestination': distanceToDestination,
      if (estimatedArrivalTime != null) 'estimatedArrivalTime': estimatedArrivalTime,
      'isEmergency': isEmergency,
    };
  }

  LatLng get position => LatLng(latitude, longitude);

  LocationTrackingModel copyWith({
    String? sessionId,
    String? providerId,
    double? latitude,
    double? longitude,
    LocationTrackingStatus? status,
    double? accuracy,
    double? bearing,
    double? speed,
    DateTime? timestamp,
    String? notes,
    double? distanceToDestination,
    int? estimatedArrivalTime,
    bool? isEmergency,
  }) {
    return LocationTrackingModel(
      sessionId: sessionId ?? this.sessionId,
      providerId: providerId ?? this.providerId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      accuracy: accuracy ?? this.accuracy,
      bearing: bearing ?? this.bearing,
      speed: speed ?? this.speed,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
      distanceToDestination: distanceToDestination ?? this.distanceToDestination,
      estimatedArrivalTime: estimatedArrivalTime ?? this.estimatedArrivalTime,
      isEmergency: isEmergency ?? this.isEmergency,
    );
  }

  String get formattedDistance {
    if (distanceToDestination == null) return 'Unknown';
    if (distanceToDestination! < 1) {
      return '${(distanceToDestination! * 1000).round()}m away';
    }
    return '${distanceToDestination!.toStringAsFixed(1)}km away';
  }

  String get formattedETA {
    if (estimatedArrivalTime == null) return 'Unknown';
    if (estimatedArrivalTime! < 60) {
      return '${estimatedArrivalTime!} min';
    }
    final hours = estimatedArrivalTime! ~/ 60;
    final minutes = estimatedArrivalTime! % 60;
    return '${hours}h ${minutes}m';
  }

  String get formattedSpeed {
    if (speed == null) return 'Unknown';
    return '${speed!.toStringAsFixed(1)} km/h';
  }

  @override
  String toString() {
    return 'LocationTrackingModel(sessionId: $sessionId, status: ${status.value}, position: ($latitude, $longitude))';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationTrackingModel &&
        other.sessionId == sessionId &&
        other.providerId == providerId &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return sessionId.hashCode ^ providerId.hashCode ^ timestamp.hashCode;
  }
}

/// Session location data for seeker view
class SessionLocationData {
  final String sessionId;
  final LocationTrackingModel? currentLocation;
  final LatLng? destinationLocation;
  final String? destinationAddress;
  final List<LocationTrackingModel> locationHistory;
  final bool isTrackingActive;
  final DateTime? trackingStartTime;
  final DateTime? trackingEndTime;

  const SessionLocationData({
    required this.sessionId,
    this.currentLocation,
    this.destinationLocation,
    this.destinationAddress,
    this.locationHistory = const [],
    this.isTrackingActive = false,
    this.trackingStartTime,
    this.trackingEndTime,
  });

  factory SessionLocationData.fromJson(Map<String, dynamic> json) {
    return SessionLocationData(
      sessionId: json['sessionId'] as String,
      currentLocation: json['currentLocation'] != null 
          ? LocationTrackingModel.fromJson(json['currentLocation'] as Map<String, dynamic>)
          : null,
      destinationLocation: json['destinationLocation'] != null
          ? LatLng(
              (json['destinationLocation']['latitude'] as num).toDouble(),
              (json['destinationLocation']['longitude'] as num).toDouble(),
            )
          : null,
      destinationAddress: json['destinationAddress'] as String?,
      locationHistory: (json['locationHistory'] as List<dynamic>?)
          ?.map((item) => LocationTrackingModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      isTrackingActive: json['isTrackingActive'] as bool? ?? false,
      trackingStartTime: json['trackingStartTime'] != null
          ? DateTime.parse(json['trackingStartTime'] as String)
          : null,
      trackingEndTime: json['trackingEndTime'] != null
          ? DateTime.parse(json['trackingEndTime'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      if (currentLocation != null) 'currentLocation': currentLocation!.toJson(),
      if (destinationLocation != null) 'destinationLocation': {
        'latitude': destinationLocation!.latitude,
        'longitude': destinationLocation!.longitude,
      },
      if (destinationAddress != null) 'destinationAddress': destinationAddress,
      'locationHistory': locationHistory.map((item) => item.toJson()).toList(),
      'isTrackingActive': isTrackingActive,
      if (trackingStartTime != null) 'trackingStartTime': trackingStartTime!.toIso8601String(),
      if (trackingEndTime != null) 'trackingEndTime': trackingEndTime!.toIso8601String(),
    };
  }

  SessionLocationData copyWith({
    String? sessionId,
    LocationTrackingModel? currentLocation,
    LatLng? destinationLocation,
    String? destinationAddress,
    List<LocationTrackingModel>? locationHistory,
    bool? isTrackingActive,
    DateTime? trackingStartTime,
    DateTime? trackingEndTime,
  }) {
    return SessionLocationData(
      sessionId: sessionId ?? this.sessionId,
      currentLocation: currentLocation ?? this.currentLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      locationHistory: locationHistory ?? this.locationHistory,
      isTrackingActive: isTrackingActive ?? this.isTrackingActive,
      trackingStartTime: trackingStartTime ?? this.trackingStartTime,
      trackingEndTime: trackingEndTime ?? this.trackingEndTime,
    );
  }

  Duration? get trackingDuration {
    if (trackingStartTime == null) return null;
    final endTime = trackingEndTime ?? DateTime.now();
    return endTime.difference(trackingStartTime!);
  }

  bool get hasValidLocation {
    return currentLocation != null && isTrackingActive;
  }

  LocationTrackingStatus get currentStatus {
    return currentLocation?.status ?? LocationTrackingStatus.notStarted;
  }

  @override
  String toString() {
    return 'SessionLocationData(sessionId: $sessionId, isActive: $isTrackingActive, status: ${currentStatus.value})';
  }
}

/// Emergency stop data
class EmergencyStopModel {
  final String sessionId;
  final String providerId;
  final double latitude;
  final double longitude;
  final String reason;
  final DateTime timestamp;
  final String? additionalNotes;
  final bool isResolved;
  final DateTime? resolvedAt;

  const EmergencyStopModel({
    required this.sessionId,
    required this.providerId,
    required this.latitude,
    required this.longitude,
    required this.reason,
    required this.timestamp,
    this.additionalNotes,
    this.isResolved = false,
    this.resolvedAt,
  });

  factory EmergencyStopModel.fromJson(Map<String, dynamic> json) {
    return EmergencyStopModel(
      sessionId: json['sessionId'] as String,
      providerId: json['providerId'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      reason: json['reason'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      additionalNotes: json['additionalNotes'] as String?,
      isResolved: json['isResolved'] as bool? ?? false,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'providerId': providerId,
      'latitude': latitude,
      'longitude': longitude,
      'reason': reason,
      'timestamp': timestamp.toIso8601String(),
      if (additionalNotes != null) 'additionalNotes': additionalNotes,
      'isResolved': isResolved,
      if (resolvedAt != null) 'resolvedAt': resolvedAt!.toIso8601String(),
    };
  }

  LatLng get position => LatLng(latitude, longitude);
}