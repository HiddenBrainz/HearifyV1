import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/auth_design_system.dart';
import '../../../services/audio_service.dart';
import '../../../services/speech_recognition_service.dart';
import '../../../shared/data/practice_history.dart';
import '../../auth/presentation/widgets/gradient_primary_button.dart';

/// Port of HearifyV1's `customPracticeScreenContent` (ContentView.swift
/// L2807). Lets the user maintain their own list of practice sentences/
/// words, play them via TTS, and optionally record themselves. List
/// persists across sessions via SharedPreferences.
class CustomPracticeController extends StateNotifier<List<String>> {
  CustomPracticeController() : super(const []) {
    _load();
  }
  static const _key = 'customPracticeItems.v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      state = (jsonDecode(raw) as List).cast<String>();
    } catch (_) {/* ignore */}
  }

  Future<void> add(String text) async {
    if (text.trim().isEmpty) return;
    state = [text.trim(), ...state];
    await _persist();
  }

  Future<void> remove(int index) async {
    if (index < 0 || index >= state.length) return;
    final next = [...state]..removeAt(index);
    state = next;
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state));
  }
}

final customPracticeProvider =
    StateNotifierProvider<CustomPracticeController, List<String>>(
        (ref) => CustomPracticeController());

class CustomPracticeScreen extends ConsumerStatefulWidget {
  const CustomPracticeScreen({super.key});

  @override
  ConsumerState<CustomPracticeScreen> createState() =>
      _CustomPracticeScreenState();
}

class _CustomPracticeScreenState extends ConsumerState<CustomPracticeScreen> {
  static const Color _accent = AppColors.gradientPurple;

  final _input = TextEditingController();

  @override
  void deactivate() {
    // `ref` is invalid once `dispose()` runs, so tear down audio/STT
    // here while the element is still mounted.
    ref.read(audioServiceProvider).stop();
    ref.read(sttServiceProvider).cancel();
    super.deactivate();
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final items = ref.watch(customPracticeProvider);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.bgPrimary,
      ),
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          title: Text(
            'Custom Practice',
            style: AppTextStyles.title.copyWith(fontSize: 20),
          ),
        ),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: AppGradients.screenBackground,
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.l,
                    AppSpacing.l,
                    AppSpacing.l,
                    AppSpacing.m,
                  ),
                  child: _AddCard(
                    controller: _input,
                    accent: _accent,
                    onAdd: () async {
                      final text = _input.text;
                      if (text.trim().isEmpty) return;
                      await ref
                          .read(customPracticeProvider.notifier)
                          .add(text);
                      _input.clear();
                      if (!context.mounted) return;
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ),
                Expanded(
                  child: items.isEmpty
                      ? _EmptyState()
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.l,
                            AppSpacing.s,
                            AppSpacing.l,
                            AppSpacing.xxl,
                          ),
                          itemCount: items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.m),
                          itemBuilder: (_, i) => _PracticeItemTile(
                            text: items[i],
                            accent: _accent,
                            onDelete: () => ref
                                .read(customPracticeProvider.notifier)
                                .remove(i),
                            onScoreReady: (target, heard, score) =>
                                _showScoreDialog(target, heard, score, b),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showScoreDialog(
    String target,
    String heard,
    double score,
    Brightness b,
  ) async {
    await showDialog<void>(
      context: context,
      barrierColor: AppColors.bgPrimary.withValues(alpha: 0.72),
      builder: (ctx) => _ScoreDialog(
        target: target,
        heard: heard,
        score: score,
        brightness: b,
      ),
    );
  }
}

class _AddCard extends StatelessWidget {
  const _AddCard({
    required this.controller,
    required this.accent,
    required this.onAdd,
  });

  final TextEditingController controller;
  final Color accent;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.authCard,
        borderRadius: BorderRadius.circular(AppRadii.authCard),
        border: Border.all(
          color: accent.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.18),
            blurRadius: 22,
            spreadRadius: -8,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add a word or sentence',
              style: AppTextStyles.inputLabel,
            ),
            const SizedBox(height: AppSpacing.m),
            Container(
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(AppRadii.input),
              ),
              child: TextField(
                controller: controller,
                maxLines: 2,
                minLines: 1,
                cursorColor: accent,
                style: AppTextStyles.inputText,
                decoration: InputDecoration(
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.l,
                    vertical: 16,
                  ),
                  hintText: 'e.g. "The sky is blue"',
                  hintStyle: AppTextStyles.placeholder,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            GradientPrimaryButton(
              label: 'Add',
              leadingIcon: Icons.add_rounded,
              gradient: AppTheme.accentGradient(b),
              onPressed: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Text(
          "Add your own words or sentences — they'll appear here and can "
          'be played or practiced just like preset ones.',
          textAlign: TextAlign.center,
          style: AppTextStyles.subtitle.copyWith(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _PracticeItemTile extends ConsumerWidget {
  const _PracticeItemTile({
    required this.text,
    required this.accent,
    required this.onDelete,
    required this.onScoreReady,
  });

  final String text;
  final Color accent;
  final VoidCallback onDelete;
  final void Function(String target, String heard, double score) onScoreReady;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audio = ref.watch(audioServiceProvider);
    final stt = ref.watch(sttServiceProvider);
    final isRecording = stt.isRecording;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.authCard,
        borderRadius: BorderRadius.circular(AppRadii.button),
        border: Border.all(
          color: accent.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.14),
            blurRadius: 18,
            spreadRadius: -8,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.m,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.inputText.copyWith(fontSize: 15),
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            _CircleIconButton(
              icon: audio.isSpeaking
                  ? Icons.stop_rounded
                  : Icons.play_arrow_rounded,
              tint: accent,
              tooltip: audio.isSpeaking ? 'Stop' : 'Play',
              onTap: () async {
                if (audio.isSpeaking) {
                  await audio.stop();
                } else {
                  await audio.speak(text);
                }
              },
            ),
            const SizedBox(width: AppSpacing.xs),
            _CircleIconButton(
              icon: isRecording ? Icons.stop_rounded : Icons.mic_rounded,
              tint: isRecording
                  ? AppColors.errorText
                  : accent,
              tooltip: isRecording ? 'Stop recording' : 'Record',
              onTap: () async {
                if (isRecording) {
                  final r = await stt.stopRecording();
                  if (r != null) {
                    final score = pronunciationSimilarity(text, r.words);
                    await ref.read(practiceHistoryProvider.notifier).add(
                          PracticeAttempt(
                            target: text,
                            heard: r.words,
                            score: score,
                            timestamp: DateTime.now(),
                          ),
                        );
                    onScoreReady(text, r.words, score);
                  }
                } else {
                  await stt.startRecording(expectedText: text);
                }
              },
            ),
            const SizedBox(width: AppSpacing.xs),
            _CircleIconButton(
              icon: Icons.delete_outline_rounded,
              tint: AppColors.textInactive,
              tooltip: 'Remove',
              onTap: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.tint,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color tint;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: tint.withValues(alpha: 0.14),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s),
            child: Icon(icon, color: tint, size: 20),
          ),
        ),
      ),
    );
  }
}

class _ScoreDialog extends StatelessWidget {
  const _ScoreDialog({
    required this.target,
    required this.heard,
    required this.score,
    required this.brightness,
  });

  final String target;
  final String heard;
  final double score;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final b = brightness;
    final scoreColor = score >= 0.75
        ? AppTheme.success(b)
        : score >= 0.5
            ? AppTheme.warning(b)
            : AppTheme.error(b);
    final message = score >= 0.9
        ? 'Excellent!'
        : score >= 0.75
            ? 'Nice work!'
            : score >= 0.5
                ? 'Keep practicing'
                : 'Give it another go';
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppGradients.authCard,
          borderRadius: BorderRadius.circular(AppRadii.authCard),
          border: Border.all(
            color: scoreColor.withValues(alpha: 0.45),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: scoreColor.withValues(alpha: 0.22),
              blurRadius: 32,
              spreadRadius: -6,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.xxl,
            AppSpacing.xxl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.subtitle.copyWith(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                '${(score * 100).round()}%',
                style: AppTextStyles.title.copyWith(
                  fontSize: 56,
                  color: scoreColor,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              _KeyValueRow(label: 'Target', value: target),
              const SizedBox(height: AppSpacing.s),
              _KeyValueRow(
                label: 'Heard',
                value: heard.isEmpty ? '—' : heard,
              ),
              const SizedBox(height: AppSpacing.xxl),
              GradientPrimaryButton(
                label: 'Done',
                leadingIcon: Icons.check_rounded,
                gradient: AppTheme.accentGradient(b),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppRadii.input),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.m,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text(
              label,
              style: AppTextStyles.inputLabel.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.inputText.copyWith(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
