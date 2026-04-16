import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../hearing_tests/domain/common_models.dart';

/// Port of HearifyV1/Models/ConversationScenario.swift.
enum Speaker { user, other, narrator }

enum ScenarioCategory {
  restaurant('Restaurant', Icons.restaurant),
  shopping('Shopping', Icons.shopping_cart),
  medical('Medical', Icons.medical_services_outlined),
  business('Business', Icons.work_outline),
  social('Social', Icons.groups_outlined),
  travel('Travel', Icons.flight),
  emergency('Emergency', Icons.warning_amber_outlined),
  phone('Phone Call', Icons.phone_outlined);

  const ScenarioCategory(this.displayName, this.icon);
  final String displayName;
  final IconData icon;

  Color color(Brightness b) => switch (this) {
        ScenarioCategory.restaurant => AppTheme.accentOrange(b),
        ScenarioCategory.shopping => AppTheme.primaryCyan(b),
        ScenarioCategory.medical => AppTheme.error(b),
        ScenarioCategory.business => AppTheme.primaryBlue(b),
        ScenarioCategory.social => AppTheme.accentPurple(b),
        ScenarioCategory.travel => AppTheme.success(b),
        ScenarioCategory.emergency => AppTheme.warning(b),
        ScenarioCategory.phone => AppTheme.primaryBlue(b),
      };
}

class ConversationTurn {
  const ConversationTurn({
    required this.speaker,
    required this.text,
    this.audioHint = '',
    this.expectedResponses = const [],
    this.context = '',
    this.tip = '',
  });
  final Speaker speaker;
  final String text;
  final String audioHint;
  final List<String> expectedResponses;
  final String context;
  final String tip;
}

class ConversationScenario {
  const ConversationScenario({
    required this.title,
    required this.description,
    required this.difficulty,
    required this.category,
    required this.turns,
    this.context = '',
    this.culturalNotes = const [],
    this.keyPhrases = const [],
  });
  final String title;
  final String description;
  final DifficultyLevel difficulty;
  final ScenarioCategory category;
  final List<ConversationTurn> turns;
  final String context;
  final List<String> culturalNotes;
  final List<String> keyPhrases;
}

const List<ConversationScenario> sampleScenarios = [
  ConversationScenario(
    title: 'Ordering at a Restaurant',
    description: 'Practice ordering food and drinks at a restaurant',
    difficulty: DifficultyLevel.easy,
    category: ScenarioCategory.restaurant,
    turns: [
      ConversationTurn(
        speaker: Speaker.other,
        text: 'Good evening! Welcome to our restaurant. How many in your party?',
        audioHint: 'Good EE-vning! WEL-come to our RES-tuh-ront.',
        context: 'The host greets you at the entrance',
        tip: 'Speak clearly when stating numbers',
      ),
      ConversationTurn(
        speaker: Speaker.user,
        text: 'Table for two, please',
        audioHint: 'TAY-bul for TOO, pleez',
        expectedResponses: [
          'Table for two please',
          'Two people please',
          'A table for two'
        ],
        context: 'Request a table',
        tip: 'Stress "two" clearly to avoid confusion with "too"',
      ),
      ConversationTurn(
        speaker: Speaker.other,
        text: 'Perfect! Right this way. Here are your menus.',
        audioHint: 'PUR-fect! Here are your MEN-yooz.',
        context: 'The host leads you to your table',
      ),
      ConversationTurn(
        speaker: Speaker.user,
        text: 'Thank you',
        expectedResponses: ['Thank you', 'Thanks'],
        tip: 'Make eye contact and smile',
      ),
      ConversationTurn(
        speaker: Speaker.other,
        text: 'Are you ready to order, or do you need a few more minutes?',
        context: 'The waiter is taking your order',
      ),
      ConversationTurn(
        speaker: Speaker.user,
        text: "I'll have the grilled chicken, please",
        audioHint: "I'll have the GRILD CHIK-in, pleez",
        expectedResponses: [
          "I'll have the chicken",
          'The chicken please',
          'Can I have the chicken'
        ],
        tip: 'Pronounce "grilled" with one syllable: GRILD',
      ),
    ],
    context:
        "You're at a nice restaurant for dinner. The staff is friendly and professional.",
    culturalNotes: [
      "In the US, it's common to say 'please' when ordering",
      'Tipping 15–20% is expected in American restaurants',
      "It's polite to make eye contact with servers",
    ],
    keyPhrases: ["Table for two", "I'll have", 'Thank you', 'The check please'],
  ),
  ConversationScenario(
    title: "Doctor's Appointment",
    description: 'Describe symptoms and understand medical advice',
    difficulty: DifficultyLevel.medium,
    category: ScenarioCategory.medical,
    turns: [
      ConversationTurn(
        speaker: Speaker.other,
        text: 'Good morning. What brings you in today?',
        context: 'Doctor asking about your symptoms',
      ),
      ConversationTurn(
        speaker: Speaker.user,
        text: "I've been having headaches for three days",
        expectedResponses: [
          'I have headaches',
          'My head hurts',
          "I've been having headaches"
        ],
        tip: 'Stress important words: HEADACHES, THREE DAYS',
      ),
      ConversationTurn(
        speaker: Speaker.other,
        text: 'I see. How would you describe the pain? Is it sharp or dull?',
        context: 'Doctor asking for details',
      ),
      ConversationTurn(
        speaker: Speaker.user,
        text: "It's a dull, throbbing pain",
        expectedResponses: [
          'Dull throbbing pain',
          'A dull ache',
          'Throbbing pain'
        ],
        tip: '"Throbbing" = THROB-ing (2 syllables)',
      ),
    ],
    context:
        "You're at a doctor's office for a checkup. The doctor is professional and caring.",
    culturalNotes: [
      'Be honest and detailed about symptoms',
      'Bring a list of current medications',
      "It's okay to ask questions if you don't understand",
    ],
    keyPhrases: [
      "I've been having",
      'For three days',
      'It hurts when',
      'What should I do'
    ],
  ),
  ConversationScenario(
    title: 'Job Interview',
    description: 'Practice professional conversation and self-introduction',
    difficulty: DifficultyLevel.hard,
    category: ScenarioCategory.business,
    turns: [
      ConversationTurn(
        speaker: Speaker.other,
        text:
            'Good afternoon. Thank you for coming in today. Please, have a seat.',
        context: 'Interviewer greeting you',
        tip: 'Professional, confident tone is important',
      ),
      ConversationTurn(
        speaker: Speaker.user,
        text: 'Thank you for the opportunity to interview',
        audioHint: 'Thank you for the op-or-TU-ni-ty to IN-ter-view',
        expectedResponses: [
          'Thank you for having me',
          'Thanks for the opportunity',
          'I appreciate the opportunity'
        ],
        tip: 'Opportunity = op-or-TU-ni-ty (5 syllables)',
      ),
      ConversationTurn(
        speaker: Speaker.other,
        text:
            "Let's start with you telling me a bit about yourself and your experience.",
        context: 'Interviewer asking about your background',
      ),
      ConversationTurn(
        speaker: Speaker.user,
        text: 'I have five years of experience in software development',
        expectedResponses: [
          'I have experience in',
          "I've been working in",
          'My background is in'
        ],
        tip: 'Speak confidently, emphasize key skills',
      ),
    ],
    context:
        "You're in a formal job interview for a professional position.",
    culturalNotes: [
      'Maintain eye contact to show confidence',
      'Use professional language, avoid slang',
      "It's okay to pause and think before answering",
    ],
    keyPhrases: [
      'I have experience in',
      'My strength is',
      "I'm passionate about",
      'In my previous role'
    ],
  ),
];
