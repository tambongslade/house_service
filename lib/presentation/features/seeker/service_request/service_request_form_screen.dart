import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/core_exports.dart';
import '../map/seeker_map_screen.dart';

class ServiceRequestFormScreen extends StatefulWidget {
  final String category;
  final String categoryDisplayName;

  const ServiceRequestFormScreen({
    super.key,
    required this.category,
    required this.categoryDisplayName,
  });

  @override
  State<ServiceRequestFormScreen> createState() => _ServiceRequestFormScreenState();
}

class _ServiceRequestFormScreenState extends State<ServiceRequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  // Form fields
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  double _duration = 4.0;
  String _selectedProvince = 'Littoral';
  ServiceRequestLocation? _selectedLocation;
  final _specialInstructionsController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _couponController = TextEditingController();

  // Payment details fields
  final _phoneController = TextEditingController();
  final _payerNameController = TextEditingController();
  final _payerEmailController = TextEditingController();
  String _paymentMedium = 'mobile money';

  bool _isSubmitting = false;
  bool _isLoadingLocation = false;
  bool _isValidatingCoupon = false;
  CouponInfo _couponInfo = CouponInfo.empty();

  final List<String> _cameroonProvinces = [
    'Adamawa',
    'Centre',
    'East',
    'Far North',
    'Littoral',
    'North',
    'Northwest',
    'South',
    'Southwest',
    'West',
  ];

  @override
  void dispose() {
    _specialInstructionsController.dispose();
    _descriptionController.dispose();
    _couponController.dispose();
    _phoneController.dispose();
    _payerNameController.dispose();
    _payerEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Request ${widget.categoryDisplayName}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Service Details'),
              const SizedBox(height: 16),
              
              // Service Date
              _buildDateField(),
              const SizedBox(height: 16),
              
              // Service Time
              _buildTimeField(),
              const SizedBox(height: 16),
              
              // Duration
              _buildDurationField(),
              const SizedBox(height: 24),
              
              _buildSectionHeader('Location'),
              const SizedBox(height: 16),
              
              // Province selection
              _buildProvinceField(),
              const SizedBox(height: 16),
              
              // Location selection
              _buildLocationField(),
              const SizedBox(height: 24),
              
              _buildSectionHeader('Additional Information'),
              const SizedBox(height: 16),
              
              // Description
              _buildDescriptionField(),
              const SizedBox(height: 16),
              
              // Special Instructions
              _buildSpecialInstructionsField(),
              const SizedBox(height: 24),
              
              _buildSectionHeader('Payment Details'),
              const SizedBox(height: 16),

              // Phone number
              _buildPhoneField(),
              const SizedBox(height: 16),

              // Payment medium
              _buildPaymentMediumField(),
              const SizedBox(height: 16),

              // Payer name (optional)
              _buildPayerNameField(),
              const SizedBox(height: 16),

              // Payer email (optional)
              _buildPayerEmailField(),
              const SizedBox(height: 24),

              _buildSectionHeader('Coupon Code (Optional)'),
              const SizedBox(height: 16),

              // Coupon Code
              _buildCouponField(),
              const SizedBox(height: 32),

              // Cost estimate
              _buildCostEstimate(),
              const SizedBox(height: 24),

              // Submit button
              _buildSubmitButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.blue.shade800,
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Service Date *',
          hintText: 'Select date for service',
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        child: Text(
          _selectedDate != null
              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
              : 'Select date',
          style: TextStyle(
            color: _selectedDate != null ? Colors.black87 : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeField() {
    return InkWell(
      onTap: () => _selectTime(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Start Time *',
          hintText: 'Select start time',
          prefixIcon: const Icon(Icons.access_time),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        child: Text(
          _selectedTime != null
              ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
              : 'Select time',
          style: TextStyle(
            color: _selectedTime != null ? Colors.black87 : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildDurationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.timer, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              'Duration: ${_duration.toStringAsFixed(1)} hours',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: _duration,
          min: 0.5,
          max: 12.0,
          divisions: 23,
          label: '${_duration.toStringAsFixed(1)}h',
          onChanged: (value) {
            setState(() {
              _duration = value;
            });
          },
        ),
        Text(
          'Minimum 0.5 hours, maximum 12 hours',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildProvinceField() {
    return DropdownButtonFormField<String>(
      value: _selectedProvince,
      decoration: InputDecoration(
        labelText: 'Province *',
        prefixIcon: const Icon(Icons.location_on),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      items: _cameroonProvinces.map((province) {
        return DropdownMenuItem<String>(
          value: province,
          child: Text(province),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedProvince = value ?? 'Littoral';
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a province';
        }
        return null;
      },
    );
  }

  Widget _buildLocationField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Service Location *',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_selectedLocation != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location selected',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.green.shade700,
                          ),
                        ),
                        if (_selectedLocation!.address != null)
                          Text(
                            _selectedLocation!.address!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade600,
                            ),
                          ),
                        Text(
                          '${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                  icon: _isLoadingLocation
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location),
                  label: Text(_isLoadingLocation ? 'Getting location...' : 'Use current location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectLocationOnMap,
                  icon: const Icon(Icons.map),
                  label: const Text('Select on map'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue.shade600,
                    side: BorderSide(color: Colors.blue.shade600),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Service Description',
        hintText: 'Briefly describe what needs to be done',
        prefixIcon: const Icon(Icons.description),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      maxLines: 3,
      maxLength: 200,
    );
  }

  Widget _buildSpecialInstructionsField() {
    return TextFormField(
      controller: _specialInstructionsController,
      decoration: InputDecoration(
        labelText: 'Special Instructions',
        hintText: 'Any special requirements or notes',
        prefixIcon: const Icon(Icons.note_add),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      maxLines: 2,
      maxLength: 150,
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      decoration: InputDecoration(
        labelText: 'Phone Number *',
        hintText: '237670000000',
        prefixIcon: const Icon(Icons.phone),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        helperText: 'Format: 237XXXXXXXXX (Cameroon)',
      ),
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Phone number is required';
        }
        if (!RegExp(r'^237\d{9}$').hasMatch(value.trim())) {
          return 'Invalid format. Use 237XXXXXXXXX';
        }
        return null;
      },
    );
  }

  Widget _buildPaymentMediumField() {
    return DropdownButtonFormField<String>(
      value: _paymentMedium,
      decoration: InputDecoration(
        labelText: 'Payment Method *',
        prefixIcon: const Icon(Icons.payment),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: const [
        DropdownMenuItem(
          value: 'mobile money',
          child: Text('Mobile Money (MTN/Orange)'),
        ),
        DropdownMenuItem(
          value: 'orange money',
          child: Text('Orange Money'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _paymentMedium = value!;
        });
      },
    );
  }

  Widget _buildPayerNameField() {
    return TextFormField(
      controller: _payerNameController,
      decoration: InputDecoration(
        labelText: 'Payer Name (Optional)',
        hintText: 'Enter payer name',
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        helperText: 'Name for payment receipt',
      ),
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _buildPayerEmailField() {
    return TextFormField(
      controller: _payerEmailController,
      decoration: InputDecoration(
        labelText: 'Payer Email (Optional)',
        hintText: 'Enter email for receipt',
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        helperText: 'Email for payment receipt',
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value != null && value.trim().isNotEmpty) {
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
            return 'Invalid email format';
          }
        }
        return null;
      },
    );
  }

  Widget _buildCouponField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_offer, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'Enter Coupon Code',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Coupon input and validate button
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _couponController,
                  decoration: InputDecoration(
                    hintText: 'Enter coupon code (optional)',
                    prefixIcon: const Icon(Icons.confirmation_number),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (value) {
                    // Clear applied coupon if user changes the code
                    setState(() {
                      if (_couponInfo.isApplied && value != _couponInfo.couponCode) {
                        _couponInfo = CouponInfo.empty();
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _couponController.text.trim().isNotEmpty && !_isValidatingCoupon 
                    ? _validateCoupon : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: _isValidatingCoupon
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Validate'),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          Text(
            'Enter a coupon code to get a discount on your service',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostEstimate() {
    const basePrice = 3000;
    final originalPrice = _duration <= 4.0 ? basePrice : basePrice + ((_duration - 4.0) * 2 * 375).round();
    final discount = _couponInfo.isApplied ? (_couponInfo.discountAmount ?? 0.0) : 0.0;
    final finalPrice = _couponInfo.isApplied ? (_couponInfo.finalAmount ?? originalPrice.toDouble()) : originalPrice.toDouble();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.monetization_on, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Estimated Cost',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Original price
          if (_couponInfo.isApplied) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Original Amount:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  '${originalPrice.round()} FCFA',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Discount (${_couponInfo.couponCode}):',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '-${discount.round()} FCFA',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
          ],
          
          // Final price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _couponInfo.isApplied ? 'Final Amount:' : 'Total:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              Text(
                '${finalPrice.round()} FCFA',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _couponInfo.isApplied ? Colors.green.shade700 : Colors.blue.shade800,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          Text(
            'For ${_duration.toStringAsFixed(1)} hours of service',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.blue.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Base price: $basePrice FCFA (4 hours)\n${_duration > 4.0 ? 'Overtime: ${((_duration - 4.0) * 2 * 375).round()} FCFA (${(_duration - 4.0).toStringAsFixed(1)} extra hours)' : 'No overtime charges'}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.blue.shade600,
            ),
          ),
          
          if (_couponInfo.isApplied) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade700, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Coupon "${_couponInfo.couponCode}" applied successfully!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _canSubmit() && !_isSubmitting ? _submitRequest : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade800,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send),
                  const SizedBox(width: 12),
                  Text(
                    'Submit Request',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  bool _canSubmit() {
    return _selectedDate != null &&
        _selectedTime != null &&
        _selectedLocation != null &&
        !_isSubmitting;
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = now;
    final lastDate = now.add(const Duration(days: 90));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied, we cannot request permissions.';
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition();
      
      // Try to get a human-readable address
      String address = 'Current Location (${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)})';
      
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
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
            address = 'Current Location: ${addressParts.join(', ')}';
          }
        }
      } catch (e) {
        debugPrint('Error getting address for current location: $e');
        // Keep the coordinate address as fallback
      }
      
      setState(() {
        _selectedLocation = ServiceRequestLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          address: address,
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Current location captured successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get current location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _selectLocationOnMap() async {
    final result = await Navigator.push<ServiceRequestLocation>(
      context,
      MaterialPageRoute(
        builder: (context) => SeekerMapScreen(
          isForLocationSelection: true,
          initialLocation: _selectedLocation != null
              ? LatLng(_selectedLocation!.latitude, _selectedLocation!.longitude)
              : null,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location selected successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _validateCoupon() async {
    final couponCode = _couponController.text.trim().toUpperCase();
    if (couponCode.isEmpty) return;

    setState(() {
      _isValidatingCoupon = true;
    });

    try {
      const basePrice = 3000;
      final originalAmount = _duration <= 4.0 ? basePrice : basePrice + ((_duration - 4.0) * 2 * 375).round();
      
      final request = CouponValidationRequest(
        code: couponCode,
        orderAmount: originalAmount.toDouble(),
      );

      final response = await _apiService.validateCoupon(request);

      if (mounted) {
        if (response.isSuccess && response.data != null) {
          final validationResult = response.data!;
          
          if (validationResult.isValid) {
            setState(() {
              _couponInfo = CouponInfo.applied(
                couponCode: validationResult.couponCode,
                discountAmount: validationResult.discountAmount,
                finalAmount: validationResult.finalAmount,
              );
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Coupon applied! You save ${validationResult.discountAmount.round()} FCFA'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            setState(() {
              _couponInfo = CouponInfo.empty();
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(validationResult.errorMessage ?? 'Invalid coupon code'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          setState(() {
            _couponInfo = CouponInfo.empty();
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error ?? 'Failed to validate coupon'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _couponInfo = CouponInfo.empty();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error validating coupon: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isValidatingCoupon = false;
        });
      }
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate() || !_canSubmit()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: Replace 'service_id_placeholder' with actual service ID
      // You need to pass the service ID from the previous screen or get it from the category

      // Create payment details
      final paymentDetails = PaymentDetails(
        phone: _phoneController.text.trim(),
        medium: _paymentMedium,
        name: _payerNameController.text.trim().isNotEmpty
            ? _payerNameController.text.trim()
            : null,
        email: _payerEmailController.text.trim().isNotEmpty
            ? _payerEmailController.text.trim()
            : null,
      );

      // Create booking request
      final bookingRequest = InitiateBookingRequest(
        serviceId: 'service_id_placeholder', // TODO: Get actual service ID
        sessionDate: '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
        startTime: '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
        duration: _duration,
        paymentDetails: paymentDetails,
        notes: _specialInstructionsController.text.trim().isNotEmpty
            ? _specialInstructionsController.text.trim()
            : null,
        couponCode: _couponInfo.isApplied ? _couponInfo.couponCode : null,
      );

      // Initiate booking
      final response = await _apiService.initiateBooking(bookingRequest);

      if (response.isSuccess && response.data != null) {
        final bookingResponse = response.data!;

        if (mounted) {
          // Show payment pending dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => _PaymentPendingDialog(
              bookingResponse: bookingResponse,
              apiService: _apiService,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error ?? 'Failed to initiate booking'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

// Payment Pending Dialog Widget
class _PaymentPendingDialog extends StatefulWidget {
  final InitiateBookingResponse bookingResponse;
  final ApiService apiService;

  const _PaymentPendingDialog({
    required this.bookingResponse,
    required this.apiService,
  });

  @override
  State<_PaymentPendingDialog> createState() => _PaymentPendingDialogState();
}

class _PaymentPendingDialogState extends State<_PaymentPendingDialog> {
  String _statusMessage = '';
  bool _isPolling = true;
  int _remainingSeconds = 180; // 3 minutes

  @override
  void initState() {
    super.initState();
    _statusMessage = widget.bookingResponse.message;
    _startPolling();
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _isPolling && _remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
        _startCountdown();
      }
    });
  }

  void _startPolling() async {
    await for (final status in widget.apiService.pollBookingStatus(widget.bookingResponse.bookingId)) {
      if (!mounted) break;

      setState(() {
        _statusMessage = status.message;
      });

      if (status.isCompleted) {
        setState(() {
          _isPolling = false;
        });
        _showSuccessAndClose(status);
        break;
      } else if (status.isFailed) {
        setState(() {
          _isPolling = false;
        });
        _showErrorAndClose('Payment failed. Please try again.');
        break;
      } else if (status.isExpired) {
        setState(() {
          _isPolling = false;
        });
        _showErrorAndClose('Payment expired. Please try again.');
        break;
      }
    }

    // Check if polling timed out
    if (mounted && _isPolling) {
      setState(() {
        _isPolling = false;
      });
      _showErrorAndClose('Payment timeout. Please check your payment status.');
    }
  }

  void _showSuccessAndClose(BookingStatusResponse status) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment successful! Your session has been created.'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop(); // Close payment dialog
    Navigator.of(context).pop(); // Go back to previous screen
  }

  void _showErrorAndClose(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );

    Navigator.of(context).pop(); // Close dialog
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          if (_isPolling)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          const SizedBox(width: 12),
          const Text('Payment Pending'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_statusMessage),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Amount to Pay:', style: TextStyle(fontWeight: FontWeight.w500)),
              Text(
                '${widget.bookingResponse.amount.toStringAsFixed(0)} FCFA',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          if (widget.bookingResponse.hasDiscount) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Original Amount:', style: TextStyle(decoration: TextDecoration.lineThrough)),
                Text('${widget.bookingResponse.originalAmount.toStringAsFixed(0)} FCFA'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Discount:', style: TextStyle(color: Colors.green)),
                Text(
                  '-${widget.bookingResponse.discountAmount.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Time Remaining:'),
              Text(
                _formatTime(_remainingSeconds),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _remainingSeconds < 60 ? Colors.red : Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (!_isPolling)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
      ],
    );
  }
}