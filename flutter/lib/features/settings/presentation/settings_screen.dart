import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/auth_design_system.dart';
import '../../../services/audio_service.dart';
import '../../../services/tts/prerendered_lookup.dart';
import '../../auth/data/auth_controller.dart';

/// Consolidates secondary entry points that used to live on the home
/// shell: About, clinician tools, and sign-out. Styled to match the
/// login / home premium dark aesthetic — each row is a dark auth-card
/// surface with a tinted leading icon so the list reads as a stack of
/// destinations rather than a raw list.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = Theme.of(context).brightness;
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
            'Settings',
            style: AppTextStyles.title.copyWith(fontSize: 20),
          ),
        ),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: AppGradients.screenBackground,
          ),
          child: SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                AppSpacing.l,
                AppSpacing.l,
                AppSpacing.xxl,
              ),
              children: [
                const _SectionLabel('Audio'),
                const SizedBox(height: AppSpacing.m),
                const _AudioSettingsCard(),
                const SizedBox(height: AppSpacing.xl),
                const _SectionLabel('General'),
                const SizedBox(height: AppSpacing.m),
                _SettingsTile(
                  icon: Icons.info_outline,
                  accent: AppTheme.primaryBlue(b),
                  title: 'About Hearify',
                  subtitle: 'Version, legal, credits',
                  onTap: () => context.push('/about'),
                ),
                const SizedBox(height: AppSpacing.m),
                _SettingsTile(
                  icon: Icons.share_outlined,
                  accent: AppTheme.success(b),
                  title: 'Share with Clinician',
                  subtitle: 'Generate a link code',
                  onTap: () => context.push('/clinician/link'),
                ),
                const SizedBox(height: AppSpacing.xl),
                _SettingsTile(
                  icon: Icons.logout,
                  accent: AppTheme.error(b),
                  title: 'Sign Out',
                  subtitle: null,
                  destructive: true,
                  onTap: () =>
                      ref.read(authControllerProvider.notifier).signOut(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.authCard,
        borderRadius: BorderRadius.circular(AppRadii.button),
        border: Border.all(
          color: accent.withValues(alpha: 0.45),
          width: 1.1,
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.button),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.button),
          splashColor: accent.withValues(alpha: 0.14),
          highlightColor: accent.withValues(alpha: 0.08),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l,
              vertical: AppSpacing.l,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppRadii.input),
                  ),
                  child: Icon(icon, color: accent, size: 22),
                ),
                const SizedBox(width: AppSpacing.l),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.ctaLabel.copyWith(
                          color: destructive ? accent : AppColors.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle!,
                          style: AppTextStyles.inputLabel.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textInactive,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.s),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.inputLabel.copyWith(
          fontSize: 12,
          letterSpacing: 1.2,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AudioSettingsCard extends ConsumerWidget {
  const _AudioSettingsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = Theme.of(context).brightness;
    final accent = AppTheme.primaryBlue(b);
    final audio = ref.watch(audioServiceProvider);
    final controller = ref.read(audioServiceProvider);
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
            blurRadius: 20,
            spreadRadius: -8,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.l,
        ),
        child: Column(
          children: [
            _SliderRow(
              icon: Icons.speed_rounded,
              label: 'Playback Speed',
              accent: accent,
              value: audio.currentSpeed,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              valueLabel: '${audio.currentSpeed.toStringAsFixed(1)}x',
              onChanged: controller.setPlaybackSpeed,
            ),
            const _RowDivider(),
            _SliderRow(
              icon: Icons.volume_up_rounded,
              label: 'Volume',
              accent: accent,
              value: audio.currentVolume,
              min: 0.0,
              max: 1.0,
              divisions: 20,
              valueLabel: '${(audio.currentVolume * 100).round()}%',
              onChanged: controller.setVolume,
            ),
            const _RowDivider(),
            _VoicePickerRow(accent: accent),
            const _RowDivider(),
            _SliderRow(
              icon: Icons.graphic_eq_rounded,
              label: 'Background Noise',
              accent: accent,
              value: audio.backgroundNoiseVolume,
              min: 0.0,
              max: 1.0,
              divisions: 20,
              valueLabel:
                  '${(audio.backgroundNoiseVolume * 100).round()}%',
              onChanged: controller.setBackgroundNoiseVolume,
            ),
          ],
        ),
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Divider(
        height: 1,
        thickness: 0.6,
        color: AppColors.hairline,
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.icon,
    required this.label,
    required this.accent,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.valueLabel,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String valueLabel;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final safe = value.clamp(min, max);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: accent),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.ctaLabel.copyWith(fontSize: 15),
              ),
            ),
            Text(
              valueLabel,
              style: AppTextStyles.ctaLabel.copyWith(
                fontSize: 14,
                color: accent,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: accent,
            inactiveTrackColor: AppColors.inputBackground,
            thumbColor: accent,
            overlayColor: accent.withValues(alpha: 0.18),
            valueIndicatorColor: accent,
            trackHeight: 3,
          ),
          child: Slider(
            value: safe,
            min: min,
            max: max,
            divisions: divisions,
            label: valueLabel,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

/// Picker that switches the bundled Kokoro voice used for every
/// pre-rendered stimulus and for runtime Sherpa Kokoro synthesis on
/// Custom Practice. The list comes from `assets/audio/tts/manifest.json`
/// produced by `tools/prerender_tts.py`.
class _VoicePickerRow extends ConsumerWidget {
  const _VoicePickerRow({required this.accent});
  final Color accent;

  Future<void> _openPicker(
    BuildContext context,
    AudioService audio,
    List<KokoroVoiceInfo> voices,
  ) async {
    final selected = await showModalBottomSheet<KokoroVoiceInfo>(
      context: context,
      backgroundColor: AppColors.authCardBase,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                0,
                AppSpacing.l,
                AppSpacing.l,
              ),
              itemCount: voices.length,
              separatorBuilder: (_, _) => const Divider(
                height: 1,
                thickness: 0.5,
                color: AppColors.hairline,
              ),
              itemBuilder: (_, i) {
                final v = voices[i];
                final isSelected = v.id == audio.kokoroVoiceId;
                return ListTile(
                  leading: Icon(
                    v.gender == 'male'
                        ? Icons.man_rounded
                        : Icons.woman_rounded,
                    color: accent,
                  ),
                  title: Text(
                    v.displayName,
                    style: AppTextStyles.ctaLabel.copyWith(fontSize: 15),
                  ),
                  subtitle: Text(
                    v.gender.isEmpty
                        ? v.id
                        : '${v.gender[0].toUpperCase()}${v.gender.substring(1)}  ·  ${v.id}',
                    style: AppTextStyles.inputLabel.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_rounded, color: accent)
                      : null,
                  onTap: () => Navigator.pop(context, v),
                );
              },
            ),
          ),
        );
      },
    );
    if (selected != null) {
      await audio.setKokoroVoice(selected.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audio = ref.watch(audioServiceProvider);
    final voices = audio.kokoroVoices;
    final ready = audio.isPrerenderedReady;
    final selectedId = audio.kokoroVoiceId;
    final selected = voices.where((v) => v.id == selectedId).firstOrNull;

    final String display;
    if (!ready) {
      display = 'Loading…';
    } else if (voices.isEmpty) {
      display = 'No voices bundled';
    } else if (selected == null) {
      display = 'Default';
    } else {
      display = selected.gender.isEmpty
          ? selected.displayName
          : '${selected.displayName}  ·  ${selected.gender[0].toUpperCase()}${selected.gender.substring(1)}';
    }

    final canTap = ready && voices.isNotEmpty;
    return InkWell(
      onTap: canTap ? () => _openPicker(context, audio, voices) : null,
      borderRadius: BorderRadius.circular(AppRadii.input),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Icon(Icons.record_voice_over_rounded, size: 18, color: accent),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Voice',
                    style: AppTextStyles.ctaLabel.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    display,
                    style: AppTextStyles.inputLabel.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.expand_more_rounded,
              color: canTap ? accent : AppColors.textPlaceholder,
            ),
          ],
        ),
      ),
    );
  }
}
