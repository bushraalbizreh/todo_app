import 'package:flutter/material.dart';

import '../core/localization/localization.dart';
import '../core/theme/app_theme.dart';
import '../models/todo_models.dart';

class TaskCard extends StatefulWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onComplete,
    this.onUncomplete,
    this.onDelete,
    this.isCompletedScreen = false,
  });

  final TodoTask task;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onUncomplete;
  final VoidCallback? onDelete;
  final bool isCompletedScreen;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  late double _offset;
  late final AnimationController _animationController;
  Animation<double>? _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _offset = widget.task.initialSwipeOffset;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(_handleAnimationTick);
  }

  @override
  void didUpdateWidget(covariant TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.id != widget.task.id) {
      _offset = widget.task.initialSwipeOffset;
    }
  }

  void _handleAnimationTick() {
    final animation = _offsetAnimation;
    if (!mounted || animation == null) return;
    setState(() => _offset = animation.value);
  }

  void _animateTo(double target, {bool complete = false, VoidCallback? onCompleteCallback}) {
    _animationController.stop();
    _offsetAnimation = Tween<double>(begin: _offset, end: target).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController
      ..reset()
      ..forward().whenComplete(() {
        if (complete && mounted) onCompleteCallback?.call();
      });
  }

  @override
  void dispose() {
    _animationController
      ..removeListener(_handleAnimationTick)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        // On completed screen: swipe left to delete, no complete action
        // On normal screen: swipe right to complete
        final isCompletedScreen = widget.isCompletedScreen;
        final canSwipeRight = !isCompletedScreen && widget.onComplete != null;
        final canSwipeLeft = isCompletedScreen && widget.onDelete != null;

        Widget background;
        if (isCompletedScreen) {
          background = Positioned.fill(child: _DeleteBackground(onDelete: widget.onDelete));
        } else {
          background = const Positioned.fill(child: _CompletionBackground());
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: Stack(
            children: <Widget>[
              background,
              GestureDetector(
                onTap: widget.onTap,
                onHorizontalDragUpdate: (details) {
                  if (!canSwipeRight && !canSwipeLeft) return;
                  _animationController.stop();
                  setState(() {
                    if (canSwipeRight) {
                      _offset = (_offset + details.delta.dx).clamp(0, width);
                    } else {
                      _offset = (_offset + details.delta.dx).clamp(-width, 0);
                    }
                  });
                },
                onHorizontalDragEnd: (_) {
                  if (canSwipeRight) {
                    if (_offset >= width * .34) {
                      _animateTo(width, complete: true, onCompleteCallback: widget.onComplete);
                    } else {
                      _animateTo(widget.task.initialSwipeOffset);
                    }
                  } else if (canSwipeLeft) {
                    if (_offset <= -width * .34) {
                      _animateTo(-width, complete: true, onCompleteCallback: widget.onDelete);
                    } else {
                      _animateTo(widget.task.initialSwipeOffset);
                    }
                  }
                },
                child: Transform.translate(
                  offset: Offset(_offset, 0),
                  child: _TaskSurface(
                    task: widget.task,
                    width: width,
                    isCompletedScreen: isCompletedScreen,
                    onUncomplete: widget.onUncomplete,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CompletionBackground extends StatelessWidget {
  const _CompletionBackground();

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    return Container(
      color: palette.emeraldSoft,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: AppSpacing.md),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF059669),
            size: 22,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            context.l10n.complete,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: const Color(0xFF047857),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground({this.onDelete});

  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.errorContainer,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppSpacing.md),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            context.l10n.delete,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onErrorContainer,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Icon(
            Icons.delete_rounded,
            color: Theme.of(context).colorScheme.onErrorContainer,
            size: 22,
          ),
        ],
      ),
    );
  }
}

class _TaskSurface extends StatelessWidget {
  const _TaskSurface({
    required this.task,
    required this.width,
    this.isCompletedScreen = false,
    this.onUncomplete,
  });

  final TodoTask task;
  final double width;
  final bool isCompletedScreen;
  final VoidCallback? onUncomplete;

  @override
  Widget build(BuildContext context) {
    final visual = TaskVisualStyle.of(task.tone);
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      width: width,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: visual.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: const Color(0x14000000)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          _PriorityDot(color: visual.bullet),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              task.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: visual.foreground,
                fontSize: 15,
                fontWeight: task.isDimmed ? FontWeight.w500 : FontWeight.w700,
                decoration: task.isDimmed
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                decorationColor: visual.foreground.withAlpha(150),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          if (task.dueLabel == 'Priority 1')
            _PriorityBadge(label: task.dueLabel, color: visual.foreground)
          else if (task.trailingIcon != null)
            Icon(
              task.trailingIcon,
              size: 18,
              color: visual.foreground.withAlpha(210),
            )
          else if (task.dueLabel.isNotEmpty)
            Text(
              task.dueLabel,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: visual.foreground.withAlpha(220),
                fontWeight: task.priority == TaskPriority.urgent
                    ? FontWeight.w800
                    : FontWeight.w700,
              ),
            ),
          const SizedBox(width: AppSpacing.sm),
          if (isCompletedScreen)
            _UncompleteCheckbox(
              onTap: onUncomplete,
              foregroundColor: visual.foreground,
            ),
        ],
      ),
    );
  }
}

class _UncompleteCheckbox extends StatelessWidget {
  const _UncompleteCheckbox({
    required this.onTap,
    required this.foregroundColor,
  });

  final VoidCallback? onTap;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border.all(color: foregroundColor, width: 2),
          borderRadius: BorderRadius.circular(AppRadii.sm),
          color: Colors.transparent,
        ),
        child: Icon(
          Icons.check_rounded,
          size: 16,
          color: foregroundColor,
        ),
      ),
    );
  }
}

class _PriorityDot extends StatelessWidget {
  const _PriorityDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(color: color.withAlpha(55), blurRadius: 0, spreadRadius: 4),
        ],
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0x33000000),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: .7,
        ),
      ),
    );
  }
}
