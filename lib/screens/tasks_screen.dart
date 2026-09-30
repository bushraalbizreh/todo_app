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

class TasksScreen extends StatelessWidget {
  const TasksScreen({
    super.key,
    required this.repository,
    required this.list,
    required this.onBack,
    required this.onDestinationSelected,
    this.onOpenSettings,
  });

  final TodoRepository repository;
  final TodoList list;
  final VoidCallback onBack;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback? onOpenSettings;

  void _openSearch(BuildContext context) {
    final items = repository
        .tasksForList(list.id, includeCompleted: true)
        .map((task) => task.title)
        .toList(growable: false);
    showSearch<String?>(
      context: context,
      delegate: AppSearchDelegate(
        items: items,
        hintText: context.l10n.searchTasks,
        onItemSelected: (title) {
          TodoTask? task;
          for (final item in repository.tasksForList(
            list.id,
            includeCompleted: true,
          )) {
            if (item.title == title) {
              task = item;
              break;
            }
          }
          if (task != null) {
            showTaskEditorSheet(
              context: context,
              repository: repository,
              listId: list.id,
              task: task,
            );
          }
        },
      ),
    );
  }

  void _openMore(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _TasksMoreSheet(
        onEditList: () {
          Navigator.of(sheetContext).pop();
          showListEditorSheet(
            context: context,
            repository: repository,
            list: list,
          );
        },
        onDeleteList: () {
          Navigator.of(sheetContext).pop();
          _confirmDeleteList(context);
        },
      ),
    );
  }

  Future<void> _confirmDeleteList(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.deleteListQuestion),
        content: Text(context.l10n.deleteListMessage(list.name)),
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
    if (shouldDelete == true) {
      repository.removeList(list.id);
      onBack();
    }
  }

  /// Pull-to-refresh only syncs with the remote store.
  ///
  /// It must NEVER open the Add Task editor: the refresh gesture and the
  /// Add action are completely independent (regression-tested in
  /// `test/pull_to_refresh_test.dart`).
  Future<void> _refresh(BuildContext context) =>
      context.read<TodoCubit>().refresh();

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
                title: list.name,
                subtitle: context.l10n.activeTaskCount(
                  repository
                      .tasksForList(list.id, includeCompleted: false)
                      .length,
                ),
                maxWidth: 448,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                leading: AppIconButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: context.l10n.backToLists,
                  onPressed: onBack,
                  size: 22,
                ),
                actions: <Widget>[
                  AppIconButton(
                    icon: Icons.search_rounded,
                    tooltip: context.l10n.searchTasks,
                    onPressed: () => _openSearch(context),
                    size: 20,
                  ),
                  const SizedBox(width: 2),
                  AppIconButton(
                    icon: Icons.more_vert_rounded,
                    tooltip: context.l10n.moreOptions,
                    onPressed: () => _openMore(context),
                    size: 21,
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
                          final currentList =
                              state.repository.listById(list.id) ?? list;
                          final allTasks = state.repository.tasksForList(
                            currentList.id,
                            includeCompleted: true,
                          );
                          final tasks = allTasks
                              .where((task) => !task.isCompleted)
                              .toList(growable: false);
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
                                    _TaskGestureHint(),
                                    const SizedBox(height: AppSpacing.sm),
                                    if (tasks.isEmpty)
                                      _EmptyTasksState(
                                        listName: currentList.name,
                                      )
                                    else
                                      ...tasks.map(
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
                                              listId: currentList.id,
                                              task: task,
                                            ),
                                            onComplete: () => context
                                                .read<TodoCubit>()
                                                .toggleTask(task.id),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: FloatingActionButton.extended(
            onPressed: () => showTaskEditorSheet(
              context: context,
              repository: repository,
              listId: list.id,
            ),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text(context.l10n.addTask),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        bottomNavigationBar: AppBottomNavigation(
          selectedIndex: 0,
          onSelected: onDestinationSelected,
          maxWidth: 448,
          accentColor: palette.coral,
        ),
      ),
    );
  }
}

/// Surfaces failed Todo writes while the user is on this screen.
///
/// By design the lists overview carries the persistent sync status and the
/// focus page has its own error banner; without this, a write that failed
/// here would stay invisible until the user navigated back. The message is
/// transient (SnackBar), localized and retryable, so it does not change the
/// screen's design.
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
    // An error that already existed before this screen opened is (or will
    // be) visible where it happened — only *new* failures are announced.
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

class _TaskGestureHint extends StatelessWidget {
  const _TaskGestureHint();

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    final style = Theme.of(context).textTheme.labelMedium?.copyWith(
      color: palette.slate,
      fontWeight: FontWeight.w700,
      letterSpacing: .35,
    );
    return Row(
      children: <Widget>[
        Expanded(
          child: _HintLabel(
            icon: Icons.arrow_downward_rounded,
            label: context.l10n.pullDownToRefresh,
            style: style,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _HintLabel(
            icon: Icons.swipe_rounded,
            label: context.l10n.swipeRightToComplete,
            style: style,
            alignEnd: true,
          ),
        ),
      ],
    );
  }
}

class _HintLabel extends StatelessWidget {
  const _HintLabel({
    required this.icon,
    required this.label,
    required this.style,
    this.alignEnd = false,
  });

  final IconData icon;
  final String label;
  final TextStyle? style;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignEnd
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 15, color: AppColors.of(context).muted),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
      ],
    );
  }
}

class _EmptyTasksState extends StatelessWidget {
  const _EmptyTasksState({required this.listName});

  final String listName;

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
              color: palette.rose.withAlpha(28),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, color: palette.rose, size: 28),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.nothingUrgentHere,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.addTaskToList(listName),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _TasksMoreSheet extends StatelessWidget {
  const _TasksMoreSheet({
    required this.onEditList,
    required this.onDeleteList,
  });

  final VoidCallback onEditList;
  final VoidCallback onDeleteList;

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    return AppSheetSurface(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(context.l10n.editList),
            onTap: onEditList,
          ),
          ListTile(
            leading: Icon(Icons.delete_outline_rounded, color: error),
            title: Text(
              context.l10n.deleteList,
              style: TextStyle(color: error),
            ),
            onTap: onDeleteList,
          ),
        ],
      ),
    );
  }
}
