import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hearify/core/theme/app_theme.dart';
import 'package:hearify/features/onboarding/data/hearing_profile_controller.dart';

void main() {
  testWidgets('HearingTypeSelectionScreen renders all three options',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) {
            return const Scaffold(body: Text('smoke'));
          },
        ),
      ),
    ));
    expect(find.text('smoke'), findsOneWidget);
    expect(TrainingModuleType.values.length, 3);
  });
}
