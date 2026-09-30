import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/localization/localization.dart';
import '../core/theme/app_theme.dart';
import '../data/todo_repository.dart';
import '../features/todo/presentation/todo_cubit.dart';
import '../widgets/app_widgets.dart';
import '../widgets/editor_sheets.dart';
import '../widgets/list_overview_widgets.dart';

class ListsOverviewScreen extends StatelessWidget {
  const ListsOverviewScreen({
    super.key,
    required this.repository,
    required this.onOpenList,
    required this.onDestinationSelected,
    this.onOpenSettings,
  });

  final TodoRepository repository;
  final ValueChanged<String> onOpenList;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback? onOpenSettings;

  void _openSearch(BuildContext context) {
    final items = repository.lists.map((list) => list.name).toList();
    showSearch<String?>(
      context: context,
      delegate: AppSearchDelegate(
        items: items,
        hintText: context.l10n.searchLists,
        onItemSelected: (name) {
          final list = repository.listByName(name);
          if (list != null) onOpenList(list.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    return Scaffold(
      extendBody: true,
      backgroundColor: palette.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            AppTopBar(
              title: context.l10n.tasks,
              maxWidth: 384,
              actions: <Widget>[
                AppIconButton(
                  icon: Icons.search_rounded,
                  tooltip: context.l10n.search,
                  onPressed: () => _openSearch(context),
                  size: 21,
                ),
                const SizedBox(width: 2),
                AppIconButton(
                  icon: Icons.settings_outlined,
                  tooltip: context.l10n.settings,
                  onPressed: onOpenSettings,
                  size: 22,
                ),
              ],
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 384),
                  child: RefreshIndicator(
                    color: palette.rose,
                    backgroundColor: palette.surface,
                    // Pulling down only syncs; it never opens the list
                    // editor (regression-tested in
                    // test/pull_to_refresh_test.dart).
                    onRefresh: () => context.read<TodoCubit>().refresh(),
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      slivers: <Widget>[
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 128),
                          sliver: BlocBuilder<TodoCubit, TodoState>(
                            builder: (context, state) {
                              final lists = state.repository.lists;
                              return SliverList(
                                delegate: SliverChildListDelegate(<Widget>[
                                  ListsHeader(repository: state.repository),
                                  const SizedBox(height: AppSpacing.md),
                                  VelocityDashboard(
                                    activeTasks:
                                        state.repository.activeTaskCount,
                                    completedTasks:
                                        state.repository.completedToday,
                                    streak: state.repository.focusStreak,
                                    totalTasks: state.repository.allTasks.length,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  const GestureHint(),
                                  const SizedBox(height: AppSpacing.md),
                                  if (state.status == TodoStatus.loading)
                                    const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(AppSpacing.md),
                                        child: SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.4,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ...lists.map(
                                    (list) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: AppSpacing.sm,
                                      ),
                                      child: ListOverviewCard(
                                        list: list,
                                        repository: state.repository,
                                        onTap: () => onOpenList(list.id),
                                      ),
                                    ),
                                  ),
                                  if (lists.isEmpty && !state.isLoading)
                                    const _EmptyListsState(),
                                ]),
                              );
                            },
                          ),
                        ),
                      ],
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
          backgroundColor: palette.rose,
          onPressed: () =>
              showListEditorSheet(context: context, repository: repository),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: Text(context.l10n.newList),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: 0,
        onSelected: onDestinationSelected,
        maxWidth: 384,
        accentColor: palette.rose,
      ),
    );
  }
}

class _EmptyListsState extends StatelessWidget {
  const _EmptyListsState();

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: <Widget>[
          Icon(Icons.playlist_add_rounded, size: 42, color: palette.muted),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.createYourFirstList,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.keepEveryPart,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
