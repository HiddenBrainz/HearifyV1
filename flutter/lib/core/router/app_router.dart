import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/auth_controller.dart';
import '../../features/auth/presentation/patient_login_screen.dart';
import '../../features/classic_exercises/presentation/classic_exercises_hub_screen.dart';
import '../../features/clinician/presentation/clinician_dashboard_screen.dart';
import '../../features/clinician/presentation/clinician_linking_screen.dart';
import '../../features/conversations/presentation/conversation_hub_screen.dart';
import '../../features/education/presentation/about_screen.dart';
import '../../features/education/presentation/legal_documents_screens.dart';
import '../../features/education/presentation/module_program_screen.dart';
import '../../features/hearing_tests/presentation/advanced_listening_screen.dart';
import '../../features/hearing_tests/presentation/av_speech_test_screen.dart';
import '../../features/onboarding/data/consent_controller.dart';
import '../../features/onboarding/data/hearing_profile_controller.dart';
import '../../features/onboarding/presentation/data_consent_screen.dart';
import '../../features/onboarding/presentation/hearing_type_selection_screen.dart';
import '../../features/onboarding/presentation/legal_agreement_screen.dart';
import '../../features/education/domain/module_program.dart';
import '../../features/progress/presentation/progress_dashboard_screen.dart';
import '../../features/speaking_practice/presentation/phoneme_visualization_screen.dart';
import '../../features/speaking_practice/presentation/recording_history_screen.dart';
import '../../features/speaking_practice/presentation/speaking_practice_hub_screen.dart';
import '../../features/speaking_practice/presentation/speaking_practice_screen.dart';
import '../../features/speaking_practice/presentation/targeted_practice_screen.dart';
import '../theme/app_theme.dart';

/// Routes the user through the onboarding gauntlet in the same order as
/// HearifyV1App.swift: Login → Legal → Data Consent → Hearing Type → Home.
///
/// Each guard reads the corresponding provider so skipping a completed step
/// is automatic on relaunch.
GoRouter buildRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: _RouterRefresh(ref),
    redirect: (ctx, state) {
      final auth = ref.read(authControllerProvider);
      final legal = ref.read(legalAcceptanceProvider);
      final consent = ref.read(consentControllerProvider);
      final profile = ref.read(hearingProfileProvider);

      final loc = state.matchedLocation;

      if (!auth.isSignedIn && loc != '/login') return '/login';
      if (auth.isSignedIn && !legal && loc != '/onboarding/legal') {
        return '/onboarding/legal';
      }
      if (auth.isSignedIn &&
          legal &&
          !consent.flowComplete &&
          loc != '/onboarding/consent') {
        return '/onboarding/consent';
      }
      if (auth.isSignedIn &&
          legal &&
          consent.flowComplete &&
          !profile.completed &&
          loc != '/onboarding/hearing-type') {
        return '/onboarding/hearing-type';
      }
      if (auth.isSignedIn &&
          legal &&
          consent.flowComplete &&
          profile.completed &&
          (loc == '/login' || loc.startsWith('/onboarding'))) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HomeShell()),
      GoRoute(path: '/login', builder: (_, __) => const PatientLoginScreen()),
      GoRoute(
        path: '/onboarding/legal',
        builder: (_, __) => const LegalAgreementScreen(),
      ),
      GoRoute(
        path: '/onboarding/consent',
        builder: (_, __) => const DataConsentScreen(),
      ),
      GoRoute(
        path: '/onboarding/hearing-type',
        builder: (_, __) => const HearingTypeSelectionScreen(),
      ),
      GoRoute(path: '/about', builder: (_, __) => const AboutScreen()),
      GoRoute(
        path: '/about/terms',
        builder: (_, __) => const TermsOfServiceScreen(),
      ),
      GoRoute(
        path: '/about/privacy',
        builder: (_, __) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/education/module/:id',
        builder: (ctx, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 1;
          final profile = ref.read(hearingProfileProvider);
          final program = id == 2
              ? module2
              : (profile.selected == null
                  ? module1Default
                  : module1For(profile.selected!));
          return ModuleProgramScreen(
            program: program,
            onStartTraining: () {
              ctx.push(id == 2 ? '/speaking' : '/listening');
            },
          );
        },
      ),
      GoRoute(
        path: '/listening',
        builder: (_, __) => const AdvancedListeningScreen(),
      ),
      GoRoute(
        path: '/listening/voice-test',
        builder: (_, __) => const AvSpeechTestScreen(),
      ),
      GoRoute(
        path: '/speaking',
        builder: (_, __) => const SpeakingPracticeHubScreen(),
      ),
      GoRoute(
        path: '/speaking/practice',
        builder: (_, __) => const SpeakingPracticeScreen(),
      ),
      GoRoute(
        path: '/speaking/targeted',
        builder: (_, __) => const TargetedPracticeScreen(),
      ),
      GoRoute(
        path: '/speaking/phonemes',
        builder: (_, __) => const PhonemeVisualizationScreen(),
      ),
      GoRoute(
        path: '/speaking/history',
        builder: (_, __) => const RecordingHistoryScreen(),
      ),
      GoRoute(
        path: '/classic',
        builder: (_, __) => const ClassicExercisesHubScreen(),
      ),
      GoRoute(
        path: '/conversations',
        builder: (_, __) => const ConversationHubScreen(),
      ),
      GoRoute(
        path: '/progress',
        builder: (_, __) => const ProgressDashboardScreen(),
      ),
      GoRoute(
        path: '/clinician/link',
        builder: (_, __) => const ClinicianLinkingScreen(),
      ),
      GoRoute(
        path: '/clinician/dashboard',
        builder: (_, __) => const ClinicianDashboardScreen(),
      ),
    ],
  );
}

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(this._ref) {
    _sub = <ProviderSubscription>[
      _ref.listen(authControllerProvider, (_, __) => notifyListeners()),
      _ref.listen(legalAcceptanceProvider, (_, __) => notifyListeners()),
      _ref.listen(consentControllerProvider, (_, __) => notifyListeners()),
      _ref.listen(hearingProfileProvider, (_, __) => notifyListeners()),
    ];
  }

  final Ref _ref;
  late final List<ProviderSubscription> _sub;

  @override
  void dispose() {
    for (final s in _sub) {
      s.close();
    }
    super.dispose();
  }
}

/// Placeholder home — feature phases 4-9 slot their content here.
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = Theme.of(context).brightness;
    final profile = ref.watch(hearingProfileProvider);
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary(b),
      appBar: AppBar(
        title: const Text('Hearify'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => context.push('/about'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Welcome${profile.selected != null ? ' — ${profile.selected!.displayName} track' : ''}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary(b),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Phases 1-3 ported (foundation, auth/onboarding, education, shared UI). '
              'Hearing tests, speaking practice, conversations, and progress come next.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary(b),
              ),
            ),
            const SizedBox(height: 24),
            _moduleTile(
              context,
              title: 'Module 1 — Hearing Training',
              subtitle: profile.selected?.displayName ?? 'Default',
              icon: Icons.hearing,
              onTap: () => context.push('/education/module/1'),
              b: b,
            ),
            const SizedBox(height: 12),
            _moduleTile(
              context,
              title: 'Classic Exercises',
              subtitle:
                  'Matched Pairs, Word Recognition, Sentences in Noise…',
              icon: Icons.view_module,
              onTap: () => context.push('/classic'),
              b: b,
            ),
            const SizedBox(height: 12),
            _moduleTile(
              context,
              title: 'Listening Practice',
              subtitle: 'Advanced listening exercises',
              icon: Icons.headphones,
              onTap: () => context.push('/listening'),
              b: b,
            ),
            const SizedBox(height: 12),
            _moduleTile(
              context,
              title: 'Voice Test',
              subtitle: 'Compare TTS voices and speeds',
              icon: Icons.record_voice_over,
              onTap: () => context.push('/listening/voice-test'),
              b: b,
            ),
            const SizedBox(height: 12),
            _moduleTile(
              context,
              title: 'Module 2 — Speaking & Pronunciation',
              subtitle: 'Speech practice with feedback',
              icon: Icons.mic,
              onTap: () => context.push('/education/module/2'),
              b: b,
            ),
            const SizedBox(height: 12),
            _moduleTile(
              context,
              title: 'Speaking Practice',
              subtitle: 'Standard, targeted, phonemes, history',
              icon: Icons.mic_external_on,
              onTap: () => context.push('/speaking'),
              b: b,
            ),
            const SizedBox(height: 12),
            _moduleTile(
              context,
              title: 'Conversations',
              subtitle: 'Restaurant, medical, business scenarios',
              icon: Icons.forum_outlined,
              onTap: () => context.push('/conversations'),
              b: b,
            ),
            const SizedBox(height: 12),
            _moduleTile(
              context,
              title: 'Progress',
              subtitle: 'Streak, level, accuracy, achievements',
              icon: Icons.insights,
              onTap: () => context.push('/progress'),
              b: b,
            ),
            const SizedBox(height: 12),
            _moduleTile(
              context,
              title: 'Share with Clinician',
              subtitle: 'Generate a link code',
              icon: Icons.share,
              onTap: () => context.push('/clinician/link'),
              b: b,
            ),
            const SizedBox(height: 12),
            _moduleTile(
              context,
              title: 'Clinician Dashboard',
              subtitle: 'For audiologists — view linked patients',
              icon: Icons.medical_information_outlined,
              onTap: () => context.push('/clinician/dashboard'),
              b: b,
            ),
            const SizedBox(height: 12),
            _moduleTile(
              context,
              title: 'About Hearify',
              subtitle: 'Version, legal, credits',
              icon: Icons.info_outline,
              onTap: () => context.push('/about'),
              b: b,
            ),
          ],
        ),
      ),
    );
  }

  Widget _moduleTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required Brightness b,
  }) =>
      Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        color: AppTheme.cardBackground(b),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppTheme.primaryBlue(b).withValues(alpha: 0.15),
            child: Icon(icon, color: AppTheme.primaryBlue(b)),
          ),
          title: Text(title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary(b),
              )),
          subtitle: Text(subtitle,
              style: TextStyle(color: AppTheme.textSecondary(b))),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      );
}
