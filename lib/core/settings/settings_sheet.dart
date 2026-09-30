import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/auth_cubit.dart';
import '../localization/localization.dart';
import '../theme/app_theme.dart';
import 'settings_cubit.dart';

Future<void> showSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _SettingsSheet(),
  );
}

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    return Material(
      color: palette.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
        ),
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settings) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        context.l10n.settings,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      tooltip: context.l10n.close,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  context.l10n.appearance,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                _ThemeChoices(current: settings.themePreference),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  context.l10n.language,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                _LanguageChoices(current: settings.locale),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  context.l10n.account,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                const _AccountTile(),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  context.l10n.dataAndPrivacy,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.cloud_done_outlined, color: palette.coral),
                  title: Text(context.l10n.cloudSync),
                  subtitle: Text(context.l10n.privacyNote),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ThemeChoices extends StatelessWidget {
  const _ThemeChoices({required this.current});

  final AppThemePreference current;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: AppThemePreference.values.map((preference) {
        final label = switch (preference) {
          AppThemePreference.system => context.l10n.systemTheme,
          AppThemePreference.light => context.l10n.lightMode,
          AppThemePreference.dark => context.l10n.darkMode,
        };
        return ChoiceChip(
          label: Text(label),
          selected: current == preference,
          onSelected: (_) =>
              context.read<SettingsCubit>().setTheme(preference),
        );
      }).toList(growable: false),
    );
  }
}

class _LanguageChoices extends StatelessWidget {
  const _LanguageChoices({required this.current});

  final Locale current;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Locale>(
      segments: <ButtonSegment<Locale>>[
        ButtonSegment<Locale>(
          value: const Locale('en'),
          label: Text(context.l10n.english),
          icon: const Icon(Icons.language_rounded),
        ),
        ButtonSegment<Locale>(
          value: const Locale('ar'),
          label: Text(context.l10n.arabic),
          icon: const Icon(Icons.translate_rounded),
        ),
      ],
      selected: <Locale>{current},
      onSelectionChanged: (selection) {
        if (selection.isNotEmpty) {
          context.read<SettingsCubit>().setLocale(selection.first);
        }
      },
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, auth) {
        final connected = auth.isSignedIn;
        final failed =
            auth.status == AuthStatus.error && auth.errorMessage != null;
        final palette = AppColors.of(context);
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: palette.focusSurface,
            foregroundColor: palette.focusPrimary,
            child: Icon(connected ? Icons.person_rounded : Icons.person_outline_rounded),
          ),
          title: Text(
            connected ? context.l10n.accountConnected : context.l10n.localOnly,
          ),
          subtitle: Text(
            // A failed sign-in/out must be reported instead of leaving the
            // tile to claim nothing happened.
            failed
                ? context.l10n.unexpectedError
                : connected
                    ? context.l10n.connectedToCloud
                    : context.l10n.guestMode,
            style: failed
                ? TextStyle(color: palette.coral, fontWeight: FontWeight.w600)
                : null,
          ),
          trailing: connected
              ? TextButton(
                  onPressed: () => context.read<AuthCubit>().signOut(),
                  child: Text(context.l10n.signOut),
                )
              : FilledButton.tonal(
                  onPressed: () => context.read<AuthCubit>().signInAnonymously(),
                  child: Text(context.l10n.connectAccount),
                ),
        );
      },
    );
  }
}
