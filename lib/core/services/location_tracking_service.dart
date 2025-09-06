import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/location_tracking_models.dart';
import 'api_service.dart';

class LocationTrackingService extends ChangeNotifier {
  static final LocationTrackingService _instance = LocationTrackingService._internal();
  factory LocationTrackingService() => _instance;
  LocationTrackingService._internal();

  final ApiService _apiService = ApiService();
  
  // Current tracking state
  String? _activeSessionId;
  bool _isTracking = false;
  LocationTrackingModel? _currentLocation;
  StreamSubscription<Position>? _positionStream;
  Timer? _updateTimer;
  Timer? _heartbeatTimer;
  
  // Tracking settings
  static const Duration _updateInterval = Duration(seconds: 10);
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const double _minimumDistanceFilter = 10.0; // meters
  static const double _arrivalThreshold = 50.0; // meters to consider "arrived"
  
  // Location history and analytics
  final List<LocationTrackingModel> _locationHistory = [];
  LatLng? _destinationLocation;
  String? _destinationAddress;
  DateTime? _trackingStartTime;
  
  // Stream controllers for real-time updates
  final StreamController<LocationTrackingModel> _locationUpdateController = 
      StreamController<LocationTrackingModel>.broadcast();
  final StreamController<LocationTrackingStatus> _statusUpdateController = 
      StreamController<LocationTrackingStatus>.broadcast();
  final StreamController<String> _errorController = 
      StreamController<String>.broadcast();

  // Getters
  bool get isTracking => _isTracking;
  String? get activeSessionId => _activeSessionId;
  LocationTrackingModel? get currentLocation => _currentLocation;
  List<LocationTrackingModel> get locationHistory => List.unmodifiable(_locationHistory);
  LatLng? get destinationLocation => _destinationLocation;
  String? get destinationAddress => _destinationAddress;
  DateTime? get trackingStartTime => _trackingStartTime;
  
  // Streams
  Stream<LocationTrackingModel> get locationUpdates => _locationUpdateController.stream;
  Stream<LocationTrackingStatus> get statusUpdates => _statusUpdateController.stream;
  Stream<String> get errors => _errorController.stream;

  /// Initialize location tracking for a session
  Future<bool> startTracking({
    required String sessionId,
    required LatLng destination,
    String? destinationAddress,
  }) async {
    try {
      // Check if already tracking
      if (_isTracking) {
        await stopTracking();
      }

      // Check location permissions
      final permission = await _checkLocationPermissions();
      if (!permission) {
        _errorController.add('Location permissions not granted');
        return false;
      }

      // Initialize tracking state
      _activeSessionId = sessionId;
      _destinationLocation = destination;
      _destinationAddress = destinationAddress;
      _trackingStartTime = DateTime.now();
      _isTracking = true;
      _locationHistory.clear();

      // Start location streaming
      await _startLocationStream();
      
      // Start periodic updates and heartbeat
      _startPeriodicUpdates();
      _startHeartbeat();

      // Notify backend that tracking has started
      await _notifyTrackingStarted();

      print('Location tracking started for session: $sessionId');
      notifyListeners();
      return true;
    } catch (e) {
      print('Error starting location tracking: $e');
      _errorController.add('Failed to start tracking: $e');
      return false;
    }
  }

  /// Stop location tracking
  Future<void> stopTracking({LocationTrackingStatus? finalStatus}) async {
    try {
      if (!_isTracking) return;

      // Update status to complete if not specified
      final status = finalStatus ?? LocationTrackingStatus.serviceComplete;
      
      // Send final location update
      if (_currentLocation != null) {
        await _updateLocationStatus(status);
      }

      // Cleanup streaming and timers
      await _positionStream?.cancel();
      _updateTimer?.cancel();
      _heartbeatTimer?.cancel();

      // Reset state
      _isTracking = false;
      _activeSessionId = null;
      _currentLocation = null;
      _destinationLocation = null;
      _destinationAddress = null;
      _trackingStartTime = null;

      print('Location tracking stopped');
      notifyListeners();
    } catch (e) {
      print('Error stopping location tracking: $e');
      _errorController.add('Failed to stop tracking: $e');
    }
  }

  /// Update tracking status manually
  Future<void> updateStatus(LocationTrackingStatus status) async {
    if (!_isTracking || _currentLocation == null) return;
    
    try {
      await _updateLocationStatus(status);
      _statusUpdateController.add(status);
      notifyListeners();
    } catch (e) {
      print('Error updating tracking status: $e');
      _errorController.add('Failed to update status: $e');
    }
  }

  /// Trigger emergency stop
  Future<void> emergencyStop(String reason, {String? additionalNotes}) async {
    if (!_isTracking || _currentLocation == null) return;
    
    try {
      // Create emergency stop model
      final emergencyStop = EmergencyStopModel(
        sessionId: _activeSessionId!,
        providerId: _currentLocation!.providerId,
        latitude: _currentLocation!.latitude,
        longitude: _currentLocation!.longitude,
        reason: reason,
        timestamp: DateTime.now(),
        additionalNotes: additionalNotes,
      );

      // Send emergency stop to backend
      await _apiService.reportEmergencyStop(_activeSessionId!, emergencyStop.toJson());

      // Update status and stop tracking
      await updateStatus(LocationTrackingStatus.emergency);
      await stopTracking(finalStatus: LocationTrackingStatus.emergency);

      print('Emergency stop triggered: $reason');
    } catch (e) {
      print('Error triggering emergency stop: $e');
      _errorController.add('Failed to trigger emergency stop: $e');
    }
  }

  /// Get session location data for seeker view
  Future<SessionLocationData?> getSessionLocationData(String sessionId) async {
    try {
      final response = await _apiService.getSeekerTrackingView(sessionId);
      if (response.isSuccess && response.data != null) {
        return SessionLocationData.fromJson(response.data!);
      }
      return null;
    } catch (e) {
      print('Error getting session location data: $e');
      return null;
    }
  }

  /// Check and request location permissions
  Future<bool> _checkLocationPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _errorController.add('Location services are disabled');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _errorController.add('Location permissions are denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _errorController.add('Location permissions are permanently denied');
      return false;
    }

    return true;
  }

  /// Start location stream
  Future<void> _startLocationStream() async {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Update every 5 meters
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) => _onLocationUpdate(position),
      onError: (error) {
        print('Location stream error: $error');
        _errorController.add('Location error: $error');
      },
    );
  }

  /// Handle location updates from GPS
  void _onLocationUpdate(Position position) async {
    if (!_isTracking || _activeSessionId == null) return;

    try {
      // Calculate distance to destination
      double? distanceToDestination;
      if (_destinationLocation != null) {
        distanceToDestination = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          _destinationLocation!.latitude,
          _destinationLocation!.longitude,
        ) / 1000; // Convert to kilometers
      }

      // Determine status based on distance
      LocationTrackingStatus status = _determineStatus(distanceToDestination);

      // Create location tracking model
      final locationUpdate = LocationTrackingModel(
        sessionId: _activeSessionId!,
        providerId: 'current_provider', // This should come from session data
        latitude: position.latitude,
        longitude: position.longitude,
        status: status,
        accuracy: position.accuracy,
        bearing: position.heading,
        speed: position.speed * 3.6, // Convert m/s to km/h
        timestamp: DateTime.now(),
        distanceToDestination: distanceToDestination,
        estimatedArrivalTime: _calculateETA(distanceToDestination, position.speed),
      );

      // Update current location
      _currentLocation = locationUpdate;
      _locationHistory.add(locationUpdate);

      // Emit updates
      _locationUpdateController.add(locationUpdate);
      if (locationUpdate.status != (_locationHistory.length > 1 
          ? _locationHistory[_locationHistory.length - 2].status 
          : LocationTrackingStatus.notStarted)) {
        _statusUpdateController.add(locationUpdate.status);
      }

      notifyListeners();
    } catch (e) {
      print('Error processing location update: $e');
      _errorController.add('Error processing location: $e');
    }
  }

  /// Determine tracking status based on distance to destination
  LocationTrackingStatus _determineStatus(double? distanceKm) {
    if (distanceKm == null) return LocationTrackingStatus.onRoute;
    
    final distanceMeters = distanceKm * 1000;
    if (distanceMeters <= _arrivalThreshold) {
      return LocationTrackingStatus.atLocation;
    } else {
      return LocationTrackingStatus.onRoute;
    }
  }

  /// Calculate estimated time of arrival
  int? _calculateETA(double? distanceKm, double speedMs) {
    if (distanceKm == null || speedMs <= 0) return null;
    
    final speedKmh = speedMs * 3.6;
    if (speedKmh < 1) return null; // Not moving
    
    final timeHours = distanceKm / speedKmh;
    return (timeHours * 60).round(); // Convert to minutes
  }

  /// Start periodic updates to backend
  void _startPeriodicUpdates() {
    _updateTimer = Timer.periodic(_updateInterval, (timer) async {
      if (_currentLocation != null && _isTracking) {
        await _sendLocationUpdate();
      }
    });
  }

  /// Start heartbeat to maintain connection
  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) async {
      if (_isTracking && _activeSessionId != null) {
        await _sendHeartbeat();
      }
    });
  }

  /// Send location update to backend
  Future<void> _sendLocationUpdate() async {
    if (_currentLocation == null || _activeSessionId == null) return;

    try {
      await _apiService.updateProviderLocation(
        _activeSessionId!,
        _currentLocation!.toJson(),
      );
    } catch (e) {
      print('Error sending location update: $e');
      // Don't add to error stream for periodic updates to avoid spam
    }
  }

  /// Send heartbeat to maintain session
  Future<void> _sendHeartbeat() async {
    if (_activeSessionId == null) return;

    try {
      await _apiService.sendTrackingHeartbeat(_activeSessionId!);
    } catch (e) {
      print('Error sending heartbeat: $e');
    }
  }

  /// Update location status on backend
  Future<void> _updateLocationStatus(LocationTrackingStatus status) async {
    if (_currentLocation == null || _activeSessionId == null) return;

    final updatedLocation = _currentLocation!.copyWith(status: status);
    
    try {
      await _apiService.updateProviderLocation(
        _activeSessionId!,
        updatedLocation.toJson(),
      );
      
      _currentLocation = updatedLocation;
      _locationHistory.add(updatedLocation);
    } catch (e) {
      print('Error updating location status: $e');
      rethrow;
    }
  }

  /// Notify backend that tracking has started
  Future<void> _notifyTrackingStarted() async {
    if (_activeSessionId == null) return;

    try {
      await _apiService.startLocationTracking(_activeSessionId!);
    } catch (e) {
      print('Error notifying tracking start: $e');
      // Don't throw - tracking can continue without backend notification
    }
  }

  /// Calculate total distance traveled
  double get totalDistance {
    if (_locationHistory.length < 2) return 0.0;
    
    double total = 0.0;
    for (int i = 1; i < _locationHistory.length; i++) {
      final prev = _locationHistory[i - 1];
      final current = _locationHistory[i];
      
      total += Geolocator.distanceBetween(
        prev.latitude,
        prev.longitude,
        current.latitude,
        current.longitude,
      );
    }
    
    return total / 1000; // Convert to kilometers
  }

  /// Get tracking duration
  Duration? get trackingDuration {
    if (_trackingStartTime == null) return null;
    return DateTime.now().difference(_trackingStartTime!);
  }

  /// Clean up resources
  @override
  void dispose() {
    stopTracking();
    _locationUpdateController.close();
    _statusUpdateController.close();
    _errorController.close();
    super.dispose();
  }
}