import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/auth_controller.dart';
import '../../features/auth/presentation/patient_login_screen.dart';
import '../../features/classic_exercises/presentation/training_categories_screen.dart';
import '../../features/clinician/presentation/clinician_dashboard_screen.dart';
import '../../features/clinician/presentation/clinician_linking_screen.dart';
import '../../features/education/presentation/about_screen.dart';
import '../../features/education/presentation/legal_documents_screens.dart';
import '../../features/hearing_tests/presentation/advanced_listening_screen.dart';
import '../../features/hearing_tests/presentation/av_speech_test_screen.dart';
import '../../features/onboarding/data/consent_controller.dart';
import '../../features/onboarding/data/hearing_profile_controller.dart';
import '../../features/onboarding/presentation/data_consent_screen.dart';
import '../../features/onboarding/presentation/legal_agreement_screen.dart';
import '../../features/onboarding/presentation/welcome_screen.dart';
import '../../features/practice_list/presentation/practice_list_screen.dart';
import '../../features/progress/presentation/progress_dashboard_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

/// Routes the user through the onboarding gauntlet in the same order as
/// HearifyV1App.swift: Login → Legal → Data Consent → Hearing Type → Home.
///
/// Each guard reads the corresponding provider so skipping a completed step
/// is automatic on relaunch. Home (`/`) is the Training Categories landing;
/// the former `/classic` hub collapsed into it and now redirects there.
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
          loc != '/onboarding/welcome') {
        return '/onboarding/welcome';
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
      GoRoute(
        path: '/',
        builder: (_, _) => const TrainingCategoriesScreen(),
      ),
      GoRoute(path: '/login', builder: (_, _) => const PatientLoginScreen()),
      GoRoute(
        path: '/onboarding/legal',
        builder: (_, _) => const LegalAgreementScreen(),
      ),
      GoRoute(
        path: '/onboarding/consent',
        builder: (_, _) => const DataConsentScreen(),
      ),
      GoRoute(
        path: '/onboarding/welcome',
        builder: (_, _) => const WelcomeScreen(),
      ),
      GoRoute(path: '/about', builder: (_, _) => const AboutScreen()),
      GoRoute(
        path: '/about/terms',
        builder: (_, _) => const TermsOfServiceScreen(),
      ),
      GoRoute(
        path: '/about/privacy',
        builder: (_, _) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/listening',
        builder: (_, _) => const AdvancedListeningScreen(),
      ),
      GoRoute(
        path: '/listening/voice-test',
        builder: (_, _) => const AvSpeechTestScreen(),
      ),
      // Preserve old deep links: /classic now folds into the home grid.
      GoRoute(path: '/classic', redirect: (_, _) => '/'),
      GoRoute(
        path: '/progress',
        builder: (_, _) => const ProgressDashboardScreen(),
      ),
      GoRoute(
        path: '/practice-list',
        builder: (_, _) => const PracticeListScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, _) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/clinician/link',
        builder: (_, _) => const ClinicianLinkingScreen(),
      ),
      GoRoute(
        path: '/clinician/dashboard',
        builder: (_, _) => const ClinicianDashboardScreen(),
      ),
    ],
  );
}

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(this._ref) {
    _sub = <ProviderSubscription>[
      _ref.listen(authControllerProvider, (_, _) => notifyListeners()),
      _ref.listen(legalAcceptanceProvider, (_, _) => notifyListeners()),
      _ref.listen(consentControllerProvider, (_, _) => notifyListeners()),
      _ref.listen(hearingProfileProvider, (_, _) => notifyListeners()),
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
