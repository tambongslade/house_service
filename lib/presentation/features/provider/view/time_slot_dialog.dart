import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/models/api_response.dart';

class TimeSlotDialog extends StatefulWidget {
  final String day;
  final Map<String, dynamic>? existingSlot;
  final List<Map<String, dynamic>> existingTimeSlots;
  final String? dayId;
  final VoidCallback onTimeSlotAdded;
  final ApiService apiService;
  final TimeOfDay? presetStartTime;
  final TimeOfDay? presetEndTime;

  const TimeSlotDialog({
    super.key,
    required this.day,
    this.existingSlot,
    this.existingTimeSlots = const [],
    this.dayId,
    required this.onTimeSlotAdded,
    required this.apiService,
    this.presetStartTime,
    this.presetEndTime,
  });

  @override
  State<TimeSlotDialog> createState() => _TimeSlotDialogState();
}

class _TimeSlotDialogState extends State<TimeSlotDialog> {
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  bool _isAvailable = true;
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  final Map<String, String> _dayNames = {
    'monday': 'Monday',
    'tuesday': 'Tuesday',
    'wednesday': 'Wednesday',
    'thursday': 'Thursday',
    'friday': 'Friday',
    'saturday': 'Saturday',
    'sunday': 'Sunday',
  };

  @override
  void initState() {
    super.initState();
    if (widget.existingSlot != null) {
      _initializeFromExistingSlot();
    } else if (widget.presetStartTime != null && widget.presetEndTime != null) {
      _startTime = widget.presetStartTime!;
      _endTime = widget.presetEndTime!;
    }
  }

  void _initializeFromExistingSlot() {
    final slot = widget.existingSlot!;

    // Parse start time
    final startTimeStr = slot['startTime'] ?? '09:00';
    final startParts = startTimeStr.split(':');
    if (startParts.length == 2) {
      _startTime = TimeOfDay(
        hour: int.tryParse(startParts[0]) ?? 9,
        minute: int.tryParse(startParts[1]) ?? 0,
      );
    }

    // Parse end time
    final endTimeStr = slot['endTime'] ?? '17:00';
    final endParts = endTimeStr.split(':');
    if (endParts.length == 2) {
      _endTime = TimeOfDay(
        hour: int.tryParse(endParts[0]) ?? 17,
        minute: int.tryParse(endParts[1]) ?? 0,
      );
    }

    _isAvailable = slot['isAvailable'] ?? true;
    _notesController.text = slot['notes'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingSlot != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.access_time,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditing ? 'Edit Time Slot' : 'Add Time Slot',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _dayNames[widget.day] ?? widget.day,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Time Selection
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Time Range',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeSelector(
                          'Start Time',
                          _startTime,
                          (time) => setState(() => _startTime = time),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTimeSelector(
                          'End Time',
                          _endTime,
                          (time) => setState(() => _endTime = time),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Availability Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isAvailable ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isAvailable ? Colors.green[200]! : Colors.red[200]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isAvailable ? Icons.check_circle : Icons.cancel,
                    color: _isAvailable ? Colors.green[600] : Colors.red[600],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Availability Status',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                _isAvailable
                                    ? Colors.green[800]
                                    : Colors.red[800],
                          ),
                        ),
                        Text(
                          _isAvailable
                              ? 'Available for bookings'
                              : 'Not available',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                _isAvailable
                                    ? Colors.green[600]
                                    : Colors.red[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isAvailable,
                    onChanged: (value) => setState(() => _isAvailable = value),
                    activeColor: Colors.green[600],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notes (Optional)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      hintText: 'e.g., Available for emergency calls',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveTimeSlot,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Text(isEditing ? 'Update' : 'Add'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector(
    String label,
    TimeOfDay time,
    Function(TimeOfDay) onChanged,
  ) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time.format(context),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTimeSlot() async {
    // Validate time range
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;

    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newTimeSlot = {
        'startTime':
            '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
        'endTime':
            '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
        'isAvailable': _isAvailable,
      };

      // Get existing time slots and add/update the new one
      List<Map<String, dynamic>> updatedTimeSlots = List.from(
        widget.existingTimeSlots,
      );

      // If editing existing slot, remove the old one first
      if (widget.existingSlot != null) {
        updatedTimeSlots.removeWhere(
          (slot) =>
              slot['startTime'] == widget.existingSlot!['startTime'] &&
              slot['endTime'] == widget.existingSlot!['endTime'],
        );
      }

      // Add the new/updated time slot
      updatedTimeSlots.add(newTimeSlot);

      // Sort time slots by start time
      updatedTimeSlots.sort(
        (a, b) => _compareTimeStrings(a['startTime'], b['startTime']),
      );

      final notes =
          _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null;

      // Determine if we need to create or update availability
      late final ApiResponse<Map<String, dynamic>> response;

      if (widget.dayId != null &&
          RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(widget.dayId!)) {
        // Case 1: Existing availability with valid ObjectId - UPDATE by ID
        print(
          'TimeSlotDialog: Updating existing availability by ID: ${widget.dayId}',
        );
        response = await widget.apiService.updateDayAvailability(
          widget.dayId!,
          widget.day.toLowerCase(),
          updatedTimeSlots,
          notes: notes,
          isActive: true,
        );
      } else if (widget.existingTimeSlots.isEmpty &&
          widget.existingSlot == null) {
        // Case 2: Empty day - CREATE new availability
        print(
          'TimeSlotDialog: Creating new availability for empty day: ${widget.day}',
        );
        response = await widget.apiService.createAvailability({
          'dayOfWeek': widget.day.toLowerCase(),
          'timeSlots': updatedTimeSlots,
          if (notes != null) 'notes': notes,
        });
      } else {
        // Case 3: Existing availability but no valid ObjectId - UPDATE by day name
        print(
          'TimeSlotDialog: Updating availability by day name: ${widget.day}',
        );
        response = await widget.apiService.updateAvailabilityByDay(
          widget.day.toLowerCase(),
          updatedTimeSlots,
          notes: notes,
          isActive: true,
        );
      }

      if (response.isSuccess) {
        if (mounted) {
          Navigator.of(context).pop();
          widget.onTimeSlotAdded();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.existingSlot != null
                    ? 'Time slot updated successfully'
                    : 'Time slot added successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save time slot: ${response.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving time slot: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  int _compareTimeStrings(String time1, String time2) {
    final parts1 = time1.split(':');
    final parts2 = time2.split(':');
    final minutes1 = int.parse(parts1[0]) * 60 + int.parse(parts1[1]);
    final minutes2 = int.parse(parts2[0]) * 60 + int.parse(parts2[1]);
    return minutes1.compareTo(minutes2);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
