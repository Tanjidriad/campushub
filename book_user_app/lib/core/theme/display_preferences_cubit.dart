import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists OLED-style true black for dark mode.
class DisplayPreferencesCubit extends Cubit<bool> {
  DisplayPreferencesCubit() : super(false) {
    _load();
  }

  static const _keyOledBlack = 'display_oled_black';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    emit(prefs.getBool(_keyOledBlack) ?? false);
  }

  Future<void> setOledBlack(bool value) async {
    emit(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOledBlack, value);
  }

  Future<void> toggleOledBlack() => setOledBlack(!state);
}
