import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:house_service/l10n/app_localizations.dart';
import 'package:house_service/core/state/app_state.dart';
import 'package:house_service/core/models/provider_models.dart';
import 'package:house_service/core/models/service_request_models.dart';
import 'package:house_service/presentation/features/seeker/providers/provider_profile_screen.dart';

class SeekerMapScreen extends StatefulWidget {
  final bool isForLocationSelection;
  final LatLng? initialLocation;

  const SeekerMapScreen({
    super.key,
    this.isForLocationSelection = false,
    this.initialLocation,
  });

  @override
  State<SeekerMapScreen> createState() => _SeekerMapScreenState();
}

class _SeekerMapScreenState extends State<SeekerMapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _loadingLocation = true;
  bool _loadingProviders = false;
  List<ProviderBasic> _nearbyProviders = [];
  Set<Marker> _markers = {};
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  
  // For location selection
  LatLng? _selectedLocationForService;
  

  // Cameroon coordinates (default fallback location)
  static const LatLng _defaultLocation = LatLng(3.848, 11.502);

  // Service categories for filtering
  final List<String> _categories = [
    'all',
    'cleaning',
    'plumbing',
    'electrical',
    'painting',
    'gardening',
    'carpentry',
    'cooking',
    'tutoring',
    'beauty',
    'maintenance',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isForLocationSelection && widget.initialLocation != null) {
      _selectedLocationForService = widget.initialLocation;
    }
    _initializeLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationError('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationError('Location permissions are permanently denied');
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _loadingLocation = false;
        });
      }

      // Move camera to current location
      if (_mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            15.0,
          ),
        );
      }

      // Load nearby providers only if not in location selection mode
      if (!widget.isForLocationSelection) {
        await _loadNearbyProviders();
      } else {
        await _createLocationSelectionMarker();
      }
    } catch (e) {
      // Error getting location
      if (mounted) {
        setState(() {
          _loadingLocation = false;
        });
      }
      _showLocationError('Failed to get current location: ${e.toString()}');
    }
  }

  void _showLocationError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _initializeLocation,
        ),
      ),
    );
  }

  Future<void> _loadNearbyProviders() async {
    if (_loadingProviders) return;
    
    if (!mounted) return;
    setState(() {
      _loadingProviders = true;
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final response = await appState.apiService.getAllProviders(
        page: 1,
        limit: 50, // Get more providers for map display
      );

      if (response.isSuccess && response.data != null) {
        final providersData = response.data!['providers'] as List<dynamic>?;
        
        if (providersData != null) {
          final providers = providersData
              .map((provider) => ProviderBasic.fromJson(provider as Map<String, dynamic>))
              .toList();

          if (mounted) {
            setState(() {
              _nearbyProviders = providers;
              _loadingProviders = false;
            });
          }

          await _createMarkers();
        }
      }
    } catch (e) {
      // Error loading providers
      if (mounted) {
        setState(() {
          _loadingProviders = false;
        });
      }
    }
  }

  Future<BitmapDescriptor> _createCustomMarker() async {
    // Create a simple custom marker for providers
    const size = 80;
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..isAntiAlias = true;
    
    const center = Offset(size / 2, size / 2);
    const radius = size / 3;
    
    // Draw shadow
    paint.color = Colors.black.withValues(alpha: 0.3);
    canvas.drawCircle(center.translate(2, 2), radius, paint);
    
    // Draw main circle (provider marker)
    paint.color = const Color(0xFF2196F3);
    canvas.drawCircle(center, radius, paint);
    
    // Draw white border
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    canvas.drawCircle(center, radius, paint);
    
    // Draw service icon
    paint.color = Colors.white;
    paint.style = PaintingStyle.fill;
    const iconSize = 16.0;
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.home_repair_service.codePoint),
        style: const TextStyle(
          fontSize: iconSize,
          color: Colors.white,
          fontFamily: 'MaterialIcons',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
    
    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size, size);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  Future<void> _createMarkers() async {
    final markers = <Marker>{};
    
    // Add current location marker
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Your Location',
          ),
        ),
      );
    }

    // Create custom marker for providers
    final customMarker = await _createCustomMarker();

    // Add provider markers (simulate locations for demo)
    for (int i = 0; i < _nearbyProviders.length; i++) {
      final provider = _nearbyProviders[i];
      
      // Generate random coordinates around current location or default location
      final baseLocation = _currentPosition != null 
          ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
          : _defaultLocation;
      
      // Generate random offset within 5km radius
      final random = DateTime.now().millisecondsSinceEpoch + i;
      final latOffset = ((random % 100) - 50) / 1000.0; // ~±5km
      final lngOffset = ((random % 200) - 100) / 1000.0; // ~±10km
      
      final providerLocation = LatLng(
        baseLocation.latitude + latOffset,
        baseLocation.longitude + lngOffset,
      );

      markers.add(
        Marker(
          markerId: MarkerId('provider_${provider.id}'),
          position: providerLocation,
          icon: customMarker,
          consumeTapEvents: false,
          onTap: () {
            // Do nothing - marker should not be interactive
          },
        ),
      );
    }

    if (mounted) {
      setState(() {
        _markers = markers;
      });
    }
  }

  Future<void> _createLocationSelectionMarker() async {
    final markers = <Marker>{};
    
    // Add current location marker
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Your Current Location',
          ),
        ),
      );
    }

    // Add selected location marker if exists
    if (_selectedLocationForService != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: _selectedLocationForService!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(
            title: 'Selected Service Location',
          ),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _markers = markers;
      });
    }
  }

  void _onMapTap(LatLng position) {
    if (!widget.isForLocationSelection) return;

    setState(() {
      _selectedLocationForService = position;
    });

    _createLocationSelectionMarker();
  }

  Future<void> _confirmLocation() async {
    if (_selectedLocationForService != null) {
      String address = '${_selectedLocationForService!.latitude.toStringAsFixed(6)}, ${_selectedLocationForService!.longitude.toStringAsFixed(6)}';
      
      try {
        // Try to get a human-readable address
        List<Placemark> placemarks = await placemarkFromCoordinates(
          _selectedLocationForService!.latitude,
          _selectedLocationForService!.longitude,
        );
        
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          final addressParts = <String>[];
          
          if (placemark.street != null && placemark.street!.isNotEmpty) {
            addressParts.add(placemark.street!);
          }
          if (placemark.locality != null && placemark.locality!.isNotEmpty) {
            addressParts.add(placemark.locality!);
          }
          if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
            addressParts.add(placemark.administrativeArea!);
          }
          if (placemark.country != null && placemark.country!.isNotEmpty) {
            addressParts.add(placemark.country!);
          }
          
          if (addressParts.isNotEmpty) {
            address = addressParts.join(', ');
          }
        }
      } catch (e) {
        // Error getting address
        // Keep the coordinate address as fallback
      }
      
      final location = ServiceRequestLocation(
        latitude: _selectedLocationForService!.latitude,
        longitude: _selectedLocationForService!.longitude,
        address: address,
      );
      
      if (mounted) {
        Navigator.pop(context, location);
      }
    }
  }

  void _navigateToProviderProfile(String providerId, String providerName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProviderProfileScreen(
          providerId: providerId,
          providerName: providerName,
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    
    // Set initial camera position
    if (_currentPosition != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          15.0,
        ),
      );
    }
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'all':
        return AppLocalizations.of(context)!.all;
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
      case 'other':
        return 'Other';
      default:
        return category.replaceAll('_', ' ').split(' ')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isForLocationSelection 
              ? 'Select Service Location'
              : 'Find Service Providers',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          if (!widget.isForLocationSelection)
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: _loadingLocation ? null : _initializeLocation,
            ),
          if (widget.isForLocationSelection && _selectedLocationForService != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _confirmLocation,
            ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Google Maps - Always present to avoid Stack assertion
          _loadingLocation
              ? Container(
                  color: Colors.grey.shade100,
                  child: const Center(child: CircularProgressIndicator()),
                )
              : GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition != null
                        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                        : _defaultLocation,
                    zoom: 15.0,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: true,
                  mapToolbarEnabled: false,
                  onTap: _onMapTap,
                ),

          // Search and filter overlay - Only for provider finding mode
          if (!widget.isForLocationSelection)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.searchForServices,
                      prefixIcon: Icon(Icons.search, color: colors.onSurfaceVariant),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onSubmitted: (value) {
                      // Implement search functionality if needed
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Category filter
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(_getCategoryDisplayName(category)),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (mounted) {
                              setState(() {
                                _selectedCategory = selected ? category : null;
                              });
                            }
                            // Filter providers by category if needed
                          },
                          selectedColor: Colors.blue.shade100,
                          backgroundColor: Colors.grey.shade100,
                          side: BorderSide.none,
                        ),
                      );
                    },
                  ),
                ),
              ],
              ),
            ),

          // Instructions for location selection
          if (widget.isForLocationSelection)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tap anywhere on the map to select your service location',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedLocationForService != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green.shade600),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Location selected! Tap the check icon to confirm.',
                              style: TextStyle(
                                color: Colors.green.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

          // Confirm location button for location selection
          if (widget.isForLocationSelection && _selectedLocationForService != null)
            Positioned(
              bottom: 30,
              left: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: _confirmLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check),
                    const SizedBox(width: 8),
                    Text(
                      'Confirm This Location',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Loading indicator for providers
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: _loadingProviders
                ? const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Loading providers...'),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Provider count badge - Only for provider finding mode
          if (!widget.isForLocationSelection && _nearbyProviders.isNotEmpty)
            Positioned(
              bottom: 30,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade800,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '${_nearbyProviders.length} providers found',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

}