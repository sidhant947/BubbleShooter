import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bubbleshooter/ui/core/services/haptic_service.dart';
import 'package:bubbleshooter/ui/features/game/views/game_view.dart';
import 'package:bubbleshooter/ui/providers.dart';

class LevelSelectView extends ConsumerStatefulWidget {
  const LevelSelectView({super.key});

  @override
  ConsumerState<LevelSelectView> createState() => _LevelSelectViewState();
}

class _LevelSelectViewState extends ConsumerState<LevelSelectView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(homeViewModelProvider.notifier).loadProgress());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final skin = ref.watch(currentSkinProvider);
    final highestCompleted = state.progress?.highestLevelCompleted ?? 0;
    final currentLevel = state.progress?.currentLevel ?? 1;
    final int totalLevelsToShow = currentLevel + 10;

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
                    GestureDetector(
                      onTap: () {
                        HapticService.lightImpact();
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: skin.surfaceColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white24,
                            width: 1.0,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: skin.headingColor,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'LEVELS',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: skin.headingColor,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),

              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: totalLevelsToShow,
                  itemBuilder: (context, index) {
                    final levelNumber = index + 1;
                    final isCompleted = levelNumber <= highestCompleted;
                    final isCurrent = levelNumber == currentLevel;
                    final isLocked = levelNumber > currentLevel;

                    return _buildLevelCard(
                      context,
                      levelNumber: levelNumber,
                      isCompleted: isCompleted,
                      isCurrent: isCurrent,
                      isLocked: isLocked,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(
    BuildContext context, {
    required int levelNumber,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLocked,
  }) {
    final skin = ref.watch(currentSkinProvider);
    Color cardBg = skin.surfaceColor;
    Color textColor = skin.headingColor;
    Color borderColor = skin.accentColor;
    Widget content;
    bool isClickable = !isLocked;

    final isGodBoss = levelNumber % 10 == 0;
    final isMiniBoss = !isGodBoss && levelNumber % 5 == 0;

    if (isGodBoss) {
      borderColor = const Color(0xFFEF4444);
    } else if (isMiniBoss) {
      borderColor = const Color(0xFFF59E0B);
    }

    if (isCompleted) {
      cardBg = skin.primaryColor;
      textColor = skin.headingColor;
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$levelNumber',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Icon(
            isGodBoss ? Icons.workspace_premium_rounded : (isMiniBoss ? Icons.military_tech_rounded : Icons.check_circle_rounded),
            size: 14,
            color: isGodBoss ? const Color(0xFFFCA5A5) : (isMiniBoss ? const Color(0xFFFDE68A) : textColor),
          ),
        ],
      );
    } else if (isCurrent) {
      cardBg = skin.headingColor;
      textColor = skin.scaffoldBg;
      if (!isGodBoss && !isMiniBoss) {
        borderColor = skin.primaryColor;
      }
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$levelNumber',
            style: TextStyle(
              fontSize: 17,
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (isGodBoss || isMiniBoss)
            Icon(
              isGodBoss ? Icons.local_fire_department_rounded : Icons.star_rate_rounded,
              size: 13,
              color: isGodBoss ? const Color(0xFFEF4444) : const Color(0xFFD97706),
            ),
        ],
      );
    } else {
      cardBg = skin.surfaceColor.withValues(alpha: 0.5);
      if (!isGodBoss && !isMiniBoss) {
        borderColor = skin.accentColor.withValues(alpha: 0.3);
      }
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isGodBoss ? Icons.local_fire_department_outlined : (isMiniBoss ? Icons.shield_outlined : Icons.lock_outline_rounded),
            size: 16,
            color: isGodBoss
                ? const Color(0xFFEF4444).withValues(alpha: 0.8)
                : (isMiniBoss ? const Color(0xFFF59E0B).withValues(alpha: 0.8) : skin.subtextColor),
          ),
          const SizedBox(height: 1),
          Text(
            '$levelNumber',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: skin.subtextColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: isClickable
          ? () async {
              HapticService.selectionClick();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameView(levelNumber: levelNumber),
                ),
              );
              ref.read(homeViewModelProvider.notifier).loadProgress();
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: isGodBoss ? 2.0 : (isMiniBoss ? 1.8 : 1.5),
          ),
        ),
        alignment: Alignment.center,
        child: content,
      ),
    );
  }
}
