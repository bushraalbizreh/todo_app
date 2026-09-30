import 'dart:async';

import 'package:flutter/material.dart';

import '../core/localization/localization.dart';
import '../core/theme/app_theme.dart';
import '../data/todo_repository.dart';
import '../models/todo_models.dart';
import 'app_widgets.dart';

class ListsHeader extends StatelessWidget {
  const ListsHeader({super.key, required this.repository});

  final TodoRepository repository;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Text(
                context.l10n.overview.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: palette.rose,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.25,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: ListenableBuilder(
                listenable: repository,
                builder: (context, _) {
                  // The header reflects the real sync state: a failed write
                  // is reported (and retryable), guests/local mode say so,
                  // and "Synced just now" is only shown after a real
                  // successful remote operation — never before.
                  final hasError = repository.lastSyncError != null;
                  final Color dotColor;
                  final String label;
                  if (hasError) {
                    dotColor = palette.coral;
                    label = context.l10n.unexpectedError;
                  } else if (!repository.hasRemoteDataSource) {
                    dotColor = palette.slate;
                    label = context.l10n.localOnly;
                  } else if (repository.isSyncing ||
                      !repository.hasSyncedOnce) {
                    dotColor = palette.rose;
                    label = context.l10n.syncing;
                  } else {
                    dotColor = palette.rose;
                    label = context.l10n.syncedJustNow;
                  }
                  return Semantics(
                    button: hasError,
                    child: GestureDetector(
                      onTap: hasError
                          ? () => unawaited(repository.sync())
                          : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: dotColor,
                              shape: BoxShape.circle,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: dotColor.withAlpha(153),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: hasError ? palette.coral : null,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          context.l10n.myLists,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ],
    );
  }
}

class VelocityDashboard extends StatelessWidget {
  const VelocityDashboard({
    super.key,
    required this.activeTasks,
    required this.completedTasks,
    required this.streak,
    required this.totalTasks,
  });

  final int activeTasks;
  final int completedTasks;
  final int streak;
  final int totalTasks;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    final activeProgress = totalTasks == 0 ? 0.0 : activeTasks / totalTasks;
    final completedProgress = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;
    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadii.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              AppIconTile(
                icon: Icons.speed_rounded,
                backgroundColor: const Color(0xFFFFF1F2),
                foregroundColor: palette.rose,
                borderColor: const Color(0xFFFFE4E6),
                size: 24,
                iconSize: 16,
                radius: 6,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  context.l10n.velocityDashboard.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: palette.ink,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .35,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              AppPill(
                label: context.l10n.plusThisWeek,
                icon: Icons.trending_up_rounded,
                color: const Color(0xFF047857),
                backgroundColor: const Color(0xFFECFDF5),
                borderColor: const Color(0xFFA7F3D0),
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.sm,
              bottom: AppSpacing.sm,
            ),
            child: Divider(height: 1, color: palette.borderLight),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: _DashboardStat(
                  value: '$activeTasks',
                  label: context.l10n.activeTasks,
                  progress: activeProgress,
                  progressColor: palette.rose,
                ),
              ),
              const SizedBox(height: 52, child: VerticalDivider(width: 1)),
              Expanded(
                child: _DashboardStat(
                  value: '$completedTasks',
                  label: context.l10n.completed,
                  progress: completedProgress,
                  progressColor: const Color(0xFFF59E0B),
                  valueColor: const Color(0xFFD97706),
                  leadingPadding: AppSpacing.sm,
                ),
              ),
              const SizedBox(height: 52, child: VerticalDivider(width: 1)),
              Expanded(
                child: _DashboardStat(
                  value: '${streak}d',
                  label: context.l10n.dayStreak,
                  progress: 1,
                  progressColor: const Color(0xFF14B8A6),
                  valueColor: const Color(0xFF0F766E),
                  leadingPadding: AppSpacing.sm,
                  suffix: const Icon(
                    Icons.local_fire_department_rounded,
                    size: 17,
                    color: Color(0xFF0D9488),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardStat extends StatelessWidget {
  const _DashboardStat({
    required this.value,
    required this.label,
    required this.progress,
    required this.progressColor,
    this.valueColor,
    this.leadingPadding = AppSpacing.xs,
    this.suffix,
  });

  final String value;
  final String label;
  final double progress;
  final Color progressColor;
  final Color? valueColor;
  final double leadingPadding;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    return Padding(
      padding: EdgeInsets.only(left: leadingPadding, right: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: valueColor ?? palette.ink,
                      fontSize: 23,
                      letterSpacing: -.5,
                    ),
                  ),
                ),
              ),
              if (suffix != null) ...<Widget>[
                const SizedBox(width: 3),
                suffix!,
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: palette.slate,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          AppProgressBar(value: progress, color: progressColor),
        ],
      ),
    );
  }
}

class GestureHint extends StatelessWidget {
  const GestureHint({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.keyboard_arrow_down_rounded, size: 17, color: palette.muted),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            context.l10n.pullDownToRefresh,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: palette.slate,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class ListOverviewCard extends StatelessWidget {
  const ListOverviewCard({
    super.key,
    required this.list,
    required this.repository,
    required this.onTap,
  });

  final TodoList list;
  final TodoRepository repository;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final countLabel = list.countLabel == 'ideas'
        ? context.l10n.ideasUnit
        : context.l10n.tasksUnit;
    final totalTasks = repository.taskCountForList(list.id);
    final completedTasks = repository.completedTaskCountForList(list.id);
    final progress = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;
    return AppSurfaceCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      borderRadius: AppRadii.lg,
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.black.withAlpha(10),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
      child: Stack(
        children: <Widget>[
          Positioned(
            left: isRtl ? null : 0,
            right: isRtl ? 0 : null,
            top: 0,
            bottom: 0,
            child: Container(width: 4, color: list.accent),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AppIconTile(
                      icon: list.icon,
                      backgroundColor: list.softBackground,
                      foregroundColor: list.accent,
                      borderColor: list.softBorder,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    list.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: list.accent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              list.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: list.subtitleColor ?? palette.slate,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        AppPill(
                          value: '$totalTasks',
                          label: countLabel,
                          color: list.accent,
                          labelColor: palette.slate,
                          backgroundColor: palette.surfaceContainerLow,
                          borderColor: palette.border,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                        ),
                        if (totalTasks > 0) ...<Widget>[
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 80,
                            child: AppProgressBar(
                              value: progress,
                              color: list.accent,
                              height: 4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 14, bottom: 12),
                  child: Divider(height: 1, color: palette.borderLight),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: <Widget>[
                      Icon(list.previewIcon, size: 17, color: list.accent),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          list.previewTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: palette.ink),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: palette.muted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
