import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/models/device_connection.dart';
import 'package:meditrack/models/history_event.dart';
import 'package:meditrack/models/medication_config.dart';
import 'package:meditrack/models/tray_state_model.dart';
import 'package:meditrack/screens/dashboard/states/locked_idle_view.dart';
import 'package:meditrack/screens/dashboard/states/unlocked_idle_view.dart';
import 'package:meditrack/services/firebase_service_base.dart';
import 'package:meditrack/services/local_storage_service.dart';
import 'package:meditrack/state/meditrack_state.dart';
import 'package:meditrack/widgets/day_strip.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **Property 1: Bug Condition - Missing UI Elements in Locked/Unlocked Idle Views**
///
/// **Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5**
///
/// This test is EXPECTED TO FAIL on unfixed code. When it fails, that confirms
/// the bug exists. After the fix is implemented, this test should PASS.
///
/// The test verifies that:
/// - Weekly day strip is MISSING in locked_idle_view.dart
/// - "TODAY'S REGIMEN" greeting is MISSING in locked_idle_view.dart
/// - Edit button in header is MISSING in locked_idle_view.dart
/// - Weekly day strip is MISSING in unlocked_idle_view.dart
/// - "TODAY'S REGIMEN" greeting is MISSING in unlocked_idle_view.dart
/// - Edit button in header is MISSING in unlocked_idle_view.dart
///
/// **CRITICAL**: This is a Bug Condition Exploration Test for a bugfix spec.
/// DO NOT attempt to fix the test or code when it fails.
void main() {
  // Set up mock SharedPreferences for testing
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    
    // Mock the flutter_local_notifications plugin
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dexterous.com/flutter/local_notifications'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'initialize') {
          return true;
        } else if (methodCall.method == 'getNotificationAppLaunchDetails') {
          return null;
        }
        return null;
      },
    );
  });

  tearDownAll(() {
    // Clean up mock handler
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dexterous.com/flutter/local_notifications'),
      null,
    );
  });

  group('Bug Condition Exploration - Missing UI Elements', () {
    late _MockMediTrackState mockState;

    setUpAll(() async {
      // Test configuration
      final testConfig = MedicationConfig(
        name: 'Aspirin',
        dosageStrength: '100mg',
        unitForm: '1 tablet',
        purpose: 'Blood thinner',
        alarmTimes: ['08:00', '20:00'],
        courseType: CourseType.ongoing,
        startDate: _todayString(),
        activeDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        missedWindowMinutes: 15,
      );

      mockState = await _MockMediTrackState.create(
        medicationConfig: testConfig,
        stockLevel: 30,
        deviceConnection: DeviceConnection(
          connected: true,
          lastSeen: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    });

    testWidgets(
      'LOCKED IDLE VIEW: Weekly day strip is MISSING (Expected Behavior: should be present)',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LockedIdleView(
                state: mockState,
                onEditTap: () {},
              ),
            ),
          ),
        );

        // ASSERTION: DayStrip widget should be present but is currently MISSING
        // This assertion FAILS on unfixed code (which is correct - proves bug exists)
        // After fix, this assertion PASSES (confirms expected behavior)
        expect(
          find.byType(DayStrip),
          findsOneWidget,
          reason: 'BUG: Weekly day strip is missing in locked idle view. '
              'Expected: DayStrip widget should be rendered below greeting section.',
        );
      },
    );

    testWidgets(
      'LOCKED IDLE VIEW: "TODAY\'S REGIMEN" greeting is MISSING (Expected Behavior: should be present)',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LockedIdleView(
                state: mockState,
                onEditTap: () {},
              ),
            ),
          ),
        );

        // ASSERTION: "TODAY'S REGIMEN" greeting should be present but is currently MISSING
        expect(
          find.text("TODAY'S REGIMEN"),
          findsOneWidget,
          reason: 'BUG: "TODAY\'S REGIMEN" greeting section is missing in locked idle view. '
              'Expected: Greeting eyebrow should be visible below header.',
        );

        // ASSERTION: Time-appropriate greeting headline should be present
        final greetingPatterns = [
          'Good morning',
          'Good afternoon',
          'Good evening',
        ];
        final foundGreeting = greetingPatterns.any(
          (pattern) => find.textContaining(pattern).evaluate().isNotEmpty,
        );
        expect(
          foundGreeting,
          isTrue,
          reason: 'BUG: Time-appropriate greeting headline is missing in locked idle view. '
              'Expected: One of "Good morning/afternoon/evening" should be visible.',
        );
      },
    );

    testWidgets(
      'LOCKED IDLE VIEW: Edit button in header is MISSING (Expected Behavior: should be present)',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LockedIdleView(
                state: mockState,
                onEditTap: () {},
              ),
            ),
          ),
        );

        // ASSERTION: Edit button (pencil icon) should be present in header but is currently MISSING
        // DashboardHeader has onEditTap but locked_idle_view is not passing it
        final editButtons = find.byWidgetPredicate(
          (widget) =>
              widget is Icon &&
              widget.icon == Icons.edit_rounded &&
              widget.size == 18,
        );
        expect(
          editButtons,
          findsOneWidget,
          reason: 'BUG: Edit button is missing from dashboard header in locked idle view. '
              'Expected: Edit button (pencil icon) should be visible in header when onEditTap is provided.',
        );
      },
    );

    testWidgets(
      'UNLOCKED IDLE VIEW: Weekly day strip is MISSING (Expected Behavior: should be present)',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnlockedIdleView(
                state: mockState,
                onDispense: () {},
                onEditTap: () {},
              ),
            ),
          ),
        );

        // ASSERTION: DayStrip widget should be present but is currently MISSING
        expect(
          find.byType(DayStrip),
          findsOneWidget,
          reason: 'BUG: Weekly day strip is missing in unlocked idle view. '
              'Expected: DayStrip widget should be rendered below greeting section.',
        );
      },
    );

    testWidgets(
      'UNLOCKED IDLE VIEW: "TODAY\'S REGIMEN" greeting is MISSING (Expected Behavior: should be present)',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnlockedIdleView(
                state: mockState,
                onDispense: () {},
                onEditTap: () {},
              ),
            ),
          ),
        );

        // ASSERTION: "TODAY'S REGIMEN" greeting should be present but is currently MISSING
        expect(
          find.text("TODAY'S REGIMEN"),
          findsOneWidget,
          reason: 'BUG: "TODAY\'S REGIMEN" greeting section is missing in unlocked idle view. '
              'Expected: Greeting eyebrow should be visible below header.',
        );

        // ASSERTION: Time-appropriate greeting headline should be present
        final greetingPatterns = [
          'Good morning',
          'Good afternoon',
          'Good evening',
        ];
        final foundGreeting = greetingPatterns.any(
          (pattern) => find.textContaining(pattern).evaluate().isNotEmpty,
        );
        expect(
          foundGreeting,
          isTrue,
          reason: 'BUG: Time-appropriate greeting headline is missing in unlocked idle view. '
              'Expected: One of "Good morning/afternoon/evening" should be visible.',
        );
      },
    );

    testWidgets(
      'UNLOCKED IDLE VIEW: Edit button in header is MISSING (Expected Behavior: should be present)',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnlockedIdleView(
                state: mockState,
                onDispense: () {},
                onEditTap: () {},
              ),
            ),
          ),
        );

        // ASSERTION: Edit button (pencil icon) should be present in header but is currently MISSING
        final editButtons = find.byWidgetPredicate(
          (widget) =>
              widget is Icon &&
              widget.icon == Icons.edit_rounded &&
              widget.size == 18,
        );
        expect(
          editButtons,
          findsOneWidget,
          reason: 'BUG: Edit button is missing from dashboard header in unlocked idle view. '
              'Expected: Edit button (pencil icon) should be visible in header when onEditTap is provided.',
        );
      },
    );

    test('Bug Condition Formal Specification', () {
      // This test documents the formal bug condition from the design document
      // Bug Condition: isBugCondition(input) returns true when:
      //   input.dashboardState IN ['lockedIdle', 'unlockedIdle']
      //   AND NOT input.ui.contains('weeklyDayStrip')
      //   AND NOT input.ui.contains('todaysRegimenGreeting')
      //   AND NOT input.dashboardHeader.contains('editButton')

      final bugCondition = BugCondition(
        dashboardState: 'lockedIdle',
        hasWeeklyDayStrip: false,
        hasTodaysRegimenGreeting: false,
        hasEditButtonInHeader: false,
      );

      expect(
        bugCondition.isBugCondition(),
        isTrue,
        reason: 'Bug condition is satisfied for lockedIdle state',
      );

      final fixedCondition = BugCondition(
        dashboardState: 'lockedIdle',
        hasWeeklyDayStrip: true,
        hasTodaysRegimenGreeting: true,
        hasEditButtonInHeader: true,
      );

      expect(
        fixedCondition.isBugCondition(),
        isFalse,
        reason: 'Bug condition is NOT satisfied after fix',
      );
    });
  });
}

// Helper to get today's date string
String _todayString() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

// Mock state for testing
class _MockMediTrackState extends MediTrackState {
  @override
  final MedicationConfig? medicationConfig;

  @override
  final int stockLevel;

  @override
  final DeviceConnection deviceConnection;

  static Future<_MockMediTrackState> create({
    required MedicationConfig? medicationConfig,
    required int stockLevel,
    required DeviceConnection deviceConnection,
  }) async {
    final localStorageService = await _MockLocalStorageService.create();
    return _MockMediTrackState._(
      medicationConfig: medicationConfig,
      stockLevel: stockLevel,
      deviceConnection: deviceConnection,
      localStorageService: localStorageService,
    );
  }

  _MockMediTrackState._({
    required this.medicationConfig,
    required this.stockLevel,
    required this.deviceConnection,
    required LocalStorageService localStorageService,
  }) : super(
          firebaseService: _MockFirebaseService(),
          localStorageService: localStorageService,
        );

  @override
  double get daysOfSupplyRemaining {
    if (medicationConfig == null || medicationConfig!.dosesPerDay == 0) {
      return 0;
    }
    return stockLevel / medicationConfig!.dosesPerDay;
  }
}

// Mock services (minimal implementations for testing)
class _MockFirebaseService implements FirebaseServiceBase {
  @override
  Stream<MedicationConfig?> watchMedicationConfig() => Stream.value(null);

  @override
  Stream<int> watchStockLevel() => Stream.value(0);

  @override
  Stream<TrayStateModel> watchTrayState() =>
      Stream.value(TrayStateModel.idle());

  @override
  Stream<DeviceConnection> watchDeviceConnection() =>
      Stream.value(DeviceConnection.unknown());

  @override
  Stream<List<HistoryEvent>> watchHistory() => Stream.value([]);

  @override
  Future<void> saveMedicationConfig(MedicationConfig config) async {}

  @override
  Future<void> updateStockLevel(int level) async {}

  @override
  Future<void> triggerDispense({required String slot}) async {}

  @override
  Future<void> clearDispenseTrigger() async {}

  @override
  Future<void> addHistoryEvent(HistoryEvent event) async {}

  @override
  Future<void> debugSimulateDispensing(String slot) async {}

  @override
  Future<void> debugSimulateTaken(String slot, String medName) async {}

  @override
  Future<void> debugSimulateMissed(
      String slot, String medName, String reason) async {}

  @override
  Future<void> debugSetDeviceOnline() async {}

  @override
  Future<void> debugSetDeviceOffline() async {}

  @override
  Future<void> debugClearAll() async {}
}

class _MockLocalStorageService extends LocalStorageService {
  static Future<_MockLocalStorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return _MockLocalStorageService._(prefs);
  }

  _MockLocalStorageService._(SharedPreferences prefs) : super(prefs);

  @override
  DateTime? getLastAcknowledgedResolvedAt() => null;

  @override
  Future<void> setLastAcknowledgedResolvedAt(DateTime dt) async {}
}

// Bug condition model
class BugCondition {
  final String dashboardState;
  final bool hasWeeklyDayStrip;
  final bool hasTodaysRegimenGreeting;
  final bool hasEditButtonInHeader;

  BugCondition({
    required this.dashboardState,
    required this.hasWeeklyDayStrip,
    required this.hasTodaysRegimenGreeting,
    required this.hasEditButtonInHeader,
  });

  bool isBugCondition() {
    return (dashboardState == 'lockedIdle' || dashboardState == 'unlockedIdle') &&
        !hasWeeklyDayStrip &&
        !hasTodaysRegimenGreeting &&
        !hasEditButtonInHeader;
  }
}
