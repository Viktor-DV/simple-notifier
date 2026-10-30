import 'package:flutter/material.dart';

/// Semantic colors for light/dark themes (via [ThemeExtension]).
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.backgroundPrimary,
    required this.backgroundSecondary,
    required this.card,
    required this.textPrimary,
    required this.textSecondary,
    required this.fieldFill,
    required this.accent,
    required this.accentDanger,
    required this.onAccent,
    required this.usedBadge,
  });

  final Color backgroundPrimary;
  final Color backgroundSecondary;
  final Color card;
  final Color textPrimary;
  final Color textSecondary;
  final Color fieldFill;
  final Color accent;
  final Color accentDanger;
  final Color onAccent;
  final Color usedBadge;

  static const light = AppPalette(
    backgroundPrimary: Color(0xFFF5F5F5),
    backgroundSecondary: Color(0xFFEEEEEE),
    card: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF212121),
    textSecondary: Color(0xFF757575),
    fieldFill: Color(0xFFE8E8E8),
    accent: Color(0xFF424242),
    accentDanger: Color(0xFFC62828),
    onAccent: Color(0xFFFFFFFF),
    usedBadge: Color(0xFF9E9E9E),
  );

  static const dark = AppPalette(
    backgroundPrimary: Color(0xFF121212),
    backgroundSecondary: Color(0xFF1E1E1E),
    card: Color(0xFF2C2C2C),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB0B0B0),
    fieldFill: Color(0xFF383838),
    accent: Color(0xFFE0E0E0),
    accentDanger: Color(0xFFEF5350),
    onAccent: Color(0xFF212121),
    usedBadge: Color(0xFF6D6D6D),
  );

  @override
  AppPalette copyWith({
    Color? backgroundPrimary,
    Color? backgroundSecondary,
    Color? card,
    Color? textPrimary,
    Color? textSecondary,
    Color? fieldFill,
    Color? accent,
    Color? accentDanger,
    Color? onAccent,
    Color? usedBadge,
  }) {
    return AppPalette(
      backgroundPrimary: backgroundPrimary ?? this.backgroundPrimary,
      backgroundSecondary: backgroundSecondary ?? this.backgroundSecondary,
      card: card ?? this.card,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      fieldFill: fieldFill ?? this.fieldFill,
      accent: accent ?? this.accent,
      accentDanger: accentDanger ?? this.accentDanger,
      onAccent: onAccent ?? this.onAccent,
      usedBadge: usedBadge ?? this.usedBadge,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      backgroundPrimary:
          Color.lerp(backgroundPrimary, other.backgroundPrimary, t)!,
      backgroundSecondary:
          Color.lerp(backgroundSecondary, other.backgroundSecondary, t)!,
      card: Color.lerp(card, other.card, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      fieldFill: Color.lerp(fieldFill, other.fieldFill, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentDanger: Color.lerp(accentDanger, other.accentDanger, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      usedBadge: Color.lerp(usedBadge, other.usedBadge, t)!,
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
