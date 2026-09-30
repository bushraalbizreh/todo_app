import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/localization/localization.dart';
import '../core/theme/app_theme.dart';
import '../data/todo_repository.dart';
import '../features/todo/presentation/todo_cubit.dart';
import '../models/todo_models.dart';
import '../widgets/app_widgets.dart';
import '../widgets/editor_sheets.dart';
import '../widgets/task_card.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({
    super.key,
    required this.repository,
    required this.onDestinationSelected,
    this.onOpenSettings,
  });

  final TodoRepository repository;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback? onOpenSettings;

  void _openSearch(BuildContext context) {
    final items = repository.todaysTasks
        .map((task) => task.title)
        .toList(growable: false);
    showSearch<String?>(
      context: context,
      delegate: AppSearchDelegate(
        items: items,
        hintText: context.l10n.searchTasks,
        onItemSelected: (title) {
          TodoTask? task;
          for (final item in repository.todaysTasks) {
            if (item.title == title) {
              task = item;
              break;
            }
          }
          if (task != null) {
            showTaskEditorSheet(
              context: context,
              repository: repository,
              listId: task.listId,
              task: task,
            );
          }
        },
      ),
    );
  }

  Future<void> _refresh(BuildContext context) =>
      context.read<TodoCubit>().refresh();

  void _handleComplete(BuildContext context, TodoTask task) {
    context.read<TodoCubit>().toggleTask(task.id);
  }

  void _handleDelete(BuildContext context, TodoTask task) {
    context.read<TodoCubit>().removeTask(task.id);
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    return _WriteErrorReporter(
      repository: repository,
      child: Scaffold(
        extendBody: true,
        backgroundColor: palette.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: <Widget>[
              AppTopBar(
                title: context.l10n.today,
                maxWidth: 448,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                actions: <Widget>[
                  AppIconButton(
                    icon: Icons.search_rounded,
                    tooltip: context.l10n.searchTasks,
                    onPressed: () => _openSearch(context),
                    size: 20,
                  ),
                  const SizedBox(width: 2),
                  BlocBuilder<TodoCubit, TodoState>(
                    builder: (context, state) {
                      final todaysCount = state.repository.todaysTasks.length;
                      if (todaysCount == 0) return const SizedBox.shrink();
                      return Row(
                        children: [
                          TextButton(
                            onPressed: () => _clearTodays(context),
                            style: TextButton.styleFrom(
                              minimumSize: const Size(0, 36),
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              context.l10n.clearTodays,
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: palette.coral,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          AppIconButton(
                            icon: Icons.more_vert_rounded,
                            tooltip: context.l10n.moreOptions,
                            onPressed: () => onOpenSettings?.call(),
                            size: 21,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 448),
                    child: RefreshIndicator(
                      color: palette.coral,
                      backgroundColor: palette.surface,
                      onRefresh: () => _refresh(context),
                      child: BlocBuilder<TodoCubit, TodoState>(
                        builder: (context, state) {
                          final todaysTasks = state.repository.todaysTasks;
                          return CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            slivers: <Widget>[
                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  10,
                                  16,
                                  132,
                                ),
                                sliver: SliverList(
                                  delegate: SliverChildListDelegate(<Widget>[
                                    if (todaysTasks.isEmpty)
                                      _EmptyTodaysState()
                                    else
                                      ...todaysTasks.map(
                                        (task) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 10,
                                          ),
                                          child: TaskCard(
                                            key: ValueKey<String>(task.id),
                                            task: task,
                                            onTap: () => showTaskEditorSheet(
                                              context: context,
                                              repository: state.repository,
                                              listId: task.listId,
                                              task: task,
                                            ),
                                            onComplete: () => _handleComplete(context, task),
                                            onDelete: () => _handleDelete(context, task),
                                          ),
                                        ),
                                      ),
                                  ]),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: AppBottomNavigation(
          selectedIndex: 1,
          onSelected: onDestinationSelected,
          maxWidth: 448,
          accentColor: palette.coral,
        ),
      ),
    );
  }

  Future<void> _clearTodays(BuildContext context) async {
    final todaysTasks = repository.todaysTasks;
    if (todaysTasks.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.clearTodaysConfirmation(todaysTasks.length)),
        content: Text(context.l10n.clearTodaysConfirmationPermanent),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      for (final task in todaysTasks) {
        context.read<TodoCubit>().removeTask(task.id);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.todaysTasksCleared)),
        );
      }
    }
  }
}

/// Surfaces failed Todo writes while the user is on this screen.
class _WriteErrorReporter extends StatefulWidget {
  const _WriteErrorReporter({required this.repository, required this.child});

  final TodoRepository repository;
  final Widget child;

  @override
  State<_WriteErrorReporter> createState() => _WriteErrorReporterState();
}

class _WriteErrorReporterState extends State<_WriteErrorReporter> {
  Object? _lastError;

  @override
  void initState() {
    super.initState();
    _lastError = widget.repository.lastSyncError;
    widget.repository.addListener(_handleRepositoryChanged);
  }

  void _handleRepositoryChanged() {
    final error = widget.repository.lastSyncError;
    final becameFailing = error != null && _lastError == null;
    _lastError = error;
    if (!becameFailing || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.l10n.unexpectedError),
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: context.l10n.retry,
            onPressed: () => unawaited(widget.repository.sync()),
          ),
        ),
      );
  }

  @override
  void dispose() {
    widget.repository.removeListener(_handleRepositoryChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _EmptyTodaysState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: palette.coral.withAlpha(28),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.today_rounded, color: palette.coral, size: 28),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.nothingUrgentHere,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.noTasksForToday,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}