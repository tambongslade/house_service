import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Removed unused imports
import 'package:house_service/core/models/location_tracking_models.dart';
import 'package:house_service/core/services/location_tracking_service.dart';

class SeekerTrackingScreen extends StatefulWidget {
  final String sessionId;
  final String providerName;
  final String serviceName;

  const SeekerTrackingScreen({
    super.key,
    required this.sessionId,
    required this.providerName,
    required this.serviceName,
  });

  @override
  State<SeekerTrackingScreen> createState() => _SeekerTrackingScreenState();
}

class _SeekerTrackingScreenState extends State<SeekerTrackingScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  SessionLocationData? _trackingData;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _refreshTimer;
  
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _statusController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _statusAnimation;
  
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadTrackingData();
    _startPeriodicRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _pulseController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _statusController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _statusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _statusController, curve: Curves.easeOut),
    );
  }

  Future<void> _loadTrackingData() async {
    try {
      final trackingService = LocationTrackingService();
      final data = await trackingService.getSessionLocationData(widget.sessionId);
      
      if (mounted) {
        setState(() {
          _trackingData = data;
          _isLoading = false;
          _errorMessage = null;
        });
        
        if (data != null) {
          await _updateMapMarkers();
          _statusController.forward();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load tracking data: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _loadTrackingData();
      }
    });
  }

  Future<void> _updateMapMarkers() async {
    if (_trackingData == null) return;
    
    final markers = <Marker>{};
    final polylines = <Polyline>{};
    
    // Add destination marker
    if (_trackingData!.destinationLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: _trackingData!.destinationLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'Service Location',
            snippet: _trackingData!.destinationAddress ?? 'Your location',
          ),
        ),
      );
    }
    
    // Add provider marker if location is available
    if (_trackingData!.currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('provider'),
          position: _trackingData!.currentLocation!.position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: widget.providerName,
            snippet: _trackingData!.currentLocation!.status.displayName,
          ),
        ),
      );
      
      // Create route polyline if both locations exist
      if (_trackingData!.destinationLocation != null) {
        polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: [
              _trackingData!.currentLocation!.position,
              _trackingData!.destinationLocation!,
            ],
            color: Colors.blue,
            width: 3,
            patterns: [PatternItem.dash(20), PatternItem.gap(10)],
          ),
        );
      }
      
      // Add location history trail
      if (_trackingData!.locationHistory.length > 1) {
        final historyPoints = _trackingData!.locationHistory
            .map((location) => LatLng(location.latitude, location.longitude))
            .toList();
        
        polylines.add(
          Polyline(
            polylineId: const PolylineId('history'),
            points: historyPoints,
            color: Colors.grey.shade400,
            width: 2,
          ),
        );
      }
    }
    
    setState(() {
      _markers = markers;
      _polylines = polylines;
    });
    
    // Update camera to show both markers
    if (_mapController != null && markers.length > 1) {
      await _fitMarkersInView();
    }
  }

  Future<void> _fitMarkersInView() async {
    if (_mapController == null || _markers.isEmpty) return;
    
    final bounds = _calculateBounds(_markers.map((m) => m.position).toList());
    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100.0),
    );
  }

  LatLngBounds _calculateBounds(List<LatLng> positions) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Track Provider',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.serviceName,
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTrackingData,
          ),
        ],
      ),
      body: _buildBody(context, theme),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Unable to load tracking data',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadTrackingData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (_trackingData?.isTrackingActive != true) {
      return _buildWaitingScreen(theme);
    }
    
    return Stack(
      children: [
        // Google Maps
        GoogleMap(
          onMapCreated: (controller) => _mapController = controller,
          initialCameraPosition: CameraPosition(
            target: _trackingData?.currentLocation?.position ??
                   _trackingData?.destinationLocation ??
                   const LatLng(3.848, 11.502), // Cameroon default
            zoom: 15.0,
          ),
          markers: _markers,
          polylines: _polylines,
          myLocationEnabled: false,
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
        
        // Provider info card
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: _buildProviderInfoCard(theme),
        ),
      ],
    );
  }

  Widget _buildWaitingScreen(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_searching,
                    size: 48,
                    color: Colors.blue.shade800,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Waiting for Provider',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your provider hasn\'t started tracking yet.\nYou\'ll see their location once they begin.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement call provider functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Call provider feature coming soon!')),
              );
            },
            child: const Text('Call Provider'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(ThemeData theme) {
    final status = _trackingData?.currentStatus ?? LocationTrackingStatus.notStarted;
    
    return AnimatedBuilder(
      animation: _statusAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _statusAnimation.value,
          child: Card(
            color: _getStatusColor(status).withValues(alpha: 0.9),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _getStatusIcon(status),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          status.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProviderInfoCard(ThemeData theme) {
    final location = _trackingData?.currentLocation;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade800,
                  child: Text(
                    widget.providerName.isNotEmpty 
                        ? widget.providerName[0].toUpperCase()
                        : 'P',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.providerName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.serviceName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (location?.estimatedArrivalTime != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'ETA: ${location!.formattedETA}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (location != null) ...[
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.location_on,
                    label: location.formattedDistance,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  if (location.speed != null)
                    _buildInfoChip(
                      icon: Icons.speed,
                      label: location.formattedSpeed,
                      color: Colors.orange,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement call functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Call feature coming soon!')),
                        );
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Call'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement message functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Message feature coming soon!')),
                        );
                      },
                      icon: const Icon(Icons.message),
                      label: const Text('Message'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
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