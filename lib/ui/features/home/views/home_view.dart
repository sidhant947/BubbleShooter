import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bubbleshooter/domain/models/bubble.dart';
import 'package:bubbleshooter/ui/core/services/haptic_service.dart';
import 'package:bubbleshooter/ui/core/widgets/balloon_widget.dart';
import 'package:bubbleshooter/ui/core/widgets/tangible_button.dart';
import 'package:bubbleshooter/ui/features/game/views/game_view.dart';
import 'package:bubbleshooter/ui/features/level_select/views/level_select_view.dart';
import 'package:bubbleshooter/ui/features/settings/views/settings_view.dart';
import 'package:bubbleshooter/ui/providers.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(homeViewModelProvider.notifier).loadProgress();
    });

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 8.0, end: 22.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color surfaceColor,
    required Color iconColor,
    double iconSize = 20,
  }) {
    return GestureDetector(
      onTap: () {
        HapticService.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surfaceColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 1.0),
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor,
        ),
      ),
    );
  }

  Widget _buildBubbleTrio(dynamic skin, double size) {
    return SizedBox(
      width: size * 1.6,
      height: size * 1.3,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                width: size * 1.1,
                height: size * 1.1,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: skin.glowColor.withValues(alpha: 0.45),
                      blurRadius: _glowAnimation.value * 1.6,
                      spreadRadius: _glowAnimation.value * 0.6,
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: BalloonWidget(
              color: BubbleColor.blue,
              size: size * 0.72,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: BalloonWidget(
              color: BubbleColor.yellow,
              size: size * 0.72,
            ),
          ),
          Positioned(
            top: 0,
            child: BalloonWidget(
              color: BubbleColor.red,
              size: size * 0.88,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final skin = ref.watch(currentSkinProvider);

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _circleButton(
                      icon: Icons.star_rounded,
                      surfaceColor: skin.surfaceColor,
                      iconColor: skin.headingColor,
                      onTap: () =>
                          _launchUrl('https://github.com/sidhant947/BubbleShooter'),
                    ),
                    if (state.progress != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: skin.surfaceColor,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: skin.accentColor, width: 1.5),
                        ),
                        child: Text(
                          'LEVEL ${state.progress!.currentLevel}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: skin.headingColor,
                            letterSpacing: 0.8,
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    _circleButton(
                      icon: Icons.favorite_rounded,
                      surfaceColor: skin.surfaceColor,
                      iconColor: skin.headingColor,
                      onTap: () => _launchUrl('https://ko-fi.com/sidhant947'),
                    ),
                  ],
                ),
                const Spacer(flex: 3),
                _buildBubbleTrio(skin, 90),
                const SizedBox(height: 28),
                Text(
                  'BUBBLE SHOOTER',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: skin.headingColor,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'BUBBLE POPPING PUZZLE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: skin.subtextColor,
                    letterSpacing: 1.0,
                  ),
                ),
                const Spacer(flex: 4),
                TangibleButton(
                  text: state.progress == null ||
                          state.progress!.currentLevel <= 1
                      ? 'Start Game'
                      : 'Play',
                  isSecondary: true,
                  primaryColor: skin.primaryColor,
                  secondaryColor: skin.surfaceColor,
                  textColor: skin.headingColor,
                  onPressed: state.isLoading
                      ? null
                      : () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GameView(
                                levelNumber:
                                    state.progress?.currentLevel ?? 1,
                              ),
                            ),
                          );
                          ref
                              .read(homeViewModelProvider.notifier)
                              .loadProgress();
                        },
                ),
                const SizedBox(height: 14),
                TangibleButton(
                  text: 'Select Level',
                  isSecondary: true,
                  primaryColor: skin.primaryColor,
                  secondaryColor: skin.surfaceColor,
                  textColor: skin.headingColor,
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LevelSelectView(),
                      ),
                    );
                    ref.read(homeViewModelProvider.notifier).loadProgress();
                  },
                ),
                const SizedBox(height: 14),
                TangibleButton(
                  text: 'Zen Mode',
                  isSecondary: true,
                  primaryColor: skin.primaryColor,
                  secondaryColor: skin.surfaceColor,
                  textColor: skin.headingColor,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GameView(isZenMode: true),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TangibleButton(
                  text: 'Settings',
                  isSecondary: true,
                  primaryColor: skin.primaryColor,
                  secondaryColor: skin.surfaceColor,
                  textColor: skin.headingColor,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsView(),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
