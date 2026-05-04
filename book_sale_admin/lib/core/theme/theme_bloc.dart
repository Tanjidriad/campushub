import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Events
abstract class ThemeEvent {}

class ToggleThemeEvent extends ThemeEvent {}

class LoadThemeEvent extends ThemeEvent {}

/// State
class ThemeState {
  final ThemeMode themeMode;
  const ThemeState({this.themeMode = ThemeMode.light});

  ThemeState copyWith({ThemeMode? themeMode}) =>
      ThemeState(themeMode: themeMode ?? this.themeMode);
}

/// BLoC — persists theme choice
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const _key = 'theme_mode';
  final _storage = const FlutterSecureStorage(aOptions: AndroidOptions());

  ThemeBloc() : super(const ThemeState()) {
    on<LoadThemeEvent>(_onLoad);
    on<ToggleThemeEvent>(_onToggle);
  }

  Future<void> _onLoad(LoadThemeEvent event, Emitter<ThemeState> emit) async {
    final stored = await _storage.read(key: _key);
    final mode = stored == 'dark' ? ThemeMode.dark : ThemeMode.light;
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> _onToggle(
    ToggleThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final next = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    await _storage.write(
      key: _key,
      value: next == ThemeMode.dark ? 'dark' : 'light',
    );
    emit(state.copyWith(themeMode: next));
  }
}
