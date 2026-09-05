import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bubbleshooter/data/repositories/progress_repository.dart';
import 'package:bubbleshooter/domain/models/bubble_level.dart';
import 'package:bubbleshooter/domain/use_cases/bubble_level_generator.dart';

@immutable
class GameViewModelState {
  const GameViewModelState({
    this.levelNumber = 1,
    this.levelName = '',
    this.shotsRemaining = 35,
    this.isComplete = false,
    this.isGameOver = false,
    this.gameOverReason,
    this.canUndo = false,
    this.levelType = LevelType.normal,
    this.isZenMode = false,
  });

  final int levelNumber;
  final String levelName;
  final int shotsRemaining;
  final bool isComplete;
  final bool isGameOver;
  final String? gameOverReason;
  final bool canUndo;
  final LevelType levelType;
  final bool isZenMode;

  GameViewModelState copyWith({
    int? levelNumber,
    String? levelName,
    int? shotsRemaining,
    bool? isComplete,
    bool? isGameOver,
    String? gameOverReason,
    bool? canUndo,
    LevelType? levelType,
    bool? isZenMode,
  }) {
    return GameViewModelState(
      levelNumber: levelNumber ?? this.levelNumber,
      levelName: levelName ?? this.levelName,
      shotsRemaining: shotsRemaining ?? this.shotsRemaining,
      isComplete: isComplete ?? this.isComplete,
      isGameOver: isGameOver ?? this.isGameOver,
      gameOverReason: gameOverReason ?? this.gameOverReason,
      canUndo: canUndo ?? this.canUndo,
      levelType: levelType ?? this.levelType,
      isZenMode: isZenMode ?? this.isZenMode,
    );
  }
}

class GameViewModel extends StateNotifier<GameViewModelState> {
  GameViewModel({
    required this.progressRepository,
  }) : super(const GameViewModelState());

  final ProgressRepository progressRepository;

  void loadLevel(int levelNumber) {
    final level = BubbleLevelGenerator.generateLevel(levelNumber);
    state = GameViewModelState(
      levelNumber: levelNumber,
      levelName: level.name,
      shotsRemaining: level.shots,
      isComplete: false,
      isGameOver: false,
      canUndo: false,
      levelType: level.levelType,
      isZenMode: false,
    );
  }

  void loadZenMode() {
    state = GameViewModelState(
      levelNumber: 0,
      levelName: 'ZEN INFINITE',
      shotsRemaining: 999999,
      isComplete: false,
      isGameOver: false,
      canUndo: false,
      levelType: LevelType.zen,
      isZenMode: true,
    );
  }

  void updateShots(int shotsRemaining, {bool canUndo = false}) {
    state = state.copyWith(
      shotsRemaining: shotsRemaining,
      canUndo: canUndo,
    );
  }

  void onLevelCompleted() {
    state = state.copyWith(
      isComplete: true,
    );
    if (!state.isZenMode && state.levelNumber > 0) {
      progressRepository.completeLevel(state.levelNumber);
    }
  }

  void onGameOver(String reason) {
    state = state.copyWith(
      isGameOver: true,
      gameOverReason: reason,
    );
  }
}
