import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/auth_controller.dart';
import '../../features/auth/presentation/patient_login_screen.dart';
import '../../features/classic_exercises/presentation/classic_exercises_hub_screen.dart';
import '../../features/clinician/presentation/clinician_dashboard_screen.dart';
import '../../features/clinician/presentation/clinician_linking_screen.dart';
import '../../features/education/presentation/about_screen.dart';
import '../../features/education/presentation/legal_documents_screens.dart';
import '../../features/hearing_tests/presentation/advanced_listening_screen.dart';
import '../../features/hearing_tests/presentation/av_speech_test_screen.dart';
import '../../features/onboarding/data/consent_controller.dart';
import '../../features/onboarding/data/hearing_profile_controller.dart';
import '../../features/onboarding/presentation/data_consent_screen.dart';
import '../../features/onboarding/presentation/hearing_type_selection_screen.dart';
import '../../features/onboarding/presentation/legal_agreement_screen.dart';
import '../../features/progress/presentation/progress_dashboard_screen.dart';
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
        path: '/listening',
        builder: (_, __) => const AdvancedListeningScreen(),
      ),
      GoRoute(
        path: '/listening/voice-test',
        builder: (_, __) => const AvSpeechTestScreen(),
      ),
      GoRoute(
        path: '/classic',
        builder: (_, __) => const ClassicExercisesHubScreen(),
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
            const SizedBox(height: 24),
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
