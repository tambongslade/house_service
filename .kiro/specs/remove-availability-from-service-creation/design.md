# Design Document

## Overview

This design outlines the modifications needed to remove the availability setup step from the service creation flow in the ProviderSetupScreen. The current two-step process (service details + availability) will be simplified to a single-step process that focuses only on service creation.

## Architecture

The modification involves changes to the ProviderSetupScreen widget, specifically:

- Removing the PageView navigation between steps
- Eliminating the availability setup UI components
- Simplifying the completion flow to only handle service creation
- Updating the progress indicators and navigation logic

## Components and Interfaces

### Modified Components

#### ProviderSetupScreen
- **Current State**: Two-step flow with PageView navigation
- **New State**: Single-step flow with direct service creation
- **Key Changes**:
  - Remove `_currentStep` state management
  - Remove PageView and page controller
  - Remove availability-related UI components
  - Simplify button logic to directly create service

#### UI Components to Remove
- `_buildAvailabilityStep()` method
- Availability-related state variables:
  - `_availableDays` map
  - `_startTime` and `_endTime` TimeOfDay variables
- Time selector widgets
- Day checkbox widgets
- Progress dots for multi-step flow

#### UI Components to Modify
- `_buildBottomButton()`: Remove step-based logic, always show "Create Service"
- AppBar: Remove progress dots, simplify title
- `_handleNextStep()`: Remove step navigation, directly call service creation

### Service Creation Flow

#### Current Flow
1. User fills service details → Next button
2. User sets availability → Complete Setup button
3. Create service API call
4. Create availability API calls for each selected day
5. Navigate back with success

#### New Flow
1. User fills service details → Create Service button
2. Create service API call only
3. Navigate back with success

## Data Models

### Service Creation Payload
The service creation payload remains unchanged, but the `isAvailable` field will be set to `true` by default:

```dart
final serviceData = {
  'title': _titleController.text.trim(),
  'description': _descriptionController.text.trim(),
  'category': _selectedCategory!.toLowerCase(),
  'pricePerHour': int.parse(_priceController.text),
  'images': _images,
  'location': _locationController.text.trim(),
  'tags': _tags,
  'isAvailable': true, // Always true for new services
  'minimumBookingHours': int.parse(_minHoursController.text),
  'maximumBookingHours': int.parse(_maxHoursController.text),
};
```

### Removed Data Models
- Availability creation payload (no longer needed)
- Time slot data structures
- Day selection data structures

## Error Handling

### Simplified Error Handling
- Remove availability-specific error handling
- Focus only on service creation errors
- Maintain existing form validation for service details

### Error Scenarios
1. **Service Creation Failure**: Show error message and allow retry
2. **Form Validation Failure**: Highlight invalid fields and prevent submission
3. **Network Errors**: Show network error message with retry option

## Testing Strategy

### Unit Tests
- Test service creation without availability setup
- Test form validation for service details
- Test default service availability state
- Test navigation after successful creation

### Integration Tests
- Test complete service creation flow
- Test API integration for service creation only
- Test error handling scenarios

### UI Tests
- Test single-step UI flow
- Test button states and loading indicators
- Test form input validation
- Test success/error message display

## Implementation Notes

### State Management Changes
- Remove `_currentStep` variable and related logic
- Remove PageController and page navigation
- Simplify button state management

### API Integration Changes
- Remove `_createAvailability()` method calls
- Keep only `_createService()` method call
- Simplify completion flow in `_completeSetup()`

### Default Behavior
- New services will be created with `isAvailable: true`
- Providers can configure specific availability through the dedicated availability page
- No default time slots will be created during service creation

## Migration Considerations

### Backward Compatibility
- Existing services with availability data remain unchanged
- New services without availability data will work with existing booking system
- Availability management page continues to function independently

### User Experience
- Faster service creation process
- Clear separation between service creation and availability management
- Consistent with having a dedicated availability page