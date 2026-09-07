import 'package:flutter_test/flutter_test.dart';
import 'package:prokopa/src/app/app.dart';
import 'package:prokopa/src/app/bootstrap_screen.dart';

void main() {
  testWidgets('ProkopaApp builds and renders BootstrapScreen', (tester) async {
    await tester.pumpWidget(const ProkopaApp());
    expect(find.byType(ProkopaApp), findsOneWidget);
    expect(find.byType(BootstrapScreen), findsOneWidget);
    expect(find.text('Prokopa: Habits and Jurnaling'), findsOneWidget);
  });
}
