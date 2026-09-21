# Requirements Document: MediTrack Complete System

## 1. Medication Configuration

### 1.1 Wizard Setup Flow
The system SHALL provide a 5-step guided wizard for medication configuration including: medication details, pill inventory, dosing schedule, course length, and pickup window configuration.

### 1.2 Medication Details Collection
The system SHALL collect medication name (max 100 characters) and dosage strength (max 50 characters) from the user.

### 1.3 Pill Inventory Management
The system SHALL allow users to set pill inventory with a stepper control capped at 15 pills maximum.

### 1.4 Dosing Schedule Configuration
The system SHALL support 1-3 alarm times per day in "HH:mm" format, sorted chronologically.

### 1.5 Course Type Selection
The system SHALL support two course types: ongoing (with active day selection) and fixed-duration (with duration in days).

### 1.6 Ongoing Course Active Days
For ongoing courses, the system SHALL allow users to select active days of the week (1-7, representing Monday-Sunday).

### 1.7 Fixed-Duration Course Length
For fixed-duration courses, the system SHALL require a duration between 1-365 days.

### 1.8 Pickup Window Configuration
The system SHALL allow users to configure missed window minutes (5-120 minutes) and pickup grace minutes (1-30 minutes).

### 1.9 Configuration Snapshot Save
The system SHALL save configuration as a full snapshot to Firebase, never using patch updates.

### 1.10 Mid-Course Edit Safety
The system SHALL block configuration saves while tray state is "dispensing".

### 1.11 Forward-Only Schedule Changes
The system SHALL apply schedule changes forward only, with course boundaries restarting from save time.

### 1.12 Configuration Validation
The system SHALL validate all configuration fields before saving and display appropriate error messages for invalid inputs.

## 2. Dashboard State Management

### 2.1 NOT_CONFIGURED State
The system SHALL display onboarding UI when no medication configuration exists.

### 2.2 LOCKED_IDLE State
The system SHALL display a locked/disabled Remote Dispense button when no active dose slot is available.

### 2.3 UNLOCKED_IDLE State
The system SHALL display an unlocked/enabled Remote Dispense button when current slot status is DUE and stock level is greater than 0.

### 2.4 DISPENSING State
The system SHALL display a loading spinner and "Dispensing..." message when dispense trigger is active and tray state is "dispensing".

### 2.5 RESOLVED_TAKEN State
The system SHALL display a success card when the latest history event is "taken" and not yet acknowledged by the user.

### 2.6 RESOLVED_MISSED State
The system SHALL display a warning card with missed type indicator when the latest history event is "missed" and not yet acknowledged.

### 2.7 COURSE_COMPLETED State
The system SHALL display a completion message and adherence summary when a fixed-duration course has elapsed, with Remote Dispense button permanently disabled.

### 2.8 State-Driven Rendering
The dashboard SHALL be a pure function of Firebase state and local lastAcknowledgedResolvedAt timestamp.

### 2.9 Single Active Slot
The system SHALL ensure at most one dose slot has status DUE at any given time.

### 2.10 State Transition Logic
The system SHALL follow the defined state machine rules for all dashboard state transitions.

## 3. Remote Dispensing Control

### 3.1 User-Triggered Dispensing Only
The system SHALL only dispense pills when explicitly triggered by user tapping the Remote Dispense button (ESP32 never dispenses autonomously).

### 3.2 Firebase Trigger Write
The system SHALL write dispense/triggerDispense = true to Firebase when user taps the Remote Dispense button.

### 3.3 ESP32 Trigger Detection
The ESP32 SHALL detect the dispense trigger within 1-2 seconds and update tray/state to "dispensing".

### 3.4 Servo Control
The ESP32 SHALL rotate the SG90 servo to dispense a single pill using the rotating disk singulator mechanism.

### 3.5 Hardware-Verified Pickup
The ESP32 SHALL use the HX711 load cell to verify pill presence in the catch tray after dispensing.

### 3.6 Stock Decrement
The ESP32 SHALL decrement stock/current by exactly 1 using a Firebase transaction after successful pill dispense.

### 3.7 Stock Atomicity
The system SHALL ensure stock decrements are atomic with no race conditions (stock_before - stock_after == 1 OR both equal 0).

### 3.8 Dispense Completion
The ESP32 SHALL write tray/state = "idle", tray/pillPresent = true, and clear dispense/triggerDispense = false after successful dispense.

### 3.9 History Event Creation
The ESP32 SHALL create a history event with type "taken" when pill is successfully dispensed and removed from tray within pickup window.

### 3.10 Dispense Failure Retry
The ESP32 SHALL retry servo rotation up to 3 times if no pill is detected via load cell.

### 3.11 Dispense Failure Handling
If dispense fails after 3 retries, the ESP32 SHALL write tray/state = "idle", tray/pillPresent = false, and NOT decrement stock.

## 4. Missed Dose Detection

### 4.1 Hardware-Verified Missed Doses (not_picked_up)
The ESP32 SHALL create a history event with missedType = "not_picked_up" when pickup window expires with pill still in tray (detected via load cell).

### 4.2 App-Detected Missed Doses (not_dispensed)
The Flutter app SHALL create a history event with missedType = "not_dispensed" when dose window closes without user ever triggering dispense.

### 4.3 Missed Dose Type Exclusivity
Each missed dose event SHALL have exactly one missedType: either "not_picked_up" OR "not_dispensed", never both.

### 4.4 Pickup Window Expiration
The system SHALL define pickup window as the time between dispense completion and missedWindowMinutes + pickupGraceMinutes elapsed.

### 4.5 Dose Window Closure
The system SHALL close dose windows when the next slot arrives OR at midnight for the last slot of the day.

### 4.6 Periodic Missed Detection
The Flutter app SHALL periodically check for not_dispensed missed doses on app open or via background task.

### 4.7 No Duplicate Miss Events
The system SHALL NOT create duplicate history events for the same dose slot.

## 5. History and Adherence Tracking

### 5.1 History Event Storage
The system SHALL store all dose events (taken and missed) in Firebase under history/{pushId} with timestamp, scheduledTime, type, and missedType fields.

### 5.2 Weekly Adherence Calculation
The system SHALL calculate weekly adherence as: (taken events in past 7 days) / (total events in past 7 days).

### 5.3 Weekly Adherence Display
The History screen SHALL display weekly adherence percentage in a summary card.

### 5.4 History Filtering by Type
The History screen SHALL provide segmented control filtering: All, Taken, or Missed events.

### 5.5 History Filtering by Date Range
The History screen SHALL provide date range selector: 7 days, 30 days, or All time.

### 5.6 Chronological Display
The History screen SHALL display events in chronological order with timestamps.

### 5.7 Visual Distinction
The History screen SHALL visually distinguish taken vs missed doses.

### 5.8 Missed Type Indicators
The History screen SHALL display missed dose type indicators for hardware-verified vs app-detected misses.

### 5.9 History Query Optimization
The system SHALL use Firebase `.orderByChild('timestamp').limitToLast(100)` for efficient history queries.

### 5.10 History Persistence
All history events SHALL be append-only with no deletion capability (except full account deletion).

## 6. Notifications

### 6.1 Local Notification Scheduling
The system SHALL schedule local notifications for all dose times in the next 7 days using flutter_local_notifications.

### 6.2 Notification Timing
Notifications SHALL fire when a slot transitions from UPCOMING to DUE status.

### 6.3 Notification Content
Notification payload SHALL be: "It is {slotTime}. Time to take your {medication.name}."

### 6.4 Active Day Filtering
Notifications SHALL only be scheduled for active days (for ongoing courses).

### 6.5 Notification Cancellation
The system SHALL cancel all scheduled notifications when medication configuration changes.

### 6.6 Notification Rescheduling
The system SHALL reschedule notifications after wizard save.

### 6.7 Notification Permission Handling
The system SHALL continue functioning normally if notification permissions are denied, showing a persistent banner to enable notifications.

### 6.8 No Action Buttons
Notifications SHALL NOT include action buttons (user must open app to dispense).

### 6.9 Notification Completeness
For every active day and alarm time in the next 7 days, exactly one notification SHALL be scheduled.

## 7. Firebase Integration

### 7.1 Async Message Bus
All communication between Flutter app and ESP32 SHALL flow through Firebase Realtime Database (never direct communication).

### 7.2 Field Ownership - medication/*
The Flutter app SHALL have exclusive write access to medication/* fields.

### 7.3 Field Ownership - tray/*
The ESP32 SHALL have exclusive write access to tray/* fields.

### 7.4 Field Ownership - stock/current
Both Flutter app (for refill) and ESP32 (for decrement) MAY write to stock/current, with ESP32 using Firebase transactions.

### 7.5 Field Ownership - history/*
Both Flutter app (not_dispensed) and ESP32 (not_picked_up, taken) MAY write to history/*, using Firebase push IDs for unique keys.

### 7.6 Real-Time Sync
The system SHALL provide real-time synchronization with WebSocket connections.

### 7.7 Device Connection Monitoring
The system SHALL monitor device/connected and device/lastSeen to detect ESP32 connectivity.

### 7.8 Offline Indicator
The system SHALL display an offline indicator when device/connected == false OR lastSeen > 5 minutes stale.

### 7.9 Offline Dispense Prevention
The system SHALL disable the Remote Dispense button when device is offline.

### 7.10 Firebase Security Rules
The system SHALL enforce security rules: users can only read/write their own data, ESP32 has limited write access to tray/* only.

### 7.11 Firebase Authentication
The system SHALL use Firebase Anonymous Auth for MVP (single-user device).

### 7.12 Configuration Error Handling
The system SHALL treat malformed medication config as null (NOT_CONFIGURED state) and prompt user to set up again.

## 8. Local Storage

### 8.1 Acknowledgment Tracking
The system SHALL store lastAcknowledgedResolvedAt timestamp in SharedPreferences.

### 8.2 Resolution Card Display Logic
The system SHALL show resolution card if latest history event timestamp > lastAcknowledgedResolvedAt.

### 8.3 Acknowledgment Persistence
The lastAcknowledgedResolvedAt timestamp SHALL persist across app restarts.

### 8.4 Acknowledgment Update
The system SHALL update lastAcknowledgedResolvedAt when user dismisses resolution card.

### 8.5 Acknowledgment Idempotence
Acknowledging a resolution card multiple times SHALL be safe, using the latest acknowledgment time.

## 9. Scheduling Service

### 9.1 Slot State Computation
The system SHALL compute current slot state (UPCOMING, DUE, DISPENSED, CLOSED) based on alarmTimes and current time.

### 9.2 Slot Window Definition
A slot window SHALL be defined as: starts at alarm time, ends at next alarm time OR midnight for last slot.

### 9.3 Upcoming Slot Display
The system SHALL show next dose time when current slot is UPCOMING.

### 9.4 Active Day Filtering
For ongoing courses, the system SHALL skip slots that fall on inactive days.

### 9.5 Course Completion Check
The system SHALL check if fixed-duration courses are completed by comparing current time to createdAt + durationDays.

### 9.6 Midnight Rollover
The system SHALL correctly handle midnight rollover when computing next day's first slot.

## 10. User Interface

### 10.1 Navy Primary Color
The UI SHALL use navy (#1A2A4E) as the primary color.

### 10.2 Mint Success Color
The UI SHALL use mint (#7FDBCA) for success indicators and taken doses.

### 10.3 Coral Missed Color
The UI SHALL use coral (#FF6B6B) for missed dose indicators.

### 10.4 Lavender Card Backgrounds
The UI SHALL use lavender tint (#F5F3FA) for card backgrounds.

### 10.5 IBM Plex Fonts
The UI SHALL use IBM Plex Sans for display text and IBM Plex Mono for labels.

### 10.6 Fully Rounded Pill Buttons
The UI SHALL render pill-shaped buttons with borderRadius: 999px, mint background, and navy text.

### 10.7 Card Styling
The UI SHALL render cards with 16px border radius and 16px padding.

### 10.8 Two-Tone Capsule Icon
The UI SHALL display a two-tone capsule icon (top half mint, bottom half coral).

### 10.9 8px Spacing Grid
The UI SHALL use 8px as the base spacing unit with multiples (8, 16, 24, 32).

### 10.10 Stepper Navigation
The Wizard SHALL use Flutter's Stepper widget with Continue/Cancel buttons for navigation.

### 10.11 Onboarding View
The Dashboard SHALL display an onboarding view with setup instructions when NOT_CONFIGURED.

### 10.12 Loading Indicators
The UI SHALL show loading spinners during async operations (dispensing, wizard save).

### 10.13 Error Dialogs
The UI SHALL display error dialogs for validation failures and dispense errors.

## 11. Hardware Requirements

### 11.1 ESP32 DevKit V1
The hardware SHALL use ESP32 DevKit V1 with 240MHz dual-core processor and Wi-Fi 802.11 b/g/n.

### 11.2 SG90 Servo
The hardware SHALL use SG90 servo with 180° rotation for the singulator disk mechanism.

### 11.3 Load Cell and HX711
The hardware SHALL use a 0-1kg load cell with HX711 24-bit ADC for pickup verification.

### 11.4 Piezo Buzzer
The hardware SHALL include a piezo buzzer for audio feedback (optional).

### 11.5 3D Printed Chassis
The hardware SHALL include 3D-printed components: hopper, singulator disk, catch tray, and enclosure.

### 11.6 Hopper Capacity
The hopper SHALL have a maximum capacity of 15 pills (hard constraint).

### 11.7 Power Supply
The ESP32 SHALL be powered by 5V power supply (USB or wall adapter).

### 11.8 Load Cell Calibration
The load cell SHALL be calibrated on first use for accurate weight detection.

## 12. Performance Requirements

### 12.1 Dashboard Rebuild Performance
Dashboard rebuilds SHALL complete in < 16ms to maintain 60 FPS.

### 12.2 Firebase Query Performance
Initial history load SHALL complete in < 500ms with 100 events.

### 12.3 Real-Time Update Latency
Real-time Firebase updates SHALL have < 100ms latency.

### 12.4 Notification Scheduling Performance
Notification scheduling SHALL complete in < 1 second for 21 notifications.

### 12.5 ESP32 Trigger Detection Latency
ESP32 SHALL detect dispense trigger within 1-2 seconds.

### 12.6 Pickup Detection Latency
Load cell pickup detection SHALL have < 500ms latency.

### 12.7 Dispense Cycle Duration
Complete dispense cycle (trigger to completion) SHALL typically complete in 3-5 seconds.

## 13. Security and Privacy

### 13.1 Data Encryption in Transit
All data transmitted to/from Firebase SHALL be encrypted using HTTPS.

### 13.2 Data Encryption at Rest
All data stored in Firebase SHALL be encrypted at rest (Firebase default).

### 13.3 No PII Collection
The system SHALL NOT collect personally identifiable information beyond medication name.

### 13.4 No Third-Party Tracking
The system SHALL NOT include third-party analytics or tracking services.

### 13.5 ESP32 Credential Security
ESP32 credentials SHALL be stored in secure flash memory, not hardcoded.

### 13.6 Rate Limiting
The system SHALL implement rate limiting on dispense triggers (max 5 per hour).

### 13.7 Academic Prototype Disclaimer
The system SHALL display a disclaimer that it is not HIPAA compliant and not for medical diagnosis or treatment.

## 14. Error Handling

### 14.1 Firebase Connection Loss
The system SHALL display an offline indicator and disable Remote Dispense button when Firebase connection is lost.

### 14.2 Firebase Connection Recovery
The system SHALL automatically sync when Firebase connection is restored with no data loss.

### 14.3 Stock Level Zero
The system SHALL display "Out of Stock" warning and disable Remote Dispense button when stockLevel == 0.

### 14.4 Stock Refill Workflow
The system SHALL allow users to update stock level via Wizard edit mode after physical hopper refill.

### 14.5 Dispense Failure Notification
The system SHALL display "Dispense failed" error dialog when ESP32 cannot complete dispense after 3 retries.

### 14.6 Concurrent Save Prevention
The system SHALL block Wizard save button and show warning when tray.state == "dispensing".

### 14.7 Invalid Configuration Handling
The system SHALL treat invalid Firebase configuration data as NOT_CONFIGURED state and prompt re-setup.

### 14.8 Notification Permission Denial
The system SHALL show a persistent banner with "Settings" button if notification permissions are denied.

## 15. Testing Requirements

### 15.1 Unit Test Coverage
Unit tests SHALL achieve 90% line coverage and 100% branch coverage for core algorithms.

### 15.2 Dashboard State Tests
Unit tests SHALL cover all 7 dashboard states and state transitions.

### 15.3 Slot Computation Tests
Unit tests SHALL cover single dose, multiple doses, window close logic, and day boundary transitions.

### 15.4 Course Completion Tests
Unit tests SHALL verify ongoing courses never complete and fixed courses complete after duration elapsed.

### 15.5 Adherence Calculation Tests
Unit tests SHALL verify adherence calculation for empty history, all taken, mixed events, and date range filtering.

### 15.6 Property-Based Tests
The system SHALL include property-based tests for slot non-overlap, stock monotonic decrease, and acknowledgment idempotence.

### 15.7 Integration Tests
Integration tests SHALL cover complete dose cycle, both missed dose types, wizard edits, and offline/online cycles.

### 15.8 Mock Firebase Usage
Integration tests SHALL use mocked Firebase services for reproducible testing.

### 15.9 Time Manipulation
Tests SHALL use fake_async or equivalent for time-dependent test scenarios.

## 16. Dependencies and Third-Party Services

### 16.1 Flutter SDK
The system SHALL use Flutter SDK ^3.13.0.

### 16.2 Firebase Core
The system SHALL include firebase_core ^2.24.0 for Firebase initialization.

### 16.3 Firebase Realtime Database
The system SHALL include firebase_database ^10.4.0 for real-time data sync.

### 16.4 Firebase Auth
The system SHALL include firebase_auth ^4.16.0 for anonymous authentication.

### 16.5 Provider State Management
The system SHALL use provider ^6.1.1 for state management.

### 16.6 SharedPreferences
The system SHALL use shared_preferences ^2.2.2 for local storage.

### 16.7 Local Notifications
The system SHALL use flutter_local_notifications ^16.3.0 and timezone ^0.9.2.

### 16.8 Date/Time Formatting
The system SHALL use intl ^0.18.1 for date/time formatting.

### 16.9 ESP32 Firmware Libraries
The ESP32 firmware SHALL use firebase-esp32, HX711_ADC, Servo, and ArduinoJson libraries.

### 16.10 Firebase Free Tier
The system SHALL operate within Firebase Spark plan free tier (1 GB stored, 10 GB/month downloaded).

## 17. Non-Goals (Explicit Exclusions)

### 17.1 No Manual "I Took It" Button
The system SHALL NOT provide a manual button for users to mark doses as taken without hardware verification.

### 17.2 No Multi-Compartment UI
The system SHALL NOT support multiple medication compartments (single medication only).

### 17.3 No Dosage Calculators
The system SHALL NOT include medical dosage calculators or recommendations.

### 17.4 No PRN or Every-Other-Day Scheduling
The system SHALL NOT support PRN (as-needed) or every-other-day scheduling patterns.

### 17.5 No Settings/Account Screen
The system SHALL NOT include a dedicated settings or account management screen.

### 17.6 No Notification Action Buttons
Notifications SHALL NOT include action buttons for dispensing or marking as taken.

### 17.7 No Server-Side Pagination
The system SHALL NOT implement server-side pagination for history (client-side only).

### 17.8 No Autonomous ESP32 Dosing
The ESP32 SHALL NOT autonomously dispense pills based on schedule (app-triggered only).

---

**Total Requirements: 175**

**Requirement Categories:**
- Medication Configuration: 12 requirements
- Dashboard State Management: 10 requirements
- Remote Dispensing Control: 11 requirements
- Missed Dose Detection: 7 requirements
- History and Adherence Tracking: 10 requirements
- Notifications: 9 requirements
- Firebase Integration: 12 requirements
- Local Storage: 5 requirements
- Scheduling Service: 6 requirements
- User Interface: 13 requirements
- Hardware Requirements: 8 requirements
- Performance Requirements: 7 requirements
- Security and Privacy: 7 requirements
- Error Handling: 8 requirements
- Testing Requirements: 9 requirements
- Dependencies and Third-Party Services: 10 requirements
- Non-Goals: 8 requirements

**Traceability:** All requirements are derived from the design document sections including Overview, Components, Data Models, Algorithms, Error Handling, Testing Strategy, Performance Considerations, Security Considerations, and Dependencies.
