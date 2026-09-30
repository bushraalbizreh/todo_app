import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:to_do_with_fire_base/core/theme/app_theme.dart';
import 'package:to_do_with_fire_base/data/todo_repository.dart';
import 'package:to_do_with_fire_base/features/todo/presentation/todo_cubit.dart';
import 'package:to_do_with_fire_base/l10n/app_localizations.dart';
import 'package:to_do_with_fire_base/main.dart';
import 'package:to_do_with_fire_base/models/todo_models.dart';
import 'package:to_do_with_fire_base/screens/lists_overview_screen.dart';
import 'package:to_do_with_fire_base/widgets/list_overview_widgets.dart';
import 'package:to_do_with_fire_base/widgets/task_card.dart';

void main() {
  testWidgets('renders the lists overview', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('My Lists'), findsOneWidget);
    expect(find.text('Personal'), findsOneWidget);
    expect(find.text('New List'), findsOneWidget);
    expect(find.text('VELOCITY DASHBOARD'), findsOneWidget);
  });

  testWidgets('opens a list and its task heatmap', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byType(ListOverviewCard).first);
    await tester.pumpAndSettle();

    expect(find.text('8 active tasks'), findsOneWidget);
    expect(find.text('Submit Q3 tax report & invoices'), findsOneWidget);
    expect(find.text('Add Task'), findsOneWidget);
  });

  testWidgets('adds a task from the floating action button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byType(ListOverviewCard).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Task'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.first, 'Buy fresh flowers');
    await tester.tap(find.widgetWithText(FilledButton, 'Add task'));
    await tester.pumpAndSettle();

    expect(find.text('9 active tasks'), findsOneWidget);
    final taskFinder = find.text('Buy fresh flowers');
    if (taskFinder.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        taskFinder,
        500,
        scrollable: find.byType(Scrollable).last,
      );
    }
    expect(taskFinder, findsOneWidget);
  });

  testWidgets('creates a list from the overview action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('New List'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.first, 'Home projects');
    await tester.tap(find.widgetWithText(FilledButton, 'Create list'));
    await tester.pumpAndSettle();

    final listFinder = find.text('Home projects');
    if (listFinder.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        listFinder,
        500,
        scrollable: find.byType(Scrollable).last,
      );
    }
    expect(listFinder, findsOneWidget);
  });

  testWidgets('swipes a task to complete it', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byType(ListOverviewCard).first);
    await tester.pumpAndSettle();

    await tester.drag(find.byType(TaskCard).first, const Offset(260, 0));
    await tester.pumpAndSettle();

    expect(find.text('Submit Q3 tax report & invoices'), findsNothing);
    expect(find.text('7 active tasks'), findsOneWidget);
  });

  testWidgets('deletes a task from its editor', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byType(ListOverviewCard).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Submit Q3 tax report & invoices'));
    await tester.pumpAndSettle();
    expect(find.text('Delete task'), findsOneWidget);

    await tester.tap(find.text('Delete task'));
    await tester.pumpAndSettle();

    expect(find.text('Submit Q3 tax report & invoices'), findsNothing);
    expect(find.text('7 active tasks'), findsOneWidget);
  });

  testWidgets('clear completed only exists in Completed Tasks screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    // Navigate to Completed Tasks tab (index 2)
    await tester.tap(find.text('Completed Tasks'));
    await tester.pumpAndSettle();

    // The Clear Completed button should be visible in the AppBar
    await tester.tap(find.text('Clear Completed'));
    await tester.pumpAndSettle();

    // Confirm the dialog - find the Delete button in the AlertDialog
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    // Verify the completed tasks were cleared - the empty state should show
    expect(find.text('No completed tasks yet.'), findsOneWidget);
    
    // The snackbar should show "Completed tasks cleared"
    expect(find.text('Completed tasks cleared.'), findsOneWidget);
  });

  testWidgets('shows the empty state when every list is removed', (
    WidgetTester tester,
  ) async {
    final repository = TodoRepository.seeded();
    for (final list in List<TodoList>.of(repository.lists)) {
      repository.removeList(list.id);
    }

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: BlocProvider<TodoCubit>(
          create: (_) => TodoCubit(repository),
          child: ListsOverviewScreen(
            repository: repository,
            onOpenList: (id) {},
            onDestinationSelected: (index) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Create your first list'), findsOneWidget);
    expect(find.text('My Lists'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits a narrow mobile viewport', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());
    expect(tester.takeException(), isNull);

    final firstCard = find.byType(ListOverviewCard).first;
    await tester.ensureVisible(firstCard);
    await tester.tap(firstCard);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Add Task'), findsOneWidget);
  });
}
