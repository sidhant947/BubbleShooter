import 'package:flutter/material.dart';

class AppSkin {
  const AppSkin({
    required this.id,
    required this.name,
    required this.description,
    required this.previewColor,
    required this.bgGradient,
    required this.primaryColor,
    required this.accentColor,
    required this.surfaceColor,
    required this.headingColor,
    required this.subtextColor,
    required this.scaffoldBg,
    required this.glowColor,
  });

  final String id;
  final String name;
  final String description;
  final Color previewColor;
  final List<Color> bgGradient;
  final Color primaryColor;
  final Color accentColor;
  final Color surfaceColor;
  final Color headingColor;
  final Color subtextColor;
  final Color scaffoldBg;
  final Color glowColor;

  static const AppSkin classicArcade = AppSkin(
    id: 'classic_arcade',
    name: 'Classic Arcade',
    description: 'Timeless arcade deep teal with emerald accents and crisp contrast',
    previewColor: Color(0xFF14B8A6),
    bgGradient: [
      Color(0xFF134E4A),
      Color(0xFF042F2E),
      Color(0xFF021C1C),
    ],
    primaryColor: Color(0xFF2DD4BF),
    accentColor: Color(0xFF0D9488),
    surfaceColor: Color(0xFF0B3B38),
    headingColor: Color(0xFFF0FDFA),
    subtextColor: Color(0xFF99F6E4),
    scaffoldBg: Color(0xFF042F2E),
    glowColor: Color(0xFF14B8A6),
  );

  static const AppSkin midnightOled = AppSkin(
    id: 'midnight_oled',
    name: 'Midnight OLED',
    description: 'Pure obsidian dark mode with subtle slate borders and icy highlights',
    previewColor: Color(0xFF94A3B8),
    bgGradient: [
      Color(0xFF18181B),
      Color(0xFF09090B),
      Color(0xFF000000),
    ],
    primaryColor: Color(0xFFE2E8F0),
    accentColor: Color(0xFF64748B),
    surfaceColor: Color(0xFF18181B),
    headingColor: Color(0xFFFAFAFA),
    subtextColor: Color(0xFFA1A1AA),
    scaffoldBg: Color(0xFF09090B),
    glowColor: Color(0xFF94A3B8),
  );

  static const AppSkin synthwaveSunset = AppSkin(
    id: 'synthwave_sunset',
    name: 'Synthwave Sunset',
    description: 'Electric dusk gradient with neon magenta and deep purple twilight',
    previewColor: Color(0xFFD946EF),
    bgGradient: [
      Color(0xFF3B0764),
      Color(0xFF1E0836),
      Color(0xFF0F031D),
    ],
    primaryColor: Color(0xFFE879F9),
    accentColor: Color(0xFFA855F7),
    surfaceColor: Color(0xFF280B45),
    headingColor: Color(0xFFFAF5FF),
    subtextColor: Color(0xFFE9D5FF),
    scaffoldBg: Color(0xFF1E0836),
    glowColor: Color(0xFFD946EF),
  );

  static const AppSkin deepOcean = AppSkin(
    id: 'deep_ocean',
    name: 'Deep Ocean',
    description: 'Abyssal navy depths with luminous sapphire and cyan reflections',
    previewColor: Color(0xFF0EA5E9),
    bgGradient: [
      Color(0xFF0C4A6E),
      Color(0xFF082F49),
      Color(0xFF031624),
    ],
    primaryColor: Color(0xFF38BDF8),
    accentColor: Color(0xFF0284C7),
    surfaceColor: Color(0xFF073859),
    headingColor: Color(0xFFF0F9FF),
    subtextColor: Color(0xFFBAE6FD),
    scaffoldBg: Color(0xFF082F49),
    glowColor: Color(0xFF0EA5E9),
  );

  static const AppSkin cyberTokyo = AppSkin(
    id: 'cyber_tokyo',
    name: 'Cyber Tokyo',
    description: 'High-tech neo-shinjuku nights with electric cyan and carbon slate',
    previewColor: Color(0xFF06B6D4),
    bgGradient: [
      Color(0xFF111827),
      Color(0xFF0B1120),
      Color(0xFF030712),
    ],
    primaryColor: Color(0xFF22D3EE),
    accentColor: Color(0xFF0891B2),
    surfaceColor: Color(0xFF1E293B),
    headingColor: Color(0xFFECFEFF),
    subtextColor: Color(0xFFA5F3FC),
    scaffoldBg: Color(0xFF0B1120),
    glowColor: Color(0xFF06B6D4),
  );

  static const AppSkin amberForge = AppSkin(
    id: 'amber_forge',
    name: 'Amber Forge',
    description: 'Warm glowing embers and molten bronze in a cozy dark atmosphere',
    previewColor: Color(0xFFF59E0B),
    bgGradient: [
      Color(0xFF451A03),
      Color(0xFF270F02),
      Color(0xFF140700),
    ],
    primaryColor: Color(0xFFFBBF24),
    accentColor: Color(0xFFD97706),
    surfaceColor: Color(0xFF351602),
    headingColor: Color(0xFFFFFBEB),
    subtextColor: Color(0xFFFDE68A),
    scaffoldBg: Color(0xFF270F02),
    glowColor: Color(0xFFF59E0B),
  );

  static const AppSkin emeraldZen = AppSkin(
    id: 'emerald_zen',
    name: 'Emerald Zen',
    description: 'Lush botanical garden aesthetic with calming mint and rich moss tones',
    previewColor: Color(0xFF10B981),
    bgGradient: [
      Color(0xFF064E3B),
      Color(0xFF022C22),
      Color(0xFF011A14),
    ],
    primaryColor: Color(0xFF34D399),
    accentColor: Color(0xFF059669),
    surfaceColor: Color(0xFF08382C),
    headingColor: Color(0xFFECFDF5),
    subtextColor: Color(0xFFA7F3D0),
    scaffoldBg: Color(0xFF022C22),
    glowColor: Color(0xFF10B981),
  );

  static const AppSkin royalAmethyst = AppSkin(
    id: 'royal_amethyst',
    name: 'Royal Amethyst',
    description: 'Regal jewel tones with velvet violet and polished lavender sheen',
    previewColor: Color(0xFF8B5CF6),
    bgGradient: [
      Color(0xFF2E1065),
      Color(0xFF1B073D),
      Color(0xFF0E0221),
    ],
    primaryColor: Color(0xFFA78BFA),
    accentColor: Color(0xFF7C3AED),
    surfaceColor: Color(0xFF240A52),
    headingColor: Color(0xFFF5F3FF),
    subtextColor: Color(0xFFDDD6FE),
    scaffoldBg: Color(0xFF1B073D),
    glowColor: Color(0xFF8B5CF6),
  );

  static const List<AppSkin> allSkins = [
    classicArcade,
    midnightOled,
    synthwaveSunset,
    deepOcean,
    cyberTokyo,
    amberForge,
    emeraldZen,
    royalAmethyst,
  ];

  static AppSkin fromId(String? id) {
    return allSkins.firstWhere(
      (skin) => skin.id == id,
      orElse: () => classicArcade,
    );
  }
}
