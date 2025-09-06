import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/state/app_state.dart';
import '../../language/widgets/language_settings_tile.dart';
import '../../../../l10n/app_localizations.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen>
    with TickerProviderStateMixin {
  UserModel? _userProfile;
  bool _isLoading = true;
  String? _errorMessage;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadProfile();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = ApiService();
      debugPrint('Profile: Loading user profile...');

      final response = await apiService.getProfile();

      debugPrint(
        'Profile: Response - Success: ${response.isSuccess}, Error: ${response.error}',
      );

      if (!mounted) return; // Check mounted before setState

      if (response.isSuccess && response.data != null) {
        setState(() {
          _userProfile = response.data;
          _isLoading = false;
        });
        debugPrint('Profile: Loaded successfully - ${_userProfile!.fullName}');
      } else {
        setState(() {
          _errorMessage = response.error ?? 'Failed to load profile';
          _isLoading = false;
        });
        debugPrint('Profile: Load failed - $_errorMessage');
      }
    } catch (e) {
      if (!mounted) return; // Check mounted before setState

      setState(() {
        _errorMessage = 'Network error: ${e.toString()}';
        _isLoading = false;
      });
      debugPrint('Profile: Exception - $e');
    }
  }

  Future<void> _showLogoutConfirmationDialog() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: Color(0xFFEF4444), size: 24),
              SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.logoutConfirmTitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          content: Text(
            AppLocalizations.of(context)!.logoutConfirmMessage,
            style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFEF4444),
              ),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  AppLocalizations.of(context)!.logout,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await _handleLogout();
    }
  }

  Future<void> _handleLogout() async {
    if (!mounted) return;

    // Show loading state during logout

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      debugPrint('Profile: Starting logout process...');
      debugPrint(
        'Profile: Current login state before logout: ${appState.isLoggedIn}',
      );

      // Use AppState logout method which handles everything properly
      await appState.logout();

      debugPrint('Profile: Logout completed');
      debugPrint(
        'Profile: Current login state after logout: ${appState.isLoggedIn}',
      );

      if (!mounted) return;

      debugPrint('Profile: Logout successful');

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.loggedOutSuccessfully),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      }

      // Navigate to login screen and clear navigation stack
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      debugPrint('Profile: Logout exception - $e');

      if (!mounted) return;

      // Handle logout error state

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!.networkErrorDuringLogout(e.toString()),
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_userProfile == null) {
      return _buildErrorState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: RefreshIndicator(
          onRefresh: _loadProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 32),
                _buildStatsRow(),
                const SizedBox(height: 24),
                _buildAccountInfo(),
                const SizedBox(height: 24),
                _buildBusinessInfo(),
                const SizedBox(height: 24),
                _buildAccountActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.loading,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.failedToLoadProfile,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Unable to load your profile information',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 16),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ElevatedButton(
                onPressed: _loadProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.retry,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final initials =
        _userProfile!.fullName.isNotEmpty
            ? _userProfile!.fullName
                .split(' ')
                .where((name) => name.isNotEmpty) // Filter out empty strings
                .map((name) => name[0])
                .take(2)
                .join()
                .toUpperCase()
            : 'P';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _userProfile!.fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_user, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  _userProfile!.role?.value.toUpperCase() ?? 'PROVIDER',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _userProfile!.email,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: AppLocalizations.of(context)!.memberSince,
            value:
                _userProfile!.createdAt != null
                    ? _formatYear(_userProfile!.createdAt!)
                    : 'N/A',
            icon: Icons.calendar_today_outlined,
            color: const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Account Status',
            value: 'Active',
            icon: Icons.verified_outlined,
            color: const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfo() {
    return _buildSection(
      title: AppLocalizations.of(context)!.profile,
      icon: Icons.person_outline,
      child: Column(
        children: [
          _buildInfoTile(
            icon: Icons.email_outlined,
            label: AppLocalizations.of(context)!.email,
            value: _userProfile!.email,
            color: const Color(0xFF3B82F6),
          ),
          _buildDivider(),
          _buildInfoTile(
            icon: Icons.phone_outlined,
            label: AppLocalizations.of(context)!.phone,
            value:
                _userProfile!.phoneNumber ??
                AppLocalizations.of(context)!.notProvided,
            color: const Color(0xFF10B981),
          ),
          _buildDivider(),
          _buildInfoTile(
            icon: Icons.calendar_today_outlined,
            label: AppLocalizations.of(context)!.memberSince,
            value:
                _userProfile!.createdAt != null
                    ? _formatDate(_userProfile!.createdAt!)
                    : AppLocalizations.of(context)!.notProvided,
            color: const Color(0xFF8B5CF6),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessInfo() {
    return _buildSection(
      title: AppLocalizations.of(context)!.details,
      icon: Icons.business_outlined,
      child: Column(
        children: [
          _buildInfoTile(
            icon: Icons.fingerprint_outlined,
            label: 'Provider ID',
            value:
                _userProfile!.id.length > 8
                    ? '${_userProfile!.id.substring(0, 8)}...'
                    : _userProfile!.id,
            color: const Color(0xFF64748B),
          ),
          _buildDivider(),
          _buildInfoTile(
            icon: Icons.verified_outlined,
            label: AppLocalizations.of(context)!.status,
            value: AppLocalizations.of(context)!.confirmed,
            valueColor: const Color(0xFF10B981),
            color: const Color(0xFF10B981),
          ),
          _buildDivider(),
          _buildInfoTile(
            icon: Icons.update_outlined,
            label: AppLocalizations.of(context)!.updatePersonalInfo,
            value:
                _userProfile!.updatedAt != null
                    ? _formatDate(_userProfile!.updatedAt!)
                    : AppLocalizations.of(context)!.notProvided,
            color: const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions() {
    return _buildSection(
      title: AppLocalizations.of(context)!.settings,
      icon: Icons.settings_outlined,
      child: Column(
        children: [
          _buildActionTile(
            icon: Icons.edit_outlined,
            title: AppLocalizations.of(context)!.editProfile,
            subtitle: AppLocalizations.of(context)!.updatePersonalInfo,
            color: const Color(0xFF3B82F6),
            onTap: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.featureComingSoon(
                      AppLocalizations.of(context)!.editProfile,
                    ),
                  ),
                  backgroundColor: Color(0xFF3B82F6),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          _buildDivider(),
          _buildActionTile(
            icon: Icons.security_outlined,
            title: AppLocalizations.of(context)!.securitySettings,
            subtitle: AppLocalizations.of(context)!.passwordAndSecurity,
            color: const Color(0xFF10B981),
            onTap: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.featureComingSoon(
                      AppLocalizations.of(context)!.securitySettings,
                    ),
                  ),
                  backgroundColor: Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          _buildDivider(),
          _buildActionTile(
            icon: Icons.notifications_outlined,
            title: AppLocalizations.of(context)!.notifications,
            subtitle: AppLocalizations.of(context)!.manageNotifications,
            color: const Color(0xFFF59E0B),
            onTap: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.featureComingSoon(
                      AppLocalizations.of(context)!.notifications,
                    ),
                  ),
                  backgroundColor: Color(0xFFF59E0B),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          _buildDivider(),
          const LanguageSettingsTile(),
          _buildDivider(),
          _buildActionTile(
            icon: Icons.help_outline,
            title: AppLocalizations.of(context)!.helpAndSupport,
            subtitle: AppLocalizations.of(context)!.getHelpOrContact,
            color: const Color(0xFF8B5CF6),
            onTap: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.featureComingSoon(
                      AppLocalizations.of(context)!.helpAndSupport,
                    ),
                  ),
                  backgroundColor: Color(0xFF8B5CF6),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          _buildDivider(),
          _buildActionTile(
            icon: Icons.logout,
            title: AppLocalizations.of(context)!.logout,
            subtitle: AppLocalizations.of(context)!.signOut,
            color: const Color(0xFFEF4444),
            onTap: () {
              HapticFeedback.lightImpact();
              _showLogoutConfirmationDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    IconData? icon,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 20, color: const Color(0xFF3B82F6)),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: Colors.grey[100],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (color ?? const Color(0xFF64748B)).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: color ?? const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: valueColor ?? const Color(0xFF1E293B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    final actionColor = color ?? const Color(0xFF64748B);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: actionColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: actionColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatYear(DateTime date) {
    return '${date.year}';
  }
}
