import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prokopa/src/app/app.dart';
import 'package:prokopa/src/app/app_shell.dart';

void main() {
  const labels = ['Dashboard', 'Habits', 'Journal', 'Stats'];

  Finder navigation(String label) => find.byKey(ValueKey('app-nav-$label'));

  testWidgets('application starts on Dashboard without feature data', (
    tester,
  ) async {
    await tester.pumpWidget(const ProkopaApp());
    expect(find.byType(AppShell), findsOneWidget);
    final selected = tester
        .widgetList<Semantics>(find.byType(Semantics))
        .where((widget) => widget.properties.selected == true);
    expect(selected, hasLength(1));
    expect(selected.single.key, const ValueKey('app-nav-Dashboard'));
  });

  testWidgets('exactly four labeled primary destinations are visible', (
    tester,
  ) async {
    await tester.pumpWidget(const ProkopaApp());

    for (final label in labels) {
      expect(navigation(label), findsOneWidget);
    }
    for (final label in [
      'Profile',
      'Settings',
      'Insights',
      'Login',
      'Signup',
      'Account',
      'Sleep',
    ]) {
      expect(navigation(label), findsNothing);
    }
  });

  for (final label in labels.skip(1)) {
    testWidgets('$label can be selected and Dashboard can be restored', (
      tester,
    ) async {
      await tester.pumpWidget(const ProkopaApp());
      await tester.tap(navigation(label));
      await tester.pumpAndSettle();
      expect(
        tester.widget<Semantics>(navigation(label)).properties.selected,
        isTrue,
      );

      await tester.tap(navigation('Dashboard'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<Semantics>(navigation('Dashboard')).properties.selected,
        isTrue,
      );
    });
  }

  testWidgets('destination elements are retained after tab changes', (
    tester,
  ) async {
    await tester.pumpWidget(const ProkopaApp());
    final dashboardElement = tester.element(find.text('Dashboard').first);

    for (final label in [
      'Habits',
      'Journal',
      'Stats',
      'Dashboard',
      'Journal',
      'Dashboard',
    ]) {
      await tester.tap(navigation(label));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    expect(
      tester.element(find.text('Dashboard').first),
      same(dashboardElement),
    );
  });

  testWidgets('navigation exposes selected semantics and tap targets', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(const ProkopaApp());

    for (final label in labels) {
      await tester.tap(navigation(label));
      await tester.pumpAndSettle();
      final selectedTabs = tester
          .widgetList<Semantics>(find.byType(Semantics))
          .where((widget) => widget.properties.selected == true);
      expect(selectedTabs, hasLength(1));
      expect(selectedTabs.single.key, ValueKey('app-nav-$label'));
    }
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    semantics.dispose();
  });

  testWidgets('navigation works with keyboard focus and activation', (
    tester,
  ) async {
    await tester.pumpWidget(const ProkopaApp());
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(
      tester.widget<Semantics>(navigation('Habits')).properties.selected,
      isTrue,
    );
  });

  for (final scale in [1.0, 2.0]) {
    testWidgets(
      'navigation fits a small Android viewport at text scale $scale',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(const ProkopaApp());

        for (final label in labels) {
          final control = navigation(label);
          final size = tester.getSize(control);
          expect(size.width, greaterThanOrEqualTo(48));
          expect(size.height, greaterThanOrEqualTo(48));
          await tester.tap(control);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      },
    );
  }

  testWidgets('system dark appearance and reduced motion are respected', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(const ProkopaApp());

    expect(
      Theme.of(tester.element(find.byType(AppShell))).brightness,
      Brightness.dark,
    );
    await tester.tap(navigation('Stats'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Semantics>(navigation('Stats')).properties.selected,
      isTrue,
    );
  });
}
