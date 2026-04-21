import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/audio_service.dart';
import '../../../shared/widgets/modern_card.dart';
import '../../../shared/data/practice_history.dart';
import '../data/exercise_repository.dart';
import '../domain/classic_exercise.dart';
import '../domain/session_config.dart';

/// Port of the matched-pairs listening drill (routed to
/// `auditoryHierarchyScreenContent` in ContentView.swift). One pair per
/// attempt: TTS plays either the first or second word at random; the user
/// taps which one they heard. A session runs for
/// `SessionConfig.itemsPerSession` attempts then offers to continue or end.
class MatchedPairsScreen extends ConsumerStatefulWidget {
  const MatchedPairsScreen({super.key, required this.subcategory});

  final MatchedPairsSubcategory subcategory;

  @override
  ConsumerState<MatchedPairsScreen> createState() => _MatchedPairsScreenState();
}

class _MatchedPairsScreenState extends ConsumerState<MatchedPairsScreen> {
  final _rand = math.Random();

  List<MatchedPair> _pool = const [];
  List<MatchedPair> _session = const [];
  int _index = 0;
  int _correct = 0;
  bool _loading = true;
  bool _targetIsFirst = true;
  String? _selected;
  bool _revealed = false;
  Timer? _autoAdvance;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void deactivate() {
    // `ref` is invalid once `dispose()` runs, so tear down audio here
    // while the element is still mounted.
    _autoAdvance?.cancel();
    ref.read(audioServiceProvider).stop();
    super.deactivate();
  }

  Future<void> _load() async {
    final pool = await ref
        .read(exerciseRepositoryProvider)
        .loadMatchedPairsFor(widget.subcategory);
    if (!mounted) return;
    setState(() {
      _pool = pool;
      _session = _drawSession();
      _loading = false;
    });
    _playCurrent();
  }

  List<MatchedPair> _drawSession() {
    final pool = _pool;
    if (pool.isEmpty) return const [];
    final shuffled = [...pool]..shuffle(_rand);
    final n = math.min(SessionConfig.itemsPerSession, shuffled.length);
    return shuffled.sublist(0, n);
  }

  MatchedPair? get _current =>
      _session.isEmpty ? null : _session[_index.clamp(0, _session.length - 1)];

  Future<void> _playCurrent() async {
    final p = _current;
    if (p == null) return;
    _targetIsFirst = _rand.nextBool();
    await ref
        .read(audioServiceProvider)
        .speak(_targetIsFirst ? p.first : p.second);
  }

  void _pick(String word) {
    if (_revealed) return;
    final p = _current!;
    final target = _targetIsFirst ? p.first : p.second;
    final isCorrect = word == target;
    setState(() {
      _selected = word;
      _revealed = true;
      if (isCorrect) _correct++;
    });
    ref.read(practiceHistoryProvider.notifier).add(
          PracticeAttempt(
            target: target,
            heard: word,
            score: isCorrect ? 1 : 0,
            timestamp: DateTime.now(),
          ),
        );
    if (isCorrect) {
      // Let the green check read for a beat, then move on automatically.
      _autoAdvance?.cancel();
      _autoAdvance = Timer(const Duration(milliseconds: 800), () {
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
      _selected = null;
      _revealed = false;
    });
    _playCurrent();
  }

  void _startNewSession() {
    _autoAdvance?.cancel();
    setState(() {
      _session = _drawSession();
      _index = 0;
      _correct = 0;
      _selected = null;
      _revealed = false;
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
          'You\'ve answered ${_revealed ? _index + 1 : _index} of ${_session.length}. '
          'Your score so far will be saved.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep going')),
          FilledButton.tonal(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('End')),
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
        title: Text('${widget.subcategory.displayName} — session complete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${(pct * 100).round()}%',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: pct >= 0.75
                      ? AppTheme.success(b)
                      : pct >= 0.5
                          ? AppTheme.warning(b)
                          : AppTheme.error(b),
                )),
            Text('$_correct of $answered correct',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary(b),
                )),
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
            child: Text(
                'Another ${SessionConfig.itemsPerSession}'),
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
    final audio = ref.watch(audioServiceProvider);
    final color = widget.subcategory.color(b);

    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary(b),
      appBar: AppBar(
        title: Text(widget.subcategory.displayName),
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
                    child: Text('No matched pairs found',
                        style: TextStyle(
                          color: AppTheme.textSecondary(b),
                        )))
                : _body(audio, color, b),
      ),
    );
  }

  Widget _body(AudioService audio, Color color, Brightness b) {
    final p = _current!;
    final target = _targetIsFirst ? p.first : p.second;
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        children: [
          Row(
            children: [
              Text('${_index + 1} / ${_session.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary(b),
                  )),
              const SizedBox(width: 12),
              Expanded(
                child: LinearProgressIndicator(
                  value: (_index + 1) / _session.length,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Text('$_correct correct',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.success(b),
                  )),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          ModernCard(
            child: Column(
              children: [
                Icon(audio.isSpeaking ? Icons.graphic_eq : Icons.headphones,
                    size: 40, color: color),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: audio.isSpeaking
                      ? null
                      : () async {
                          await ref
                              .read(audioServiceProvider)
                              .speak(target);
                        },
                  icon: const Icon(Icons.replay),
                  label: const Text('Replay'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text('Which word did you hear?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary(b),
              )),
          const SizedBox(height: AppTheme.spacingM),
          _choice(p.first, target, b),
          const SizedBox(height: AppTheme.spacingM),
          _choice(p.second, target, b),
          const Spacer(),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: color,
            ),
            onPressed: _revealed ? _next : null,
            child: Text(_index >= _session.length - 1 ? 'Finish' : 'Next'),
          ),
        ],
      ),
    );
  }

  Widget _choice(String word, String target, Brightness b) {
    final correct = _revealed && word == target;
    final wrongSelected = _revealed && _selected == word && !correct;
    final tileColor = correct
        ? AppTheme.success(b).withValues(alpha: 0.2)
        : wrongSelected
            ? AppTheme.error(b).withValues(alpha: 0.2)
            : AppTheme.cardBackground(b);
    return Material(
      color: tileColor,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        onTap: _revealed ? null : () => _pick(word),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Row(
            children: [
              Icon(
                correct
                    ? Icons.check_circle
                    : wrongSelected
                        ? Icons.cancel
                        : Icons.volume_up_outlined,
                color: correct
                    ? AppTheme.success(b)
                    : wrongSelected
                        ? AppTheme.error(b)
                        : AppTheme.primaryBlue(b),
              ),
              const SizedBox(width: 12),
              Text(word,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary(b),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

enum _SummaryAction { done, another }
