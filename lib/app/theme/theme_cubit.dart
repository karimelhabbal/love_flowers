import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

/// Persists the user's light/dark/system preference.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._preferences)
      : super(_modeFromString(_preferences.getString(AppConstants.themePrefKey)));

  final SharedPreferences _preferences;

  static ThemeMode _modeFromString(String? value) => switch (value) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  Future<void> setMode(ThemeMode mode) async {
    await _preferences.setString(AppConstants.themePrefKey, mode.name);
    emit(mode);
  }

  Future<void> cycleMode() => setMode(
        switch (state) {
          ThemeMode.system => ThemeMode.light,
          ThemeMode.light => ThemeMode.dark,
          ThemeMode.dark => ThemeMode.system,
        },
      );
}
