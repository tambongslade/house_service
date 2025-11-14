import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/models/user_model.dart';
import '../../auth/view/login_screen.dart';

class ProviderSetupWithSignupScreen extends StatefulWidget {
  final Map<String, dynamic> signupData;
  
  const ProviderSetupWithSignupScreen({
    super.key,
    required this.signupData,
  });

  @override
  State<ProviderSetupWithSignupScreen> createState() => _ProviderSetupWithSignupScreenState();
}

class _ProviderSetupWithSignupScreenState extends State<ProviderSetupWithSignupScreen> {
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
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _loadServiceCategories() async {
    try {
      final apiService = ApiService();
      final response = await apiService.getServiceCategories();

      if (response.isSuccess && response.data != null) {
        if (mounted) {
          setState(() {
            _availableCategories = List<String>.from(
              response.data!['categories'],
            );
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
      // Fallback categories from documentation
      if (mounted) {
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
  }

  Future<void> _handleCompleteRegistration() async {
    if (_validateProfileForm()) {
      if (mounted) {
        setState(() => _isLoading = true);
      }

      try {
        final appState = Provider.of<AppState>(context, listen: false);

        // Prepare provider setup data
        final providerSetupData = {
          'bio': _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
          'serviceCategories': _selectedCategories,
          'serviceAreas': _selectedAreas,
          'experienceLevel': _selectedExperience,
          'serviceRadius': int.parse(_serviceRadiusController.text),
          'certifications': _certifications,
          'portfolioUrls': _portfolioUrls,
        };

        // Remove null values
        providerSetupData.removeWhere((key, value) => value == null);

        // Register with complete provider setup data
        final result = await appState.register(
          widget.signupData['fullName'],
          widget.signupData['email'],
          widget.signupData['password'],
          widget.signupData['phoneNumber'],
          role: 'provider',
          providerSetupData: providerSetupData,
        );

        if (!result.success) {
          throw Exception(result.error ?? 'Registration failed');
        }

        // Provider registration with setup data successful - show success dialog
        if (mounted) {
          await _showProviderRegistrationSuccessDialog();
        }
      } catch (e) {
        debugPrint('Complete registration failed: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration failed: ${e.toString()}'),
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
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _showProviderRegistrationSuccessDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF7E6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.pending_actions,
                color: Color(0xFFFA8C16),
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Registration Submitted!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your provider account has been created and is pending admin approval. You will receive an email notification once your account is verified and you can start offering services.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF718096),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B6CB0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Continue to Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              return const Text(
                'HOME AIDE Services',
                style: TextStyle(
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Complete Your Provider Profile',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tell us about your services to help clients find you',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF718096),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Bio Section
              _buildSectionHeader('Professional Bio'),
              const SizedBox(height: 12),
              _buildTextFormField(
                controller: _bioController,
                label: 'Describe your experience and services',
                hint: 'e.g., "I have 5 years of experience in home cleaning and maintenance..."',
                maxLines: 4,
                validator: null, // Optional field
              ),
              if (_bioController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${_bioController.text.length}/500 characters',
                    style: TextStyle(
                      fontSize: 12,
                      color: _bioController.text.length > 500 ? Colors.red : Colors.grey[600],
                    ),
                  ),
                ),
              const SizedBox(height: 32),

              // Service Categories
              _buildSectionHeader('Service Categories *'),
              const SizedBox(height: 12),
              _buildCategoriesSection(),
              const SizedBox(height: 32),

              // Service Areas
              _buildSectionHeader('Service Areas *'),
              const SizedBox(height: 12),
              _buildAreasSection(),
              const SizedBox(height: 32),

              // Experience Level
              _buildSectionHeader('Experience Level *'),
              const SizedBox(height: 12),
              _buildExperienceSection(),
              const SizedBox(height: 32),

              // Service Radius
              _buildSectionHeader('Service Radius (km)'),
              const SizedBox(height: 12),
              _buildTextFormField(
                controller: _serviceRadiusController,
                label: 'How far are you willing to travel?',
                hint: '25',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter service radius';
                  }
                  final radius = int.tryParse(value);
                  if (radius == null || radius < 1 || radius > 100) {
                    return 'Please enter a valid radius (1-100 km)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Certifications Section
              _buildCertificationsSection(),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleCompleteRegistration,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Complete Registration',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2D3748),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
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

  Widget _buildCategoriesSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableCategories.map((category) {
        final isSelected = _selectedCategories.contains(category);
        return FilterChip(
          label: Text(
            category.replaceAll('_', ' ').toUpperCase(),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (mounted) {
              setState(() {
                if (selected) {
                  _selectedCategories.add(category);
                } else {
                  _selectedCategories.remove(category);
                }
              });
            }
          },
          selectedColor: Theme.of(context).primaryColor,
          backgroundColor: Colors.grey[100],
          side: BorderSide(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAreasSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableAreas.map((area) {
        final isSelected = _selectedAreas.contains(area);
        return FilterChip(
          label: Text(
            area.replaceAll('_', ' '),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (mounted) {
              setState(() {
                if (selected) {
                  _selectedAreas.add(area);
                } else {
                  _selectedAreas.remove(area);
                }
              });
            }
          },
          selectedColor: Theme.of(context).primaryColor,
          backgroundColor: Colors.grey[100],
          side: BorderSide(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExperienceSection() {
    return Column(
      children: _experienceLevels.map((level) {
        return RadioListTile<String>(
          title: Text(
            level.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          value: level,
          groupValue: _selectedExperience,
          onChanged: (value) {
            if (mounted) {
              setState(() {
                _selectedExperience = value;
              });
            }
          },
          activeColor: Theme.of(context).primaryColor,
        );
      }).toList(),
    );
  }

  Widget _buildCertificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Certifications (Optional)'),
        const SizedBox(height: 8),
        const Text(
          'Add any certifications that validate your expertise',
          style: TextStyle(fontSize: 14, color: Color(0xFF718096)),
        ),
        const SizedBox(height: 12),
        
        // Certification input field
        Row(
          children: [
            Expanded(
              child: _buildTextFormField(
                controller: _certificationController,
                label: 'Certification name',
                hint: 'e.g., Electrical Safety Certificate',
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => _addCertification(_certificationController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Display added certifications
        if (_certifications.isNotEmpty)
          Column(
            children: _certifications.map((cert) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        cert,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => _removeCertification(cert),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  void _addCertification(String certification) {
    if (certification.trim().isNotEmpty) {
      if (mounted) {
        setState(() {
          _certifications.add(certification.trim());
          _certificationController.clear();
        });
      }
    }
  }

  void _removeCertification(String certification) {
    if (mounted) {
      setState(() {
        _certifications.remove(certification);
      });
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _certificationController.dispose();
    _serviceRadiusController.dispose();
    super.dispose();
  }
}