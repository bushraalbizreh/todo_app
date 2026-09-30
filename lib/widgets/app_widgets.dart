import 'package:flutter/material.dart';

import '../core/localization/localization.dart';
import '../core/theme/app_theme.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 22,
    this.backgroundColor,
    this.foregroundColor,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: size),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 40, height: 40),
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor ?? palette.slate,
        shape: const CircleBorder(),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const <Widget>[],
    this.maxWidth = 384,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    return Material(
      color: palette.surface.withAlpha(242),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: palette.borderLight)),
        ),
        child: Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: padding,
              child: Row(
                children: <Widget>[
                  if (leading != null) ...<Widget>[
                    leading!,
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (subtitle != null) ...<Widget>[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: palette.slate,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  ...actions,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    this.maxWidth = 384,
    this.accentColor,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final double maxWidth;
  final Color? accentColor;

  static const List<_NavItemData> _items = <_NavItemData>[
    _NavItemData(
      icon: Icons.format_list_bulleted_rounded,
      selectedIcon: Icons.format_list_bulleted_rounded,
    ),
    _NavItemData(
      icon: Icons.today_rounded,
      selectedIcon: Icons.today_rounded,
    ),
    _NavItemData(
      icon: Icons.check_circle_outline_rounded,
      selectedIcon: Icons.check_circle_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    final selectedColor = accentColor ?? palette.coral;
    final labels = <String>[context.l10n.lists, context.l10n.today, context.l10n.completedTasks];
    return Material(
      color: palette.surface.withAlpha(248),
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: palette.border)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.center,
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: List<Widget>.generate(_items.length, (index) {
                    final item = _items[index];
                    final selected = index == selectedIndex;
                    return Expanded(
                      child: _NavigationItem(
                        data: item,
                        label: labels[index],
                        selected: selected,
                        accentColor: selectedColor,
                        onTap: () => onSelected(index),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.data,
    required this.label,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  final _NavItemData data;
  final String label;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    final color = selected ? accentColor : palette.slate;
    return Semantics(
      button: true,
      selected: selected,
      // The label is intentionally not set here: the child Text below already
      // contributes it. Setting it again would merge into a duplicated
      // "Focus\nFocus" announcement for screen readers.
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? accentColor.withAlpha(30)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  border: selected
                      ? Border.all(color: accentColor.withAlpha(35))
                      : null,
                ),
                child: Icon(
                  selected ? data.selectedIcon : data.icon,
                  size: 20,
                  color: color,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.icon,
    required this.selectedIcon,
  });

  final IconData icon;
  final IconData selectedIcon;
}

class AppSurfaceCard extends StatelessWidget {
  const AppSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
    this.color,
    this.borderColor,
    this.borderRadius = AppRadii.lg,
    this.boxShadow,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    final radius = BorderRadius.circular(borderRadius);
    final shadows = boxShadow ??
        <BoxShadow>[
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ];
    return Material(
      color: color ?? palette.surface,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        button: onTap != null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: borderColor ?? palette.border),
              boxShadow: shadows,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class AppIconTile extends StatelessWidget {
  const AppIconTile({
    super.key,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
    this.size = 44,
    this.iconSize = 22,
    this.radius = 12,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final double size;
  final double iconSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? backgroundColor),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: iconSize, color: foregroundColor),
    );
  }
}

class AppPill extends StatelessWidget {
  const AppPill({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.value,
    this.labelColor,
    this.backgroundColor,
    this.borderColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  });

  final String label;
  final IconData? icon;
  final Color? color;
  final String? value;
  final Color? labelColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    final foreground = color ?? palette.slate;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? palette.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: borderColor ?? palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 5),
          ],
          if (value != null) ...<Widget>[
            Text(
              value!,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: value == null ? foreground : (labelColor ?? palette.slate),
                  fontWeight: value == null ? FontWeight.w700 : FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.backgroundColor,
    this.height = 6,
  });

  final double value;
  final Color color;
  final Color? backgroundColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Container(
        height: height,
        color: backgroundColor ?? palette.surfaceContainerHigh,
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: value.clamp(0, 1),
            child: Container(color: color),
          ),
        ),
      ),
    );
  }
}

class AppSheetSurface extends StatelessWidget {
  const AppSheetSurface({
    super.key,
    required this.child,
    this.showHandle = true,
    this.bottomPadding = AppSpacing.xs,
  });

  final Widget child;
  final bool showHandle;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    return Material(
      color: palette.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (showHandle) const AppSheetHandle(),
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class AppSheetHandle extends StatelessWidget {
  const AppSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      margin: const EdgeInsets.only(top: 10, bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.of(context).border,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
    );
  }
}

class AppSheetHeader extends StatelessWidget {
  const AppSheetHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onClose,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: 4),
                Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
        AppIconButton(
          icon: Icons.close_rounded,
          tooltip: context.l10n.close,
          onPressed: onClose ?? () => Navigator.of(context).pop(),
          size: 20,
        ),
      ],
    );
  }
}

class AppSearchDelegate extends SearchDelegate<String?> {
  AppSearchDelegate({
    required this.items,
    this.hintText = 'Search',
    this.onItemSelected,
  });

  final List<String> items;
  final String hintText;
  final ValueChanged<String>? onItemSelected;

  @override
  String get searchFieldLabel => hintText;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return <Widget>[
      if (query.isNotEmpty)
        IconButton(
          onPressed: () => query = '',
          icon: const Icon(Icons.clear_rounded),
          tooltip: context.l10n.clearSearch,
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back_rounded),
      tooltip: context.l10n.back,
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSuggestions(context);

  Widget _buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return _SearchEmptyState(hint: context.l10n.typeToSearch);
    }

    final normalizedQuery = query.trim().toLowerCase();
    final matches = items
        .where((item) => item.toLowerCase().contains(normalizedQuery))
        .toList(growable: false);

    if (matches.isEmpty) {
      return _SearchEmptyState(hint: context.l10n.noMatchesFound);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: matches.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.xs),
      itemBuilder: (context, index) {
        final item = matches[index];
        final palette = AppColors.of(context);
        return ListTile(
          onTap: () {
            onItemSelected?.call(item);
            close(context, item);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          tileColor: palette.surface,
          leading: const Icon(Icons.search_rounded),
          title: Text(item),
        );
      },
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState({required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(
          hint,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.of(context).slate,
              ),
        ),
      ),
    );
  }
}
