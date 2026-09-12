import 'package:flutter/material.dart';

enum BubbleColor {
  red(
    defaultColor: Color(0xFFEF4444),
    defaultDarkColor: Color(0xFFB91C1C),
    defaultLightColor: Color(0xFFFCA5A5),
  ),
  blue(
    defaultColor: Color(0xFF2563EB),
    defaultDarkColor: Color(0xFF1D4ED8),
    defaultLightColor: Color(0xFF93C5FD),
  ),
  green(
    defaultColor: Color(0xFF16A34A),
    defaultDarkColor: Color(0xFF15803D),
    defaultLightColor: Color(0xFF86EFAC),
  ),
  yellow(
    defaultColor: Color(0xFFEAB308),
    defaultDarkColor: Color(0xFFA16207),
    defaultLightColor: Color(0xFFFEF08A),
  ),
  purple(
    defaultColor: Color(0xFF9333EA),
    defaultDarkColor: Color(0xFF6B21A8),
    defaultLightColor: Color(0xFFD8B4FE),
  ),
  orange(
    defaultColor: Color(0xFFF97316),
    defaultDarkColor: Color(0xFFC2410C),
    defaultLightColor: Color(0xFFFDBA74),
  ),
  cyan(
    defaultColor: Color(0xFF06B6D4),
    defaultDarkColor: Color(0xFF0E7490),
    defaultLightColor: Color(0xFFA5F3FC),
  );

  const BubbleColor({
    required this.defaultColor,
    required this.defaultDarkColor,
    required this.defaultLightColor,
  });

  final Color defaultColor;
  final Color defaultDarkColor;
  final Color defaultLightColor;

  static Map<BubbleColor, Color>? customOverrides;

  Color get color => customOverrides?[this] ?? defaultColor;

  Color get darkColor {
    final custom = customOverrides?[this];
    if (custom == null) return defaultDarkColor;
    final hsl = HSLColor.fromColor(custom);
    return hsl.withLightness((hsl.lightness * 0.68).clamp(0.0, 1.0)).toColor();
  }

  Color get lightColor {
    final custom = customOverrides?[this];
    if (custom == null) return defaultLightColor;
    final hsl = HSLColor.fromColor(custom);
    return hsl.withLightness((hsl.lightness + (1.0 - hsl.lightness) * 0.45).clamp(0.0, 1.0)).toColor();
  }
}

@immutable
class GridPosition {
  const GridPosition(this.row, this.col);

  final int row;
  final int col;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridPosition &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => 'GridPosition($row, $col)';
}

@immutable
class Bubble {
  const Bubble({
    required this.id,
    required this.color,
    required this.row,
    required this.col,
  });

  final String id;
  final BubbleColor color;
  final int row;
  final int col;

  GridPosition get position => GridPosition(row, col);

  Bubble copyWith({
    String? id,
    BubbleColor? color,
    int? row,
    int? col,
  }) {
    return Bubble(
      id: id ?? this.id,
      color: color ?? this.color,
      row: row ?? this.row,
      col: col ?? this.col,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bubble && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
