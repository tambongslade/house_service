import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/app_state.dart';
import '../../../../l10n/app_localizations.dart';

import 'provider_profile_screen.dart';
import 'provider_setup_screen.dart';
import 'provider_services_screen.dart';
import 'provider_bookings_screen.dart';
import 'provider_availability_screen.dart';
import 'provider_availability_validation_screen.dart';
import 'provider_dashboard_content.dart';

class ProviderMainScreen extends StatefulWidget {
  const ProviderMainScreen({super.key});

  @override
  State<ProviderMainScreen> createState() => _ProviderMainScreenState();
}

class _ProviderMainScreenState extends State<ProviderMainScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  final List<Widget> _screens = [
    const ProviderDashboardContent(), // Dashboard content without AppBar
    const ProviderServicesScreen(), // Services management
    const ProviderBookingsScreen(), // Bookings management
    const ProviderAvailabilityScreen(), // Availability/Schedule management
    const ProviderAvailabilityValidationScreen(), // Availability validation & session management
    const ProviderProfileScreen(), // Profile
  ];

  List<String> _getTitles(BuildContext context) {
    return [
      AppLocalizations.of(context)!.dashboard,
      AppLocalizations.of(context)!.myServices,
      AppLocalizations.of(context)!.sessions,
      AppLocalizations.of(context)!.availability,
      'Availability Validation',
      AppLocalizations.of(context)!.profile,
    ];
  }

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    _updateFabVisibility();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _updateFabVisibility() {
    if (_currentIndex == 1) {
      // Services tab
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildModernAppBar(theme, appState),
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: _buildAnimatedFAB(),
      bottomNavigationBar: _buildModernBottomNavBar(theme),
    );
  }

  PreferredSizeWidget _buildModernAppBar(ThemeData theme, AppState appState) {
    return AppBar(
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: Text(
        _getTitles(context)[_currentIndex],
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions:
          _currentIndex == 4
              ? null
              : [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: PopupMenuButton<String>(
                    onSelected: (value) async {
                      HapticFeedback.lightImpact();
                      if (value == 'profile') {
                        setState(() {
                          _currentIndex = 5;
                        });
                      } else if (value == 'logout') {
                        await appState.logout();
                        if (mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const ProviderMainScreen(),
                            ),
                          );
                        }
                      }
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem<String>(
                          value: 'profile',
                          child: Row(
                            children: [
                              Icon(Icons.person_outline, size: 20),
                              SizedBox(width: 12),
                              Text('My Profile'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, size: 20, color: Colors.red),
                              SizedBox(width: 12),
                              Text(
                                'Logout',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                ),
              ],
    );
  }

  Widget _buildAnimatedFAB() {
    return ScaleTransition(
      scale: _fabAnimation,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          heroTag: "main_screen_fab",
          onPressed: () {
            HapticFeedback.mediumImpact();
            _navigateToAddService();
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            AppLocalizations.of(context)!.addService,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernBottomNavBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex == 5 ? 4 : _currentIndex,
          onTap: (index) {
            HapticFeedback.lightImpact();
            setState(() {
              // Map bottom nav indices to screen indices
              // Profile tab (index 4) should go to screen index 5
              if (index == 4) {
                _currentIndex = 5;
              } else {
                _currentIndex = index;
              }
              _updateFabVisibility();
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF3B82F6),
          unselectedItemColor: const Color(0xFF64748B),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          items: [
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.dashboard_outlined, 0),
              activeIcon: _buildNavIcon(Icons.dashboard, 0, isActive: true),
              label: AppLocalizations.of(context)!.dashboard,
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.work_outline, 1),
              activeIcon: _buildNavIcon(Icons.work, 1, isActive: true),
              label: AppLocalizations.of(context)!.myServices,
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.book_online_outlined, 2),
              activeIcon: _buildNavIcon(Icons.book_online, 2, isActive: true),
              label: AppLocalizations.of(context)!.sessions,
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.schedule_outlined, 3),
              activeIcon: _buildNavIcon(Icons.schedule, 3, isActive: true),
              label: AppLocalizations.of(context)!.availability,
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.person_outline, 4),
              activeIcon: _buildNavIcon(Icons.person, 4, isActive: true),
              label: AppLocalizations.of(context)!.profile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color:
            isActive
                ? const Color(0xFF3B82F6).withOpacity(0.1)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 24,
        color: isActive ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
      ),
    );
  }

  void _navigateToAddService() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ProviderSetupScreen()),
    );
  }
}
