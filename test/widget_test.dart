import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/main.dart';

void main() {
  testWidgets('HabitFlow app smoke test - renders splash screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: HabitFlowApp()));

    // Verify HabitFlow title is displayed on splash screen
    expect(find.text('HabitFlow'), findsOneWidget);
    expect(find.text('Build better habits, every day'), findsOneWidget);
  });
}
