import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

class LocaleState extends Equatable {
  const LocaleState(this.locale, this.textDirection);

  final Locale locale;
  final TextDirection textDirection;

  bool get isArabic => locale.languageCode == 'ar';

  @override
  List<Object?> get props => [locale, textDirection];
}

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit(this._preferences)
      : super(const LocaleState(Locale('ar'), TextDirection.rtl));

  final SharedPreferences _preferences;

  Future<void> load() async {
    final code = _preferences.getString(AppConstants.localePrefKey) ?? 'ar';
    _emit(code);
  }

  Future<void> setLanguageCode(String code) async {
    final safeCode = code == 'en' ? 'en' : 'ar';
    await _preferences.setString(AppConstants.localePrefKey, safeCode);
    _emit(safeCode);
  }

  Future<void> toggleLanguage() =>
      setLanguageCode(state.isArabic ? 'en' : 'ar');

  void _emit(String code) {
    emit(
      LocaleState(
        Locale(code),
        code == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      ),
    );
  }
}
