import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bubbleshooter/domain/models/bubble_level.dart';
import 'package:bubbleshooter/ui/core/services/haptic_service.dart';
import 'package:bubbleshooter/ui/core/widgets/tangible_button.dart';
import 'package:bubbleshooter/ui/features/game/flame/bubble_shooter_game.dart';
import 'package:bubbleshooter/ui/features/game/view_models/game_view_model.dart';
import 'package:bubbleshooter/ui/providers.dart';

class GameView extends ConsumerStatefulWidget {
  const GameView({
    super.key,
    this.levelNumber = 1,
    this.isZenMode = false,
  });

  final int levelNumber;
  final bool isZenMode;

  @override
  ConsumerState<GameView> createState() => _GameViewState();
}

class _GameViewState extends ConsumerState<GameView> {
  BubbleShooterFlameGame? _flameGame;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (widget.isZenMode) {
        ref.read(gameViewModelProvider.notifier).loadZenMode();
      } else {
        ref.read(gameViewModelProvider.notifier).loadLevel(widget.levelNumber);
      }
      _initGame();
    });
  }

  void _initGame() {
    final skin = ref.read(currentSkinProvider);
    final vm = ref.read(gameViewModelProvider.notifier);

    _flameGame = BubbleShooterFlameGame(
      levelNumber: widget.levelNumber,
      skin: skin,
      isZenMode: widget.isZenMode,
      onShotsChanged: (shots) {
        if (!mounted) return;
        vm.updateShots(shots, canUndo: _flameGame?.canUndo() ?? false);
      },
      onLevelCleared: () {
        if (!mounted) return;
        vm.onLevelCompleted();
      },
      onGameOver: (reason) {
        if (!mounted) return;
        vm.onGameOver(reason);
      },
      onHapticShoot: () => HapticService.selectionClick(),
      onHapticPop: () => HapticService.heavyImpact(),
      onHapticBounce: () => HapticService.lightImpact(),
    );
    setState(() {});
  }

  void _onLevelComplete(GameViewModelState state) {
    final skin = ref.read(currentSkinProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [skin.surfaceColor, skin.scaffoldBg],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: skin.primaryColor.withValues(alpha: 0.7), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: skin.glowColor.withValues(alpha: 0.22),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: skin.primaryColor.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    border: Border.all(color: skin.primaryColor.withValues(alpha: 0.45)),
                  ),
                  child: Icon(Icons.emoji_events_rounded, size: 44, color: skin.primaryColor),
                ),
                const SizedBox(height: 16),
                Text(
                  'LEVEL CLEARED!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: skin.headingColor,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Great shot. Ready for the next challenge?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: skin.subtextColor),
                ),
                const SizedBox(height: 24),
                TangibleButton(
                  text: 'NEXT LEVEL',
                  primaryColor: skin.primaryColor,
                  secondaryColor: skin.surfaceColor,
                  textColor: skin.headingColor,
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    final nextLvl = state.levelNumber + 1;
                    ref.read(gameViewModelProvider.notifier).loadLevel(nextLvl);
                    _flameGame?.startLevel(nextLvl);
                  },
                ),
                const SizedBox(height: 12),
                TangibleButton(
                  text: 'HOME',
                  isSecondary: true,
                  primaryColor: skin.primaryColor,
                  secondaryColor: skin.surfaceColor,
                  textColor: skin.headingColor,
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
                const SizedBox(height: 12),
                TangibleButton(
                  text: 'BUY ME A COFFEE ☕',
                  isSecondary: true,
                  primaryColor: const Color(0xFFFF5E5B),
                  secondaryColor: skin.surfaceColor,
                  textColor: skin.headingColor,
                  onPressed: () {
                    final uri = Uri.parse('https://ko-fi.com/sidhant947');
                    launchUrl(uri, mode: LaunchMode.externalApplication);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showGameOverDialog(String reason) {
    final skin = ref.read(currentSkinProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: skin.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: skin.primaryColor, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.highlight_off_rounded,
                  size: 48,
                  color: Color(0xFFEF4444),
                ),
                const SizedBox(height: 12),
                Text(
                  'GAME OVER',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: skin.headingColor,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  reason,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: skin.subtextColor,
                  ),
                ),
                const SizedBox(height: 24),
                TangibleButton(
                  text: 'RETRY',
                  primaryColor: skin.primaryColor,
                  secondaryColor: skin.surfaceColor,
                  textColor: skin.headingColor,
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    final state = ref.read(gameViewModelProvider);
                    if (widget.isZenMode || state.isZenMode) {
                      ref.read(gameViewModelProvider.notifier).loadZenMode();
                      _flameGame?.startLevel(0);
                    } else {
                      final lvl = state.levelNumber;
                      ref.read(gameViewModelProvider.notifier).loadLevel(lvl);
                      _flameGame?.startLevel(lvl);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TangibleButton(
                  text: 'HOME',
                  isSecondary: true,
                  primaryColor: skin.primaryColor,
                  secondaryColor: skin.surfaceColor,
                  textColor: skin.headingColor,
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    double iconSize = 20,
    bool enabled = true,
    Color? iconColor,
    Color? backgroundColor,
    String? badge,
    Color? badgeColor,
  }) {
    return GestureDetector(
      onTap: enabled
          ? () {
              HapticService.selectionClick();
              onTap();
            }
          : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundColor ?? const Color(0xFF134545),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white24,
                  width: 1.0,
                ),
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: iconColor ?? const Color(0xFFF5F5F0),
              ),
            ),
            if (badge != null)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor ?? const Color(0xFF2D8B7A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white70, width: 1),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameViewModelProvider);
    final skin = ref.watch(currentSkinProvider);

    if (_flameGame != null && _flameGame!.skin != skin) {
      _flameGame!.updateSkin(skin);
    }

    ref.listen<GameViewModelState>(gameViewModelProvider, (prev, next) {
      if (next.isComplete && !(prev?.isComplete ?? false)) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _onLevelComplete(next);
          }
        });
      }

      if (next.isGameOver && !(prev?.isGameOver ?? false)) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            _showGameOverDialog(next.gameOverReason ?? 'Level Failed');
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: skin.scaffoldBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.2),
            radius: 1.2,
            colors: skin.bgGradient,
            stops: const [0.0, 0.65, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _circleButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      iconSize: 18,
                      iconColor: skin.headingColor,
                      backgroundColor: skin.surfaceColor,
                      onTap: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            state.isZenMode ? 'ZEN MODE' : 'LEVEL ${state.levelNumber}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: skin.headingColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                          if (state.levelType == LevelType.godBoss) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'BOSS',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ] else if (state.levelType == LevelType.miniBoss) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'MINI BOSS',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    _circleButton(
                      icon: Icons.refresh_rounded,
                      iconSize: 20,
                      iconColor: skin.headingColor,
                      backgroundColor: skin.surfaceColor,
                      onTap: () {
                        if (state.isZenMode) {
                          ref.read(gameViewModelProvider.notifier).loadZenMode();
                          _flameGame?.startLevel(0);
                        } else {
                          ref.read(gameViewModelProvider.notifier).loadLevel(state.levelNumber);
                          _flameGame?.startLevel(state.levelNumber);
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _flameGame == null
                    ? const Center(child: CircularProgressIndicator())
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: ClipRect(
                          child: Stack(
                            children: [
                              GameWidget(game: _flameGame!),
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                height: 56,
                                child: IgnorePointer(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          skin.scaffoldBg.withValues(alpha: 0.9),
                                          skin.scaffoldBg.withValues(alpha: 0.5),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
