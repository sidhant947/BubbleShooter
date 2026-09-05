import 'package:flutter/foundation.dart';
import 'package:bubbleshooter/data/services/hive_service.dart';
import 'package:bubbleshooter/domain/models/app_skin.dart';
import 'package:bubbleshooter/ui/core/services/haptic_service.dart';

class SettingsRepository extends ChangeNotifier {
  SettingsRepository({required this.hiveService}) {
    final skinId = hiveService.getSelectedSkinId();
    _currentSkin = AppSkin.fromId(skinId);
    _hintHelperEnabled = hiveService.getHintHelperEnabled();
    _hapticsEnabled = hiveService.getHapticsEnabled();
    HapticService.isHapticsEnabled = _hapticsEnabled;
  }

  final HiveService hiveService;
  late AppSkin _currentSkin;
  late bool _hintHelperEnabled;
  late bool _hapticsEnabled;

  AppSkin get currentSkin => _currentSkin;
  bool get hintHelperEnabled => _hintHelperEnabled;
  bool get hapticsEnabled => _hapticsEnabled;

  Future<void> setSkin(AppSkin skin) async {
    _currentSkin = skin;
    notifyListeners();
    await hiveService.saveSelectedSkinId(skin.id);
  }

  Future<void> setHintHelperEnabled(bool enabled) async {
    _hintHelperEnabled = enabled;
    notifyListeners();
    await hiveService.saveHintHelperEnabled(enabled);
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    _hapticsEnabled = enabled;
    HapticService.isHapticsEnabled = enabled;
    notifyListeners();
    await hiveService.saveHapticsEnabled(enabled);
  }
}
