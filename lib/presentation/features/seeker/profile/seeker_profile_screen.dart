import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/models/user_model.dart';
import '../../onboarding/view/onboarding_screen.dart';
import 'seeker_edit_profile_screen.dart';
import '../../language/widgets/language_settings_tile.dart';
import '../../../../l10n/app_localizations.dart';

class SeekerProfileScreen extends StatefulWidget {
  const SeekerProfileScreen({super.key});

  @override
  State<SeekerProfileScreen> createState() => _SeekerProfileScreenState();
}

class _SeekerProfileScreenState extends State<SeekerProfileScreen> {
  UserModel? _profile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ApiService();
      final response = await api.getProfile();
      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        setState(() {
          _profile = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load profile';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Network error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.profile,
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Averta',
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadProfile,
          ),
        ],
      ),
      body: _buildBody(appState),
    );
  }

  Widget _buildBody(AppState appState) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
              const SizedBox(height: 12),
              const Text(
                'Failed to Load Profile',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Averta',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Averta',
                  color: Color(0xFF718096),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProfile,
                child: Text(AppLocalizations.of(context)!.retry),
              ),
            ],
          ),
        ),
      );
    }

    final profile = _profile;
    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildAvatar(
                    profile?.fullName ?? appState.user?.displayName ?? 'User',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile?.fullName ?? appState.user?.displayName ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontFamily: 'Averta',
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profile?.email ?? appState.user?.email ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Averta',
                      color: Color(0xFF718096),
                    ),
                  ),
                  if (profile?.phoneNumber != null &&
                      profile!.phoneNumber!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      profile.phoneNumber!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Averta',
                        color: Color(0xFF718096),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        final updated = await Navigator.of(
                          context,
                        ).push<UserModel>(
                          MaterialPageRoute(
                            builder:
                                (_) => SeekerEditProfileScreen(
                                  initialProfile: profile,
                                ),
                          ),
                        );
                        if (!mounted) return;
                        if (updated != null) {
                          // On return, refresh profile view
                          await _loadProfile();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF2B6CB0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.editProfile,
                        style: TextStyle(
                          fontFamily: 'Averta',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2B6CB0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Removed non-navigating account info items (duplicate of header)

            // Only keep settings that navigate: language settings
            Container(
              color: Colors.white,
              child: const Column(children: [LanguageSettingsTile()]),
            ),

            const SizedBox(height: 20),

            // Logout
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: AppLocalizations.of(context)!.logout,
                    titleColor: const Color(0xFFE53E3E),
                    iconColor: const Color(0xFFE53E3E),
                    onTap: () => _showLogoutDialog(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String fullName) {
    final initials = _initialsFromName(fullName);
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFF2B6CB0).withOpacity(0.1),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 28,
            fontFamily: 'Averta',
            fontWeight: FontWeight.bold,
            color: Color(0xFF2B6CB0),
          ),
        ),
      ),
    );
  }

  String _initialsFromName(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
    String? trailingText,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: iconColor ?? const Color(0xFF718096), size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Averta',
                    fontWeight: FontWeight.w500,
                    color: titleColor ?? const Color(0xFF2D3748),
                  ),
                ),
              ),
              if (trailingText != null) ...[
                Flexible(
                  child: Text(
                    trailingText,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Averta',
                      color: Color(0xFF718096),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF718096),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            AppLocalizations.of(context)!.logoutConfirmTitle,
            style: TextStyle(fontFamily: 'Averta', fontWeight: FontWeight.bold),
          ),
          content: Text(
            AppLocalizations.of(context)!.logoutConfirmMessage,
            style: TextStyle(fontFamily: 'Averta'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: const TextStyle(
                  fontFamily: 'Averta',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF718096),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await appState.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const OnboardingScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.logout,
                style: const TextStyle(
                  fontFamily: 'Averta',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Removed unused _formatDate helper after pruning non-navigating items
}
