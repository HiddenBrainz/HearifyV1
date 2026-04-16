import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/audio_service.dart';
import '../../../services/speech_recognition_service.dart';
import '../../../shared/widgets/modern_card.dart';
import '../../speaking_practice/data/practice_history.dart';
import '../domain/conversation_scenario.dart';

/// Port of HearifyV1/Views/ConversationScenarioView.swift. Walks through
/// the scenario turn by turn: "other" turns are read via TTS, "user" turns
/// require the user to speak (captured via STT). Scoring compares the
/// heard text against the best matching expected response.
class ConversationScenarioScreen extends ConsumerStatefulWidget {
  const ConversationScenarioScreen({super.key, required this.scenario});
  final ConversationScenario scenario;

  @override
  ConsumerState<ConversationScenarioScreen> createState() =>
      _ConversationScenarioScreenState();
}

class _ConversationScenarioScreenState
    extends ConsumerState<ConversationScenarioScreen> {
  int _turnIndex = 0;
  final List<_TurnOutcome> _outcomes = [];
  bool _hasPlayed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleCurrentTurn());
  }

  @override
  void dispose() {
    ref.read(audioServiceProvider).stop();
    ref.read(sttServiceProvider).cancel();
    super.dispose();
  }

  ConversationTurn? get _current => _turnIndex < widget.scenario.turns.length
      ? widget.scenario.turns[_turnIndex]
      : null;

  Future<void> _handleCurrentTurn() async {
    final turn = _current;
    if (turn == null) return;
    if (turn.speaker == Speaker.other || turn.speaker == Speaker.narrator) {
      if (!_hasPlayed) {
        _hasPlayed = true;
        await ref.read(audioServiceProvider).speak(turn.text);
      }
    }
  }

  Future<void> _advance() async {
    final c = _current;
    if (c == null) return;
    await ref.read(audioServiceProvider).stop();
    await ref.read(sttServiceProvider).cancel();
    setState(() {
      _turnIndex++;
      _hasPlayed = false;
    });
    if (_turnIndex >= widget.scenario.turns.length) {
      _showSummary();
    } else {
      _handleCurrentTurn();
    }
  }

  Future<void> _startUserTurn() async {
    final stt = ref.read(sttServiceProvider);
    if (!stt.isAuthorized) {
      final ok = await stt.requestAuthorization();
      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission required')),
          );
        }
        return;
      }
    }
    await stt.startRecording();
  }

  Future<void> _stopUserTurn() async {
    final turn = _current;
    if (turn == null || turn.speaker != Speaker.user) return;
    final stt = ref.read(sttServiceProvider);
    final result = await stt.stopRecording();
    if (result == null) return;
    final best = _bestMatch(
        result.words, [turn.text, ...turn.expectedResponses]);
    _outcomes.add(_TurnOutcome(
      turnIndex: _turnIndex,
      expected: turn.text,
      heard: result.words,
      score: best,
    ));
    await ref.read(practiceHistoryProvider.notifier).add(
          PracticeAttempt(
            target: turn.text,
            heard: result.words,
            score: best,
            timestamp: DateTime.now(),
          ),
        );
    setState(() {});
  }

  double _bestMatch(String heard, List<String> candidates) {
    double best = 0;
    for (final c in candidates) {
      final score = pronunciationSimilarity(c, heard);
      if (score > best) best = score;
    }
    return best;
  }

  void _showSummary() async {
    final b = Theme.of(context).brightness;
    final avg = _outcomes.isEmpty
        ? 0.0
        : _outcomes.map((o) => o.score).reduce((a, b) => a + b) /
            _outcomes.length;
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        title: const Text('Scenario complete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${(avg * 100).round()}%',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: avg >= 0.75
                      ? AppTheme.success(b)
                      : avg >= 0.5
                          ? AppTheme.warning(b)
                          : AppTheme.error(b),
                )),
            Text('${_outcomes.length} of ${widget.scenario.turns.length} user turns scored',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary(b),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final audio = ref.watch(audioServiceProvider);
    final stt = ref.watch(sttServiceProvider);
    final turn = _current;
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary(b),
      appBar: AppBar(title: Text(widget.scenario.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            children: [
              _contextCard(b),
              const SizedBox(height: AppTheme.spacingM),
              LinearProgressIndicator(
                value: widget.scenario.turns.isEmpty
                    ? 0
                    : _turnIndex / widget.scenario.turns.length,
              ),
              const SizedBox(height: AppTheme.spacingM),
              Expanded(
                child: turn == null
                    ? const Center(child: CircularProgressIndicator())
                    : _turnBody(turn, audio, stt, b),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contextCard(Brightness b) => ModernCard(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(widget.scenario.category.icon,
                color: widget.scenario.category.color(b)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.scenario.context,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary(b),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _turnBody(ConversationTurn turn, AudioService audio,
          SpeechRecognitionService stt, Brightness b) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: ModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _speakerChip(turn.speaker, b),
                    const SizedBox(height: 8),
                    Text(turn.text,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary(b),
                        )),
                    if (turn.audioHint.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(turn.audioHint,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: AppTheme.textSecondary(b),
                          )),
                    ],
                    if (turn.tip.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.tips_and_updates_outlined,
                              size: 14, color: AppTheme.accentOrange(b)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(turn.tip,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary(b),
                                )),
                          ),
                        ],
                      ),
                    ],
                    if (turn.speaker == Speaker.user &&
                        _outcomes.isNotEmpty &&
                        _outcomes.last.turnIndex == _turnIndex) ...[
                      const SizedBox(height: 14),
                      _outcomeBlock(_outcomes.last, b),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          _controls(turn, audio, stt, b),
        ],
      );

  Widget _speakerChip(Speaker s, Brightness b) {
    final label = switch (s) {
      Speaker.user => 'You',
      Speaker.other => 'Other',
      Speaker.narrator => 'Narrator',
    };
    final color = switch (s) {
      Speaker.user => AppTheme.primaryBlue(b),
      Speaker.other => AppTheme.accentPurple(b),
      Speaker.narrator => AppTheme.textSecondary(b),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          )),
    );
  }

  Widget _outcomeBlock(_TurnOutcome o, Brightness b) {
    final color = o.score >= 0.75
        ? AppTheme.success(b)
        : o.score >= 0.5
            ? AppTheme.warning(b)
            : AppTheme.error(b);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.mic, size: 14, color: color),
              const SizedBox(width: 6),
              Text('${(o.score * 100).round()}% match',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  )),
            ],
          ),
          const SizedBox(height: 4),
          Text('Heard: "${o.heard}"',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary(b),
              )),
        ],
      ),
    );
  }

  Widget _controls(ConversationTurn turn, AudioService audio,
      SpeechRecognitionService stt, Brightness b) {
    if (turn.speaker == Speaker.user) {
      return Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: stt.isRecording
                    ? AppTheme.error(b)
                    : AppTheme.primaryBlue(b),
              ),
              onPressed: stt.isRecording ? _stopUserTurn : _startUserTurn,
              icon: Icon(stt.isRecording ? Icons.stop : Icons.mic,
                  color: Colors.white),
              label: Text(stt.isRecording ? 'Stop' : 'Record',
                  style: const TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              minimumSize: const Size(96, 52),
            ),
            onPressed: _advance,
            child: const Text('Next'),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: FilledButton.tonalIcon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            onPressed: audio.isSpeaking
                ? () => audio.stop()
                : () => audio.speak(turn.text),
            icon: Icon(audio.isSpeaking ? Icons.stop : Icons.volume_up),
            label: Text(audio.isSpeaking ? 'Stop' : 'Replay'),
          ),
        ),
        const SizedBox(width: 12),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size(96, 52),
          ),
          onPressed: _advance,
          child: const Text('Next'),
        ),
      ],
    );
  }
}

class _TurnOutcome {
  const _TurnOutcome({
    required this.turnIndex,
    required this.expected,
    required this.heard,
    required this.score,
  });
  final int turnIndex;
  final String expected;
  final String heard;
  final double score;
}
