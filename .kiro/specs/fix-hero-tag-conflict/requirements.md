# Requirements Document

## Introduction

This feature addresses a Flutter hero tag conflict that occurs when navigating between the "add service" and "my services" pages in the provider section of the house service app. The error occurs because multiple FloatingActionButton widgets share the same default hero tag, causing Flutter to throw an exception about duplicate hero tags.

## Requirements

### Requirement 1

**User Story:** As a provider, I want to navigate seamlessly between the services page and availability page without encountering hero tag conflicts, so that I can manage my services and schedule without interruption.

#### Acceptance Criteria

1. WHEN a provider navigates from the services page to the availability page THEN the navigation SHALL complete without throwing hero tag exceptions
2. WHEN a provider navigates from the availability page to the services page THEN the navigation SHALL complete without throwing hero tag exceptions
3. WHEN multiple FloatingActionButton widgets are present in the navigation stack THEN each SHALL have a unique heroTag to prevent conflicts
4. WHEN the app displays FloatingActionButton widgets THEN they SHALL maintain their visual appearance and functionality

### Requirement 2

**User Story:** As a provider, I want all FloatingActionButton interactions to work correctly after the hero tag fix, so that I can continue to add services and manage my availability without any functional regression.

#### Acceptance Criteria

1. WHEN a provider taps the "Add Service" FloatingActionButton on the services page THEN it SHALL navigate to the service creation screen
2. WHEN a provider taps the "Quick Setup" FloatingActionButton on the availability page THEN it SHALL open the quick setup dialog
3. WHEN FloatingActionButton animations are triggered THEN they SHALL display smoothly without visual glitches
4. WHEN the app switches between tabs that show/hide FloatingActionButtons THEN the animations SHALL work correctly

### Requirement 3

**User Story:** As a developer, I want a systematic approach to prevent future hero tag conflicts, so that new FloatingActionButton additions don't cause similar issues.

#### Acceptance Criteria

1. WHEN new FloatingActionButton widgets are added to the app THEN they SHALL follow a consistent heroTag naming convention
2. WHEN FloatingActionButton widgets are used in different screens THEN each SHALL have a descriptive and unique heroTag
3. WHEN reviewing the codebase THEN all FloatingActionButton widgets SHALL have explicit heroTag values rather than relying on defaults
4. WHEN the hero tag naming convention is applied THEN it SHALL be clear which screen or feature each tag belongs to