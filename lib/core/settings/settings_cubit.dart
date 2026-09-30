import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../storage/app_storage.dart';

enum AppThemePreference { system, light, dark }

extension AppThemePreferenceX on AppThemePreference {
  ThemeMode get themeMode {
    switch (this) {
      case AppThemePreference.system:
        return ThemeMode.system;
      case AppThemePreference.light:
        return ThemeMode.light;
      case AppThemePreference.dark:
        return ThemeMode.dark;
    }
  }

  String get storageValue => name;

  static AppThemePreference fromStorage(Object? value) {
    return AppThemePreference.values.firstWhere(
      (preference) => preference.name == value,
      orElse: () => AppThemePreference.system,
    );
  }
}

class SettingsState {
  const SettingsState({
    this.locale = const Locale('en'),
    this.themePreference = AppThemePreference.system,
    this.isLoaded = false,
  });

  final Locale locale;
  final AppThemePreference themePreference;
  final bool isLoaded;

  ThemeMode get themeMode => themePreference.themeMode;

  SettingsState copyWith({
    Locale? locale,
    AppThemePreference? themePreference,
    bool? isLoaded,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
      themePreference: themePreference ?? this.themePreference,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

class SettingsRepository {
  const SettingsRepository(this._storage);

  static const String _localeKey = 'settings.locale';
  static const String _themeKey = 'settings.theme';

  final AppStorage _storage;

  Future<SettingsState> load() async {
    final localeCode = await _storage.read<String>(_localeKey);
    final theme = await _storage.read<String>(_themeKey);
    final locale = switch (localeCode) {
      'ar' => const Locale('ar'),
      _ => const Locale('en'),
    };
    return SettingsState(
      locale: locale,
      themePreference: AppThemePreferenceX.fromStorage(theme),
      isLoaded: true,
    );
  }

  Future<void> saveLocale(Locale locale) =>
      _storage.write(_localeKey, locale.languageCode);

  Future<void> saveTheme(AppThemePreference preference) =>
      _storage.write(_themeKey, preference.storageValue);
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required SettingsRepository repository,
    SettingsState initialState = const SettingsState(),
  })  : _repository = repository,
        super(initialState) {
    unawaited(load());
  }

  final SettingsRepository _repository;

  Future<void> load() async {
    try {
      emit(await _repository.load());
    } catch (error) {
      debugPrint('Could not restore preferences: $error');
      emit(state.copyWith(isLoaded: true));
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode == state.locale.languageCode) return;
    emit(state.copyWith(locale: locale));
    await _repository.saveLocale(locale);
  }

  Future<void> setTheme(AppThemePreference preference) async {
    if (preference == state.themePreference) return;
    emit(state.copyWith(themePreference: preference));
    await _repository.saveTheme(preference);
  }
}
