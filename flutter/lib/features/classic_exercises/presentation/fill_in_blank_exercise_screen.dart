import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/audio_service.dart';
import '../../../shared/data/practice_history.dart';
import '../../../shared/widgets/modern_card.dart';
import '../data/exercise_repository.dart';
import '../domain/classic_exercise.dart';
import '../domain/session_config.dart';

/// Sentence Comprehension — Level 2 (Fill in the Blank). Plays the
/// full sentence via TTS, displays it with the last content word
/// blanked, the user types the missing word. Case + punctuation
/// insensitive. Auto-advances on a correct answer.
class FillInBlankExerciseScreen extends ConsumerStatefulWidget {
  const FillInBlankExerciseScreen({super.key});

  @override
  ConsumerState<FillInBlankExerciseScreen> createState() =>
      _FillInBlankExerciseScreenState();
}

class _FillInBlankExerciseScreenState
    extends ConsumerState<FillInBlankExerciseScreen> {
  final _rand = math.Random();
  final _input = TextEditingController();
  final _inputFocus = FocusNode();

  List<_Cloze> _session = const [];
  int _index = 0;
  int _correct = 0;
  bool _loading = true;
  bool _revealed = false;
  bool _lastAttemptCorrect = false;
  Timer? _autoAdvance;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void deactivate() {
    _autoAdvance?.cancel();
    ref.read(audioServiceProvider).stop();
    super.deactivate();
  }

  @override
  void dispose() {
    _input.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final pool = await ref
        .read(exerciseRepositoryProvider)
        .loadSentenceComprehension();
    final clozes = <_Cloze>[];
    for (final item in pool) {
      final masked = _maskLastWord(item.prompt);
      if (masked != null) clozes.add(masked);
    }
    if (!mounted) return;
    setState(() {
      _session = _drawSession(clozes);
      _loading = false;
    });
    _playCurrent();
  }

  List<_Cloze> _drawSession(List<_Cloze> pool) {
    if (pool.isEmpty) return const [];
    final shuffled = [...pool]..shuffle(_rand);
    final n = math.min(SessionConfig.itemsPerSession, shuffled.length);
    return shuffled.sublist(0, n);
  }

  _Cloze? get _current =>
      _session.isEmpty ? null : _session[_index.clamp(0, _session.length - 1)];

  Future<void> _playCurrent() async {
    final c = _current;
    if (c == null) return;
    await ref.read(audioServiceProvider).speak(c.fullSentence);
  }

  void _submit() {
    final c = _current;
    if (c == null || _revealed) return;
    final guess = _input.text;
    final correct = _normalize(guess) == _normalize(c.answer);
    setState(() {
      _revealed = true;
      _lastAttemptCorrect = correct;
      if (correct) _correct++;
    });
    ref.read(practiceHistoryProvider.notifier).add(
          PracticeAttempt(
            target: c.answer,
            heard: guess,
            score: correct ? 1 : 0,
            timestamp: DateTime.now(),
          ),
        );
    _inputFocus.unfocus();
    if (correct) {
      _autoAdvance?.cancel();
      _autoAdvance = Timer(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        _next();
      });
    }
  }

  void _next() {
    _autoAdvance?.cancel();
    if (_index >= _session.length - 1) {
      _showSummary();
      return;
    }
    setState(() {
      _index++;
      _revealed = false;
      _lastAttemptCorrect = false;
      _input.clear();
    });
    _playCurrent();
  }

  void _startNewSession() {
    _autoAdvance?.cancel();
    setState(() {
      _index = 0;
      _correct = 0;
      _revealed = false;
      _lastAttemptCorrect = false;
      _input.clear();
    });
    _playCurrent();
  }

  Future<void> _endEarly() async {
    _autoAdvance?.cancel();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('End session?'),
        content: Text(
          'You\'ve answered ${_revealed ? _index + 1 : _index} of '
          '${_session.length}. Your score so far will be saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep going'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('End'),
          ),
        ],
      ),
    );
    if (confirm == true) _showSummary();
  }

  Future<void> _showSummary() async {
    await ref.read(audioServiceProvider).stop();
    if (!mounted) return;
    final answered = _revealed ? _index + 1 : _index;
    final pct = answered == 0 ? 0.0 : _correct / answered;
    final b = Theme.of(context).brightness;
    final action = await showDialog<_SummaryAction>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        title: const Text('Fill in the Blank — session complete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${(pct * 100).round()}%',
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.bold,
                color: pct >= 0.75
                    ? AppTheme.success(b)
                    : pct >= 0.5
                        ? AppTheme.warning(b)
                        : AppTheme.error(b),
              ),
            ),
            Text(
              '$_correct of $answered correct',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary(b),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(_SummaryAction.done),
            child: const Text('Done'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(_SummaryAction.another),
            child: Text('Another ${SessionConfig.itemsPerSession}'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (action == _SummaryAction.another) {
      _startNewSession();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final accent = SentenceComprehensionLevel.fillInTheBlank.color(b);
    final audio = ref.watch(audioServiceProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary(b),
      appBar: AppBar(
        title: const Text('Fill in the Blank'),
        actions: [
          if (!_loading && _session.isNotEmpty)
            IconButton(
              tooltip: 'End session',
              icon: const Icon(Icons.close),
              onPressed: _endEarly,
            ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _current == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No sentences could be cloze-masked. Check that '
                        'SentenceComprehensionData.csv has full-sentence prompts.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textSecondary(b)),
                      ),
                    ),
                  )
                : _body(accent, audio, b),
      ),
    );
  }

  Widget _body(Color accent, AudioService audio, Brightness b) {
    final c = _current!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                '${_index + 1} / ${_session.length}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary(b),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LinearProgressIndicator(
                  value: (_index + 1) / _session.length,
                  color: accent,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$_correct correct',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.success(b),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          ModernCard(
            child: Column(
              children: [
                Icon(
                  audio.isSpeaking ? Icons.graphic_eq : Icons.headphones,
                  size: 40,
                  color: accent,
                ),
                const SizedBox(height: 8),
                Text(
                  'Listen — fill in the missing word',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary(b),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: audio.isSpeaking ? null : _playCurrent,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          ModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MaskedSentence(
                  cloze: c,
                  revealed: _revealed,
                  correct: _lastAttemptCorrect,
                  accent: accent,
                ),
                const SizedBox(height: AppTheme.spacingM),
                TextField(
                  controller: _input,
                  focusNode: _inputFocus,
                  enabled: !_revealed,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: 'Missing word',
                    border: const OutlineInputBorder(),
                    suffixIcon: _revealed
                        ? Icon(
                            _lastAttemptCorrect
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: _lastAttemptCorrect
                                ? AppTheme.success(b)
                                : AppTheme.error(b),
                          )
                        : null,
                  ),
                  style: TextStyle(color: AppTheme.textPrimary(b)),
                ),
                if (_revealed && !_lastAttemptCorrect) ...[
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    'Answer: ${c.answer}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.success(b),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: accent,
            ),
            onPressed: _revealed
                ? _next
                : (_input.text.trim().isEmpty ? null : _submit),
            child: Text(
              _revealed
                  ? (_index >= _session.length - 1 ? 'Finish' : 'Next')
                  : 'Check',
            ),
          ),
        ],
      ),
    );
  }

  static String _normalize(String s) =>
      s.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  /// Returns a cloze form with the last word masked out. Skips the
  /// sentence entirely if no word boundary is found.
  static _Cloze? _maskLastWord(String sentence) {
    final trimmed = sentence.trim();
    if (trimmed.isEmpty) return null;
    final match =
        RegExp(r"([A-Za-z][A-Za-z'-]*)([^A-Za-z]*)$").firstMatch(trimmed);
    if (match == null) return null;
    final word = match.group(1)!;
    final trailing = match.group(2) ?? '';
    final prefix = trimmed.substring(0, match.start);
    return _Cloze(
      fullSentence: trimmed,
      prefix: prefix,
      trailing: trailing,
      answer: word,
    );
  }
}

class _Cloze {
  const _Cloze({
    required this.fullSentence,
    required this.prefix,
    required this.trailing,
    required this.answer,
  });

  final String fullSentence;
  final String prefix;
  final String trailing;
  final String answer;
}

class _MaskedSentence extends StatelessWidget {
  const _MaskedSentence({
    required this.cloze,
    required this.revealed,
    required this.correct,
    required this.accent,
  });

  final _Cloze cloze;
  final bool revealed;
  final bool correct;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final blankColor = revealed
        ? (correct ? AppTheme.success(b) : AppTheme.error(b))
        : accent;
    final blankText = revealed ? cloze.answer : '_____';
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 18,
          height: 1.5,
          color: AppTheme.textPrimary(b),
        ),
        children: [
          TextSpan(text: cloze.prefix),
          TextSpan(
            text: blankText,
            style: TextStyle(
              color: blankColor,
              fontWeight: FontWeight.w700,
              decoration: revealed ? null : TextDecoration.underline,
              decorationColor: blankColor,
              decorationThickness: 2,
            ),
          ),
          TextSpan(text: cloze.trailing),
        ],
      ),
    );
  }
}

enum _SummaryAction { done, another }
