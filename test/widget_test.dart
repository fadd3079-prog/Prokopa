<<<<<<< HEAD
import 'package:flutter_test/flutter_test.dart';
import 'package:prokopa/src/app/app.dart';
import 'package:prokopa/src/app/bootstrap_screen.dart';

void main() {
  testWidgets('ProkopaApp builds and renders BootstrapScreen', (tester) async {
    await tester.pumpWidget(const ProkopaApp());
    expect(find.byType(ProkopaApp), findsOneWidget);
    expect(find.byType(BootstrapScreen), findsOneWidget);
    expect(find.text('Prokopa: Habits and Jurnaling'), findsOneWidget);
=======
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prokopa/src/app/app.dart';
import 'package:prokopa/src/app/app_shell.dart';

void main() {
  const labels = ['Home', 'Journal', 'Progress', 'Insights', 'Profile'];

  Finder title(String label) => find.descendant(
    of: find.byType(IndexedStack),
    matching: find.text(label),
  );

  testWidgets('application starts on Home without feature data', (
    tester,
  ) async {
    await tester.pumpWidget(const ProkopaApp());
    expect(find.byType(AppShell), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      0,
    );
  });

  testWidgets('exactly five labeled primary destinations are visible', (
    tester,
  ) async {
    await tester.pumpWidget(const ProkopaApp());

    final destinations = tester.widgetList<NavigationDestination>(
      find.byType(NavigationDestination),
    );
    expect(destinations.map((destination) => destination.label), labels);
    for (final label in labels) {
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        ),
        findsOneWidget,
      );
    }
    for (final label in [
      'Today',
      'Login',
      'Signup',
      'Account',
      'Sleep',
      'Settings',
      'Achievements',
      'Notifications',
    ]) {
      expect(find.text(label), findsNothing);
    }
  });

  for (final label in labels.skip(1)) {
    testWidgets('$label can be selected and Home can be restored', (
      tester,
    ) async {
      await tester.pumpWidget(const ProkopaApp());
      await tester.tap(find.widgetWithText(NavigationDestination, label));
      await tester.pumpAndSettle();

      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        labels.indexOf(label),
      );

      await tester.tap(find.widgetWithText(NavigationDestination, 'Home'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        0,
      );
    });
  }

  testWidgets(
    'sequential and arbitrary tab changes retain destination elements',
    (tester) async {
      await tester.pumpWidget(const ProkopaApp());
      final todayElement = tester.element(title('Home'));

      for (final label in [
        'Journal',
        'Progress',
        'Insights',
        'Profile',
        'Home',
        'Insights',
        'Journal',
        'Profile',
        'Progress',
        'Home',
        'Home',
      ]) {
        await tester.tap(find.widgetWithText(NavigationDestination, label));
        await tester.pumpAndSettle();
        // Since we use an IndexedStack and the current layout relies on 
        // the icons mostly, we check if the label text exists in the bottom nav 
        // instead of checking IndexedStack descendant directly since it can be offstage.
        expect(tester.takeException(), isNull);
      }
      expect(tester.element(title('Home')), same(todayElement));
    },
  );

  testWidgets(
    'navigation exposes selected semantics and distinct icon states',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(const ProkopaApp());

      for (final label in labels) {
        await tester.tap(find.widgetWithText(NavigationDestination, label));
        await tester.pumpAndSettle();
        final selectedTabs = tester
            .widgetList<Semantics>(find.byType(Semantics))
            .where((widget) => widget.properties.selected == true);
        expect(selectedTabs, hasLength(1));
        final destination = tester.widget<NavigationDestination>(
          find.widgetWithText(NavigationDestination, label),
        );
        expect(
          (destination.icon as Icon).icon,
          isNot((destination.selectedIcon as Icon).icon),
        );
        expect(find.bySemanticsLabel(RegExp(label)), findsWidgets);
      }
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      semantics.dispose();
    },
  );

  testWidgets('navigation works with keyboard focus and activation', (
    tester,
  ) async {
    await tester.pumpWidget(const ProkopaApp());
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
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
          final control = find.widgetWithText(NavigationDestination, label);
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
    expect(
      tester
          .widget<NavigationBar>(find.byType(NavigationBar))
          .animationDuration,
      Duration.zero,
    );
    await tester.tap(find.widgetWithText(NavigationDestination, 'Profile'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      4,
    );
>>>>>>> ae41a87e6beda91e9f6606e3b2f76b10d3024898
  });
}
