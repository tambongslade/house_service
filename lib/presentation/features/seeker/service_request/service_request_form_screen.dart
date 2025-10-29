import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/core_exports.dart';
import '../../../../l10n/app_localizations.dart';
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.requestService(widget.categoryDisplayName)),
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
              _buildSectionHeader(l10n.serviceDetails),
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

              _buildSectionHeader(l10n.location),
              const SizedBox(height: 16),
              
              // Province selection
              _buildProvinceField(),
              const SizedBox(height: 16),
              
              // Location selection
              _buildLocationField(),
              const SizedBox(height: 24),

              _buildSectionHeader(l10n.additionalInformation),
              const SizedBox(height: 16),
              
              // Description
              _buildDescriptionField(),
              const SizedBox(height: 16),
              
              // Special Instructions
              _buildSpecialInstructionsField(),
              const SizedBox(height: 24),

              _buildSectionHeader(l10n.couponCodeOptional),
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
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.serviceDate,
          hintText: l10n.selectDateForService,
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        child: Text(
          _selectedDate != null
              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
              : l10n.selectDate,
          style: TextStyle(
            color: _selectedDate != null ? Colors.black87 : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeField() {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: () => _selectTime(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.startTime,
          hintText: l10n.selectStartTime,
          prefixIcon: const Icon(Icons.access_time),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        child: Text(
          _selectedTime != null
              ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
              : l10n.selectTime,
          style: TextStyle(
            color: _selectedTime != null ? Colors.black87 : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildDurationField() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.timer, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              l10n.durationLabel(_duration.toStringAsFixed(1)),
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
          l10n.minimumMaximumHours,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildProvinceField() {
    final l10n = AppLocalizations.of(context)!;
    return DropdownButtonFormField<String>(
      initialValue: _selectedProvince,
      decoration: InputDecoration(
        labelText: l10n.province,
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
          return l10n.pleaseSelectProvince;
        }
        return null;
      },
    );
  }

  Widget _buildLocationField() {
    final l10n = AppLocalizations.of(context)!;
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
                l10n.serviceLocation,
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
                          l10n.locationSelected,
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
                  label: Text(_isLoadingLocation ? l10n.gettingLocation : l10n.useCurrentLocation),
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
                  label: Text(l10n.selectOnMap),
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
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: l10n.serviceDescription,
        hintText: l10n.brieflyDescribe,
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
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: _specialInstructionsController,
      decoration: InputDecoration(
        labelText: l10n.specialInstructions,
        hintText: l10n.anySpecialRequirements,
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

  Widget _buildCouponField() {
    final l10n = AppLocalizations.of(context)!;
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
                l10n.enterCouponCode,
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
                    hintText: l10n.enterCouponOptional,
                    prefixIcon: const Icon(Icons.confirmation_number),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (value) {
                    // Clear applied coupon if user changes the code
                    if (_couponInfo.isApplied && value != _couponInfo.couponCode) {
                      setState(() {
                        _couponInfo = CouponInfo.empty();
                      });
                    }
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
                    : Text(l10n.validate),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            l10n.enterCouponDiscount,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostEstimate() {
    final l10n = AppLocalizations.of(context)!;
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
                l10n.estimatedCost,
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
                  l10n.originalAmount,
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
                  l10n.discount(_couponInfo.couponCode ?? ''),
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
                _couponInfo.isApplied ? l10n.finalAmount : l10n.total,
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
            l10n.forHoursOfService(_duration.toStringAsFixed(1)),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.blue.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${l10n.basePriceInfo(basePrice)}\n${_duration > 4.0 ? l10n.overtimeInfo(((_duration - 4.0) * 2 * 375).round(), (_duration - 4.0).toStringAsFixed(1)) : l10n.noOvertimeCharges}',
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
                    l10n.couponAppliedSuccess(_couponInfo.couponCode ?? ''),
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
    final l10n = AppLocalizations.of(context)!;
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
                    l10n.submitRequest,
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
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw l10n.locationPermissionsDenied;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw l10n.locationPermissionsPermanentlyDenied;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition();

      // Try to get a human-readable address
      String address = l10n.currentLocationLabel(position.latitude.toStringAsFixed(6), position.longitude.toStringAsFixed(6));

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
            address = l10n.currentLocationWithAddress(addressParts.join(', '));
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
          SnackBar(
            content: Text(l10n.currentLocationCaptured),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToGetLocation(e.toString())),
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
    final l10n = AppLocalizations.of(context)!;
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
          SnackBar(
            content: Text(l10n.locationSelectedSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _validateCoupon() async {
    final l10n = AppLocalizations.of(context)!;
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
                content: Text(l10n.couponSaveAmount(validationResult.discountAmount.round())),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            setState(() {
              _couponInfo = CouponInfo.empty();
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(validationResult.errorMessage ?? l10n.invalidCouponCode),
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
              content: Text(response.error ?? l10n.failedToValidateCoupon),
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
            content: Text(l10n.errorValidatingCoupon(e.toString())),
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
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate() || !_canSubmit()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final requestData = CreateServiceRequestModel(
        category: widget.category,
        serviceDate: '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
        startTime: '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
        duration: _duration,
        location: _selectedLocation!,
        province: _selectedProvince,
        specialInstructions: _specialInstructionsController.text.trim().isNotEmpty
            ? _specialInstructionsController.text.trim()
            : null,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        couponCode: _couponInfo.isApplied ? _couponInfo.couponCode : null,
      );

      final response = await _apiService.createServiceRequest(requestData.toJson());

      if (response.isSuccess) {
        final responseData = ServiceRequestResponse.fromJson(response.data!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData.message),
              backgroundColor: Colors.green,
            ),
          );

          // Show success dialog with details
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text(l10n.requestSubmittedSuccessfully),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.requestId(responseData.requestId)),
                  const SizedBox(height: 8),
                  Text(l10n.estimatedCostAmount(responseData.estimatedCost.round())),
                  const SizedBox(height: 8),
                  Text(l10n.adminWillAssignProvider),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to previous screen
                  },
                  child: Text(l10n.ok),
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error ?? l10n.failedToSubmitRequest),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorSubmitting(e.toString())),
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