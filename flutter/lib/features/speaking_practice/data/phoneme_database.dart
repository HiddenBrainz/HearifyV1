import '../domain/phoneme.dart';

/// Port of HearifyV1/Models/PhonemeDatabase.swift — the 40+ phoneme catalog
/// used by speaking-practice screens. The Swift source has additional
/// articulation metadata (tongue position, airflow type, etc.) that the
/// Phoneme Visualization canvas needs; we keep the core data only for now
/// and expand as the visualization feature is ported.
class PhonemeDatabase {
  PhonemeDatabase._();
  static final PhonemeDatabase shared = PhonemeDatabase._();

  static const List<Phoneme> all = [
    // ── Stops
    Phoneme(
      symbol: '/p/',
      name: 'Voiceless Bilabial Stop',
      examples: ['pat', 'spin', 'stop'],
      category: PhonemeCategory.stops,
      voicing: Voicing.voiceless,
      difficulty: Difficulty.easy,
      description: 'Lips close briefly, then release a puff of air.',
    ),
    Phoneme(
      symbol: '/b/',
      name: 'Voiced Bilabial Stop',
      examples: ['bat', 'rib', 'baby'],
      category: PhonemeCategory.stops,
      voicing: Voicing.voiced,
      difficulty: Difficulty.easy,
    ),
    Phoneme(
      symbol: '/t/',
      name: 'Voiceless Alveolar Stop',
      examples: ['top', 'stop', 'cat'],
      category: PhonemeCategory.stops,
      voicing: Voicing.voiceless,
      difficulty: Difficulty.easy,
    ),
    Phoneme(
      symbol: '/d/',
      name: 'Voiced Alveolar Stop',
      examples: ['dog', 'mad', 'red'],
      category: PhonemeCategory.stops,
      voicing: Voicing.voiced,
      difficulty: Difficulty.easy,
    ),
    Phoneme(
      symbol: '/k/',
      name: 'Voiceless Velar Stop',
      examples: ['cat', 'back', 'cook'],
      category: PhonemeCategory.stops,
      voicing: Voicing.voiceless,
      difficulty: Difficulty.easy,
    ),
    Phoneme(
      symbol: '/g/',
      name: 'Voiced Velar Stop',
      examples: ['go', 'bag', 'egg'],
      category: PhonemeCategory.stops,
      voicing: Voicing.voiced,
      difficulty: Difficulty.easy,
    ),
    // ── Fricatives
    Phoneme(
      symbol: '/f/',
      name: 'Voiceless Labiodental Fricative',
      examples: ['fan', 'leaf', 'off'],
      category: PhonemeCategory.fricatives,
      voicing: Voicing.voiceless,
      difficulty: Difficulty.medium,
    ),
    Phoneme(
      symbol: '/v/',
      name: 'Voiced Labiodental Fricative',
      examples: ['van', 'dove', 'save'],
      category: PhonemeCategory.fricatives,
      voicing: Voicing.voiced,
      difficulty: Difficulty.medium,
    ),
    Phoneme(
      symbol: '/θ/',
      name: 'Voiceless Dental Fricative',
      examples: ['thin', 'bath', 'think'],
      category: PhonemeCategory.fricatives,
      voicing: Voicing.voiceless,
      difficulty: Difficulty.hard,
    ),
    Phoneme(
      symbol: '/ð/',
      name: 'Voiced Dental Fricative',
      examples: ['this', 'bathe', 'that'],
      category: PhonemeCategory.fricatives,
      voicing: Voicing.voiced,
      difficulty: Difficulty.hard,
    ),
    Phoneme(
      symbol: '/s/',
      name: 'Voiceless Alveolar Fricative',
      examples: ['sip', 'miss', 'sea'],
      category: PhonemeCategory.fricatives,
      voicing: Voicing.voiceless,
      difficulty: Difficulty.medium,
    ),
    Phoneme(
      symbol: '/z/',
      name: 'Voiced Alveolar Fricative',
      examples: ['zip', 'buzz', 'zero'],
      category: PhonemeCategory.fricatives,
      voicing: Voicing.voiced,
      difficulty: Difficulty.medium,
    ),
    Phoneme(
      symbol: '/ʃ/',
      name: 'Voiceless Postalveolar Fricative',
      examples: ['ship', 'wish', 'she'],
      category: PhonemeCategory.fricatives,
      voicing: Voicing.voiceless,
      difficulty: Difficulty.medium,
    ),
    Phoneme(
      symbol: '/ʒ/',
      name: 'Voiced Postalveolar Fricative',
      examples: ['measure', 'vision', 'treasure'],
      category: PhonemeCategory.fricatives,
      voicing: Voicing.voiced,
      difficulty: Difficulty.hard,
    ),
    Phoneme(
      symbol: '/h/',
      name: 'Voiceless Glottal Fricative',
      examples: ['hat', 'behind', 'hello'],
      category: PhonemeCategory.fricatives,
      voicing: Voicing.voiceless,
      difficulty: Difficulty.easy,
    ),
    // ── Affricates
    Phoneme(
      symbol: '/tʃ/',
      name: 'Voiceless Postalveolar Affricate',
      examples: ['chip', 'catch', 'church'],
      category: PhonemeCategory.affricates,
      voicing: Voicing.voiceless,
      difficulty: Difficulty.medium,
    ),
    Phoneme(
      symbol: '/dʒ/',
      name: 'Voiced Postalveolar Affricate',
      examples: ['judge', 'edge', 'gym'],
      category: PhonemeCategory.affricates,
      voicing: Voicing.voiced,
      difficulty: Difficulty.medium,
    ),
    // ── Nasals
    Phoneme(
      symbol: '/m/',
      name: 'Bilabial Nasal',
      examples: ['man', 'sum', 'mom'],
      category: PhonemeCategory.nasals,
      voicing: Voicing.voiced,
      difficulty: Difficulty.easy,
    ),
    Phoneme(
      symbol: '/n/',
      name: 'Alveolar Nasal',
      examples: ['no', 'sun', 'nine'],
      category: PhonemeCategory.nasals,
      voicing: Voicing.voiced,
      difficulty: Difficulty.easy,
    ),
    Phoneme(
      symbol: '/ŋ/',
      name: 'Velar Nasal',
      examples: ['sing', 'ring', 'song'],
      category: PhonemeCategory.nasals,
      voicing: Voicing.voiced,
      difficulty: Difficulty.medium,
    ),
    // ── Liquids / glides
    Phoneme(
      symbol: '/l/',
      name: 'Alveolar Lateral',
      examples: ['lip', 'ball', 'love'],
      category: PhonemeCategory.liquids,
      voicing: Voicing.voiced,
      difficulty: Difficulty.medium,
    ),
    Phoneme(
      symbol: '/r/',
      name: 'Alveolar Approximant',
      examples: ['red', 'car', 'around'],
      category: PhonemeCategory.liquids,
      voicing: Voicing.voiced,
      difficulty: Difficulty.hard,
    ),
    Phoneme(
      symbol: '/w/',
      name: 'Bilabial Glide',
      examples: ['wet', 'away', 'water'],
      category: PhonemeCategory.glides,
      voicing: Voicing.voiced,
      difficulty: Difficulty.easy,
    ),
    Phoneme(
      symbol: '/j/',
      name: 'Palatal Glide',
      examples: ['yes', 'beyond', 'yellow'],
      category: PhonemeCategory.glides,
      voicing: Voicing.voiced,
      difficulty: Difficulty.easy,
    ),
    // ── Vowels (subset)
    Phoneme(
      symbol: '/i/',
      name: 'Close Front Unrounded',
      examples: ['bee', 'see', 'eat'],
      category: PhonemeCategory.frontVowels,
      voicing: Voicing.voiced,
      difficulty: Difficulty.easy,
    ),
    Phoneme(
      symbol: '/ɪ/',
      name: 'Near-Close Near-Front',
      examples: ['bit', 'sit', 'in'],
      category: PhonemeCategory.frontVowels,
      voicing: Voicing.voiced,
      difficulty: Difficulty.medium,
    ),
    Phoneme(
      symbol: '/ɛ/',
      name: 'Open-Mid Front',
      examples: ['bet', 'set', 'pen'],
      category: PhonemeCategory.frontVowels,
      voicing: Voicing.voiced,
      difficulty: Difficulty.medium,
    ),
    Phoneme(
      symbol: '/æ/',
      name: 'Near-Open Front',
      examples: ['cat', 'bat', 'apple'],
      category: PhonemeCategory.frontVowels,
      voicing: Voicing.voiced,
      difficulty: Difficulty.medium,
    ),
    Phoneme(
      symbol: '/u/',
      name: 'Close Back Rounded',
      examples: ['boot', 'shoe', 'food'],
      category: PhonemeCategory.backVowels,
      voicing: Voicing.voiced,
      difficulty: Difficulty.easy,
    ),
    Phoneme(
      symbol: '/ʊ/',
      name: 'Near-Close Near-Back Rounded',
      examples: ['book', 'put', 'foot'],
      category: PhonemeCategory.backVowels,
      voicing: Voicing.voiced,
      difficulty: Difficulty.medium,
    ),
    Phoneme(
      symbol: '/ɔ/',
      name: 'Open-Mid Back Rounded',
      examples: ['thought', 'law', 'saw'],
      category: PhonemeCategory.backVowels,
      voicing: Voicing.voiced,
      difficulty: Difficulty.medium,
    ),
    Phoneme(
      symbol: '/ɑ/',
      name: 'Open Back Unrounded',
      examples: ['father', 'palm', 'hot'],
      category: PhonemeCategory.backVowels,
      voicing: Voicing.voiced,
      difficulty: Difficulty.medium,
    ),
    Phoneme(
      symbol: '/ʌ/',
      name: 'Open-Mid Back Unrounded',
      examples: ['cup', 'bus', 'love'],
      category: PhonemeCategory.centralVowels,
      voicing: Voicing.voiced,
      difficulty: Difficulty.medium,
    ),
    Phoneme(
      symbol: '/ə/',
      name: 'Schwa',
      examples: ['about', 'taken', 'supply'],
      category: PhonemeCategory.centralVowels,
      voicing: Voicing.voiced,
      difficulty: Difficulty.medium,
    ),
    // ── Diphthongs
    Phoneme(
      symbol: '/eɪ/',
      name: 'Face Diphthong',
      examples: ['day', 'pay', 'late'],
      category: PhonemeCategory.diphthongs,
      voicing: Voicing.voiced,
      difficulty: Difficulty.medium,
    ),
    Phoneme(
      symbol: '/aɪ/',
      name: 'Price Diphthong',
      examples: ['my', 'time', 'bike'],
      category: PhonemeCategory.diphthongs,
      voicing: Voicing.voiced,
      difficulty: Difficulty.medium,
    ),
    Phoneme(
      symbol: '/ɔɪ/',
      name: 'Choice Diphthong',
      examples: ['boy', 'coin', 'toy'],
      category: PhonemeCategory.diphthongs,
      voicing: Voicing.voiced,
      difficulty: Difficulty.medium,
    ),
    Phoneme(
      symbol: '/aʊ/',
      name: 'Mouth Diphthong',
      examples: ['now', 'cow', 'out'],
      category: PhonemeCategory.diphthongs,
      voicing: Voicing.voiced,
      difficulty: Difficulty.medium,
    ),
    Phoneme(
      symbol: '/oʊ/',
      name: 'Goat Diphthong',
      examples: ['go', 'boat', 'show'],
      category: PhonemeCategory.diphthongs,
      voicing: Voicing.voiced,
      difficulty: Difficulty.medium,
    ),
  ];

  List<Phoneme> byCategory(PhonemeCategory c) =>
      all.where((p) => p.category == c).toList();

  List<Phoneme> byDifficulty(Difficulty d) =>
      all.where((p) => p.difficulty == d).toList();

  Phoneme? bySymbol(String symbol) {
    for (final p in all) {
      if (p.symbol == symbol) return p;
    }
    return null;
  }

  /// Classic minimal-contrast pairs used by targeted practice.
  List<PhonemePair> getComparisonPairs() {
    Phoneme find(String s) => bySymbol(s)!;
    return [
      PhonemePair(
        a: find('/θ/'),
        b: find('/ð/'),
        title: 'Voiceless vs voiced "th"',
        description: 'think / this',
      ),
      PhonemePair(
        a: find('/r/'),
        b: find('/l/'),
        title: 'R vs L',
        description: 'red / led',
      ),
      PhonemePair(
        a: find('/v/'),
        b: find('/w/'),
        title: 'V vs W',
        description: 'vet / wet',
      ),
      PhonemePair(
        a: find('/s/'),
        b: find('/ʃ/'),
        title: 'S vs SH',
        description: 'sip / ship',
      ),
      PhonemePair(
        a: find('/b/'),
        b: find('/v/'),
        title: 'B vs V',
        description: 'bent / vent',
      ),
      PhonemePair(
        a: find('/f/'),
        b: find('/v/'),
        title: 'F vs V',
        description: 'fan / van',
      ),
      PhonemePair(
        a: find('/tʃ/'),
        b: find('/ʃ/'),
        title: 'CH vs SH',
        description: 'chip / ship',
      ),
    ];
  }
}
