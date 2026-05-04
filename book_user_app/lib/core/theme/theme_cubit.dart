import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage(),
      super(ThemeMode.system) {
    _loadTheme();
  }

  static const _key = 'theme_mode';
  final FlutterSecureStorage _storage;

  Future<void> _loadTheme() async {
    final value = await _storage.read(key: _key);
    switch (value) {
      case 'light':
        emit(ThemeMode.light);
      case 'dark':
        emit(ThemeMode.dark);
      default:
        emit(ThemeMode.system);
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    emit(mode);
    await _storage.write(key: _key, value: mode.name);
  }

  void toggleTheme() {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setTheme(next);
  }
}
