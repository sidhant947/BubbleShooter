import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bubbleshooter/domain/models/app_skin.dart';
import 'package:bubbleshooter/domain/models/bubble.dart';
import 'package:bubbleshooter/ui/core/services/haptic_service.dart';
import 'package:bubbleshooter/ui/core/widgets/balloon_widget.dart';
import 'package:bubbleshooter/ui/core/widgets/tangible_button.dart';
import 'package:bubbleshooter/ui/providers.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  static const List<Color> _palettePresets = [
    Color(0xFFEF4444),
    Color(0xFFF43F5E),
    Color(0xFFEC4899),
    Color(0xFF9333EA),
    Color(0xFF6366F1),
    Color(0xFF2563EB),
    Color(0xFF06B6D4),
    Color(0xFF14B8A6),
    Color(0xFF16A34A),
    Color(0xFF84CC16),
    Color(0xFFEAB308),
    Color(0xFFF97316),
  ];

  static String _toHex(Color color) {
    final rgb = color.toARGB32() & 0x00FFFFFF;
    return rgb.toRadixString(16).padLeft(6, '0').toUpperCase();
  }

  void _showColorEditDialog(
    BuildContext context,
    WidgetRef ref,
    BubbleColor bubbleColor,
    AppSkin skin,
  ) {
    final settingsRepo = ref.read(settingsRepositoryProvider);
    final controller = TextEditingController(text: _toHex(bubbleColor.color));
    Color previewColor = bubbleColor.color;
    String? errorText;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          void onTextChanged(String text) {
            final clean = text.replaceAll('#', '').trim();
            if (clean.length == 6) {
              final val = int.tryParse(clean, radix: 16);
              if (val != null) {
                setState(() {
                  previewColor = Color(int.parse('FF$clean', radix: 16));
                  errorText = null;
                });
                return;
              }
            }
            setState(() {
              errorText = 'Enter 6 hex digits';
            });
          }

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: skin.scaffoldBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: skin.primaryColor.withValues(alpha: 0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                    'EDIT COLOR',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: skin.headingColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  BalloonWidget(
                    color: bubbleColor,
                    customColor: previewColor,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 6,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: skin.headingColor,
                      letterSpacing: 1.5,
                    ),
                    decoration: InputDecoration(
                      prefixText: '# ',
                      prefixStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: skin.subtextColor,
                      ),
                      counterText: '',
                      filled: true,
                      fillColor: skin.surfaceColor,
                      errorText: errorText,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: skin.accentColor.withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: skin.accentColor.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: skin.primaryColor),
                      ),
                    ),
                    onChanged: onTextChanged,
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: _palettePresets.map((preset) {
                      final isSelected = previewColor.toARGB32() == preset.toARGB32();
                      return GestureDetector(
                        onTap: () {
                          HapticService.selectionClick();
                          setState(() {
                            previewColor = preset;
                            controller.text = _toHex(preset);
                            errorText = null;
                          });
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: preset,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.white24,
                              width: isSelected ? 2.5 : 1.0,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  TangibleButton(
                    text: 'Save Color',
                    height: 48,
                    primaryColor: skin.primaryColor,
                    borderColor: skin.accentColor,
                    textColor: skin.headingColor,
                    onPressed: errorText == null
                        ? () {
                            HapticService.selectionClick();
                            settingsRepo.updateBubbleColor(bubbleColor, previewColor);
                            Navigator.pop(dialogContext);
                          }
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(
                      'CANCEL',
                      style: TextStyle(
                        color: skin.subtextColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSkin = ref.watch(currentSkinProvider);
    final settingsRepo = ref.watch(settingsRepositoryProvider);

    return Scaffold(
      backgroundColor: currentSkin.scaffoldBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.2),
            radius: 1.2,
            colors: currentSkin.bgGradient,
            stops: const [0.0, 0.65, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          color: currentSkin.surfaceColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white24,
                            width: 1.0,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: currentSkin.headingColor,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'SETTINGS',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: currentSkin.headingColor,
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
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: currentSkin.surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: currentSkin.accentColor.withValues(alpha: 0.3),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: currentSkin.primaryColor.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.vibration_rounded,
                              color: currentSkin.headingColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Haptic Feedback',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: currentSkin.headingColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Vibrate on shots, bounces, and bubble pops',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: currentSkin.subtextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: ref.watch(hapticsEnabledProvider),
                            activeThumbColor: currentSkin.primaryColor,
                            activeTrackColor: currentSkin.primaryColor.withValues(alpha: 0.4),
                            inactiveThumbColor: currentSkin.subtextColor,
                            inactiveTrackColor: Colors.white10,
                            onChanged: (bool value) {
                              settingsRepo.setHapticsEnabled(value);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          'THEMES',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: currentSkin.headingColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${AppSkin.allSkins.length} styles',
                          style: TextStyle(
                            fontSize: 12,
                            color: currentSkin.subtextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 58,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: AppSkin.allSkins.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final skin = AppSkin.allSkins[index];
                          final isSelected = skin.id == currentSkin.id;

                          return GestureDetector(
                            onTap: () {
                              HapticService.selectionClick();
                              settingsRepo.setSkin(skin);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 56,
                              height: 56,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? skin.primaryColor : Colors.white24,
                                  width: isSelected ? 2.5 : 1.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: skin.glowColor.withValues(alpha: 0.5),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      skin.previewColor,
                                      skin.accentColor,
                                      skin.bgGradient.first,
                                    ],
                                  ),
                                ),
                                child: isSelected
                                    ? Icon(
                                        Icons.check_rounded,
                                        size: 24,
                                        color: skin.headingColor,
                                      )
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Text(
                          'BUBBLE COLORS',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: currentSkin.headingColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${BubbleColor.values.length} colors',
                          style: TextStyle(
                            fontSize: 12,
                            color: currentSkin.subtextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap any bubble to customize its color',
                      style: TextStyle(
                        fontSize: 12,
                        color: currentSkin.subtextColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.92,
                      ),
                      itemCount: BubbleColor.values.length,
                      itemBuilder: (context, index) {
                        final bubbleColor = BubbleColor.values[index];
                        final hex = _toHex(bubbleColor.color);

                        return GestureDetector(
                          onTap: () {
                            HapticService.selectionClick();
                            _showColorEditDialog(context, ref, bubbleColor, currentSkin);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            decoration: BoxDecoration(
                              color: currentSkin.surfaceColor.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: currentSkin.accentColor.withValues(alpha: 0.3),
                                width: 1.0,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                BalloonWidget(
                                  color: bubbleColor,
                                  size: 32,
                                ),
                                const SizedBox(height: 5),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '#$hex',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: currentSkin.subtextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    TangibleButton(
                      text: 'Reset Bubble Colors',
                      isSecondary: true,
                      height: 46,
                      secondaryColor: currentSkin.surfaceColor,
                      borderColor: currentSkin.accentColor.withValues(alpha: 0.3),
                      textColor: currentSkin.subtextColor,
                      onPressed: () {
                        HapticService.lightImpact();
                        settingsRepo.resetBubbleColors();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
