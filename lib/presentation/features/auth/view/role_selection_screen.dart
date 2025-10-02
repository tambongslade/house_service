import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/models/user_model.dart';
import '../../provider/view/provider_setup_screen.dart';
import '../../seeker/navigation/seeker_main_screen.dart';
import '../../../../l10n/app_localizations.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole? selectedRole;
  bool _isLoading = false;

  Future<void> _continueWithRole() async {
    if (selectedRole == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);

      print(
        'RoleSelection: Starting role selection for: ${selectedRole!.value}',
      );

      // Save the selected role via API
      final result = await appState.setUserRole(selectedRole!);

      if (mounted) {
        if (result.success) {
          print('RoleSelection: Role set successfully, navigating...');
          // Navigate to appropriate screen based on role
          Widget nextScreen;
          if (selectedRole == UserRole.serviceSeeker) {
            nextScreen = const SeekerMainScreen();
          } else {
            // Navigate to setup screen for new providers
            nextScreen = const ProviderSetupScreen();
          }

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => nextScreen),
          );
        } else {
          // Show specific error message from the API
          final errorMessage =
              result.error ?? 'Failed to set user role. Please try again.';
          print('RoleSelection: Role setting failed: $errorMessage');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 40,
          child: Image.asset(
            'assets/images/LOGO.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Text(
                AppLocalizations.of(context)!.homeAideServices,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Title
              Text(
                AppLocalizations.of(context)!.iAm,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF2D3748),
                ),
              ),

              const SizedBox(height: 60),

              // Role Options
              _buildRoleOption(
                role: UserRole.serviceProvider,
                title: AppLocalizations.of(context)!.serviceProvider,
                subtitle: AppLocalizations.of(context)!.iOfferProfessionalServices,
                isSelected: selectedRole == UserRole.serviceProvider,
                onTap: () {
                  setState(() {
                    selectedRole = UserRole.serviceProvider;
                  });
                },
              ),

              const SizedBox(height: 20),

              _buildRoleOption(
                role: UserRole.serviceSeeker,
                title: AppLocalizations.of(context)!.serviceSeeker,
                subtitle: 'I am looking for home services.',
                isSelected: selectedRole == UserRole.serviceSeeker,
                onTap: () {
                  setState(() {
                    selectedRole = UserRole.serviceSeeker;
                  });
                },
              ),

              const Spacer(),

              // Next Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      selectedRole != null && !_isLoading
                          ? _continueWithRole
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B6CB0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    disabledBackgroundColor: const Color(0xFFE2E8F0),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Text(
                            AppLocalizations.of(context)!.next,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption({
    required UserRole role,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF7FAFC) : Colors.white,
          border: Border.all(
            color:
                isSelected ? const Color(0xFF4299E1) : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color:
                    isSelected
                        ? const Color(0xFF2B6CB0)
                        : const Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF718096),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
