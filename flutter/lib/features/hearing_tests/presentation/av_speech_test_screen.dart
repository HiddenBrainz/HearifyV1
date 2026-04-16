import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/audio_service.dart';
import '../../../shared/widgets/modern_card.dart';

/// Port of HearifyV1/Views/AVSpeechTestView.swift.
/// Lets the user pick a TTS voice + speed and compare how the platform
/// synthesizes different sample phrases. On web the available voices come
/// from WebSpeech; on iOS from Apple's catalog; on Android from Google TTS.
class AvSpeechTestScreen extends ConsumerStatefulWidget {
  const AvSpeechTestScreen({super.key});

  @override
  ConsumerState<AvSpeechTestScreen> createState() =>
      _AvSpeechTestScreenState();
}

class _AvSpeechTestScreenState extends ConsumerState<AvSpeechTestScreen> {
  static const _samples = [
    'The quick brown fox jumps over the lazy dog.',
    'Could you please pass me the salt?',
    'Take two tablets twice a day with food.',
    'Wednesday, November twelfth, twenty twenty-six.',
    'Bat, pat, mat, cat, sat, hat, fat.',
  ];
  final _custom = TextEditingController(text: _samples.first);
  List<Map<String, String>> _voices = const [];
  String? _selectedVoiceName;
  String _selectedLocale = 'en-US';
  double _speed = 1.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadVoices());
  }

  @override
  void dispose() {
    _custom.dispose();
    ref.read(audioServiceProvider).stop();
    super.dispose();
  }

  Future<void> _loadVoices() async {
    final v = await ref.read(audioServiceProvider).availableVoices();
    if (!mounted) return;
    final filtered = v
        .where((m) => (m['locale'] ?? '').toLowerCase().startsWith('en'))
        .toList();
    setState(() => _voices = filtered.isEmpty ? v : filtered);
  }

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final audio = ref.watch(audioServiceProvider);
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary(b),
      appBar: AppBar(title: const Text('Voice Test')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          children: [
            ModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Voice',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary(b),
                      )),
                  const SizedBox(height: 8),
                  if (_voices.isEmpty)
                    Text('No voices available on this platform yet.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textTertiary(b),
                        ))
                  else
                    DropdownButtonFormField<String>(
                      initialValue: _selectedVoiceName,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: _voices
                          .map((m) => DropdownMenuItem<String>(
                                value: m['name'],
                                child: Text(
                                  '${m['name'] ?? '?'} · ${m['locale'] ?? ''}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (v) async {
                        setState(() => _selectedVoiceName = v);
                        final locale = _voices.firstWhere(
                            (m) => m['name'] == v,
                            orElse: () => const {})['locale'];
                        if (v != null && locale != null) {
                          _selectedLocale = locale;
                          await audio.setVoice(v, locale);
                        }
                      },
                    ),
                  const SizedBox(height: 16),
                  Text('Speed: ${_speed.toStringAsFixed(2)}×',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary(b),
                      )),
                  Slider(
                    value: _speed,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    label: '${_speed.toStringAsFixed(2)}×',
                    onChanged: (v) async {
                      setState(() => _speed = v);
                      await audio.setPlaybackSpeed(v);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            ModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Custom text',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary(b),
                      )),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _custom,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: AppTheme.primaryBlue(b),
                    ),
                    onPressed: audio.isSpeaking
                        ? () => audio.stop()
                        : () async {
                            await audio.setPlaybackSpeed(_speed);
                            await audio.speak(_custom.text);
                          },
                    icon: Icon(audio.isSpeaking ? Icons.stop : Icons.play_arrow),
                    label: Text(audio.isSpeaking ? 'Stop' : 'Speak'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text('Preset samples',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary(b),
                )),
            const SizedBox(height: 8),
            ..._samples.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ModernCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(s,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textPrimary(b),
                              )),
                        ),
                        IconButton(
                          onPressed: () async {
                            await audio.setPlaybackSpeed(_speed);
                            await audio.speak(s);
                          },
                          icon: Icon(Icons.play_circle_fill,
                              color: AppTheme.primaryBlue(b)),
                        ),
                      ],
                    ),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Locale: $_selectedLocale · Voices come from the host platform\'s '
                'TTS engine (Apple TTS on iOS, Google TTS on Android, WebSpeech on web).',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textTertiary(b),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
