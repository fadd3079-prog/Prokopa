import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/database/app_database.dart';
import 'package:habitflow/core/providers/core_providers.dart';
import 'package:habitflow/main.dart';

void main() {
  testWidgets('HabitFlow app smoke test - renders splash and transitions to dashboard', (
    WidgetTester tester,
  ) async {
    final testDb = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(testDb),
        ],
        child: const HabitFlowApp(),
      ),
    );

    // Verify HabitFlow title is displayed on splash screen
    expect(find.text('HabitFlow'), findsOneWidget);
    expect(find.text('Build better habits, every day'), findsOneWidget);

    // Fast-forward past the 2-second splash timer
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 100));

    // Verify Dashboard navigation
    expect(find.text("Today's Habits"), findsOneWidget);

    await testDb.close();
  });
}
