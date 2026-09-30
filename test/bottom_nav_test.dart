import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:to_do_with_fire_base/l10n/app_localizations.dart';
import 'package:to_do_with_fire_base/widgets/app_widgets.dart';

/// Independent UX coverage for the bottom navigation (item 7).
///
/// These tests review the ACTUAL widget against mobile UX rules — selected
/// state, 48dp tap targets, duplicate-free semantics, localization and
/// RTL layout — rather than copying anything from design/.
void main() {
  Widget host({
    required int selectedIndex,
    Locale locale = const Locale('en'),
    ValueChanged<int>? onSelected,
  }) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        bottomNavigationBar: AppBottomNavigation(
          selectedIndex: selectedIndex,
          onSelected: onSelected ?? (_) {},
        ),
      ),
    );
  }

  testWidgets('exactly one destination is marked selected, and it follows '
      'the index', (tester) async {
    for (final entry in <MapEntry<int, String>>[
      const MapEntry<int, String>(0, 'Lists'),
      const MapEntry<int, String>(1, 'Today'),
      const MapEntry<int, String>(2, 'Completed Tasks'),
    ]) {
      await tester.pumpWidget(host(selectedIndex: entry.key));
      await tester.pumpAndSettle();

      final handle = tester.ensureSemantics();
      for (final label in const <String>['Lists', 'Today', 'Completed Tasks']) {
        final node = tester.getSemantics(find.text(label));
        expect(
          node.flagsCollection.isSelected == Tristate.isTrue,
          label == entry.value,
          reason: 'with selectedIndex=${entry.key} only "$entry.value" '
              'must announce selected=true',
        );
      }
      handle.dispose();
    }
  });

  testWidgets('every tap target is at least 48x48 logical pixels',
      (tester) async {
    await tester.pumpWidget(host(selectedIndex: 0));
    await tester.pumpAndSettle();

    final targets = find.byType(InkWell);
    expect(targets, findsNWidgets(3));
    for (var i = 0; i < targets.evaluate().length; i++) {
      final size = tester.getSize(targets.at(i));
      expect(size.width, greaterThanOrEqualTo(48.0),
          reason: 'item $i width must meet the 48dp guideline');
      expect(size.height, greaterThanOrEqualTo(48.0),
          reason: 'item $i height must meet the 48dp guideline');
    }
  });

  testWidgets('tapping a destination reports its index exactly once',
      (tester) async {
    final taps = <int>[];
    await tester.pumpWidget(
      host(selectedIndex: 0, onSelected: taps.add),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Completed Tasks'));
    await tester.pumpAndSettle();

    expect(taps, <int>[2], reason: 'one tap → one navigation action');
  });

  testWidgets('semantics expose a single un-duplicated label per item',
      (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpWidget(host(selectedIndex: 2));
      await tester.pumpAndSettle();

      for (final label in const <String>['Lists', 'Today', 'Completed Tasks']) {
        expect(
          find.bySemanticsLabel(label),
          findsOneWidget,
          reason: '"$label" must appear exactly once for screen readers',
        );
        final node = tester.getSemantics(find.text(label));
        expect(node.label, label,
            reason: 'the announced label must not repeat '
                '(e.g. "Completed Tasks\\nCompleted Tasks")');
        expect(node.flagsCollection.isButton, isTrue);
      }
    } finally {
      handle.dispose();
    }
  });

  testWidgets('labels are localized (Arabic renders Arabic text)',
      (tester) async {
    await tester.pumpWidget(host(selectedIndex: 0, locale: const Locale('ar')));
    await tester.pumpAndSettle();

    expect(find.text('القوائم'), findsOneWidget);
    expect(find.text('اليوم'), findsOneWidget);
    expect(find.text('المهام المكتملة'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'no layout errors in RTL');
  });

  testWidgets('RTL mirrors the item order without overflow', (tester) async {
    await tester.pumpWidget(
      host(selectedIndex: 0, locale: const Locale('en')),
    );
    await tester.pumpAndSettle();
    final ltrFirst = tester.getRect(find.text('Lists')).left;
    final ltrLast = tester.getRect(find.text('Completed Tasks')).left;

    await tester.pumpWidget(
      host(selectedIndex: 0, locale: const Locale('ar')),
    );
    await tester.pumpAndSettle();
    final rtlFirst = tester.getRect(find.text('القوائم')).left;
    final rtlLast = tester.getRect(find.text('المهام المكتملة')).left;

    expect(ltrFirst, lessThan(ltrLast),
        reason: 'LTR: Lists sits left of Completed Tasks');
    expect(rtlFirst, greaterThan(rtlLast),
        reason: 'RTL: القوائم must sit to the RIGHT of المهام المكتملة');
    expect(tester.takeException(), isNull);
  });
}