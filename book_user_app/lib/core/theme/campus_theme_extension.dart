import 'package:flutter/material.dart';

/// Extra visual options layered on Material [ThemeData] (OLED black, etc.).
class CampusThemeExtension extends ThemeExtension<CampusThemeExtension> {
  final bool oledBlack;

  const CampusThemeExtension({this.oledBlack = false});

  @override
  CampusThemeExtension copyWith({bool? oledBlack}) {
    return CampusThemeExtension(
      oledBlack: oledBlack ?? this.oledBlack,
    );
  }

  @override
  CampusThemeExtension lerp(
    ThemeExtension<CampusThemeExtension>? other,
    double t,
  ) {
    if (other is! CampusThemeExtension) return this;
    return CampusThemeExtension(
      oledBlack: t < 0.5 ? oledBlack : other.oledBlack,
    );
  }
}

extension CampusThemeExtensionX on BuildContext {
  CampusThemeExtension? get campusTheme =>
      Theme.of(this).extension<CampusThemeExtension>();
}
