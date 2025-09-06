import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:house_service/core/state/app_state.dart';
import 'package:house_service/l10n/app_localizations.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _showRationale = false;
  LocationPermission? _currentPermissionStatus;
  
  late AnimationController _pulseController;
  late AnimationController _iconController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkCurrentPermissionStatus();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );
    
    _iconController.forward();
  }

  Future<void> _checkCurrentPermissionStatus() async {
    try {
      final permission = await Geolocator.checkPermission();
      setState(() {
        _currentPermissionStatus = permission;
      });
      
      // If location is already granted, proceed automatically
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        _handlePermissionGranted();
      }
    } catch (e) {
      print('Error checking location permission: $e');
    }
  }

  Future<void> _requestLocationPermission() async {
    setState(() {
      _isLoading = true;
      _showRationale = false;
    });

    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDialog();
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Check current permission
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      setState(() {
        _currentPermissionStatus = permission;
        _isLoading = false;
      });

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        _handlePermissionGranted();
      } else if (permission == LocationPermission.deniedForever) {
        setState(() {
          _showRationale = true;
        });
      } else {
        // Permission denied, show rationale
        setState(() {
          _showRationale = true;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _showRationale = true;
      });
      print('Error requesting location permission: $e');
    }
  }

  void _handlePermissionGranted() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.setLocationPermissionGranted();
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.locationServicesDisabled ?? 'Location Services Disabled'),
        content: Text(
          AppLocalizations.of(context)!.enableLocationServices ?? 
          'Location services are disabled. Please enable them in your device settings to use location features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.ok ?? 'OK'),
          ),
        ],
      ),
    );
  }

  void _openAppSettings() {
    Geolocator.openAppSettings();
  }

  void _skipPermission() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.setLocationPermissionGranted(); // Still proceed but note permission was skipped
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Location Icon
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return AnimatedBuilder(
                          animation: _iconAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value * _iconAnimation.value,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.shade200.withValues(alpha: 0.5),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.location_on,
                                  size: 60,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Title
                    Text(
                      AppLocalizations.of(context)!.enableLocation ?? 'Enable Location',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Description
                    Text(
                      AppLocalizations.of(context)!.locationPermissionDescription ?? 
                      'We need access to your location to show nearby service providers and enable GPS tracking when you book services.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Benefits List
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          _buildBenefitItem(
                            Icons.map,
                            AppLocalizations.of(context)!.findNearbyProviders ?? 'Find nearby service providers',
                          ),
                          const SizedBox(height: 12),
                          _buildBenefitItem(
                            Icons.gps_fixed,
                            AppLocalizations.of(context)!.realTimeTracking ?? 'Real-time service tracking',
                          ),
                          const SizedBox(height: 12),
                          _buildBenefitItem(
                            Icons.directions,
                            AppLocalizations.of(context)!.accurateDirections ?? 'Accurate service locations',
                          ),
                        ],
                      ),
                    ),
                    
                    if (_showRationale) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange.shade700),
                            const SizedBox(height: 8),
                            Text(
                              _currentPermissionStatus == LocationPermission.deniedForever
                                  ? (AppLocalizations.of(context)!.locationPermanentlyDenied ?? 
                                     'Location access permanently denied. Please enable it in app settings.')
                                  : (AppLocalizations.of(context)!.locationDenied ?? 
                                     'Location access denied. Some features may not work properly.'),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.orange.shade700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Action Buttons
              Column(
                children: [
                  if (!_showRationale || _currentPermissionStatus != LocationPermission.deniedForever) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _requestLocationPermission,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.location_on, size: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalizations.of(context)!.allowLocation ?? 'Allow Location Access',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                  
                  if (_showRationale && _currentPermissionStatus == LocationPermission.deniedForever) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _openAppSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.settings, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.openSettings ?? 'Open Settings',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 12),
                  
                  // Skip Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _skipPermission,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.skipForNow ?? 'Skip for now',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.blue.shade600,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}