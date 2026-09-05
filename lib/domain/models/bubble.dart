import 'package:flutter/material.dart';

enum BubbleColor {
  red(
    color: Color(0xFFEF4444),
    darkColor: Color(0xFFB91C1C),
    lightColor: Color(0xFFFCA5A5),
  ),
  blue(
    color: Color(0xFF3B82F6),
    darkColor: Color(0xFF1D4ED8),
    lightColor: Color(0xFF93C5FD),
  ),
  green(
    color: Color(0xFF10B981),
    darkColor: Color(0xFF047857),
    lightColor: Color(0xFF6EE7B7),
  ),
  yellow(
    color: Color(0xFFF59E0B),
    darkColor: Color(0xFFB45309),
    lightColor: Color(0xFFFDE68A),
  ),
  purple(
    color: Color(0xFF8B5CF6),
    darkColor: Color(0xFF6D28D9),
    lightColor: Color(0xFFC4B5FD),
  ),
  orange(
    color: Color(0xFFF97316),
    darkColor: Color(0xFFC2410C),
    lightColor: Color(0xFFFDBA74),
  ),
  cyan(
    color: Color(0xFF06B6D4),
    darkColor: Color(0xFF0E7490),
    lightColor: Color(0xFF67E8F9),
  );

  const BubbleColor({
    required this.color,
    required this.darkColor,
    required this.lightColor,
  });

  final Color color;
  final Color darkColor;
  final Color lightColor;
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
