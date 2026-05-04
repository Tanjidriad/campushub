import 'package:bloc_test/bloc_test.dart';
import 'package:book_user_app/core/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    when(
      () => mockStorage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);
    when(
      () => mockStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});
  });

  group('ThemeCubit', () {
    test('initial state is ThemeMode.system', () async {
      final cubit = ThemeCubit(storage: mockStorage);
      expect(cubit.state, ThemeMode.system);
      // Wait for async _loadTheme to complete before closing
      await Future<void>.delayed(Duration.zero);
      await cubit.close();
    });

    blocTest<ThemeCubit, ThemeMode>(
      'toggleTheme switches to dark then _loadTheme re-emits system',
      build: () => ThemeCubit(storage: mockStorage),
      act: (cubit) => cubit.toggleTheme(),
      // _loadTheme async reads null → emits system after the toggle
      expect: () => [ThemeMode.dark, ThemeMode.system],
    );

    blocTest<ThemeCubit, ThemeMode>(
      'setTheme emits light then _loadTheme re-emits system',
      build: () => ThemeCubit(storage: mockStorage),
      act: (cubit) => cubit.setTheme(ThemeMode.light),
      expect: () => [ThemeMode.light, ThemeMode.system],
    );

    blocTest<ThemeCubit, ThemeMode>(
      'loads persisted dark theme from storage',
      build: () {
        when(
          () => mockStorage.read(key: any(named: 'key')),
        ).thenAnswer((_) async => 'dark');
        return ThemeCubit(storage: mockStorage);
      },
      expect: () => [ThemeMode.dark],
    );

    blocTest<ThemeCubit, ThemeMode>(
      'loads persisted light theme from storage',
      build: () {
        when(
          () => mockStorage.read(key: any(named: 'key')),
        ).thenAnswer((_) async => 'light');
        return ThemeCubit(storage: mockStorage);
      },
      expect: () => [ThemeMode.light],
    );
  });
}
