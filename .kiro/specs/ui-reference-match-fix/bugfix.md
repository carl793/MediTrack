# Bugfix Requirements Document

## Introduction

The MediTrack dashboard UI implementation does not match the reference design that was provided. Several key UI elements are missing from dashboard states, specifically the weekly day selector strip, the "TODAY'S REGIMEN" greeting section, and the medication edit button in the dashboard header. These missing elements prevent users from viewing their weekly schedule at a glance, seeing contextual greetings, and accessing medication configuration edits easily. This bugfix addresses the UI structure inconsistencies to match the intended reference design across all dashboard states.

## Bug Analysis

### Current Behavior (Defect)

1.1 WHEN viewing the locked idle dashboard state THEN the system does not display the weekly day strip (Mon 12, Tue 13, Wed 14, etc.) that shows the current day highlighted

1.2 WHEN viewing the unlocked idle dashboard state THEN the system does not display the weekly day strip showing the current day highlighted

1.3 WHEN viewing the locked idle or unlocked idle dashboard states THEN the system does not display the "TODAY'S REGIMEN" section with time-appropriate greeting ("Good morning", "Good afternoon", "Good evening")

1.4 WHEN viewing the locked idle or unlocked idle dashboard states THEN the system does not display an edit button in the dashboard header to access medication configuration

1.5 WHEN viewing the dashboard UI structure THEN the greeting section, day strip, and medication info are not properly organized to match the reference layout hierarchy

### Expected Behavior (Correct)

2.1 WHEN viewing the locked idle dashboard state THEN the system SHALL display the weekly day strip showing 5 days (2 before today, today highlighted in navy, 2 after today) positioned below the "TODAY'S REGIMEN" greeting section

2.2 WHEN viewing the unlocked idle dashboard state THEN the system SHALL display the weekly day strip showing 5 days with today highlighted in navy, positioned below the "TODAY'S REGIMEN" greeting section

2.3 WHEN viewing the locked idle or unlocked idle dashboard states THEN the system SHALL display the "TODAY'S REGIMEN" eyebrow label with a time-appropriate greeting headline and descriptive subtext

2.4 WHEN viewing the locked idle or unlocked idle dashboard states THEN the system SHALL display an edit button (pencil icon in lavender chip background) in the dashboard header that opens the medication wizard in edit mode

2.5 WHEN viewing the dashboard UI structure THEN the layout SHALL follow this hierarchy: Dashboard Header → "TODAY'S REGIMEN" greeting → Day Strip → Status chips → Medication cards → Action buttons

### Unchanged Behavior (Regression Prevention)

3.1 WHEN viewing the not configured dashboard state THEN the system SHALL CONTINUE TO display the existing greeting section, day strip, and "Add Medication" button as currently implemented

3.2 WHEN the day strip is displayed THEN the system SHALL CONTINUE TO show today's card with navy background and white text while other days have white card backgrounds

3.3 WHEN the dashboard header is displayed THEN the system SHALL CONTINUE TO show the "MediTrack" title and connection status indicator

3.4 WHEN clicking the edit button in the dashboard header THEN the system SHALL CONTINUE TO open the medication wizard with the existing configuration pre-filled

3.5 WHEN the tray is in "dispensing" state THEN the system SHALL CONTINUE TO block medication edits and show the appropriate warning message

3.6 WHEN viewing resolved states (taken/missed) THEN the system SHALL CONTINUE TO display the existing resolution cards without adding the day strip or greeting (these states are modal-like confirmations)

3.7 WHEN viewing the course completed state THEN the system SHALL CONTINUE TO display the existing completion UI without the day strip (course is finished)

3.8 WHEN the offline banner is shown THEN the system SHALL CONTINUE TO display at the top of the dashboard above all content

3.9 WHEN the bottom navigation is displayed THEN the system SHALL CONTINUE TO show Home and History tabs as currently implemented
