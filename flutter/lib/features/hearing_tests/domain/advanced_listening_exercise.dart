import 'package:flutter/material.dart';

import 'common_models.dart';

/// Port of HearifyV1/Models/AdvancedListeningExercise.swift.
enum AdvancedExerciseType {
  soundDiscrimination(
      'Sound Discrimination', Icons.graphic_eq,
      'Distinguish between similar sounds'),
  sentenceComprehension(
      'Sentence Comprehension', Icons.chat_bubble_outline,
      'Understand complete sentences'),
  contextualListening(
      'Contextual Listening', Icons.menu_book_outlined,
      'Comprehend speech in context'),
  multipleChoice(
      'Multiple Choice', Icons.fact_check_outlined,
      'Select the correct answer from options'),
  fillInTheBlank(
      'Fill in the Blank', Icons.text_fields,
      'Identify missing words in sentences'),
  sequencing(
      'Sequence Ordering', Icons.format_list_numbered,
      'Put sentences in the correct order'),
  dictation(
      'Dictation', Icons.edit_note, 'Write exactly what you hear');

  const AdvancedExerciseType(this.displayName, this.icon, this.description);

  final String displayName;
  final IconData icon;
  final String description;
}

enum BackgroundNoiseLevel {
  none('Silent', 100, Icons.volume_off),
  quiet('Quiet (Library)', 20, Icons.volume_mute),
  moderate('Moderate (Office)', 10, Icons.volume_down),
  noisy('Noisy (Restaurant)', 5, Icons.volume_up),
  veryNoisy('Very Noisy (Street)', 0, Icons.campaign);

  const BackgroundNoiseLevel(this.displayName, this.snrDb, this.icon);
  final String displayName;
  final int snrDb;
  final IconData icon;
}

enum AudioSpeed {
  verySlow('0.5×', 0.5),
  slow('0.75×', 0.75),
  normal('1.0×', 1.0),
  fast('1.25×', 1.25),
  veryFast('1.5×', 1.5);

  const AudioSpeed(this.displayName, this.multiplier);
  final String displayName;
  final double multiplier;
}

class AudioContent {
  const AudioContent({
    required this.text,
    this.audioFile,
    this.durationSeconds = 0,
    this.speed = AudioSpeed.normal,
  });
  final String text;
  final String? audioFile;
  final double durationSeconds;
  final AudioSpeed speed;
}

enum QuestionType { multipleChoice, trueFalse, fillInBlank, shortAnswer, sequencing }

class ListeningQuestion {
  const ListeningQuestion({
    required this.questionType,
    required this.prompt,
    required this.correctAnswer,
    this.options = const [],
    this.hint = '',
  });
  final QuestionType questionType;
  final String prompt;
  final String correctAnswer;
  final List<String> options;
  final String hint;
}

class AdvancedListeningExercise {
  const AdvancedListeningExercise({
    required this.type,
    required this.difficulty,
    required this.title,
    required this.instructions,
    required this.audioContent,
    required this.questions,
    this.backgroundNoiseLevel = BackgroundNoiseLevel.none,
    this.adaptiveDifficulty = false,
  });
  final AdvancedExerciseType type;
  final DifficultyLevel difficulty;
  final String title;
  final String instructions;
  final AudioContent audioContent;
  final List<ListeningQuestion> questions;
  final BackgroundNoiseLevel backgroundNoiseLevel;
  final bool adaptiveDifficulty;
}

/// Hardcoded sample set — ported from the `extension` block in the Swift file.
/// CSV-driven content still lives in assets and is exposed via
/// `TrainingDataRepository`.
const List<AdvancedListeningExercise> sampleExercises = [
  AdvancedListeningExercise(
    type: AdvancedExerciseType.soundDiscrimination,
    difficulty: DifficultyLevel.easy,
    title: 'B vs D Sounds',
    instructions: 'Listen carefully and select which word you hear',
    audioContent:
        AudioContent(text: 'bat', durationSeconds: 1.0, speed: AudioSpeed.normal),
    questions: [
      ListeningQuestion(
        questionType: QuestionType.multipleChoice,
        prompt: 'Which word did you hear?',
        correctAnswer: 'bat',
        options: ['bat', 'dat', 'pat', 'mat'],
        hint: 'Listen for the initial sound',
      ),
    ],
  ),
  AdvancedListeningExercise(
    type: AdvancedExerciseType.sentenceComprehension,
    difficulty: DifficultyLevel.medium,
    title: 'Understanding Requests',
    instructions: 'Listen to the sentence and answer the question',
    audioContent: AudioContent(
        text: 'Could you please pass me the salt?',
        durationSeconds: 2.5,
        speed: AudioSpeed.normal),
    questions: [
      ListeningQuestion(
        questionType: QuestionType.multipleChoice,
        prompt: 'What is the speaker asking for?',
        correctAnswer: 'Salt',
        options: ['Salt', 'Sugar', 'Pepper', 'Water'],
        hint: 'Focus on the key noun',
      ),
      ListeningQuestion(
        questionType: QuestionType.trueFalse,
        prompt: 'Is the speaker being polite?',
        correctAnswer: 'True',
        options: ['True', 'False'],
        hint: 'Listen for polite phrases',
      ),
    ],
    backgroundNoiseLevel: BackgroundNoiseLevel.quiet,
  ),
  AdvancedListeningExercise(
    type: AdvancedExerciseType.contextualListening,
    difficulty: DifficultyLevel.hard,
    title: 'Airport Announcement',
    instructions: 'Listen to the announcement and answer the questions',
    audioContent: AudioContent(
        text:
            'Attention passengers. Flight 205 to Boston has been delayed by 30 minutes. '
            'The new departure time is 3:45 PM. We apologize for any inconvenience.',
        durationSeconds: 8.0,
        speed: AudioSpeed.normal),
    questions: [
      ListeningQuestion(
        questionType: QuestionType.multipleChoice,
        prompt: 'What is the flight number?',
        correctAnswer: '205',
        options: ['205', '215', '305', '105'],
        hint: 'Listen for numbers',
      ),
      ListeningQuestion(
        questionType: QuestionType.multipleChoice,
        prompt: 'How long is the delay?',
        correctAnswer: '30 minutes',
        options: ['15 minutes', '30 minutes', '45 minutes', '1 hour'],
        hint: 'Focus on time references',
      ),
      ListeningQuestion(
        questionType: QuestionType.multipleChoice,
        prompt: 'What is the new departure time?',
        correctAnswer: '3:45 PM',
        options: ['3:15 PM', '3:30 PM', '3:45 PM', '4:15 PM'],
        hint: 'Listen for the specific time',
      ),
    ],
    backgroundNoiseLevel: BackgroundNoiseLevel.moderate,
  ),
  AdvancedListeningExercise(
    type: AdvancedExerciseType.fillInTheBlank,
    difficulty: DifficultyLevel.medium,
    title: 'Complete the Sentence',
    instructions: 'Listen and fill in the missing word',
    audioContent: AudioContent(
        text: 'The cat is sleeping on the couch',
        durationSeconds: 2.0,
        speed: AudioSpeed.slow),
    questions: [
      ListeningQuestion(
        questionType: QuestionType.fillInBlank,
        prompt: 'The cat is _____ on the couch',
        correctAnswer: 'sleeping',
        hint: 'What action is the cat doing?',
      ),
    ],
  ),
  AdvancedListeningExercise(
    type: AdvancedExerciseType.dictation,
    difficulty: DifficultyLevel.hard,
    title: 'Medical Instructions',
    instructions: 'Write exactly what you hear',
    audioContent: AudioContent(
        text: 'Take two tablets twice a day with food',
        durationSeconds: 3.0,
        speed: AudioSpeed.normal),
    questions: [
      ListeningQuestion(
        questionType: QuestionType.shortAnswer,
        prompt: 'Write the complete sentence:',
        correctAnswer: 'take two tablets twice a day with food',
        hint: 'Listen for numbers and timing',
      ),
    ],
    backgroundNoiseLevel: BackgroundNoiseLevel.quiet,
  ),
];
