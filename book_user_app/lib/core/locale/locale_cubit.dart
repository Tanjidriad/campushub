import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocaleCubit extends Cubit<Locale?> {
  LocaleCubit({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage(),
      super(null) {
    _loadLocale();
  }

  static const _key = 'app_locale';
  final FlutterSecureStorage _storage;

  Future<void> _loadLocale() async {
    final value = await _storage.read(key: _key);
    if (value != null) {
      emit(Locale(value));
    }
  }

  Future<void> setLocale(Locale locale) async {
    emit(locale);
    await _storage.write(key: _key, value: locale.languageCode);
  }

  Future<void> useSystemLocale() async {
    emit(null);
    await _storage.delete(key: _key);
  }
}
