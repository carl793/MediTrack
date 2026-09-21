# Implementation Tasks: MediTrack Complete System

## 1. Project Setup and Configuration

### 1.1 Flutter Project Configuration
- [ ] 1.1.1 Update pubspec.yaml with all required dependencies (firebase_core, firebase_database, firebase_auth, provider, shared_preferences, flutter_local_notifications, timezone, intl)
- [ ] 1.1.2 Configure Firebase project in Firebase Console
- [ ] 1.1.3 Download and add google-services.json (Android) and GoogleService-Info.plist (iOS)
- [x] 1.1.4 Configure Firebase initialization in main.dart
- [ ] 1.1.5 Set up project folder structure (lib/models, lib/services, lib/screens, lib/widgets, lib/utils)
- [ ] 1.1.6 Configure Firebase security rules for medication, tray, stock, history, and device paths

### 1.2 Development Environment Setup
- [ ] 1.2.1 Set up Firebase Local Emulator Suite for testing
- [ ] 1.2.2 Configure VS Code/Android Studio for Flutter development
- [ ] 1.2.3 Create .gitignore entries for Firebase config files
- [ ] 1.2.4 Set up testing framework and mockito for unit/integration tests

## 2. Data Models Implementation

### 2.1 MedicationConfig Model
- [ ] 2.1.1 Create MedicationConfig class with all fields (name, dosageStrength, alarmTimes, courseType, durationDays, activeDays, missedWindowMinutes, pickupGraceMinutes, createdAt)
- [ ] 2.1.2 Implement toJson() serialization method
- [ ] 2.1.3 Implement fromJson() deserialization method
- [ ] 2.1.4 Add validation methods for all fields
- [ ] 2.1.5 Create CourseType enum (ongoing, fixed)

### 2.2 TrayState Model
- [ ] 2.2.1 Create TrayState class with fields (state, pillPresent, lastUpdated)
- [ ] 2.2.2 Implement toJson() and fromJson() methods
- [ ] 2.2.3 Add state validation (must be "idle" or "dispensing")

### 2.3 HistoryEvent Model
- [ ] 2.3.1 Create HistoryEvent class with fields (id, timestamp, scheduledTime, type, missedType)
- [ ] 2.3.2 Implement toJson() and fromJson() methods
- [ ] 2.3.3 Create HistoryEventType enum (taken, missed)
- [ ] 2.3.4 Add validation for missedType based on type

### 2.4 DeviceConnectionState Model
- [ ] 2.4.1 Create DeviceConnectionState class with fields (connected, lastSeen)
- [ ] 2.4.2 Implement fromJson() method
- [ ] 2.4.3 Add isStale computed property (lastSeen > 5 minutes)

### 2.5 Supporting Models
- [ ] 2.5.1 Create SlotState class (status, slotTime, unlockTime, windowCloseTime)
- [ ] 2.5.2 Create SlotStatus enum (upcoming, due, dispensed, closed)
- [ ] 2.5.3 Create DashboardStateEnum (notConfigured, lockedIdle, unlockedIdle, dispensing, resolvedTaken, resolvedMissed, courseCompleted)
- [ ] 2.5.4 Create HistoryFilter enum (all, taken, missed)
- [ ] 2.5.5 Create DateRange enum (sevenDays, thirtyDays, all)

## 3. Services Layer Implementation

### 3.1 FirebaseService
- [ ] 3.1.1 Create FirebaseService class with DatabaseReference dependency
- [ ] 3.1.2 Implement watchMedicationConfig() stream
- [ ] 3.1.3 Implement saveMedicationConfig() method with validation
- [ ] 3.1.4 Implement watchStockLevel() stream
- [ ] 3.1.5 Implement updateStockLevel() method
- [ ] 3.1.6 Implement watchDispenseTrigger() stream
- [ ] 3.1.7 Implement triggerDispense() method
- [ ] 3.1.8 Implement clearDispenseTrigger() method
- [ ] 3.1.9 Implement watchTrayState() stream
- [ ] 3.1.10 Implement watchDeviceConnection() stream
- [ ] 3.1.11 Implement watchHistory() stream with orderByChild and limitToLast(100)
- [ ] 3.1.12 Implement addHistoryEvent() method
- [ ] 3.1.13 Add error handling for malformed data

### 3.2 SchedulingService
- [ ] 3.2.1 Create SchedulingService class with MedicationConfig and DateTime dependencies
- [ ] 3.2.2 Implement getCurrentSlot() algorithm
- [ ] 3.2.3 Implement _computeWindowClose() helper method
- [ ] 3.2.4 Implement isDoseUnlocked() method
- [ ] 3.2.5 Implement isPickupWindowActive() method
- [ ] 3.2.6 Implement hasDoseWindowClosed() method
- [ ] 3.2.7 Implement isCourseCompleted() method
- [ ] 3.2.8 Implement getNextDoseTime() method
- [ ] 3.2.9 Implement isActiveDay() method for ongoing courses
- [ ] 3.2.10 Handle midnight rollover correctly

### 3.3 NotificationService
- [ ] 3.3.1 Create NotificationService class with FlutterLocalNotificationsPlugin dependency
- [ ] 3.3.2 Implement initialize() method with Android and iOS configuration
- [ ] 3.3.3 Implement scheduleDoseNotification() method
- [ ] 3.3.4 Implement scheduleAllNotifications() algorithm
- [ ] 3.3.5 Implement cancelAllNotifications() method
- [ ] 3.3.6 Implement onNotificationTap() handler
- [ ] 3.3.7 Add timezone support for scheduling
- [ ] 3.3.8 Implement active day filtering
- [ ] 3.3.9 Generate unique notification IDs

### 3.4 LocalStorageService
- [ ] 3.4.1 Create LocalStorageService class with SharedPreferences dependency
- [ ] 3.4.2 Implement setLastAcknowledgedResolvedAt() method
- [ ] 3.4.3 Implement getLastAcknowledgedResolvedAt() method
- [ ] 3.4.4 Implement clearAll() method
- [ ] 3.4.5 Handle null values gracefully

### 3.5 MissedDoseDetectionService
- [ ] 3.5.1 Create MissedDoseDetectionService class
- [ ] 3.5.2 Implement detectNotDispensedMisses() algorithm
- [ ] 3.5.3 Implement _buildSlotsForDateRange() helper
- [ ] 3.5.4 Implement _isSameDay() helper
- [ ] 3.5.5 Add periodic check logic (on app open or background task)
- [ ] 3.5.6 Prevent duplicate event creation

## 4. State Management

### 4.1 MediTrackStateProvider
- [ ] 4.1.1 Create MediTrackState class with ChangeNotifier mixin
- [ ] 4.1.2 Add state fields (medicationConfig, stockLevel, trayState, deviceConnection, history, lastAcknowledgedResolvedAt)
- [ ] 4.1.3 Implement _initialize() method with stream subscriptions
- [ ] 4.1.4 Implement triggerDispense() action
- [ ] 4.1.5 Implement acknowledgeResolution() action
- [ ] 4.1.6 Implement saveMedicationConfig() action
- [ ] 4.1.7 Implement updateStock() action
- [ ] 4.1.8 Add notifyListeners() calls on state changes
- [ ] 4.1.9 Handle stream disposal on dispose()

### 4.2 Dashboard State Computation
- [ ] 4.2.1 Implement computeDashboardState() algorithm as pure function
- [ ] 4.2.2 Implement _getLatestHistoryEvent() helper
- [ ] 4.2.3 Implement _shouldShowResolutionCard() helper
- [ ] 4.2.4 Add comprehensive state transition logic
- [ ] 4.2.5 Handle all edge cases (null config, empty history, midnight)

### 4.3 Adherence Computation
- [ ] 4.3.1 Implement computeWeeklyAdherence() function
- [ ] 4.3.2 Filter events by date range (past 7 days)
- [ ] 4.3.3 Calculate taken/total ratio
- [ ] 4.3.4 Handle empty history case (return 0.0)

## 5. Dashboard Screen Implementation

### 5.1 Dashboard UI Structure
- [ ] 5.1.1 Create DashboardScreen widget (StatelessWidget with Consumer)
- [ ] 5.1.2 Implement _buildForState() method with switch statement for 7 states
- [ ] 5.1.3 Add navigation to History and Wizard screens
- [ ] 5.1.4 Add offline indicator banner

### 5.2 NOT_CONFIGURED State UI
- [ ] 5.2.1 Create OnboardingView widget
- [ ] 5.2.2 Add welcome message and setup instructions
- [ ] 5.2.3 Add "Get Started" button that navigates to Wizard

### 5.3 LOCKED_IDLE State UI
- [ ] 5.3.1 Create LockedDashboard widget
- [ ] 5.3.2 Display next dose time
- [ ] 5.3.3 Show locked/disabled Remote Dispense button
- [ ] 5.3.4 Display medication name and dosage strength

### 5.4 UNLOCKED_IDLE State UI
- [ ] 5.4.1 Create UnlockedDashboard widget
- [ ] 5.4.2 Display "Ready to dispense" message
- [ ] 5.4.3 Show unlocked/enabled Remote Dispense button (fully rounded, mint background)
- [ ] 5.4.4 Handle onDispense callback
- [ ] 5.4.5 Display current stock level

### 5.5 DISPENSING State UI
- [ ] 5.5.1 Create DispensingView widget
- [ ] 5.5.2 Show loading spinner
- [ ] 5.5.3 Display "Dispensing..." message
- [ ] 5.5.4 Disable Remote Dispense button

### 5.6 RESOLVED_TAKEN State UI
- [ ] 5.6.1 Create SuccessCard widget
- [ ] 5.6.2 Display success message with pill icon
- [ ] 5.6.3 Show two-tone capsule icon (mint top, coral bottom)
- [ ] 5.6.4 Add "Dismiss" button that calls acknowledgeResolution()
- [ ] 5.6.5 Use lavender tint card background

### 5.7 RESOLVED_MISSED State UI
- [ ] 5.7.1 Create MissedCard widget
- [ ] 5.7.2 Display warning message with missed type indicator
- [ ] 5.7.3 Differentiate not_picked_up vs not_dispensed visually
- [ ] 5.7.4 Add "Dismiss" button that calls acknowledgeResolution()
- [ ] 5.7.5 Use coral color for missed indicator

### 5.8 COURSE_COMPLETED State UI
- [ ] 5.8.1 Create CourseCompletedView widget
- [ ] 5.8.2 Display completion message
- [ ] 5.8.3 Show overall adherence summary
- [ ] 5.8.4 Add "Start New Course" button that navigates to Wizard
- [ ] 5.8.5 Permanently disable Remote Dispense button

## 6. Wizard Screen Implementation

### 6.1 Wizard UI Structure
- [ ] 6.1.1 Create WizardScreen StatefulWidget
- [ ] 6.1.2 Add currentStep state variable
- [ ] 6.1.3 Implement Flutter Stepper widget with 5 steps
- [ ] 6.1.4 Add _draftConfig state variable
- [ ] 6.1.5 Implement _nextStep() and _prevStep() methods
- [ ] 6.1.6 Add save button on final step

### 6.2 Step 0: Medication Details
- [ ] 6.2.1 Create _buildMedicationDetailsStep() method
- [ ] 6.2.2 Add TextField for medication name (max 100 chars)
- [ ] 6.2.3 Add TextField for dosage strength (max 50 chars)
- [ ] 6.2.4 Add validation for non-empty fields

### 6.3 Step 1: Pill Inventory
- [ ] 6.3.1 Create _buildPillInventoryStep() method
- [ ] 6.3.2 Add stepper control for pill count
- [ ] 6.3.3 Cap maximum at 15 pills
- [ ] 6.3.4 Add visual indicator of hopper capacity

### 6.4 Step 2: Dosing Schedule
- [ ] 6.4.1 Create _buildDosingScheduleStep() method
- [ ] 6.4.2 Add time picker for 1-3 alarm times
- [ ] 6.4.3 Ensure alarm times are sorted chronologically
- [ ] 6.4.4 Add "Add Alarm" and "Remove Alarm" buttons
- [ ] 6.4.5 Validate HH:mm format

### 6.5 Step 3: Course Length
- [ ] 6.5.1 Create _buildCourseLengthStep() method
- [ ] 6.5.2 Add radio buttons for courseType (ongoing vs fixed)
- [ ] 6.5.3 Show active days selector (Mon-Sun checkboxes) for ongoing
- [ ] 6.5.4 Show duration input field (1-365 days) for fixed
- [ ] 6.5.5 Conditional rendering based on courseType selection

### 6.6 Step 4: Pickup Window
- [ ] 6.6.1 Create _buildPickupWindowStep() method
- [ ] 6.6.2 Add slider for missedWindowMinutes (5-120)
- [ ] 6.6.3 Add slider for pickupGraceMinutes (1-30)
- [ ] 6.6.4 Display current values

### 6.7 Wizard Save Logic
- [ ] 6.7.1 Implement _saveConfiguration() method
- [ ] 6.7.2 Add comprehensive validation before save
- [ ] 6.7.3 Block save if tray.state == "dispensing"
- [ ] 6.7.4 Write full snapshot to Firebase
- [ ] 6.7.5 Update stock level
- [ ] 6.7.6 Reschedule all notifications
- [ ] 6.7.7 Show loading indicator during save
- [ ] 6.7.8 Handle errors with error dialog
- [ ] 6.7.9 Navigate back to Dashboard on success

### 6.8 Wizard Edit Mode
- [ ] 6.8.1 Accept existingConfig parameter
- [ ] 6.8.2 Pre-populate fields with existing values
- [ ] 6.8.3 Apply forward-only schedule change rules
- [ ] 6.8.4 Restart course boundaries on save

## 7. History Screen Implementation

### 7.1 History UI Structure
- [ ] 7.1.1 Create HistoryScreen StatefulWidget
- [ ] 7.1.2 Add _filter and _dateRange state variables
- [ ] 7.1.3 Implement Consumer for HistoryState
- [ ] 7.1.4 Add AppBar with title

### 7.2 Weekly Summary Card
- [ ] 7.2.1 Create WeeklySummaryCard widget
- [ ] 7.2.2 Display adherence percentage
- [ ] 7.2.3 Add visual progress indicator
- [ ] 7.2.4 Use mint/coral colors for taken/missed

### 7.3 Filter Controls
- [ ] 7.3.1 Create SegmentedControl widget
- [ ] 7.3.2 Add All/Taken/Missed options
- [ ] 7.3.3 Handle onChanged callback
- [ ] 7.3.4 Create DateRangeSelector widget
- [ ] 7.3.5 Add 7/30/All days options

### 7.4 History List
- [ ] 7.4.1 Implement _applyFilters() method
- [ ] 7.4.2 Filter by type (all/taken/missed)
- [ ] 7.4.3 Filter by date range
- [ ] 7.4.4 Create HistoryList widget with ListView.builder
- [ ] 7.4.5 Create HistoryListTile widget
- [ ] 7.4.6 Display timestamp, scheduledTime, type
- [ ] 7.4.7 Show missed type indicator for missed events
- [ ] 7.4.8 Use visual distinction (mint for taken, coral for missed)
- [ ] 7.4.9 Handle empty history state

## 8. Visual Design Implementation

### 8.1 Theme Configuration
- [ ] 8.1.1 Create MediTrackColors class with color constants
- [ ] 8.1.2 Create MediTrackTypography class with text styles
- [ ] 8.1.3 Configure ThemeData in main.dart
- [ ] 8.1.4 Add IBM Plex Sans and IBM Plex Mono fonts
- [ ] 8.1.5 Set navy as primary color

### 8.2 Custom Widgets
- [ ] 8.2.1 Create PillButton widget (fully rounded, mint background)
- [ ] 8.2.2 Create LavenderCard widget (16px radius, lavender tint background)
- [ ] 8.2.3 Create TwoToneCapsuleIcon widget (mint top, coral bottom)
- [ ] 8.2.4 Create OfflineIndicatorBanner widget

### 8.3 Spacing and Layout
- [ ] 8.3.1 Define spacing constants (8, 16, 24, 32)
- [ ] 8.3.2 Apply consistent padding across screens
- [ ] 8.3.3 Use Scaffold for all screens
- [ ] 8.3.4 Implement responsive layouts

## 9. Error Handling Implementation

### 9.1 Firebase Connection Loss
- [ ] 9.1.1 Detect offline state (device/connected == false OR lastSeen > 5 min)
- [ ] 9.1.2 Display offline indicator banner
- [ ] 9.1.3 Disable Remote Dispense button
- [ ] 9.1.4 Show "Device offline. Reconnecting..." message
- [ ] 9.1.5 Auto-remove indicator on reconnection

### 9.2 Stock Level Zero
- [ ] 9.2.1 Detect stockLevel == 0
- [ ] 9.2.2 Display "Out of Stock" warning card
- [ ] 9.2.3 Disable Remote Dispense button
- [ ] 9.2.4 Show refill instructions

### 9.3 Dispense Failure
- [ ] 9.3.1 Listen for dispense failure signals from ESP32
- [ ] 9.3.2 Show "Dispense failed" error dialog
- [ ] 9.3.3 Suggest user actions (check hopper, try again)

### 9.4 Concurrent Save Prevention
- [ ] 9.4.1 Check tray.state before allowing Wizard save
- [ ] 9.4.2 Block save button when dispensing
- [ ] 9.4.3 Show warning message
- [ ] 9.4.4 Auto-enable save button when tray returns to idle

### 9.5 Notification Permission Denial
- [ ] 9.5.1 Detect notification permission status
- [ ] 9.5.2 Show persistent banner if denied
- [ ] 9.5.3 Add "Settings" button that opens OS settings
- [ ] 9.5.4 Continue app functionality normally

### 9.6 Invalid Configuration Data
- [ ] 9.6.1 Catch parsing exceptions in fromJson()
- [ ] 9.6.2 Log errors to console
- [ ] 9.6.3 Treat as medicationConfig == null
- [ ] 9.6.4 Show onboarding with warning message

## 10. ESP32 Firmware Implementation

### 10.1 Hardware Setup
- [ ] 10.1.1 Connect ESP32 DevKit V1 to computer
- [ ] 10.1.2 Wire SG90 servo to ESP32 GPIO pin
- [ ] 10.1.3 Wire HX711 load cell amplifier to ESP32
- [ ] 10.1.4 Wire piezo buzzer to ESP32 GPIO pin
- [ ] 10.1.5 Test power supply (5V USB or wall adapter)
- [ ] 10.1.6 Calibrate load cell for 0-1kg range

### 10.2 Firebase Connection
- [ ] 10.2.1 Include firebase-esp32 library
- [ ] 10.2.2 Configure Wi-Fi credentials
- [ ] 10.2.3 Initialize Firebase connection
- [ ] 10.2.4 Implement device/connected and device/lastSeen updates
- [ ] 10.2.5 Handle reconnection on connection loss

### 10.3 Dispense Trigger Listener
- [ ] 10.3.1 Subscribe to dispense/triggerDispense path
- [ ] 10.3.2 Detect when value changes to true
- [ ] 10.3.3 Trigger dispense sequence within 1-2 seconds
- [ ] 10.3.4 Write tray/state = "dispensing"

### 10.4 Servo Dispense Logic
- [ ] 10.4.1 Rotate servo to dispense position
- [ ] 10.4.2 Implement singulator disk rotation (180°)
- [ ] 10.4.3 Wait for pill to drop into tray
- [ ] 10.4.4 Return servo to idle position
- [ ] 10.4.5 Add servo control smoothing

### 10.5 Load Cell Pickup Verification
- [ ] 10.5.1 Read load cell weight after dispense
- [ ] 10.5.2 Detect pill presence (weight > threshold)
- [ ] 10.5.3 Write tray/pillPresent = true if detected
- [ ] 10.5.4 Implement retry logic (3 attempts) if no pill detected
- [ ] 10.5.5 Poll load cell during pickup window
- [ ] 10.5.6 Detect weight drop when pill is removed
- [ ] 10.5.7 Write tray/pillPresent = false on removal

### 10.6 Stock Management
- [ ] 10.6.1 Read current stock level from Firebase
- [ ] 10.6.2 Use transaction to decrement stock by 1 after successful dispense
- [ ] 10.6.3 Do NOT decrement stock if dispense fails

### 10.7 History Event Creation (ESP32 Side)
- [ ] 10.7.1 Create history event with type "taken" after successful pickup
- [ ] 10.7.2 Create history event with missedType "not_picked_up" if pickup window expires
- [ ] 10.7.3 Use Firebase push IDs for unique event keys
- [ ] 10.7.4 Include timestamp, scheduledTime in event

### 10.8 Dispense Completion
- [ ] 10.8.1 Write tray/state = "idle" after dispense completes
- [ ] 10.8.2 Clear dispense/triggerDispense = false
- [ ] 10.8.3 Update tray/lastUpdated timestamp

### 10.9 Buzzer Audio Feedback (Optional)
- [ ] 10.9.1 Play tone on dispense start
- [ ] 10.9.2 Play different tone on dispense completion
- [ ] 10.9.3 Play error tone on dispense failure

### 10.10 ESP32 Error Handling
- [ ] 10.10.1 Handle servo jam detection
- [ ] 10.10.2 Handle empty hopper despite stock count
- [ ] 10.10.3 Log errors to Serial monitor
- [ ] 10.10.4 Consider future: write error log to Firebase

## 11. Testing Implementation

### 11.1 Unit Tests - Data Models
- [ ] 11.1.1 Test MedicationConfig toJson/fromJson
- [ ] 11.1.2 Test MedicationConfig validation rules
- [ ] 11.1.3 Test TrayState toJson/fromJson
- [ ] 11.1.4 Test HistoryEvent toJson/fromJson
- [ ] 11.1.5 Test DeviceConnectionState isStale property

### 11.2 Unit Tests - Dashboard State
- [ ] 11.2.1 Test computeDashboardState for all 7 states
- [ ] 11.2.2 Test state transitions
- [ ] 11.2.3 Test edge cases (null config, empty history, midnight rollover)
- [ ] 11.2.4 Mock all dependencies

### 11.3 Unit Tests - Scheduling
- [ ] 11.3.1 Test getCurrentSlot with single dose ["08:00"]
- [ ] 11.3.2 Test getCurrentSlot with multiple doses ["08:00", "14:00", "20:00"]
- [ ] 11.3.3 Test slot window close logic (next slot vs midnight)
- [ ] 11.3.4 Test upcoming/due/closed status transitions
- [ ] 11.3.5 Test day boundary transitions
- [ ] 11.3.6 Test isCourseCompleted for ongoing courses (always false)
- [ ] 11.3.7 Test isCourseCompleted for fixed courses (true after duration)

### 11.4 Unit Tests - Adherence
- [ ] 11.4.1 Test computeWeeklyAdherence with empty history (returns 0.0)
- [ ] 11.4.2 Test with all taken events (returns 1.0)
- [ ] 11.4.3 Test with mixed taken/missed (returns correct percentage)
- [ ] 11.4.4 Test date range filtering (excludes events > 7 days old)

### 11.5 Property-Based Tests
- [ ] 11.5.1 Implement medicationConfigGenerator
- [ ] 11.5.2 Implement dateTimeGenerator
- [ ] 11.5.3 Implement sequenceOfDispenseActionsGenerator
- [ ] 11.5.4 Test slot non-overlap property
- [ ] 11.5.5 Test stock monotonic decrease property
- [ ] 11.5.6 Test acknowledgment idempotence property

### 11.6 Integration Tests - Dose Cycle
- [ ] 11.6.1 Setup: Create valid medication config
- [ ] 11.6.2 Test: Advance time to DUE slot
- [ ] 11.6.3 Assert: Dashboard shows UNLOCKED_IDLE
- [ ] 11.6.4 Test: Trigger dispense
- [ ] 11.6.5 Assert: tray/state == "dispensing"
- [ ] 11.6.6 Test: Simulate ESP32 completing dispense
- [ ] 11.6.7 Assert: Dashboard shows RESOLVED_TAKEN
- [ ] 11.6.8 Test: User acknowledges
- [ ] 11.6.9 Assert: Dashboard returns to LOCKED_IDLE

### 11.7 Integration Tests - Missed Doses
- [ ] 11.7.1 Test not_picked_up scenario
- [ ] 11.7.2 Test not_dispensed scenario
- [ ] 11.7.3 Assert correct missedType in history events

### 11.8 Integration Tests - Wizard Edit
- [ ] 11.8.1 Setup: Active medication with history
- [ ] 11.8.2 Test: User opens wizard, changes alarmTimes
- [ ] 11.8.3 Test: Save configuration
- [ ] 11.8.4 Assert: Firebase medication/* updated
- [ ] 11.8.5 Assert: Notifications rescheduled
- [ ] 11.8.6 Assert: Course boundaries restart

### 11.9 Integration Tests - Offline/Online
- [ ] 11.9.1 Setup: System in LOCKED_IDLE
- [ ] 11.9.2 Test: Simulate Firebase disconnect
- [ ] 11.9.3 Assert: Offline indicator appears
- [ ] 11.9.4 Test: Simulate Firebase reconnect
- [ ] 11.9.5 Assert: Offline indicator disappears
- [ ] 11.9.6 Assert: State syncs correctly

### 11.10 Widget Tests
- [ ] 11.10.1 Test DashboardScreen rendering for each state
- [ ] 11.10.2 Test WizardScreen step navigation
- [ ] 11.10.3 Test HistoryScreen filtering
- [ ] 11.10.4 Test button interactions
- [ ] 11.10.5 Test error dialog displays

## 12. Performance Optimization

### 12.1 Firebase Query Optimization
- [ ] 12.1.1 Implement .orderByChild('timestamp').limitToLast(100) for history
- [ ] 12.1.2 Add client-side caching with LRU eviction
- [ ] 12.1.3 Optimize weekly adherence to only read last 7 days

### 12.2 Dashboard Re-Render Optimization
- [ ] 12.2.1 Use Consumer with selective rebuild
- [ ] 12.2.2 Memoize expensive computations (getCurrentSlot, isCourseCompleted)
- [ ] 12.2.3 Debounce rapid Firebase updates

### 12.3 Notification Scheduling Optimization
- [ ] 12.3.1 Run scheduling in background isolate (if needed)
- [ ] 12.3.2 Show loading indicator during wizard save
- [ ] 12.3.3 Limit scheduling to 7 days, reschedule daily

### 12.4 ESP32 Performance
- [ ] 12.4.1 Poll load cell at 2 Hz during idle
- [ ] 12.4.2 Poll at 10 Hz during pickup window
- [ ] 12.4.3 Use deep sleep between doses (if battery powered)

## 13. Documentation and Polish

### 13.1 Code Documentation
- [ ] 13.1.1 Add dartdoc comments to all public APIs
- [ ] 13.1.2 Document complex algorithms with inline comments
- [ ] 13.1.3 Add README.md with setup instructions
- [ ] 13.1.4 Create ARCHITECTURE.md explaining system design

### 13.2 User Documentation
- [ ] 13.2.1 Create user guide for first-time setup
- [ ] 13.2.2 Document wizard flow with screenshots
- [ ] 13.2.3 Explain missed dose types (hardware vs app-detected)
- [ ] 13.2.4 Add troubleshooting section

### 13.3 Hardware Documentation
- [ ] 13.3.1 Create wiring diagram for ESP32 connections
- [ ] 13.3.2 Document 3D printing requirements (STL files)
- [ ] 13.3.3 Add assembly instructions
- [ ] 13.3.4 Document load cell calibration procedure

### 13.4 Academic Prototype Disclaimer
- [ ] 13.4.1 Add disclaimer screen on first launch
- [ ] 13.4.2 Include "Not HIPAA compliant" notice
- [ ] 13.4.3 Add "Not for medical diagnosis or treatment" disclaimer
- [ ] 13.4.4 Require user consent before proceeding

### 13.5 Final Polish
- [ ] 13.5.1 Test on multiple devices (Android/iOS)
- [ ] 13.5.2 Verify visual fidelity matches design tokens
- [ ] 13.5.3 Test with real ESP32 hardware
- [ ] 13.5.4 Conduct end-to-end user acceptance testing
- [ ] 13.5.5 Fix any remaining bugs
- [ ] 13.5.6 Optimize app size and performance

## 14. Debug Panel (Optional Development Tool)

### 14.1 Debug Panel Implementation
- [ ] 14.1.1 Create DebugPanel widget (only in debug mode)
- [ ] 14.1.2 Add button to simulate ESP32 dispense completion
- [ ] 14.1.3 Add button to simulate pickup window expiration
- [ ] 14.1.4 Add button to simulate offline/online transitions
- [ ] 14.1.5 Add button to fast-forward time
- [ ] 14.1.6 Add button to clear all data
- [ ] 14.1.7 Display current Firebase state
- [ ] 14.1.8 Remove debug panel in release builds

---

**Total Tasks: 280+ individual implementation tasks**

**Task Categories:**
1. Project Setup and Configuration: 10 tasks
2. Data Models Implementation: 19 tasks
3. Services Layer Implementation: 46 tasks
4. State Management: 14 tasks
5. Dashboard Screen Implementation: 38 tasks
6. Wizard Screen Implementation: 37 tasks
7. History Screen Implementation: 26 tasks
8. Visual Design Implementation: 14 tasks
9. Error Handling Implementation: 21 tasks
10. ESP32 Firmware Implementation: 39 tasks
11. Testing Implementation: 52 tasks
12. Performance Optimization: 11 tasks
13. Documentation and Polish: 23 tasks
14. Debug Panel: 8 tasks

**Estimated Implementation Time:** 8-12 weeks for single developer

**Dependencies:**
- Tasks 1-2 must be completed before other tasks
- Services layer (3) should be completed before UI implementation (5-7)
- ESP32 firmware (10) can be developed in parallel with Flutter app
- Testing (11) should be ongoing throughout development
- Documentation (13) should be completed last

**Priority:**
- **High Priority:** Tasks 1-6 (core functionality)
- **Medium Priority:** Tasks 7-10 (UI polish and hardware)
- **Low Priority:** Tasks 11-14 (testing, optimization, documentation)
