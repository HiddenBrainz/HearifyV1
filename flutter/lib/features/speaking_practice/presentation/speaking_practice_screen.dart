import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/audio_service.dart';
import '../../../services/speech_recognition_service.dart';
import '../../../shared/widgets/modern_card.dart';
import '../../../shared/widgets/waveform_view.dart';
import '../data/practice_history.dart';
import '../domain/phoneme.dart';
import '../domain/practice_item.dart';

/// Port of HearifyV1/Views/SpeakingPracticeView.swift.
/// Core pronunciation loop:
/// 1. Select an item
/// 2. Tap "Listen" → AudioService.speak() plays the target
/// 3. Tap "Record" → speech_to_text captures user speech, shows running text
/// 4. On stop → pronunciationSimilarity() produces a score, saved to history
class SpeakingPracticeScreen extends ConsumerStatefulWidget {
  const SpeakingPracticeScreen({super.key, this.items});

  final List<SpeakingPracticeItem>? items;

  @override
  ConsumerState<SpeakingPracticeScreen> createState() =>
      _SpeakingPracticeScreenState();
}

class _SpeakingPracticeScreenState
    extends ConsumerState<SpeakingPracticeScreen> {
  int _index = 0;
  Difficulty? _difficultyFilter;
  double? _lastScore;
  String _lastHeard = '';

  @override
  void dispose() {
    ref.read(audioServiceProvider).stop();
    ref.read(sttServiceProvider).cancel();
    super.dispose();
  }

  List<SpeakingPracticeItem> get _items {
    final base = widget.items ?? defaultPracticeItems;
    if (_difficultyFilter == null) return base;
    return base.where((i) => i.difficulty == _difficultyFilter).toList();
  }

  SpeakingPracticeItem? get _current =>
      _items.isEmpty ? null : _items[_index.clamp(0, _items.length - 1)];

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final item = _current;
    final audio = ref.watch(audioServiceProvider);
    final stt = ref.watch(sttServiceProvider);
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary(b),
      appBar: AppBar(
        title: const Text('Speaking Practice'),
        actions: [
          PopupMenuButton<Difficulty?>(
            icon: const Icon(Icons.filter_list),
            initialValue: _difficultyFilter,
            onSelected: (v) => setState(() {
              _difficultyFilter = v;
              _index = 0;
            }),
            itemBuilder: (_) => [
              const PopupMenuItem(value: null, child: Text('All')),
              ...Difficulty.values.map((d) =>
                  PopupMenuItem(value: d, child: Text(d.displayName))),
            ],
          ),
        ],
      ),
      body: item == null
          ? const Center(child: Text('No practice items'))
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Column(
                  children: [
                    _progressBar(b),
                    const SizedBox(height: AppTheme.spacingM),
                    Expanded(child: _mainCard(item, audio, stt, b)),
                    const SizedBox(height: AppTheme.spacingM),
                    _controls(item, audio, stt, b),
                    const SizedBox(height: AppTheme.spacingS),
                    _navRow(b),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _progressBar(Brightness b) => Row(
        children: [
          Text(
            '${_index + 1} / ${_items.length}',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary(b),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: LinearProgressIndicator(
              value: _items.isEmpty ? 0 : (_index + 1) / _items.length,
            ),
          ),
        ],
      );

  Widget _mainCard(SpeakingPracticeItem item, AudioService audio,
          SpeechRecognitionService stt, Brightness b) =>
      ModernCard(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _scoreColor(b).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${item.difficulty.displayName} · ${item.category}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _scoreColor(b),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              Text(
                item.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary(b),
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              if (item.phonemeFocus != null) ...[
                Text('Focus: ${item.phonemeFocus!.symbol}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary(b),
                    )),
                const SizedBox(height: 8),
              ],
              SizedBox(
                height: 80,
                child: WaveformView(
                  audioLevels: stt.isRecording
                      ? List<double>.filled(30, stt.audioLevel)
                      : generateIdealWaveform(item.text),
                  color:
                      stt.isRecording ? AppTheme.error(b) : AppTheme.primaryBlue(b),
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              if (stt.recognizedText.isNotEmpty || _lastHeard.isNotEmpty) ...[
                Text(
                  'You said',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary(b),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stt.isRecording ? stt.recognizedText : _lastHeard,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.textPrimary(b),
                  ),
                ),
              ],
              if (_lastScore != null && !stt.isRecording) ...[
                const SizedBox(height: AppTheme.spacingM),
                Text('${(_lastScore! * 100).round()}%',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: _scoreColor(b),
                    )),
                Text(_scoreLabel(_lastScore!),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary(b),
                    )),
              ],
            ],
          ),
        ),
      );

  Color _scoreColor(Brightness b) {
    if (_lastScore == null) return AppTheme.primaryBlue(b);
    if (_lastScore! >= 0.9) return AppTheme.success(b);
    if (_lastScore! >= 0.7) return AppTheme.warning(b);
    return AppTheme.error(b);
  }

  String _scoreLabel(double s) {
    if (s >= 0.9) return 'Excellent!';
    if (s >= 0.75) return 'Great job!';
    if (s >= 0.6) return 'Good try';
    return 'Try again';
  }

  Widget _controls(SpeakingPracticeItem item, AudioService audio,
          SpeechRecognitionService stt, Brightness b) =>
      Row(
        children: [
          Expanded(
            child: FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              onPressed: audio.isSpeaking
                  ? () => audio.stop()
                  : () => audio.speak(item.text),
              icon: Icon(audio.isSpeaking ? Icons.stop : Icons.volume_up),
              label: Text(audio.isSpeaking ? 'Stop' : 'Listen'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: stt.isRecording
                    ? AppTheme.error(b)
                    : AppTheme.primaryBlue(b),
              ),
              onPressed: () => stt.isRecording
                  ? _stopRecording(stt, item)
                  : _startRecording(stt, item),
              icon: Icon(
                stt.isRecording ? Icons.stop_circle : Icons.mic,
                color: Colors.white,
              ),
              label: Text(
                stt.isRecording ? 'Stop' : 'Record',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      );

  Widget _navRow(Brightness b) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: _index == 0 ? null : () => _go(-1),
            icon: const Icon(Icons.chevron_left),
            label: const Text('Previous'),
          ),
          TextButton.icon(
            onPressed: _index >= _items.length - 1 ? null : () => _go(1),
            icon: const Icon(Icons.chevron_right),
            label: const Text('Next'),
          ),
        ],
      );

  void _go(int delta) => setState(() {
        _index = (_index + delta).clamp(0, _items.length - 1);
        _lastScore = null;
        _lastHeard = '';
      });

  Future<void> _startRecording(
      SpeechRecognitionService stt, SpeakingPracticeItem item) async {
    if (!stt.isAuthorized) {
      final ok = await stt.requestAuthorization();
      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Microphone access required. '
                'Enable it in Settings and try again.',
              ),
            ),
          );
        }
        return;
      }
    }
    setState(() {
      _lastScore = null;
      _lastHeard = '';
    });
    await stt.startRecording(expectedText: item.text);
  }

  Future<void> _stopRecording(
      SpeechRecognitionService stt, SpeakingPracticeItem item) async {
    final result = await stt.stopRecording();
    if (result == null) return;
    final score = pronunciationSimilarity(item.text, result.words);
    setState(() {
      _lastScore = score;
      _lastHeard = result.words;
    });
    await ref.read(practiceHistoryProvider.notifier).add(
          PracticeAttempt(
            target: item.text,
            heard: result.words,
            score: score,
            timestamp: DateTime.now(),
          ),
        );
  }
}
