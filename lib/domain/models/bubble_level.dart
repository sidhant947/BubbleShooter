import 'package:flutter/foundation.dart';
import 'bubble.dart';

enum LevelType {
  normal,
  miniBoss,
  godBoss,
  zen,
}

@immutable
class BubbleLevel {
  const BubbleLevel({
    required this.levelNumber,
    required this.name,
    this.columns = 10,
    this.maxRows = 16,
    required this.bubbles,
    required this.shots,
    required this.availableColors,
    this.levelType = LevelType.normal,
    this.difficultyRating = 1.0,
  });

  final int levelNumber;
  final String name;
  final int columns;
  final int maxRows;
  final Map<GridPosition, BubbleColor> bubbles;
  final int shots;
  final List<BubbleColor> availableColors;
  final LevelType levelType;
  final double difficultyRating;

  bool get isBossLevel => levelType == LevelType.godBoss;
  bool get isMiniBossLevel => levelType == LevelType.miniBoss;
}
