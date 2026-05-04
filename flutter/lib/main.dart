import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/firebase/firebase_bootstrap.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBootstrap.initialize();
  runApp(const ProviderScope(child: HearifyApp()));
}

class HearifyApp extends ConsumerWidget {
  const HearifyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Hearify',
      debugShowCheckedModeBanner: false,
      // The app's premium dark aesthetic (auth-card gradients, accent
      // colors on dark surfaces) is the design intent everywhere; the
      // light theme was never built out, so force dark on every device
      // regardless of the system appearance.
      theme: AppTheme.dark(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}

final routerProvider = Provider((ref) => buildRouter(ref));
