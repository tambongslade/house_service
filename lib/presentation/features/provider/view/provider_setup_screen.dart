import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/models/user_model.dart';

class ProviderSetupScreen extends StatefulWidget {
  const ProviderSetupScreen({super.key});

  @override
  State<ProviderSetupScreen> createState() => _ProviderSetupScreenState();
}

class _ProviderSetupScreenState extends State<ProviderSetupScreen> {
  bool _isLoading = false;

  // Profile setup data
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _certificationController = TextEditingController();
  final _serviceRadiusController = TextEditingController(text: '25');

  final List<String> _selectedCategories = [];
  final List<String> _selectedAreas = [];
  String? _selectedExperience;
  final List<String> _certifications = [];
  final List<String> _portfolioUrls = [];

  List<String> _availableCategories = [];
  List<String> _availableAreas = [];

  // Experience levels
  final List<String> _experienceLevels = [
    'beginner',
    'intermediate',
    'expert',
  ];

  // Cameroon provinces as per the backend enum
  final List<String> _cameroonProvinces = [
    'Adamaoua',
    'Centre',
    'East',
    'Far_North',
    'Littoral',
    'North',
    'Northwest',
    'South',
    'Southwest',
    'West',
  ];

  @override
  void initState() {
    super.initState();
    _loadServiceCategories();
    _availableAreas = _cameroonProvinces;
    
    // Add listener for bio character count
    _bioController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _loadServiceCategories() async {
    try {
      final apiService = ApiService();
      final response = await apiService.getServiceCategories();

      if (response.isSuccess && response.data != null) {
        setState(() {
          _availableCategories = List<String>.from(
            response.data!['categories'],
          );
        });
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
      // Fallback categories from documentation
      setState(() {
        _availableCategories = [
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Progress dots - single step now
            Row(
              children: List.generate(1, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.primaryColor,
                  ),
                );
              }),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildServiceOfferStep(),
          ),
          _buildBottomButton(theme),
        ],
      ),
    );
  }

  Widget _buildServiceOfferStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Setup Provider Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Complete your profile to start offering services',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),

              // Service Categories (Multiple Selection)
              _buildCategoriesSection(),
              const SizedBox(height: 24),

              // Service Areas (Multiple Selection)
              _buildServiceAreasSection(),
              const SizedBox(height: 24),

              // Service Radius
              _buildServiceRadiusField(),
              const SizedBox(height: 24),

              // Experience Level
              _buildExperienceLevelField(),
              const SizedBox(height: 24),

              // Certifications Section (Optional)
              _buildCertificationsSection(),
              const SizedBox(height: 24),

              // Bio Section (Optional)
              _buildBioSection(),
              const SizedBox(height: 24),

              // Portfolio Section (Optional)
              _buildPortfolioSection(),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods for UI components
  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Categories',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select the services you can provide (minimum 1)',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableCategories.map((category) {
            final isSelected = _selectedCategories.contains(category);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedCategories.remove(category);
                  } else {
                    _selectedCategories.add(category);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF3B82F6) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF3B82F6) : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  _formatCategoryName(category),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (_selectedCategories.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Please select at least one category',
              style: TextStyle(color: Colors.red[600], fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildServiceAreasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Areas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select the regions where you can provide services',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableAreas.map((area) {
            final isSelected = _selectedAreas.contains(area);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedAreas.remove(area);
                  } else {
                    _selectedAreas.add(area);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF10B981) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF10B981) : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  _formatAreaName(area),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (_selectedAreas.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Please select at least one service area',
              style: TextStyle(color: Colors.red[600], fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildServiceRadiusField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Radius (km)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'How far are you willing to travel? (1-100 km)',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        _buildTextFormField(
          controller: _serviceRadiusController,
          label: 'Service Radius',
          hint: 'e.g., 25',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter service radius';
            }
            final radius = int.tryParse(value);
            if (radius == null || radius < 1 || radius > 100) {
              return 'Please enter a radius between 1 and 100 km';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildExperienceLevelField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Experience Level',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select your experience level in providing services',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Row(
          children: _experienceLevels.map((level) {
            final isSelected = _selectedExperience == level;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedExperience = level;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    _formatExperienceLevel(level),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (_selectedExperience == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Please select your experience level',
              style: TextStyle(color: Colors.red[600], fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          labelStyle: TextStyle(color: Colors.grey[600]),
          hintStyle: TextStyle(color: Colors.grey[400]),
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
      ),
    );
  }

  Widget _buildCertificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Certifications (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add any certifications that validate your expertise',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        
        // Certification input field
        Row(
          children: [
            Expanded(
              child: _buildTextFormField(
                controller: _certificationController,
                label: 'Certification',
                hint: 'e.g., Professional Cleaner Certification',
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _addCertification(_certificationController.text),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Display certifications
        if (_certifications.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _certifications.map((cert) => _buildCertificationChip(cert)).toList(),
          ),
      ],
    );
  }

  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Professional Bio (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tell customers about your experience and expertise (max 500 characters)',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        _buildTextFormField(
          controller: _bioController,
          label: 'Bio',
          hint: 'Professional cleaner with 5+ years experience in residential and commercial cleaning...',
          maxLines: 4,
          validator: (value) {
            if (value != null && value.length > 500) {
              return 'Bio must be 500 characters or less';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${_bioController.text.length}/500',
            style: TextStyle(
              fontSize: 12,
              color: _bioController.text.length > 500 ? Colors.red : Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPortfolioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Portfolio Images (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Showcase your work with portfolio images (coming soon)',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        
        Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            color: Colors.grey[50],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate, size: 32, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'Portfolio upload coming soon',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCertificationChip(String certification) {
    return Chip(
      label: Text(certification),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: () => _removeCertification(certification),
      backgroundColor: Colors.blue[50],
      deleteIconColor: Colors.blue[700],
      labelStyle: TextStyle(color: Colors.blue[700]),
    );
  }






  void _addCertification(String certification) {
    final trimmedCert = certification.trim();
    if (trimmedCert.isNotEmpty && !_certifications.contains(trimmedCert)) {
      setState(() {
        _certifications.add(trimmedCert);
        _certificationController.clear();
      });
    }
  }

  void _removeCertification(String certification) {
    setState(() {
      _certifications.remove(certification);
    });
  }

  String _formatAreaName(String area) {
    return area.replaceAll('_', ' ');
  }

  String _formatExperienceLevel(String level) {
    return level.substring(0, 1).toUpperCase() + level.substring(1);
  }

  Widget _buildBottomButton(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Hero(
        tag: 'provider_setup_button',
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleNextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child:
              _isLoading
                  ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : const Text(
                    'Complete Profile Setup',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
        ),
      ),
    );
  }

  // Navigation and completion logic
  Future<void> _handleNextStep() async {
    // Validate profile form and setup profile
    if (_validateProfileForm()) {
      await _completeProfileSetup();
    }
  }

  bool _validateProfileForm() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    // Validate required selections
    if (_selectedCategories.isEmpty) {
      _showErrorSnackBar('Please select at least one service category');
      return false;
    }

    if (_selectedAreas.isEmpty) {
      _showErrorSnackBar('Please select at least one service area');
      return false;
    }

    if (_selectedExperience == null) {
      _showErrorSnackBar('Please select your experience level');
      return false;
    }

    return true;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green[50]!,
                  Colors.white,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Title
                const Text(
                  'Application Submitted Successfully! 🎉',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Message
                const Text(
                  'Your provider profile has been submitted for review. Our admin team will validate your application within 24-48 hours.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                
                // Info box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: const Color(0xFF3B82F6),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'What happens next?',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildNextStepItem('📧', 'You will receive an email notification once approved'),
                      const SizedBox(height: 8),
                      _buildNextStepItem('✅', 'Once approved, you can log in and start offering services'),
                      const SizedBox(height: 8),
                      _buildNextStepItem('📱', 'Keep your contact information up to date'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Continue button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handleContinueToLogin(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Continue to Login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNextStepItem(String icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleContinueToLogin() async {
    // Close dialog first
    Navigator.of(context).pop();
    
    // Logout user to ensure clean state
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      await appState.logout();
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
    
    // Navigate to login screen with success message
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      
      // Show a small snackbar on login screen
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Application submitted! Please wait for admin approval.'),
              backgroundColor: Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
        }
      });
    }
  }

  Future<void> _completeProfileSetup() async {
    setState(() => _isLoading = true);

    try {
      // Ensure user has provider role before setting up profile
      final appState = Provider.of<AppState>(context, listen: false);
      if (appState.userRole != UserRole.serviceProvider) {
        debugPrint('Provider Setup: User role not set, setting to provider...');
        final roleResult = await appState.setUserRole(UserRole.serviceProvider);
        if (!roleResult.success) {
          throw Exception('Failed to set provider role: ${roleResult.error}');
        }
        debugPrint('Provider Setup: User role set to provider successfully');
      } else {
        debugPrint('Provider Setup: User already has provider role');
      }

      debugPrint('Provider Setup: Setting up provider profile...');
      await _setupProviderProfile();
      debugPrint('Provider Setup: Profile setup completed successfully');

      if (mounted) {
        // Show success dialog with admin approval info
        await _showSuccessDialog();
      }
    } catch (e) {
      debugPrint('Provider Setup: Profile setup failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to setup profile: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _setupProviderProfile() async {
    final apiService = ApiService();

    // Create profile data for the setup endpoint
    final profileData = {
      'serviceCategories': _selectedCategories,
      'serviceAreas': _selectedAreas,
      'serviceRadius': int.parse(_serviceRadiusController.text.trim()),
      'experienceLevel': _selectedExperience!,
    };

    // Add optional fields if provided
    if (_certifications.isNotEmpty) {
      profileData['certifications'] = _certifications;
    }

    if (_bioController.text.trim().isNotEmpty) {
      profileData['bio'] = _bioController.text.trim();
    }

    // Portfolio URLs would go here when implemented
    if (_portfolioUrls.isNotEmpty) {
      profileData['portfolio'] = _portfolioUrls;
    }

    // Debug: Print profile data
    debugPrint('Profile Data:');
    profileData.forEach((key, value) {
      debugPrint('  $key: ${value.runtimeType} = $value');
    });

    debugPrint('API: Setting up provider profile with data: $profileData');
    final response = await apiService.setupProviderProfile(profileData);

    debugPrint(
      'API: Profile setup response - Success: ${response.isSuccess}, Error: ${response.error}',
    );

    if (!response.isSuccess) {
      debugPrint('API: Profile setup failed: ${response.error}');
      throw Exception(response.error ?? 'Failed to setup profile');
    } else {
      debugPrint('API: Profile setup completed successfully');
      if (response.data != null) {
        debugPrint('API: Profile status: ${response.data!['status']}');
      }
    }
  }

  String _formatCategoryName(String category) {
    return category.substring(0, 1).toUpperCase() + category.substring(1);
  }

  @override
  void dispose() {
    _bioController.dispose();
    _certificationController.dispose();
    _serviceRadiusController.dispose();
    super.dispose();
  }
}
