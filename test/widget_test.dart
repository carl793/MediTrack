import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/main.dart';

void main() {
  testWidgets('MediTrack app launches', (WidgetTester tester) async {
    await tester.pumpWidget(const MediTrackApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
