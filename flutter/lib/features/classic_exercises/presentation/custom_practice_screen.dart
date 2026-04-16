import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/audio_service.dart';
import '../../../services/speech_recognition_service.dart';
import '../../../shared/widgets/modern_card.dart';
import '../../speaking_practice/data/practice_history.dart';

/// Port of HearifyV1's `customPracticeScreenContent` (ContentView.swift
/// L2807). Lets the user maintain their own list of practice sentences/
/// words, play them via TTS, and optionally record themselves. List
/// persists across sessions via SharedPreferences (a lightweight stand-in
/// for the Swift app's UserDefaults-backed word list manager).
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
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    ref.read(audioServiceProvider).stop();
    ref.read(sttServiceProvider).cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final items = ref.watch(customPracticeProvider);
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary(b),
      appBar: AppBar(title: const Text('Custom Practice')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: ModernCard(
                child: Column(
                  children: [
                    TextField(
                      controller: _input,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Add a word or sentence',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () async {
                              await ref
                                  .read(customPracticeProvider.notifier)
                                  .add(_input.text);
                              _input.clear();
                              FocusScope.of(context).unfocus();
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        'Add your own words or sentences — they\'ll appear here '
                        'and can be played or practiced just like preset ones.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textSecondary(b),
                          fontSize: 13,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingM),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _tile(items[i], i, b),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(String text, int i, Brightness b) {
    final audio = ref.watch(audioServiceProvider);
    final stt = ref.watch(sttServiceProvider);
    return ModernCard(
      child: Row(
        children: [
          Expanded(
            child: Text(text,
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.textPrimary(b),
                )),
          ),
          IconButton(
            icon: Icon(
              audio.isSpeaking ? Icons.stop_circle : Icons.play_circle_fill,
              color: AppTheme.primaryBlue(b),
            ),
            onPressed: () async {
              if (audio.isSpeaking) {
                await audio.stop();
              } else {
                await audio.speak(text);
              }
            },
          ),
          IconButton(
            icon: Icon(
              stt.isRecording ? Icons.stop : Icons.mic,
              color: stt.isRecording
                  ? AppTheme.error(b)
                  : AppTheme.primaryBlue(b),
            ),
            onPressed: () async {
              if (stt.isRecording) {
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
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '${(score * 100).round()}% · heard: "${r.words}"'),
                      ),
                    );
                  }
                }
              } else {
                await stt.startRecording(expectedText: text);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_outline,
                color: AppTheme.textTertiary(b)),
            onPressed: () =>
                ref.read(customPracticeProvider.notifier).remove(i),
          ),
        ],
      ),
    );
  }
}
