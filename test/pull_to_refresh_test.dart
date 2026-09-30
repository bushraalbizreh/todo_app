import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:to_do_with_fire_base/core/theme/app_theme.dart';
import 'package:to_do_with_fire_base/data/todo_repository.dart';
import 'package:to_do_with_fire_base/features/todo/presentation/todo_cubit.dart';
import 'package:to_do_with_fire_base/l10n/app_localizations.dart';
import 'package:to_do_with_fire_base/main.dart';
import 'package:to_do_with_fire_base/screens/lists_overview_screen.dart';
import 'package:to_do_with_fire_base/widgets/editor_sheets.dart';
import 'package:to_do_with_fire_base/screens/tasks_screen.dart';
import 'package:to_do_with_fire_base/widgets/list_overview_widgets.dart';

/// Regression tests for the pull-to-refresh / Add Todo interaction.
///
/// Contract under test:
///  * Pulling down on the scrollable content triggers ONLY refresh/sync and
///    must never open the Add Todo editor.
///  * Pressing the Add button opens the Add Todo editor and does NOT
///    trigger a refresh.
///  * A refresh followed by its completion must not leave an editor behind.
///  * Tapping Add while a refresh is in flight opens exactly one editor.
///
/// The harness uses the real screens, the real `RefreshIndicator`, the real
/// gesture pipeline and the real repository — only the refresh callback is
/// intercepted (counted / held open) so the assertions can observe it.
class _RecordingTodoCubit extends TodoCubit {
  _RecordingTodoCubit(super.repository);

  /// How many times pull-to-refresh asked for a sync.
  int refreshCount = 0;

  /// When set, the next refresh stays in flight until this completes,
  /// so "Add while a refresh is in progress" is a real point in time.
  Completer<void>? refreshGate;

  @override
  Future<void> refresh() {
    refreshCount += 1;
    final gate = refreshGate;
    if (gate != null) return gate.future;
    return super.refresh();
  }
}

Widget _app(Widget home) {
  return MaterialApp(
    theme: AppTheme.light,
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: home,
  );
}

Future<_RecordingTodoCubit> _pumpTasksScreen(WidgetTester tester) async {
  final repository = TodoRepository.seeded();
  final cubit = _RecordingTodoCubit(repository);
  addTearDown(cubit.close);
  await tester.pumpWidget(
    _app(
      BlocProvider<TodoCubit>.value(
        value: cubit,
        child: TasksScreen(
          repository: repository,
          list: repository.listById('personal')!,
          onBack: () {},
          onDestinationSelected: (_) {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return cubit;
}

Future<_RecordingTodoCubit> _pumpOverview(WidgetTester tester) async {
  final repository = TodoRepository.seeded();
  final cubit = _RecordingTodoCubit(repository);
  addTearDown(cubit.close);
  await tester.pumpWidget(
    _app(
      BlocProvider<TodoCubit>.value(
        value: cubit,
        child: ListsOverviewScreen(
          repository: repository,
          onOpenList: (_) {},
          onDestinationSelected: (_) {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return cubit;
}

void main() {
  group('pull to refresh vs Add Todo', () {
    testWidgets(
      'pull to refresh does NOT open the Add Todo editor (tasks screen)',
      (WidgetTester tester) async {
        final cubit = await _pumpTasksScreen(tester);
        expect(find.byType(TextField), findsNothing);

        await tester.fling(
          find.byType(CustomScrollView).first,
          const Offset(0, 320),
          1000,
        );
        await tester.pumpAndSettle();

        // The gesture must have refreshed (synced)…
        expect(
          cubit.refreshCount,
          greaterThanOrEqualTo(1),
          reason: 'pulling down must trigger a refresh/sync',
        );
        // …and must not have created or opened any editor.
        expect(
          find.byType(TextField),
          findsNothing,
          reason: 'pull-to-refresh must never open the Add Todo editor',
        );
        expect(find.text('Add task'), findsNothing);
        expect(find.byType(TaskEditorSheet), findsNothing);
        expect(find.byType(ListEditorSheet), findsNothing);
      },
    );

    testWidgets(
      'pull to refresh does NOT open the Add Todo editor (lists overview)',
      (WidgetTester tester) async {
        final cubit = await _pumpOverview(tester);
        expect(find.byType(TextField), findsNothing);

        await tester.fling(
          find.byType(CustomScrollView).first,
          const Offset(0, 320),
          1000,
        );
        await tester.pumpAndSettle();

        expect(
          cubit.refreshCount,
          greaterThanOrEqualTo(1),
          reason: 'pulling down must trigger a refresh/sync',
        );
        expect(
          find.byType(TextField),
          findsNothing,
          reason: 'pull-to-refresh must never open a list editor',
        );
        expect(find.text('Create list'), findsNothing);
      },
    );

    testWidgets(
      'tapping Add opens the Add Todo editor and does NOT refresh',
      (WidgetTester tester) async {
        final cubit = await _pumpTasksScreen(tester);

        await tester.tap(find.text('Add Task'));
        await tester.pumpAndSettle();

        expect(
          find.byType(TaskEditorSheet),
          findsOneWidget,
          reason: 'the Add button must open exactly one Add Todo editor',
        );
        expect(find.widgetWithText(FilledButton, 'Add task'), findsOneWidget);
        expect(
          cubit.refreshCount,
          0,
          reason: 'the Add button must not trigger a refresh',
        );
      },
    );

    testWidgets(
      'a completed refresh does not cause Add Todo to appear',
      (WidgetTester tester) async {
        final cubit = await _pumpTasksScreen(tester);

        await tester.fling(
          find.byType(CustomScrollView).first,
          const Offset(0, 320),
          1000,
        );
        await tester.pumpAndSettle();

        expect(cubit.refreshCount, greaterThanOrEqualTo(1));
        expect(find.byType(TextField), findsNothing);

        // Add still behaves normally after the refresh finished.
        await tester.tap(find.text('Add Task'));
        await tester.pumpAndSettle();
        expect(find.byType(TaskEditorSheet), findsOneWidget);
        expect(cubit.refreshCount, greaterThanOrEqualTo(1));
      },
    );

    testWidgets(
      'tapping Add while a refresh is in progress opens exactly one editor',
      (WidgetTester tester) async {
        final cubit = await _pumpTasksScreen(tester);
        cubit.refreshGate = Completer<void>();

        await tester.fling(
          find.byType(CustomScrollView).first,
          const Offset(0, 320),
          1000,
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(cubit.refreshCount, 1, reason: 'the refresh must be in flight');

        await tester.tap(find.text('Add Task'));
        await tester.pump();

        // Exactly one editor, exactly one screen — no duplicate navigation.
        expect(find.byType(TaskEditorSheet), findsOneWidget);
        expect(find.byType(TasksScreen), findsOneWidget);

        cubit.refreshGate!.complete();
        await tester.pumpAndSettle();

        // After the refresh completes there is still exactly one editor and
        // no second refresh or navigation was triggered by the tap.
        expect(find.byType(TaskEditorSheet), findsOneWidget);
        expect(find.byType(TasksScreen), findsOneWidget);
        expect(cubit.refreshCount, 1);
      },
    );

    testWidgets(
      'end-to-end (full app): pull refreshes only, Add opens the editor',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();
        await tester.tap(find.byType(ListOverviewCard).first);
        await tester.pumpAndSettle();

        // Pull down: refresh only — no Add Todo anywhere.
        await tester.fling(
          find.byType(CustomScrollView).first,
          const Offset(0, 320),
          1000,
        );
        await tester.pumpAndSettle();
        expect(
          find.byType(TextField),
          findsNothing,
          reason: 'pull-to-refresh must not open Add Todo',
        );
        expect(find.text('Add task'), findsNothing);

        // Add: opens the editor — and only the editor.
        await tester.tap(find.text('Add Task'));
        await tester.pumpAndSettle();
        expect(
          find.byType(TaskEditorSheet),
          findsOneWidget,
          reason: 'tap Add must open Add Todo',
        );
        expect(find.widgetWithText(FilledButton, 'Add task'), findsOneWidget);
        expect(find.byType(TasksScreen), findsOneWidget);
      },
    );
  });
}
