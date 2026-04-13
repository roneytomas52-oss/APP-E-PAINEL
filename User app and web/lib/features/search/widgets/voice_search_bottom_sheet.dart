import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/search/controllers/search_controller.dart' as search;

class VoiceSearchBottomSheet extends StatefulWidget {
  final TextEditingController searchTextEditingController;
  const VoiceSearchBottomSheet({super.key, required this.searchTextEditingController});

  @override
  State<VoiceSearchBottomSheet> createState() => _VoiceSearchBottomSheetState();
}

class _VoiceSearchBottomSheetState extends State<VoiceSearchBottomSheet> with TickerProviderStateMixin {
  final search.SearchController _searchController = Get.find<search.SearchController>();
  late AnimationController _pulseController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _searchController.initVoice(isUpdate: false);
    _searchController.setVoiceText(widget.searchTextEditingController.text, isUpdate: false);
    _searchController.setVoiceSoundLevel(0.0, isUpdate: false);
    _searchController.setVoiceListening(false, isUpdate: false);

    _startListening();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  Future<void> _startListening() async {
    try {
      await _searchController.startVoiceListening(externalController: widget.searchTextEditingController);
      if (!(_searchController.voiceAvailable)) {
        showCustomSnackBar('voice_recognition_not_available'.tr);
      }
    } catch (e) {
      showCustomSnackBar('voice_input_failed'.tr);
      _searchController.setVoiceListening(false);
    }
  }

  Future<void> _stopListening({bool submit = false}) async {
    await _searchController.stopVoiceListening(submit: submit);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _searchController.cancelVoiceAutoSubmit();
    try {
      _searchController.stopVoiceListening();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<search.SearchController>(builder: (searchController) {
      final isListening = searchController.voiceIsListening;
      final recognizedText = searchController.voiceText;
      final soundLevel = searchController.voiceSoundLevel;
      bool isDesktop = ResponsiveHelper.isDesktop(context);

      return Container(
        width: isDesktop ? 500 : context.width,
        height: 570,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20), bottom: Radius.circular(isDesktop ? 20 : 0)),
        ),
        child: Stack(children: [
          Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              height: 5, width: 40,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            Text(
              'voice_search'.tr,
              style: robotoRegular.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                isListening ? 'listening'.tr : 'could_not_hear_properly_please_try_again'.tr,
                key: ValueKey(isListening),
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: isListening ? Theme.of(context).colorScheme.primary : Theme.of(context).hintColor,
                  fontWeight: isListening ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(height: 32),

            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 120),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: isListening ? LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ) : null,
                color: isListening ? null : Theme.of(context).highlightColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isListening ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3) : Theme.of(context).disabledColor.withValues(alpha: 0.15),
                  width: isListening ? 2 : 1,
                ),
                boxShadow: isListening ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  )
                ] : [],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 18,
                      color: isListening ? Theme.of(context).colorScheme.primary : Theme.of(context).hintColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'transcription'.tr,
                      style: robotoRegular.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isListening ? Theme.of(context).colorScheme.primary : Theme.of(context).hintColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    recognizedText.isNotEmpty ? recognizedText : 'tell_me_what_you_are_looking_for'.tr,
                    key: ValueKey(recognizedText),
                    style: robotoRegular.copyWith(
                      fontSize: 16,
                      height: 1.5,
                      color: recognizedText.isNotEmpty ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).hintColor.withValues(alpha: 0.6),
                      fontWeight: recognizedText.isNotEmpty ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 40),

            GestureDetector(
              onTap: () {
                if (isListening) {
                  _stopListening();
                } else {
                  _startListening();
                }
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer pulsing waves
                  if (isListening) ...[
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 140 + (30 * soundLevel),
                          height: 140 + (30 * soundLevel),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primary.withValues(
                              alpha: (0.15 - (_pulseController.value * 0.15)) * (1 + soundLevel),
                            ),
                          ),
                        );
                      },
                    ),
                    AnimatedBuilder(
                      animation: _waveController,
                      builder: (context, child) {
                        return Container(
                          width: 120 + (20 * soundLevel),
                          height: 120 + (20 * soundLevel),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primary.withValues(
                              alpha: (0.2 - (_waveController.value * 0.2)) * (1 + soundLevel),
                            ),
                          ),
                        );
                      },
                    ),
                  ],

                  // Middle glow
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 100 + (20 * soundLevel),
                    height: 100 + (20 * soundLevel),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isListening ? RadialGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                      ) : null,
                    ),
                  ),

                  // Main mic button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isListening ? LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ) : LinearGradient(
                        colors: [
                          Theme.of(context).disabledColor.withValues(alpha: 0.15),
                          Theme.of(context).disabledColor.withValues(alpha: 0.1),
                        ],
                      ),
                      boxShadow: isListening ? [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ] : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: AnimatedScale(
                      scale: isListening ? (1.0 + (0.1 * soundLevel)) : 1.0,
                      duration: const Duration(milliseconds: 100),
                      child: Icon(
                        isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                        size: 36,
                        color: isListening ? Colors.white : Theme.of(context).iconTheme.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (isListening)
              AnimatedOpacity(
                opacity: isListening ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final barHeight = 4.0 + (soundLevel * 20 * (index % 2 == 0 ? 1.5 : 1.0));
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: 4,
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(
                              alpha: 0.5 + (soundLevel * 0.5),
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'volume_level'.tr,
                      style: robotoRegular.copyWith(
                        fontSize: 11,
                        color: Theme.of(context).hintColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              isListening ? SizedBox() : Text(
                'tap_the_mic_to_try_again'.tr,
                textAlign: TextAlign.center,
                style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)
              ),

            const SizedBox(height: 40),
          ]),

          Positioned(
            top: 0, right: 0,
            child: InkWell(
              onTap: () {
                if (isListening) {
                  _stopListening();
                }
                searchController.cancelVoiceAutoSubmit();
                Get.back();
              },
              child: Icon(Icons.clear, color: Theme.of(context).disabledColor, size: 20),
            ),
          ),
        ]),
      );
    });
  }
}
