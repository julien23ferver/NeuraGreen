// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:eco_ai_tracker/data/models/ai_usage_log.dart';
import 'package:eco_ai_tracker/main.dart';

void main() {
  testWidgets('Dashboard displays title', (WidgetTester tester) async {
    // The test needs to open the Hive box before running the app.
    await Hive.initFlutter('test_');
    Hive.registerAdapter(AiUsageLogAdapter());
    await Hive.openBox<AiUsageLog>('ai_usage_logs');

    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: EcoAiTrackerApp()));

    // Verify that the title is displayed.
    expect(find.text('Eco-Impact\nAnalytics'), findsOneWidget);
  });
}