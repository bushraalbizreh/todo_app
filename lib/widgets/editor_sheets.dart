import 'package:flutter/material.dart';

import '../core/localization/localization.dart';
import '../core/theme/app_theme.dart';
import '../data/todo_repository.dart';
import '../models/todo_models.dart';
import 'app_widgets.dart';

Future<void> showListEditorSheet({
  required BuildContext context,
  required TodoRepository repository,
  TodoList? list,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ListEditorSheet(repository: repository, list: list),
  );
}

Future<void> showTaskEditorSheet({
  required BuildContext context,
  required TodoRepository repository,
  required String listId,
  TodoTask? task,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        TaskEditorSheet(repository: repository, listId: listId, task: task),
  );
}

class _SheetSurface extends StatelessWidget {
  const _SheetSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    return Material(
      color: palette.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _SheetBody extends StatelessWidget {
  const _SheetBody({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
      ),
      child: child,
    );
  }
}

class ListEditorSheet extends StatefulWidget {
  const ListEditorSheet({super.key, required this.repository, this.list});

  final TodoRepository repository;
  final TodoList? list;

  @override
  State<ListEditorSheet> createState() => _ListEditorSheetState();
}

class _ListEditorSheetState extends State<ListEditorSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _previewController;
  late int _selectedStyle;

  static const List<ListStyleOption> _styles = <ListStyleOption>[
    ListStyleOption(
      accent: Color(0xFFF43F5E),
      softBackground: Color(0xFFFFF1F2),
      softBorder: Color(0xFFFFE4E6),
      icon: Icons.person_outline_rounded,
      previewIcon: Icons.priority_high_rounded,
    ),
    ListStyleOption(
      accent: Color(0xFF6366F1),
      softBackground: Color(0xFFEEF2FF),
      softBorder: Color(0xFFE0E7FF),
      icon: Icons.work_outline_rounded,
      previewIcon: Icons.schedule_rounded,
    ),
    ListStyleOption(
      accent: Color(0xFF14B8A6),
      softBackground: Color(0xFFF0FDFA),
      softBorder: Color(0xFFCCFBF1),
      icon: Icons.shopping_bag_outlined,
      previewIcon: Icons.storefront_outlined,
    ),
    ListStyleOption(
      accent: Color(0xFFF59E0B),
      softBackground: Color(0xFFFFFBEB),
      softBorder: Color(0xFFFEF3C7),
      icon: Icons.menu_book_outlined,
      previewIcon: Icons.bookmark_outline_rounded,
    ),
    ListStyleOption(
      accent: Color(0xFF0EA5E9),
      softBackground: Color(0xFFF0F9FF),
      softBorder: Color(0xFFE0F2FE),
      icon: Icons.lightbulb_outline_rounded,
      previewIcon: Icons.explore_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    final list = widget.list;
    _nameController = TextEditingController(text: list?.name ?? '');
    _subtitleController = TextEditingController(text: list?.subtitle ?? '');
    _previewController = TextEditingController(
      text: list?.previewTitle ?? '',
    );
    _selectedStyle = list == null
        ? 0
        : _styles
              .indexWhere((style) => style.accent == list.accent)
              .clamp(0, _styles.length - 1)
              .toInt();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subtitleController.dispose();
    _previewController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.listNameRequired)),
      );
      return;
    }

    final style = _styles[_selectedStyle];
    final existing = widget.list;
    if (existing == null) {
      widget.repository.addList(
        TodoList(
          id: 'list-${DateTime.now().microsecondsSinceEpoch}',
          name: name,
          subtitle: _subtitleController.text.trim().isEmpty
              ? context.l10n.newListDescription
              : _subtitleController.text.trim(),
          countLabel: 'tasks',
          icon: style.icon,
          accent: style.accent,
          softBackground: style.softBackground,
          softBorder: style.softBorder,
          previewIcon: style.previewIcon,
          previewTitle: _previewController.text.trim().isEmpty
              ? context.l10n.addTaskPreview
              : _previewController.text.trim(),
        ),
      );
    } else {
      widget.repository.updateList(
        existing.copyWith(
          name: name,
          subtitle: _subtitleController.text.trim().isEmpty
              ? context.l10n.newListDescription
              : _subtitleController.text.trim(),
          icon: style.icon,
          accent: style.accent,
          softBackground: style.softBackground,
          softBorder: style.softBorder,
          previewIcon: style.previewIcon,
          previewTitle: _previewController.text.trim().isEmpty
              ? context.l10n.addTaskPreview
              : _previewController.text.trim(),
        ),
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetSurface(
      child: _SheetBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AppSheetHeader(
              title: widget.list == null
                  ? context.l10n.newListTitle
                  : context.l10n.editListTitle,
              subtitle: context.l10n.listPurpose,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(context.l10n.listName, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              autofocus: widget.list == null,
              decoration: InputDecoration(hintText: context.l10n.listNameHint),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              context.l10n.shortDescription,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _subtitleController,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: context.l10n.shortDescriptionHint,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(context.l10n.accent, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: List<Widget>.generate(_styles.length, (index) {
                final style = _styles[index];
                final selected = index == _selectedStyle;
                return Semantics(
                  button: true,
                  selected: selected,
                  label: context.l10n.chooseListColor,
                  child: InkWell(
                    onTap: () => setState(() => _selectedStyle = index),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? style.accent : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: style.softBackground,
                          shape: BoxShape.circle,
                          border: Border.all(color: style.softBorder),
                        ),
                        child: Icon(style.icon, size: 17, color: style.accent),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(context.l10n.taskPreview, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _previewController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: context.l10n.taskPreviewHint,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check_rounded),
                label: Text(
                  widget.list == null
                      ? context.l10n.createList
                      : context.l10n.saveChanges,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskEditorSheet extends StatefulWidget {
  const TaskEditorSheet({
    super.key,
    required this.repository,
    required this.listId,
    this.task,
  });

  final TodoRepository repository;
  final String listId;
  final TodoTask? task;

  @override
  State<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends State<TaskEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _dueController;
  late TaskPriority _priority;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _dueController = TextEditingController(text: task?.dueLabel ?? '');
    _priority = task?.priority ?? TaskPriority.high;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dueController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.taskTitleRequired)),
      );
      return;
    }

    final existing = widget.task;
    if (existing == null) {
      widget.repository.addTask(
        TodoTask(
          id: 'task-${DateTime.now().microsecondsSinceEpoch}',
          listId: widget.listId,
          title: title,
          dueLabel: _dueController.text.trim().isEmpty
              ? context.l10n.today
              : _dueController.text.trim(),
          priority: _priority,
          tone: TaskVisualStyle.toneFor(_priority),
        ),
      );
    } else {
      widget.repository.updateTask(
        existing.copyWith(
          title: title,
          dueLabel: _dueController.text.trim().isEmpty
              ? context.l10n.today
              : _dueController.text.trim(),
          priority: _priority,
          tone: TaskVisualStyle.toneFor(_priority),
        ),
      );
    }
    Navigator.of(context).pop();
  }

  void _delete() {
    final task = widget.task;
    if (task == null) return;
    widget.repository.removeTask(task.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetSurface(
      child: _SheetBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AppSheetHeader(
              title: widget.task == null
                  ? context.l10n.addTaskTitle
                  : context.l10n.editTaskTitle,
              subtitle: context.l10n.taskDescription,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              context.l10n.taskTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              autofocus: widget.task == null,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: context.l10n.taskTitleHint,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              context.l10n.when,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _dueController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: context.l10n.whenHint,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              context.l10n.priority,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            InputDecorator(
              decoration: InputDecoration(labelText: context.l10n.priority),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<TaskPriority>(
                  value: _priority,
                  isExpanded: true,
                  items: TaskPriority.values
                      .map((priority) {
                        return DropdownMenuItem<TaskPriority>(
                          value: priority,
                          child: Text(
                            localizedPriorityLabel(context, priority),
                          ),
                        );
                      })
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value != null) setState(() => _priority = value);
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check_rounded),
                label: Text(
                  widget.task == null
                      ? context.l10n.addTaskAction
                      : context.l10n.saveChanges,
                ),
              ),
            ),
            if (widget.task != null) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text(context.l10n.deleteTask),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error.withAlpha(120),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String localizedPriorityLabel(BuildContext context, TaskPriority priority) {
  final l10n = context.l10n;
  return switch (priority) {
    TaskPriority.urgent => l10n.priorityUrgent,
    TaskPriority.high => l10n.priorityToday,
    TaskPriority.medium => l10n.priorityUpcoming,
    TaskPriority.low => l10n.priorityLow,
    TaskPriority.someday => l10n.prioritySomeday,
  };
}

class ListStyleOption {
  const ListStyleOption({
    required this.accent,
    required this.softBackground,
    required this.softBorder,
    required this.icon,
    required this.previewIcon,
  });

  final Color accent;
  final Color softBackground;
  final Color softBorder;
  final IconData icon;
  final IconData previewIcon;
}
