import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/models/user_model.dart';
import 'provider_main_screen.dart';

class ProviderSetupScreen extends StatefulWidget {
  const ProviderSetupScreen({super.key});

  @override
  State<ProviderSetupScreen> createState() => _ProviderSetupScreenState();
}

class _ProviderSetupScreenState extends State<ProviderSetupScreen> {
  bool _isLoading = false;

  // Service creation data
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  // Removed pricing fields - now system-controlled uniform pricing

  String? _selectedCategory;
  String? _selectedLocation;
  bool _isAvailable = true;
  List<String> _availableCategories = [];
  final List<String> _images = [];
  final List<String> _tags = [];
  final _tagController = TextEditingController();

  // Cameroon provinces as per the backend enum
  final List<String> _cameroonProvinces = [
    'Centre',
    'Littoral', 
    'West',
    'Northwest',
    'Southwest',
    'South',
    'East',
    'North',
    'Adamawa',
    'Far North',
  ];

  @override
  void initState() {
    super.initState();
    _loadServiceCategories();
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
                'Create Service',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 32),

              // Service Title
              _buildTextFormField(
                controller: _titleController,
                label: 'Service Title',
                hint: 'e.g., Professional House Cleaning',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a service title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Service Description
              _buildTextFormField(
                controller: _descriptionController,
                label: 'Service Description',
                hint: 'Complete house cleaning including all rooms, kitchen, and bathrooms. Professional equipment provided.',
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe your service';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Service Category Dropdown
              _buildDropdownField(
                label: 'Service Category',
                value: _selectedCategory,
                items: _availableCategories,
                onChanged: (value) => setState(() => _selectedCategory = value),
              ),
              const SizedBox(height: 16),

              // Pricing info display (system-controlled)
              _buildPricingInfoCard(),
              const SizedBox(height: 16),

              // Location - Use province dropdown
              _buildLocationDropdown(),
              const SizedBox(height: 16),

              // Session duration info (system-controlled)
              _buildSessionInfoCard(),
              const SizedBox(height: 16),

              // Tags Section
              _buildTagsSection(),
              const SizedBox(height: 16),

              // Service Availability Toggle
              _buildAvailabilityToggle(),
              const SizedBox(height: 16),

              // Images Section (placeholder for now)
              _buildImagesSection(),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods for UI components
  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          labelStyle: TextStyle(color: Colors.grey[600]),
        ),
        items:
            items
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(_formatCategoryName(item)),
                  ),
                )
                .toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select an option';
          }
          return null;
        },
      ),
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

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Tags',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add tags to help customers find your service',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        
        // Tag input field
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextFormField(
                  controller: _tagController,
                  decoration: InputDecoration(
                    hintText: 'Enter a tag (e.g., eco-friendly)',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    hintStyle: TextStyle(color: Colors.grey[400]),
                  ),
                  onFieldSubmitted: _addTag,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _addTag(_tagController.text),
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
        
        // Display tags
        if (_tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) => _buildTagChip(tag)).toList(),
          ),
      ],
    );
  }

  Widget _buildTagChip(String tag) {
    return Chip(
      label: Text(tag),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: () => _removeTag(tag),
      backgroundColor: Colors.blue[50],
      deleteIconColor: Colors.blue[700],
      labelStyle: TextStyle(color: Colors.blue[700]),
    );
  }

  Widget _buildLocationDropdown() {
    return _buildDropdownField(
      label: 'Service Location (Province)',
      value: _selectedLocation,
      items: _cameroonProvinces,
      onChanged: (value) => setState(() => _selectedLocation = value),
    );
  }

  Widget _buildPricingInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Uniform Pricing System',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'All services use the same pricing structure:',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Base (4 hours)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '3,000 FCFA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Overtime',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFF59E0B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '375 FCFA per 30 minutes',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.schedule,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Session Duration',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'All sessions work with flexible duration:',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: Color(0xFF10B981)),
              SizedBox(width: 8),
              Text(
                'Minimum: 0.5 hours (30 minutes)',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: Color(0xFF10B981)),
              SizedBox(width: 8),
              Text(
                'Customers can book any duration they need',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityToggle() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: SwitchListTile(
        title: const Text('Service Available'),
        subtitle: Text(
          _isAvailable ? 'Your service is available for booking' : 'Your service is currently unavailable',
          style: TextStyle(color: Colors.grey[600]),
        ),
        value: _isAvailable,
        onChanged: (value) {
          setState(() {
            _isAvailable = value;
          });
        },
      ),
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Images',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add images to showcase your service (optional)',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
            color: Colors.grey[50],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'Tap to add images',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                'Coming soon',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim().toLowerCase();
    if (trimmedTag.isNotEmpty && !_tags.contains(trimmedTag)) {
      setState(() {
        _tags.add(trimmedTag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
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
                    'Create Service',
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
    // Validate service form and create service
    if (_formKey.currentState!.validate()) {
      await _completeSetup();
    }
  }

  Future<void> _completeSetup() async {
    // Validate that we have all required data
    if (_selectedCategory == null || _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both category and location'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Ensure user has provider role before creating service
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

      debugPrint('Provider Setup: Creating service...');
      await _createService();
      debugPrint('Provider Setup: Service created successfully');

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to provider main screen after successful setup
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          // Navigate to provider main screen and clear the navigation stack
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const ProviderMainScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      debugPrint('Provider Setup: Service creation failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create service: ${e.toString()}'),
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

  Future<void> _createService() async {
    final apiService = ApiService();

    // Create service data for session-based system (no pricing fields)
    final serviceData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'category': _selectedCategory!.toLowerCase(),
      'images': _images.isNotEmpty ? _images : <String>[], // Ensure proper list type
      'location': _selectedLocation!, // Use selected province
      'tags': _tags.isNotEmpty ? _tags : <String>[], // Ensure proper list type
      'isAvailable': _isAvailable,
      // Removed pricing and duration fields - now handled by session system
    };

    // Debug: Print each field type
    debugPrint('Service Data Types:');
    serviceData.forEach((key, value) {
      debugPrint('  $key: ${value.runtimeType} = $value');
    });

    debugPrint('API: Creating service with data: $serviceData');
    final response = await apiService.createService(serviceData);

    debugPrint(
      'API: Service creation response - Success: ${response.isSuccess}, Error: ${response.error}',
    );

    if (!response.isSuccess) {
      debugPrint('API: Service creation failed: ${response.error}');
      throw Exception(response.error ?? 'Failed to create service');
    } else {
      debugPrint('API: Service created successfully');
    }
  }

  String _formatCategoryName(String category) {
    return category.substring(0, 1).toUpperCase() + category.substring(1);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }
}
