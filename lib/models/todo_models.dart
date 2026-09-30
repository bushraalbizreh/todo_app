import 'package:flutter/material.dart';

enum TaskPriority { urgent, high, medium, low, someday }

extension TaskPriorityDetails on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.urgent:
        return 'Priority 1';
      case TaskPriority.high:
        return 'Today';
      case TaskPriority.medium:
        return 'Upcoming';
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.someday:
        return 'Someday';
    }
  }
}

enum TaskTone { coral, orange, amber, gold, sand, slate, pearl }

class TaskVisualStyle {
  const TaskVisualStyle({
    required this.gradient,
    required this.foreground,
    required this.bullet,
  });

  final List<Color> gradient;
  final Color foreground;
  final Color bullet;

  static TaskVisualStyle of(TaskTone tone) {
    switch (tone) {
      case TaskTone.coral:
        return const TaskVisualStyle(
          gradient: [Color(0xFFFF5E4D), Color(0xFFFA5252)],
          foreground: Colors.white,
          bullet: Colors.white,
        );
      case TaskTone.orange:
        return const TaskVisualStyle(
          gradient: [Color(0xFFFB8C00), Color(0xFFF4511E)],
          foreground: Colors.white,
          bullet: Color(0xFFFFFBEB),
        );
      case TaskTone.amber:
        return const TaskVisualStyle(
          gradient: [Color(0xFFF59E0B), Color(0xFFD97706)],
          foreground: Color(0xFF241705),
          bullet: Color(0xFF241705),
        );
      case TaskTone.gold:
        return const TaskVisualStyle(
          gradient: [Color(0xFFFDE68A), Color(0xFFFCD34D)],
          foreground: Color(0xFF241705),
          bullet: Color(0xFF783D01),
        );
      case TaskTone.sand:
        return const TaskVisualStyle(
          gradient: [Color(0xFFEAE6DF), Color(0xFFE2DDD5)],
          foreground: Color(0xFF44403C),
          bullet: Color(0xFFB45309),
        );
      case TaskTone.slate:
        return const TaskVisualStyle(
          gradient: [Color(0xFFE8ECEF), Color(0xFFDEE2E6)],
          foreground: Color(0xFF334155),
          bullet: Color(0xFF64748B),
        );
      case TaskTone.pearl:
        return const TaskVisualStyle(
          gradient: [Colors.white, Color(0xFFF1F3F5)],
          foreground: Color(0xFF374151),
          bullet: Color(0xFF9CA3AF),
        );
    }
  }

  static TaskTone toneFor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return TaskTone.coral;
      case TaskPriority.high:
        return TaskTone.orange;
      case TaskPriority.medium:
        return TaskTone.amber;
      case TaskPriority.low:
        return TaskTone.gold;
      case TaskPriority.someday:
        return TaskTone.pearl;
    }
  }
}

class TodoList {
  const TodoList({
    required this.id,
    required this.name,
    required this.subtitle,
    this.subtitleColor,
    required this.countLabel,
    required this.icon,
    required this.accent,
    required this.softBackground,
    required this.softBorder,
    required this.previewIcon,
    required this.previewTitle,
  });

  final String id;
  final String name;
  final String subtitle;
  final Color? subtitleColor;
  final String countLabel;
  final IconData icon;
  final Color accent;
  final Color softBackground;
  final Color softBorder;
  final IconData previewIcon;
  final String previewTitle;

  TodoList copyWith({
    String? name,
    String? subtitle,
    Color? subtitleColor,
    String? countLabel,
    IconData? icon,
    Color? accent,
    Color? softBackground,
    Color? softBorder,
    IconData? previewIcon,
    String? previewTitle,
  }) {
    return TodoList(
      id: id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      subtitleColor: subtitleColor ?? this.subtitleColor,
      countLabel: countLabel ?? this.countLabel,
      icon: icon ?? this.icon,
      accent: accent ?? this.accent,
      softBackground: softBackground ?? this.softBackground,
      softBorder: softBorder ?? this.softBorder,
      previewIcon: previewIcon ?? this.previewIcon,
      previewTitle: previewTitle ?? this.previewTitle,
    );
  }
}

class TodoTask {
  const TodoTask({
    required this.id,
    required this.listId,
    required this.title,
    required this.dueLabel,
    required this.priority,
    required this.tone,
    this.trailingIcon,
    this.isDimmed = false,
    this.isCompleted = false,
    this.initialSwipeOffset = 0,
  });

  final String id;
  final String listId;
  final String title;
  final String dueLabel;
  final TaskPriority priority;
  final TaskTone tone;
  final IconData? trailingIcon;
  final bool isDimmed;
  final bool isCompleted;
  final double initialSwipeOffset;

  TodoTask copyWith({
    String? title,
    String? dueLabel,
    TaskPriority? priority,
    TaskTone? tone,
    IconData? trailingIcon,
    bool clearTrailingIcon = false,
    bool? isDimmed,
    bool? isCompleted,
    double? initialSwipeOffset,
  }) {
    return TodoTask(
      id: id,
      listId: listId,
      title: title ?? this.title,
      dueLabel: dueLabel ?? this.dueLabel,
      priority: priority ?? this.priority,
      tone: tone ?? this.tone,
      trailingIcon: clearTrailingIcon
          ? null
          : (trailingIcon ?? this.trailingIcon),
      isDimmed: isDimmed ?? this.isDimmed,
      isCompleted: isCompleted ?? this.isCompleted,
      initialSwipeOffset: initialSwipeOffset ?? this.initialSwipeOffset,
    );
  }
}
