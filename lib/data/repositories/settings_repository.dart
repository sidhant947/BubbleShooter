import 'package:flutter/material.dart';
import 'package:bubbleshooter/data/services/hive_service.dart';
import 'package:bubbleshooter/domain/models/app_skin.dart';
import 'package:bubbleshooter/domain/models/bubble.dart';
import 'package:bubbleshooter/ui/core/services/haptic_service.dart';

class SettingsRepository extends ChangeNotifier {
  SettingsRepository({required this.hiveService}) {
    final skinId = hiveService.getSelectedSkinId();
    _currentSkin = AppSkin.fromId(skinId);
    _hintHelperEnabled = hiveService.getHintHelperEnabled();
    _hapticsEnabled = hiveService.getHapticsEnabled();
    HapticService.isHapticsEnabled = _hapticsEnabled;
    final savedColors = hiveService.getCustomColors();
    if (savedColors != null) {
      _customColors = Map<BubbleColor, Color>.from(savedColors);
      BubbleColor.customOverrides = _customColors;
    }
  }

  final HiveService hiveService;
  late AppSkin _currentSkin;
  late bool _hintHelperEnabled;
  late bool _hapticsEnabled;
  Map<BubbleColor, Color> _customColors = {};

  AppSkin get currentSkin => _currentSkin;
  bool get hintHelperEnabled => _hintHelperEnabled;
  bool get hapticsEnabled => _hapticsEnabled;
  Map<BubbleColor, Color> get customColors => _customColors;

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

  Future<void> updateBubbleColor(BubbleColor bubbleColor, Color color) async {
    _customColors[bubbleColor] = color;
    BubbleColor.customOverrides = Map<BubbleColor, Color>.from(_customColors);
    notifyListeners();
    await hiveService.saveCustomColors(_customColors);
  }

  Future<void> resetBubbleColors() async {
    _customColors.clear();
    BubbleColor.customOverrides = null;
    notifyListeners();
    await hiveService.resetCustomColors();
  }
}
