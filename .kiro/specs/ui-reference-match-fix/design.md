# UI Reference Match Fix - Bugfix Design

## Overview

The MediTrack dashboard UI is missing three critical elements present in the reference design: the weekly day strip, the "TODAY'S REGIMEN" greeting section, and the medication edit button in the dashboard header. These missing elements reduce usability by preventing users from viewing their weekly schedule at a glance, seeing contextual greetings, and easily accessing medication configuration.

The fix involves adding these UI elements to the locked and unlocked idle dashboard states while preserving all existing functionality. The approach is straightforward: integrate existing widgets (DayStrip widget already exists and is used in NotConfiguredView) and add the greeting section following the same pattern established in NotConfiguredView.

## Glossary

- **Bug_Condition (C)**: The condition that triggers the bug - when viewing locked or unlocked idle dashboard states, the UI is missing the day strip, greeting section, and edit button
- **Property (P)**: The desired behavior - these three UI elements should be visible and follow the reference layout hierarchy
- **Preservation**: Existing dashboard functionality (status chips, medication cards, buttons, navigation) must remain unchanged
- **LockedIdleView**: The widget in `lib/screens/dashboard/states/locked_idle_view.dart` that displays the dashboard when a dose is scheduled but not yet due
- **UnlockedIdleView**: The widget in `lib/screens/dashboard/states/unlocked_idle_view.dart` that displays the dashboard when a dose is ready to be dispensed
- **DashboardHeader**: The widget in `lib/screens/dashboard/widgets/dashboard_header.dart` that shows the MediTrack title, connection status, optional edit button, and user avatar
- **DayStrip**: The existing widget in `lib/widgets/day_strip.dart` that displays a 5-day horizontal strip with today highlighted in navy
- **dashboardState**: The property in MediTrackState that determines which view to render (notConfigured, lockedIdle, unlockedIdle, dispensing, etc.)

## Bug Details

### Bug Condition

The bug manifests when the user views the locked idle or unlocked idle dashboard states. The UI structure does not include the weekly day strip, the "TODAY'S REGIMEN" greeting section with time-appropriate greeting, or the edit button in the dashboard header, causing the implementation to deviate from the reference design.

**Formal Specification:**
```
FUNCTION isBugCondition(input)
  INPUT: input of type DashboardRenderContext
  OUTPUT: boolean
  
  RETURN input.dashboardState IN ['lockedIdle', 'unlockedIdle']
         AND NOT input.ui.contains('weeklyDayStrip')
         AND NOT input.ui.contains('todaysRegimenGreeting')
         AND NOT input.dashboardHeader.contains('editButton')
END FUNCTION
```

### Examples

- **Locked Idle View**: User views the locked idle state → Weekly day strip is missing, no "TODAY'S REGIMEN" section, no edit button in header → Expected: All three elements should be visible
- **Unlocked Idle View**: User views the unlocked idle state (dose ready) → Weekly day strip is missing, no "TODAY'S REGIMEN" section, no edit button in header → Expected: All three elements should be visible
- **Not Configured View**: User views the not configured state → Day strip, greeting, and edit button ARE present (context: this is the correct reference implementation) → Expected: This behavior should remain unchanged
- **Resolved/Course Completed**: User views resolved taken/missed or course completed states → These states do not show the day strip or greeting (by design, as they are modal-like confirmations) → Expected: This behavior should remain unchanged

## Expected Behavior

### Preservation Requirements

**Unchanged Behaviors:**
- All existing status chips (NEXT DOSE SCHEDULED, READY TO DISPENSE, etc.) must continue to display
- All medication cards showing drug name, dosage, and time information must continue to display
- All action buttons (Dispense, locked dispense) must continue to function
- The supply and days-left mini stat cards must continue to display
- The countdown chips must continue to display
- The bottom navigation (Home/History) must continue to function
- The offline banner must continue to display when appropriate
- The wizard opening logic (checking for dispensing state before allowing edit) must remain unchanged
- States that don't use these elements (resolved, course completed) must remain unchanged

**Scope:**
All inputs that do NOT involve the locked idle or unlocked idle states should be completely unaffected by this fix. This includes:
- Not configured state (which already has the correct implementation)
- Dispensing state (which shows a specialized dispensing UI)
- Resolved taken/missed states (which are modal-like confirmations)
- Course completed state (which shows a completion UI)
- Bottom navigation functionality
- Offline banner functionality

## Hypothesized Root Cause

Based on the bug description and code analysis, the most likely issues are:

1. **Incomplete Feature Implementation**: When locked_idle_view.dart and unlocked_idle_view.dart were created, the day strip and greeting section were not added, even though they were already implemented in not_configured_view.dart. This suggests the reference design was followed for NotConfiguredView but not applied to the other idle states.

2. **Missing Edit Button Prop**: The DashboardHeader widget already has an optional onEditTap parameter, but it is not being passed from LockedIdleView or UnlockedIdleView. The views receive an onEditTap callback but do not forward it to DashboardHeader.

3. **Layout Hierarchy Mismatch**: The current layout in locked/unlocked idle views goes directly from header to status chips to medication cards. The reference design requires: Header → Greeting → Day Strip → Status chips → Cards.

4. **Widget Reuse Oversight**: The DayStrip widget exists and is used correctly in NotConfiguredView, but was simply not imported and added to the other two idle views.

## Correctness Properties

Property 1: Bug Condition - Missing UI Elements Added

_For any_ dashboard render where the state is lockedIdle or unlockedIdle, the fixed UI SHALL display the weekly day strip below the greeting section, the "TODAY'S REGIMEN" greeting section below the header, and an edit button in the dashboard header that opens the medication wizard in edit mode.

**Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5**

Property 2: Preservation - Existing Dashboard Functionality

_For any_ dashboard render that is NOT in lockedIdle or unlockedIdle state, OR for any user interaction with existing dashboard elements (status chips, medication cards, action buttons, navigation), the fixed code SHALL produce exactly the same behavior as the original code, preserving all existing functionality for other states and interactions.

**Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9**

## Fix Implementation

### Changes Required

Assuming our root cause analysis is correct:

**File**: `lib/screens/dashboard/states/locked_idle_view.dart`

**Function**: `LockedIdleView.build()`

**Specific Changes**:
1. **Import DayStrip Widget**: Add `import '../../../widgets/day_strip.dart';` to the imports
   - The DayStrip widget already exists and is used in NotConfiguredView
   - No new widget creation needed

2. **Pass onEditTap to DashboardHeader**: Modify the DashboardHeader instantiation
   - Change `DashboardHeader(isConnected: state.deviceConnection.isOnline)` 
   - To `DashboardHeader(isConnected: state.deviceConnection.isOnline, onEditTap: onEditTap)`
   - This will display the edit button in the header

3. **Add Greeting Section**: Insert after DashboardHeader, before status chips
   - Create a helper method `String _greeting()` that returns time-appropriate greeting
   - Add the "TODAY'S REGIMEN" eyebrow label with greeting headline and subtext
   - Use the same styling as NotConfiguredView for consistency

4. **Add Day Strip**: Insert after greeting section, before status chips
   - Add `const DayStrip()` widget with proper padding
   - Position it below the greeting and above the status row

5. **Adjust Spacing**: Update spacing between sections to match reference design
   - Ensure consistent AppSpacing.md between greeting, day strip, and status chips

**File**: `lib/screens/dashboard/states/unlocked_idle_view.dart`

**Function**: `UnlockedIdleView.build()`

**Specific Changes**:
1. **Import DayStrip Widget**: Add `import '../../../widgets/day_strip.dart';` to the imports

2. **Pass onEditTap to DashboardHeader**: Modify the DashboardHeader instantiation
   - Change `DashboardHeader(isConnected: state.deviceConnection.isOnline)` 
   - To `DashboardHeader(isConnected: state.deviceConnection.isOnline, onEditTap: onEditTap)`

3. **Add Greeting Section**: Insert after DashboardHeader, before status chips
   - Create a helper method `String _greeting()` (same logic as in LockedIdleView)
   - Add the "TODAY'S REGIMEN" section with the same structure

4. **Add Day Strip**: Insert after greeting section, before status chips
   - Add `const DayStrip()` widget

5. **Adjust Spacing**: Maintain consistent spacing throughout the layout

**Implementation Pattern (from NotConfiguredView)**:
The greeting section should follow this structure:
```dart
Padding(
  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Eyebrow
            const Text(
              "TODAY'S REGIMEN",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.88,
                color: MediTrackColors.navy,
              ),
            ),
            const SizedBox(height: 4),
            // Headline
            Text(
              _greeting(),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: MediTrackColors.textPrimary,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            // Subtext (varies per state)
            Text(
              '[context-appropriate subtext]',
              style: const TextStyle(
                fontSize: 14,
                color: MediTrackColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 12),
      // Sun badge
      Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: MediTrackColors.lavenderLight,
        ),
        child: const Icon(
          Icons.wb_sunny_rounded,
          size: 20,
          color: MediTrackColors.amber,
        ),
      ),
    ],
  ),
),
```

## Testing Strategy

### Validation Approach

The testing strategy follows a two-phase approach: first, manually verify the current UI state to confirm the missing elements, then verify the fix adds all elements correctly while preserving existing functionality.

### Exploratory Bug Condition Checking

**Goal**: Surface counterexamples that demonstrate the bug BEFORE implementing the fix. Confirm the root cause analysis by verifying the missing UI elements.

**Test Plan**: Run the app and navigate to locked idle and unlocked idle states. Take screenshots and compare with the reference design. Verify that the day strip, greeting section, and edit button are missing.

**Test Cases**:
1. **Locked Idle Missing Elements Test**: Navigate to locked idle state (configure medication, wait for scheduled time to be in future) → Verify day strip is not visible, "TODAY'S REGIMEN" is not visible, edit button is not in header
2. **Unlocked Idle Missing Elements Test**: Navigate to unlocked idle state (configure medication, wait for dose window to open) → Verify same three elements are missing
3. **Not Configured Has Elements Test**: Navigate to not configured state (fresh install or after course completion) → Verify day strip and greeting ARE present (this is the correct reference)
4. **Edit Button Parameter Test**: Inspect code to confirm DashboardHeader has onEditTap parameter but it's not being passed from locked/unlocked views

**Expected Counterexamples**:
- Day strip widget is not rendered in locked/unlocked idle states
- "TODAY'S REGIMEN" greeting section is not rendered in locked/unlocked idle states
- Edit button in header is not displayed despite the onEditTap callback being available
- Possible root cause: incomplete feature implementation, missing widget import, missing prop forwarding

### Fix Checking

**Goal**: Verify that for all dashboard renders where the state is lockedIdle or unlockedIdle, the fixed UI displays all three missing elements correctly.

**Pseudocode:**
```
FOR ALL dashboardRender WHERE (state = lockedIdle OR state = unlockedIdle) DO
  ui := renderDashboard_fixed(state)
  ASSERT ui.contains('weeklyDayStrip')
  ASSERT ui.contains('todaysRegimenGreeting')
  ASSERT ui.dashboardHeader.contains('editButton')
  ASSERT layoutHierarchy(ui) = [Header, Greeting, DayStrip, StatusChips, MedicationCards, ActionButtons]
END FOR
```

### Preservation Checking

**Goal**: Verify that for all dashboard states that are NOT lockedIdle or unlockedIdle, the fixed code produces the same UI as the original code, and that all existing interactions continue to work.

**Pseudocode:**
```
FOR ALL dashboardRender WHERE (state NOT IN [lockedIdle, unlockedIdle]) DO
  uiOriginal := renderDashboard_original(state)
  uiFixed := renderDashboard_fixed(state)
  ASSERT uiOriginal = uiFixed
END FOR

FOR ALL userInteraction WITH existingDashboardElements DO
  behaviorOriginal := handleInteraction_original(interaction)
  behaviorFixed := handleInteraction_fixed(interaction)
  ASSERT behaviorOriginal = behaviorFixed
END FOR
```

**Testing Approach**: Property-based testing is recommended for preservation checking because:
- It generates many test cases automatically across different dashboard states
- It catches edge cases that manual testing might miss (e.g., specific connection states, stock levels, timing windows)
- It provides strong guarantees that behavior is unchanged for all non-buggy states

**Test Plan**: Run the app and test all other dashboard states and interactions on the UNFIXED code first to observe expected behavior, then write property-based tests capturing that behavior and verify they pass on the fixed code.

**Test Cases**:
1. **Not Configured Preservation**: Verify not configured state continues to show greeting, day strip, and "Add Medication" button with existing styling
2. **Dispensing State Preservation**: Verify dispensing state shows the dispensing animation without day strip or greeting
3. **Resolved States Preservation**: Verify resolved taken/missed states show resolution cards without day strip or greeting (modal-like confirmations)
4. **Course Completed Preservation**: Verify course completed state shows completion UI without day strip
5. **Offline Banner Preservation**: Verify offline banner displays at top when ESP32 is offline
6. **Bottom Navigation Preservation**: Verify Home/History tabs continue to function
7. **Edit Button Functionality**: Click edit button → Verify wizard opens with existing config pre-filled
8. **Edit Button Block on Dispense**: Start dispensing → Try to click edit button → Verify appropriate warning message
9. **Status Chips Preservation**: Verify all status chips (NEXT DOSE SCHEDULED, READY TO DISPENSE, etc.) continue to display correctly
10. **Medication Cards Preservation**: Verify all medication info cards continue to display drug name, dosage, time, supply info correctly

### Unit Tests

- Test that DayStrip widget renders with today highlighted in navy
- Test that greeting helper method returns correct greeting based on time of day (morning, afternoon, evening)
- Test that DashboardHeader displays edit button when onEditTap is provided
- Test that DashboardHeader does not display edit button when onEditTap is null
- Test layout hierarchy order (Header → Greeting → DayStrip → Status → Cards → Buttons)
- Test that edit button callback is wired correctly to open wizard

### Property-Based Tests

- Generate random dashboard states (lockedIdle, unlockedIdle with varying times, stock levels) and verify day strip and greeting always appear
- Generate random dashboard states (notConfigured, dispensing, resolved, completed) and verify they remain unchanged
- Generate random timestamps and verify greeting text changes correctly (morning/afternoon/evening boundaries)
- Generate random connection states and verify all UI elements render correctly regardless of connection status

### Integration Tests

- Test full flow: Configure medication → View locked idle → Verify all three elements present
- Test full flow: Wait for dose window → View unlocked idle → Verify all three elements present
- Test editing flow: Click edit button in locked idle → Verify wizard opens → Modify config → Return to dashboard → Verify elements still present
- Test editing flow: Click edit button in unlocked idle → Verify wizard opens → Verify can edit
- Test edit blocking: Start dispense → Try to click edit button → Verify blocked with warning
- Test state transitions: Not configured → Configured (locked) → Ready (unlocked) → Dispensing → Resolved → Verify UI correctness at each step
- Test day strip updates: Wait for day to change (or simulate time change) → Verify day strip highlights new "today"
- Test greeting updates: Wait for time period to change (or simulate time change) → Verify greeting text updates
