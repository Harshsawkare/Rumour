import 'package:flutter/material.dart';

/// Semantic design tokens from the Rumour palette.
/// Access via [Theme.of(context).extension<AppColors>()].
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.iconBg,
    required this.primaryHeading1,
    required this.primaryHeading2,
    required this.primarySubheading1,
    required this.primarySubheading2,
    required this.primarySubheading3,
    required this.hintText,
    required this.secondaryText1,
    required this.secondaryText2,
    required this.primaryAccent,
    required this.secondaryAccent,
    required this.textBg,
    required this.icon,
  });

  final Color background;
  final Color iconBg;
  final Color icon;
  final Color primaryHeading1;
  final Color primaryHeading2;
  final Color primarySubheading1;
  final Color primarySubheading2;
  final Color primarySubheading3;
  final Color hintText;
  final Color secondaryText1;
  final Color secondaryText2;
  final Color primaryAccent;
  final Color secondaryAccent;

  /// Background behind text blocks (e.g. badges), `#111827` at ~80% opacity.
  final Color textBg;

  /// Borders / dividers (derived from palette; not a separate token).
  Color get divider =>
      Color.alphaBlend(primarySubheading3.withValues(alpha: 0.35), background);

  static final AppColors light = AppColors(
    background: const Color(0xFFFFFFFF),
    iconBg: const Color(0xFFF3F4F6),
    icon: const Color(0xFF5E6269),
    primaryHeading1: const Color(0xFF09090B),
    primaryHeading2: const Color(0xFF000000),
    primarySubheading1: const Color(0xFF52525B),
    primarySubheading2: const Color(0xFF4B5563),
    primarySubheading3: const Color(0xFF374151),
    hintText: const Color(0xFF9CA3AF),
    secondaryText1: const Color(0xFFFFFFFF),
    secondaryText2: const Color(0xFFF3F4F6),
    primaryAccent: const Color(0xFFFACC15),
    secondaryAccent: const Color(0xFF84CC16),
    textBg: const Color.fromARGB(255, 239, 239, 241),
  );

  static final AppColors dark = AppColors(
    background: const Color(0xFF09090B),
    iconBg: const Color(0xFF27272A),
    icon: const Color(0xFFE5E7EB),
    primaryHeading1: const Color(0xFFFAFAFA),
    primaryHeading2: const Color(0xFFFFFFFF),
    primarySubheading1: const Color(0xFFA1A1AA),
    primarySubheading2: const Color(0xFF9CA3AF),
    primarySubheading3: const Color(0xFFD1D5DB),
    hintText: const Color(0xFF6B7280),
    secondaryText1: const Color(0xFF000000),
    secondaryText2: const Color(0xFF1F2937),
    primaryAccent: const Color(0xFFFDE047),
    secondaryAccent: const Color(0xFFA3E635),
    textBg: const Color(0xCC111827),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? iconBg,
    Color? icon,
    Color? primaryHeading1,
    Color? primaryHeading2,
    Color? primarySubheading1,
    Color? primarySubheading2,
    Color? primarySubheading3,
    Color? hintText,
    Color? secondaryText1,
    Color? secondaryText2,
    Color? primaryAccent,
    Color? secondaryAccent,
    Color? textBg,
  }) {
    return AppColors(
      background: background ?? this.background,
      iconBg: iconBg ?? this.iconBg,
      icon: icon ?? this.icon,
      primaryHeading1: primaryHeading1 ?? this.primaryHeading1,
      primaryHeading2: primaryHeading2 ?? this.primaryHeading2,
      primarySubheading1: primarySubheading1 ?? this.primarySubheading1,
      primarySubheading2: primarySubheading2 ?? this.primarySubheading2,
      primarySubheading3: primarySubheading3 ?? this.primarySubheading3,
      hintText: hintText ?? this.hintText,
      secondaryText1: secondaryText1 ?? this.secondaryText1,
      secondaryText2: secondaryText2 ?? this.secondaryText2,
      primaryAccent: primaryAccent ?? this.primaryAccent,
      secondaryAccent: secondaryAccent ?? this.secondaryAccent,
      textBg: textBg ?? this.textBg,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      iconBg: Color.lerp(iconBg, other.iconBg, t)!,
      icon: Color.lerp(icon, other.icon, t)!,
      primaryHeading1: Color.lerp(primaryHeading1, other.primaryHeading1, t)!,
      primaryHeading2: Color.lerp(primaryHeading2, other.primaryHeading2, t)!,
      primarySubheading1: Color.lerp(
        primarySubheading1,
        other.primarySubheading1,
        t,
      )!,
      primarySubheading2: Color.lerp(
        primarySubheading2,
        other.primarySubheading2,
        t,
      )!,
      primarySubheading3: Color.lerp(
        primarySubheading3,
        other.primarySubheading3,
        t,
      )!,
      hintText: Color.lerp(hintText, other.hintText, t)!,
      secondaryText1: Color.lerp(secondaryText1, other.secondaryText1, t)!,
      secondaryText2: Color.lerp(secondaryText2, other.secondaryText2, t)!,
      primaryAccent: Color.lerp(primaryAccent, other.primaryAccent, t)!,
      secondaryAccent: Color.lerp(secondaryAccent, other.secondaryAccent, t)!,
      textBg: Color.lerp(textBg, other.textBg, t)!,
    );
  }
}
