import 'package:hive_flutter/hive_flutter.dart';

import 'package:bubbleshooter/domain/models/user_progress.dart';
import 'user_progress_adapter.dart';

class HiveService {
  static const String _progressBoxName = 'user_progress';
  static const String _settingsBoxName = 'app_settings';
  static const String _progressKey = 'progress';

  late Box<UserProgress> _progressBox;
  late Box _settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserProgressAdapter());
    _progressBox = await Hive.openBox<UserProgress>(_progressBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  Future<UserProgress> getProgress() async {
    return _progressBox.get(_progressKey) ?? const UserProgress();
  }

  Future<void> saveProgress(UserProgress progress) async {
    await _progressBox.put(_progressKey, progress);
  }

  String? getSelectedSkinId() {
    return _settingsBox.get('selected_skin_id') as String?;
  }

  Future<void> saveSelectedSkinId(String skinId) async {
    await _settingsBox.put('selected_skin_id', skinId);
  }

  bool getHintHelperEnabled() {
    return _settingsBox.get('hint_helper_enabled', defaultValue: true) as bool;
  }

  Future<void> saveHintHelperEnabled(bool enabled) async {
    await _settingsBox.put('hint_helper_enabled', enabled);
  }

  bool getHapticsEnabled() {
    return _settingsBox.get('haptics_enabled', defaultValue: true) as bool;
  }

  Future<void> saveHapticsEnabled(bool enabled) async {
    await _settingsBox.put('haptics_enabled', enabled);
  }
}

