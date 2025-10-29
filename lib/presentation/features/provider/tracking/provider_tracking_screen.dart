import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Removed unused import
import 'package:house_service/core/models/location_tracking_models.dart';
import 'package:house_service/core/services/location_tracking_service.dart';

class ProviderTrackingScreen extends StatefulWidget {
  final String sessionId;
  final String seekerName;
  final String serviceName;
  final LatLng destinationLocation;
  final String? destinationAddress;

  const ProviderTrackingScreen({
    super.key,
    required this.sessionId,
    required this.seekerName,
    required this.serviceName,
    required this.destinationLocation,
    this.destinationAddress,
  });

  @override
  State<ProviderTrackingScreen> createState() => _ProviderTrackingScreenState();
}

class _ProviderTrackingScreenState extends State<ProviderTrackingScreen>
    with TickerProviderStateMixin {
  final LocationTrackingService _trackingService = LocationTrackingService();
  GoogleMapController? _mapController;
  
  // Tracking state
  bool _isTracking = false;
  LocationTrackingModel? _currentLocation;
  LocationTrackingStatus _currentStatus = LocationTrackingStatus.notStarted;
  StreamSubscription? _locationSubscription;
  StreamSubscription? _statusSubscription;
  
  // Animation controllers
  late AnimationController _statusController;
  late AnimationController _buttonController;
  late Animation<double> _statusAnimation;
  late Animation<double> _buttonAnimation;
  
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupLocationListeners();
    _initializeMap();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _statusSubscription?.cancel();
    _statusController.dispose();
    _buttonController.dispose();
    if (_isTracking) {
      _trackingService.stopTracking();
    }
    super.dispose();
  }

  void _initializeAnimations() {
    _statusController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _statusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _statusController, curve: Curves.bounceOut),
    );
    
    _buttonAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
  }

  void _setupLocationListeners() {
    _locationSubscription = _trackingService.locationUpdates.listen(
      (location) {
        setState(() {
          _currentLocation = location;
        });
        _updateMapMarkers();
      },
    );

    _statusSubscription = _trackingService.statusUpdates.listen(
      (status) {
        setState(() {
          _currentStatus = status;
        });
        _statusController.forward().then((_) => _statusController.reverse());
      },
    );
  }

  void _initializeMap() {
    _updateMapMarkers();
  }

  void _updateMapMarkers() {
    final markers = <Marker>{};
    final circles = <Circle>{};
    
    // Add destination marker
    markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: widget.destinationLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Service Location',
          snippet: widget.destinationAddress ?? 'Destination',
        ),
      ),
    );

    // Add current location marker if tracking
    if (_currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentLocation!.position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'Provider location',
          ),
        ),
      );

      // Add accuracy circle
      circles.add(
        Circle(
          circleId: const CircleId('accuracy'),
          center: _currentLocation!.position,
          radius: _currentLocation!.accuracy ?? 10.0,
          fillColor: Colors.blue.withValues(alpha: 0.1),
          strokeColor: Colors.blue.withValues(alpha: 0.3),
          strokeWidth: 1,
        ),
      );
      
      // Add arrival zone circle
      if (_currentStatus == LocationTrackingStatus.onRoute) {
        circles.add(
          Circle(
            circleId: const CircleId('arrival_zone'),
            center: widget.destinationLocation,
            radius: 50.0, // 50 meter arrival threshold
            fillColor: Colors.green.withValues(alpha: 0.1),
            strokeColor: Colors.green.withValues(alpha: 0.5),
            strokeWidth: 2,
          ),
        );
      }
    }

    setState(() {
      _markers = markers;
      _circles = circles;
    });
  }

  Future<void> _startTracking() async {
    _buttonController.forward().then((_) => _buttonController.reverse());
    
    final success = await _trackingService.startTracking(
      sessionId: widget.sessionId,
      destination: widget.destinationLocation,
      destinationAddress: widget.destinationAddress,
    );

    if (success) {
      setState(() {
        _isTracking = true;
        _currentStatus = LocationTrackingStatus.onRoute;
      });
      _statusController.forward().then((_) => _statusController.reverse());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to start location tracking'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _stopTracking() async {
    _buttonController.forward().then((_) => _buttonController.reverse());
    
    await _trackingService.stopTracking(
      finalStatus: LocationTrackingStatus.serviceComplete,
    );

    setState(() {
      _isTracking = false;
      _currentStatus = LocationTrackingStatus.serviceComplete;
    });
    
    _statusController.forward().then((_) => _statusController.reverse());
  }

  Future<void> _updateStatus(LocationTrackingStatus status) async {
    await _trackingService.updateStatus(status);
    _statusController.forward().then((_) => _statusController.reverse());
  }

  Future<void> _emergencyStop() async {
    final reason = await _showEmergencyStopDialog();
    if (reason != null) {
      await _trackingService.emergencyStop(reason);
      setState(() {
        _isTracking = false;
        _currentStatus = LocationTrackingStatus.emergency;
      });
    }
  }

  Future<String?> _showEmergencyStopDialog() async {
    String? selectedReason;
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Stop'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please select a reason for the emergency stop:'),
            const SizedBox(height: 16),
            ...['Vehicle breakdown', 'Health emergency', 'Safety concern', 'Other']
                .map((reason) => RadioListTile<String>(
                  title: Text(reason),
                  value: reason,
                  groupValue: selectedReason,
                  onChanged: (value) {
                    selectedReason = value;
                    Navigator.pop(context, value);
                  },
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Tracking',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'To: ${widget.seekerName}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          if (_isTracking)
            IconButton(
              icon: const Icon(Icons.emergency, color: Colors.red),
              onPressed: _emergencyStop,
              tooltip: 'Emergency Stop',
            ),
        ],
      ),
      body: Stack(
        children: [
          // Google Maps
          GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
              _fitMarkersInView();
            },
            initialCameraPosition: CameraPosition(
              target: widget.destinationLocation,
              zoom: 15.0,
            ),
            markers: _markers,
            circles: _circles,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            mapToolbarEnabled: false,
          ),

          // Status overlay
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildStatusCard(theme),
          ),

          // Control panel
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildControlPanel(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(ThemeData theme) {
    return AnimatedBuilder(
      animation: _statusAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_statusAnimation.value * 0.05),
          child: Card(
            color: _getStatusColor(_currentStatus),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      _getStatusIcon(_currentStatus),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentStatus.displayName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              _currentStatus.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_currentLocation != null) ...[
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatusInfo(
                          'Distance',
                          _currentLocation!.formattedDistance,
                          Icons.location_on,
                        ),
                        if (_currentLocation!.estimatedArrivalTime != null)
                          _buildStatusInfo(
                            'ETA',
                            _currentLocation!.formattedETA,
                            Icons.access_time,
                          ),
                        if (_currentLocation!.speed != null)
                          _buildStatusInfo(
                            'Speed',
                            _currentLocation!.formattedSpeed,
                            Icons.speed,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildControlPanel(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.serviceName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'For: ${widget.seekerName}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            if (!_isTracking) ...[
              AnimatedBuilder(
                animation: _buttonAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _buttonAnimation.value,
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _startTracking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow, size: 24),
                        label: const Text(
                          'Start Tracking',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ] else ...[
              Row(
                children: [
                  if (_currentStatus == LocationTrackingStatus.onRoute)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updateStatus(LocationTrackingStatus.atLocation),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.location_on),
                        label: const Text('I\'m Here'),
                      ),
                    ),
                  if (_currentStatus == LocationTrackingStatus.atLocation) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updateStatus(LocationTrackingStatus.onRoute),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.directions_car),
                        label: const Text('Continue'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _stopTracking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade600,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Complete'),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _stopTracking,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop Tracking'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _fitMarkersInView() async {
    if (_mapController == null || _markers.isEmpty) return;
    
    final bounds = _calculateBounds(_markers.map((m) => m.position).toList());
    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100.0),
    );
  }

  LatLngBounds _calculateBounds(List<LatLng> positions) {
    if (positions.isEmpty) {
      return LatLngBounds(
        southwest: widget.destinationLocation,
        northeast: widget.destinationLocation,
      );
    }
    
    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;
    
    for (final pos in positions) {
      minLat = math.min(minLat, pos.latitude);
      maxLat = math.max(maxLat, pos.latitude);
      minLng = math.min(minLng, pos.longitude);
      maxLng = math.max(maxLng, pos.longitude);
    }
    
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  Color _getStatusColor(LocationTrackingStatus status) {
    switch (status) {
      case LocationTrackingStatus.notStarted:
        return Colors.grey.shade600;
      case LocationTrackingStatus.onRoute:
        return Colors.blue.shade600;
      case LocationTrackingStatus.atLocation:
        return Colors.green.shade600;
      case LocationTrackingStatus.serviceComplete:
        return Colors.purple.shade600;
      case LocationTrackingStatus.emergency:
        return Colors.red.shade600;
    }
  }

  Widget _getStatusIcon(LocationTrackingStatus status) {
    IconData iconData;
    switch (status) {
      case LocationTrackingStatus.notStarted:
        iconData = Icons.hourglass_empty;
        break;
      case LocationTrackingStatus.onRoute:
        iconData = Icons.directions_car;
        break;
      case LocationTrackingStatus.atLocation:
        iconData = Icons.location_on;
        break;
      case LocationTrackingStatus.serviceComplete:
        iconData = Icons.check_circle;
        break;
      case LocationTrackingStatus.emergency:
        iconData = Icons.warning;
        break;
    }
    
    return Icon(iconData, color: Colors.white, size: 28);
  }
}