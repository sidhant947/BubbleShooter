import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bubbleshooter/data/repositories/progress_repository.dart';
import 'package:bubbleshooter/data/services/hive_service.dart';
import 'package:bubbleshooter/domain/models/bubble.dart';
import 'package:bubbleshooter/ui/features/game/view_models/game_view_model.dart';
import 'package:bubbleshooter/ui/features/home/view_models/home_view_model.dart';
import 'package:bubbleshooter/data/repositories/settings_repository.dart';
import 'package:bubbleshooter/domain/models/app_skin.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

final settingsRepositoryProvider = ChangeNotifierProvider<SettingsRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return SettingsRepository(hiveService: hiveService);
});

final currentSkinProvider = Provider<AppSkin>((ref) {
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  return settingsRepo.currentSkin;
});

final hintHelperEnabledProvider = Provider<bool>((ref) {
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  return settingsRepo.hintHelperEnabled;
});

final hapticsEnabledProvider = Provider<bool>((ref) {
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  return settingsRepo.hapticsEnabled;
});

final bubbleColorsProvider = Provider<Map<BubbleColor, Color>>((ref) {
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  return settingsRepo.customColors;
});

final progressRepositoryProvider = ChangeNotifierProvider<ProgressRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return ProgressRepository(hiveService: hiveService);
});

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeViewModelState>((ref) {
      final progressRepository = ref.read(progressRepositoryProvider);
      return HomeViewModel(progressRepository: progressRepository);
    });

final gameViewModelProvider =
    StateNotifierProvider.autoDispose<GameViewModel, GameViewModelState>((ref) {
      final progressRepository = ref.read(progressRepositoryProvider);
      return GameViewModel(
        progressRepository: progressRepository,
      );
    });
