//
//  PhonemeDatabase.swift
//  HearifyV1
//
//  Complete database of English phonemes with visual data
//  Phase 3: Computer Vision & Visual Graphics
//

import Foundation

class PhonemeDatabase {
    static let shared = PhonemeDatabase()

    // MARK: - All Phonemes
    private(set) var allPhonemes: [PhonemeVisual] = []

    // MARK: - Category-based access
    var consonants: [PhonemeVisual] {
        allPhonemes.filter {
            $0.mannerOfArticulation != .vowel
        }
    }

    var vowels: [PhonemeVisual] {
        allPhonemes.filter {
            $0.mannerOfArticulation == .vowel &&
            $0.category != .diphthong
        }
    }

    var diphthongs: [PhonemeVisual] {
        allPhonemes.filter {
            $0.category == .diphthong
        }
    }

    // MARK: - Difficulty-based access
    func phonemes(difficulty: DifficultyLevel) -> [PhonemeVisual] {
        return allPhonemes.filter { $0.difficultyLevel == difficulty }
    }

    // MARK: - Category-based access
    func phonemes(category: PhonemeCategory) -> [PhonemeVisual] {
        return allPhonemes.filter { $0.category == category }
    }

    // MARK: - Get specific phoneme
    func phoneme(symbol: String) -> PhonemeVisual? {
        return allPhonemes.first { $0.symbol == symbol }
    }

    // MARK: - Initialization
    private init() {
        allPhonemes = createPhonemeDatabase()
    }

    // MARK: - Database Creation
    private func createPhonemeDatabase() -> [PhonemeVisual] {
        var phonemes: [PhonemeVisual] = []

        // CONSONANTS - STOPS
        phonemes.append(PhonemeVisual(
            id: "p",
            symbol: "p",
            name: "Voiceless Bilabial Stop",
            examples: ["pen", "stop", "cap"],
            exampleIPA: ["pɛn", "stɑp", "kæp"],
            tongueConfig: TongueConfiguration(
                horizontal: .central,
                vertical: .mid,
                tip: .down,
                tension: .neutral
            ),
            lipShape: .compressed,
            jawOpening: .closed,
            voicing: .voiceless,
            airflowType: .oral,
            articulationPoint: .bilabial,
            mannerOfArticulation: .stop,
            description: "Close both lips, build up air pressure, then release explosively",
            visualHints: [
                VisualHint(text: "Press both lips together", highlightArea: .lips, animationType: .pulse),
                VisualHint(text: "No vocal cord vibration", highlightArea: .throat, animationType: .circle)
            ],
            commonMistakes: ["Adding aspiration in final position", "Not releasing lips fully"],
            tips: ["Put hand in front of mouth to feel air puff", "Lips should completely seal"],
            confusedWith: ["b"],
            difficultyLevel: .easy,
            category: .consonantStop
        ))

        phonemes.append(PhonemeVisual(
            id: "b",
            symbol: "b",
            name: "Voiced Bilabial Stop",
            examples: ["bat", "about", "cab"],
            exampleIPA: ["bæt", "əˈbaʊt", "kæb"],
            tongueConfig: TongueConfiguration(
                horizontal: .central,
                vertical: .mid,
                tip: .down,
                tension: .neutral
            ),
            lipShape: .compressed,
            jawOpening: .closed,
            voicing: .voiced,
            airflowType: .oral,
            articulationPoint: .bilabial,
            mannerOfArticulation: .stop,
            description: "Same as /p/ but with vocal cord vibration",
            visualHints: [
                VisualHint(text: "Press both lips together", highlightArea: .lips, animationType: .pulse),
                VisualHint(text: "Vocal cords vibrate", highlightArea: .throat, animationType: .pulse)
            ],
            commonMistakes: ["Making it voiceless like /p/", "Not enough voicing"],
            tips: ["Feel vibration in throat", "Should feel buzzing"],
            confusedWith: ["p", "v"],
            difficultyLevel: .easy,
            category: .consonantStop
        ))

        phonemes.append(PhonemeVisual(
            id: "t",
            symbol: "t",
            name: "Voiceless Alveolar Stop",
            examples: ["tea", "stop", "cat"],
            exampleIPA: ["tiː", "stɑp", "kæt"],
            tongueConfig: TongueConfiguration(
                horizontal: .front,
                vertical: .high,
                tip: .alveolar,
                tension: .tense
            ),
            lipShape: .neutral,
            jawOpening: .narrow,
            voicing: .voiceless,
            airflowType: .oral,
            articulationPoint: .alveolar,
            mannerOfArticulation: .stop,
            description: "Tongue tip touches alveolar ridge, then releases",
            visualHints: [
                VisualHint(text: "Touch tongue tip to alveolar ridge", highlightArea: .alveolarRidge, animationType: .pulse),
                VisualHint(text: "Quick release", highlightArea: .tongue, animationType: .arrow)
            ],
            commonMistakes: ["Not touching alveolar ridge", "Adding extra vowel sound"],
            tips: ["Tongue should be at roof of mouth behind teeth", "Feel air burst"],
            confusedWith: ["d", "tʃ"],
            difficultyLevel: .easy,
            category: .consonantStop
        ))

        phonemes.append(PhonemeVisual(
            id: "d",
            symbol: "d",
            name: "Voiced Alveolar Stop",
            examples: ["dog", "middle", "bad"],
            exampleIPA: ["dɔɡ", "ˈmɪdəl", "bæd"],
            tongueConfig: TongueConfiguration(
                horizontal: .front,
                vertical: .high,
                tip: .alveolar,
                tension: .tense
            ),
            lipShape: .neutral,
            jawOpening: .narrow,
            voicing: .voiced,
            airflowType: .oral,
            articulationPoint: .alveolar,
            mannerOfArticulation: .stop,
            description: "Same as /t/ but with vocal cord vibration",
            visualHints: [
                VisualHint(text: "Touch tongue tip to alveolar ridge", highlightArea: .alveolarRidge, animationType: .pulse),
                VisualHint(text: "Vocal cords vibrate", highlightArea: .throat, animationType: .pulse)
            ],
            commonMistakes: ["Making it voiceless like /t/", "Flapping in American English"],
            tips: ["Should feel throat vibration", "Keep voicing throughout"],
            confusedWith: ["t", "ð"],
            difficultyLevel: .easy,
            category: .consonantStop
        ))

        phonemes.append(PhonemeVisual(
            id: "k",
            symbol: "k",
            name: "Voiceless Velar Stop",
            examples: ["cat", "back", "school"],
            exampleIPA: ["kæt", "bæk", "skuːl"],
            tongueConfig: TongueConfiguration(
                horizontal: .back,
                vertical: .high,
                tip: .down,
                tension: .tense
            ),
            lipShape: .neutral,
            jawOpening: .narrow,
            voicing: .voiceless,
            airflowType: .oral,
            articulationPoint: .velar,
            mannerOfArticulation: .stop,
            description: "Back of tongue touches soft palate, then releases",
            visualHints: [
                VisualHint(text: "Back of tongue rises to soft palate", highlightArea: .softPalate, animationType: .pulse),
                VisualHint(text: "Sharp release", highlightArea: .tongue, animationType: .arrow)
            ],
            commonMistakes: ["Not raising tongue high enough", "Adding extra aspiration"],
            tips: ["Feel contact at back of mouth", "Air should burst out"],
            confusedWith: ["g"],
            difficultyLevel: .easy,
            category: .consonantStop
        ))

        phonemes.append(PhonemeVisual(
            id: "g",
            symbol: "g",
            name: "Voiced Velar Stop",
            examples: ["go", "big", "ghost"],
            exampleIPA: ["ɡoʊ", "bɪɡ", "ɡoʊst"],
            tongueConfig: TongueConfiguration(
                horizontal: .back,
                vertical: .high,
                tip: .down,
                tension: .tense
            ),
            lipShape: .neutral,
            jawOpening: .narrow,
            voicing: .voiced,
            airflowType: .oral,
            articulationPoint: .velar,
            mannerOfArticulation: .stop,
            description: "Same as /k/ but with vocal cord vibration",
            visualHints: [
                VisualHint(text: "Back of tongue touches soft palate", highlightArea: .softPalate, animationType: .pulse),
                VisualHint(text: "Maintain voicing", highlightArea: .throat, animationType: .pulse)
            ],
            commonMistakes: ["Devoicing in final position", "Not enough velar contact"],
            tips: ["Feel vibration in throat", "Keep voicing continuous"],
            confusedWith: ["k"],
            difficultyLevel: .easy,
            category: .consonantStop
        ))

        // FRICATIVES - HIGH PRIORITY
        phonemes.append(PhonemeVisual(
            id: "θ",
            symbol: "θ",
            name: "Voiceless Dental Fricative (TH)",
            examples: ["think", "bath", "something"],
            exampleIPA: ["θɪŋk", "bæθ", "ˈsʌmθɪŋ"],
            tongueConfig: TongueConfiguration(
                horizontal: .front,
                vertical: .mid,
                tip: .interdental,
                tension: .lax
            ),
            lipShape: .neutral,
            jawOpening: .narrow,
            voicing: .voiceless,
            airflowType: .oral,
            articulationPoint: .dental,
            mannerOfArticulation: .fricative,
            description: "Tongue tip between teeth, air flows through creating friction",
            visualHints: [
                VisualHint(text: "Place tongue between teeth", highlightArea: .teeth, animationType: .pulse),
                VisualHint(text: "Air flows continuously", highlightArea: .tongue, animationType: .arrow)
            ],
            commonMistakes: ["Substituting /s/ or /t/", "Not putting tongue between teeth", "Making /f/ sound"],
            tips: ["Tongue should be visible between teeth", "Should feel air on tongue", "Don't bite tongue hard"],
            confusedWith: ["s", "t", "f"],
            difficultyLevel: .hard,
            category: .consonantFricative
        ))

        phonemes.append(PhonemeVisual(
            id: "ð",
            symbol: "ð",
            name: "Voiced Dental Fricative (TH)",
            examples: ["this", "mother", "breathe"],
            exampleIPA: ["ðɪs", "ˈmʌðɚ", "briːð"],
            tongueConfig: TongueConfiguration(
                horizontal: .front,
                vertical: .mid,
                tip: .interdental,
                tension: .lax
            ),
            lipShape: .neutral,
            jawOpening: .narrow,
            voicing: .voiced,
            airflowType: .oral,
            articulationPoint: .dental,
            mannerOfArticulation: .fricative,
            description: "Same as /θ/ but with vocal cord vibration",
            visualHints: [
                VisualHint(text: "Tongue between teeth", highlightArea: .teeth, animationType: .pulse),
                VisualHint(text: "Feel vibration", highlightArea: .throat, animationType: .pulse)
            ],
            commonMistakes: ["Substituting /z/ or /d/", "Not voicing enough", "Confusion with /θ/"],
            tips: ["Should feel buzzing on tongue", "More common than /θ/", "Vibration is key difference"],
            confusedWith: ["z", "d", "θ"],
            difficultyLevel: .hard,
            category: .consonantFricative
        ))

        phonemes.append(PhonemeVisual(
            id: "f",
            symbol: "f",
            name: "Voiceless Labiodental Fricative",
            examples: ["fish", "coffee", "laugh"],
            exampleIPA: ["fɪʃ", "ˈkɔfi", "læf"],
            tongueConfig: TongueConfiguration(
                horizontal: .central,
                vertical: .mid,
                tip: .down,
                tension: .neutral
            ),
            lipShape: .neutral,
            jawOpening: .narrow,
            voicing: .voiceless,
            airflowType: .oral,
            articulationPoint: .labiodental,
            mannerOfArticulation: .fricative,
            description: "Lower lip touches upper teeth, air flows through",
            visualHints: [
                VisualHint(text: "Lower lip touches upper teeth", highlightArea: .lips, animationType: .pulse),
                VisualHint(text: "Continuous airflow", highlightArea: .lips, animationType: .arrow)
            ],
            commonMistakes: ["Not making lip-teeth contact", "Substituting /p/"],
            tips: ["Upper teeth should rest on lower lip", "Should see teeth on lip"],
            confusedWith: ["v", "p"],
            difficultyLevel: .medium,
            category: .consonantFricative
        ))

        phonemes.append(PhonemeVisual(
            id: "v",
            symbol: "v",
            name: "Voiced Labiodental Fricative",
            examples: ["van", "over", "love"],
            exampleIPA: ["væn", "ˈoʊvɚ", "lʌv"],
            tongueConfig: TongueConfiguration(
                horizontal: .central,
                vertical: .mid,
                tip: .down,
                tension: .neutral
            ),
            lipShape: .neutral,
            jawOpening: .narrow,
            voicing: .voiced,
            airflowType: .oral,
            articulationPoint: .labiodental,
            mannerOfArticulation: .fricative,
            description: "Same as /f/ but with vocal cord vibration",
            visualHints: [
                VisualHint(text: "Lower lip touches upper teeth", highlightArea: .lips, animationType: .pulse),
                VisualHint(text: "Feel vibration on lip", highlightArea: .throat, animationType: .pulse)
            ],
            commonMistakes: ["Substituting /w/ or /b/", "Not enough voicing", "Confusion with /f/"],
            tips: ["Should feel buzzing on lip", "Maintain voicing throughout", "NOT the same as /w/"],
            confusedWith: ["f", "w", "b"],
            difficultyLevel: .medium,
            category: .consonantFricative
        ))

        phonemes.append(PhonemeVisual(
            id: "s",
            symbol: "s",
            name: "Voiceless Alveolar Fricative",
            examples: ["see", "pass", "city"],
            exampleIPA: ["siː", "pæs", "ˈsɪti"],
            tongueConfig: TongueConfiguration(
                horizontal: .front,
                vertical: .high,
                tip: .alveolar,
                tension: .tense
            ),
            lipShape: .neutral,
            jawOpening: .narrow,
            voicing: .voiceless,
            airflowType: .oral,
            articulationPoint: .alveolar,
            mannerOfArticulation: .fricative,
            description: "Tongue near alveolar ridge, air creates hissing sound",
            visualHints: [
                VisualHint(text: "Tongue approaches alveolar ridge", highlightArea: .alveolarRidge, animationType: .pulse),
                VisualHint(text: "Create narrow channel for air", highlightArea: .tongue, animationType: .arrow)
            ],
            commonMistakes: ["Adding /ə/ before or after", "Making it /ʃ/", "Lisping"],
            tips: ["Should sound like a snake hiss", "Tongue doesn't touch ridge", "Keep tongue groove narrow"],
            confusedWith: ["z", "θ", "ʃ"],
            difficultyLevel: .medium,
            category: .consonantFricative
        ))

        phonemes.append(PhonemeVisual(
            id: "z",
            symbol: "z",
            name: "Voiced Alveolar Fricative",
            examples: ["zoo", "busy", "buzz"],
            exampleIPA: ["zuː", "ˈbɪzi", "bʌz"],
            tongueConfig: TongueConfiguration(
                horizontal: .front,
                vertical: .high,
                tip: .alveolar,
                tension: .tense
            ),
            lipShape: .neutral,
            jawOpening: .narrow,
            voicing: .voiced,
            airflowType: .oral,
            articulationPoint: .alveolar,
            mannerOfArticulation: .fricative,
            description: "Same as /s/ but with vocal cord vibration",
            visualHints: [
                VisualHint(text: "Tongue near alveolar ridge", highlightArea: .alveolarRidge, animationType: .pulse),
                VisualHint(text: "Maintain voicing", highlightArea: .throat, animationType: .pulse)
            ],
            commonMistakes: ["Devoicing to /s/", "Not enough voicing"],
            tips: ["Should sound like buzzing bee", "Feel vibration", "Common in plurals and verb endings"],
            confusedWith: ["s", "ð"],
            difficultyLevel: .medium,
            category: .consonantFricative
        ))

        phonemes.append(PhonemeVisual(
            id: "ʃ",
            symbol: "ʃ",
            name: "Voiceless Postalveolar Fricative (SH)",
            examples: ["ship", "nation", "wash"],
            exampleIPA: ["ʃɪp", "ˈneɪʃən", "wɑʃ"],
            tongueConfig: TongueConfiguration(
                horizontal: .front,
                vertical: .highMid,
                tip: .postalveolar,
                tension: .tense
            ),
            lipShape: .protruded,
            jawOpening: .narrow,
            voicing: .voiceless,
            airflowType: .oral,
            articulationPoint: .postalveolar,
            mannerOfArticulation: .fricative,
            description: "Tongue behind alveolar ridge, lips rounded, creating 'sh' sound",
            visualHints: [
                VisualHint(text: "Tongue behind alveolar ridge", highlightArea: .alveolarRidge, animationType: .pulse),
                VisualHint(text: "Round lips slightly", highlightArea: .lips, animationType: .pulse)
            ],
            commonMistakes: ["Making /s/ instead", "Not rounding lips", "Tongue too far forward"],
            tips: ["Should sound like 'shh' for quiet", "Lips pushed forward", "Softer than /s/"],
            confusedWith: ["s", "tʃ"],
            difficultyLevel: .medium,
            category: .consonantFricative
        ))

        phonemes.append(PhonemeVisual(
            id: "ʒ",
            symbol: "ʒ",
            name: "Voiced Postalveolar Fricative (ZH)",
            examples: ["measure", "vision", "beige"],
            exampleIPA: ["ˈmɛʒɚ", "ˈvɪʒən", "beɪʒ"],
            tongueConfig: TongueConfiguration(
                horizontal: .front,
                vertical: .highMid,
                tip: .postalveolar,
                tension: .tense
            ),
            lipShape: .protruded,
            jawOpening: .narrow,
            voicing: .voiced,
            airflowType: .oral,
            articulationPoint: .postalveolar,
            mannerOfArticulation: .fricative,
            description: "Same as /ʃ/ but with vocal cord vibration",
            visualHints: [
                VisualHint(text: "Tongue behind alveolar ridge", highlightArea: .alveolarRidge, animationType: .pulse),
                VisualHint(text: "Voice and round lips", highlightArea: .lips, animationType: .pulse)
            ],
            commonMistakes: ["Substituting /z/ or /dʒ/", "Not voicing enough", "Rare sound in English"],
            tips: ["Feel vibration", "Often spelled with 's' or 'si'", "Less common than /ʃ/"],
            confusedWith: ["z", "dʒ", "ʃ"],
            difficultyLevel: .hard,
            category: .consonantFricative
        ))

        phonemes.append(PhonemeVisual(
            id: "h",
            symbol: "h",
            name: "Voiceless Glottal Fricative",
            examples: ["hat", "ahead", "who"],
            exampleIPA: ["hæt", "əˈhɛd", "huː"],
            tongueConfig: TongueConfiguration(
                horizontal: .central,
                vertical: .mid,
                tip: .down,
                tension: .lax
            ),
            lipShape: .neutral,
            jawOpening: .mid,
            voicing: .voiceless,
            airflowType: .oral,
            articulationPoint: .glottal,
            mannerOfArticulation: .fricative,
            description: "Air flows from lungs through open vocal tract",
            visualHints: [
                VisualHint(text: "Open vocal tract", highlightArea: .throat, animationType: .arrow),
                VisualHint(text: "Exhale strongly", highlightArea: .throat, animationType: .pulse)
            ],
            commonMistakes: ["Dropping /h/ in some dialects", "Over-aspirating"],
            tips: ["Like fogging a mirror", "Mouth position depends on following vowel"],
            confusedWith: [],
            difficultyLevel: .easy,
            category: .consonantFricative
        ))

        // AFFRICATES
        phonemes.append(PhonemeVisual(
            id: "tʃ",
            symbol: "tʃ",
            name: "Voiceless Postalveolar Affricate (CH)",
            examples: ["church", "match", "picture"],
            exampleIPA: ["tʃɝtʃ", "mætʃ", "ˈpɪktʃɚ"],
            tongueConfig: TongueConfiguration(
                horizontal: .front,
                vertical: .high,
                tip: .postalveolar,
                tension: .tense
            ),
            lipShape: .protruded,
            jawOpening: .narrow,
            voicing: .voiceless,
            airflowType: .oral,
            articulationPoint: .postalveolar,
            mannerOfArticulation: .affricate,
            description: "Combination of /t/ stop followed immediately by /ʃ/ fricative",
            visualHints: [
                VisualHint(text: "Start with /t/ position", highlightArea: .alveolarRidge, animationType: .pulse),
                VisualHint(text: "Release into /ʃ/", highlightArea: .lips, animationType: .arrow)
            ],
            commonMistakes: ["Separating into /t/ and /ʃ/", "Making only /ʃ/"],
            tips: ["Should be one smooth sound", "Like a sneeze sound", "Feel stop then friction"],
            confusedWith: ["ʃ", "t"],
            difficultyLevel: .medium,
            category: .consonantAffricate
        ))

        phonemes.append(PhonemeVisual(
            id: "dʒ",
            symbol: "dʒ",
            name: "Voiced Postalveolar Affricate (J)",
            examples: ["judge", "age", "giraffe"],
            exampleIPA: ["dʒʌdʒ", "eɪdʒ", "dʒəˈræf"],
            tongueConfig: TongueConfiguration(
                horizontal: .front,
                vertical: .high,
                tip: .postalveolar,
                tension: .tense
            ),
            lipShape: .protruded,
            jawOpening: .narrow,
            voicing: .voiced,
            airflowType: .oral,
            articulationPoint: .postalveolar,
            mannerOfArticulation: .affricate,
            description: "Voiced version of /tʃ/: /d/ followed by /ʒ/",
            visualHints: [
                VisualHint(text: "Start with /d/ position", highlightArea: .alveolarRidge, animationType: .pulse),
                VisualHint(text: "Release into /ʒ/ with voicing", highlightArea: .throat, animationType: .pulse)
            ],
            commonMistakes: ["Substituting /j/ (yes)", "Not voicing enough", "Confusion with /tʃ/"],
            tips: ["Maintain voicing throughout", "Like /tʃ/ but voiced", "Common at end of words"],
            confusedWith: ["tʃ", "ʒ", "j"],
            difficultyLevel: .medium,
            category: .consonantAffricate
        ))

        // NASALS
        phonemes.append(PhonemeVisual(
            id: "m",
            symbol: "m",
            name: "Voiced Bilabial Nasal",
            examples: ["man", "summer", "ham"],
            exampleIPA: ["mæn", "ˈsʌmɚ", "hæm"],
            tongueConfig: TongueConfiguration(
                horizontal: .central,
                vertical: .mid,
                tip: .down,
                tension: .neutral
            ),
            lipShape: .compressed,
            jawOpening: .closed,
            voicing: .voiced,
            airflowType: .nasal,
            articulationPoint: .bilabial,
            mannerOfArticulation: .nasal,
            description: "Lips closed, air flows through nose, vocal cords vibrate",
            visualHints: [
                VisualHint(text: "Close lips completely", highlightArea: .lips, animationType: .pulse),
                VisualHint(text: "Air flows through nose", highlightArea: .velum, animationType: .arrow)
            ],
            commonMistakes: ["Not lowering velum", "Opening lips too soon"],
            tips: ["Hold your nose to feel vibration", "Can hum this sound", "Lips must be sealed"],
            confusedWith: ["n"],
            difficultyLevel: .easy,
            category: .consonantNasal
        ))

        phonemes.append(PhonemeVisual(
            id: "n",
            symbol: "n",
            name: "Voiced Alveolar Nasal",
            examples: ["no", "dinner", "sun"],
            exampleIPA: ["noʊ", "ˈdɪnɚ", "sʌn"],
            tongueConfig: TongueConfiguration(
                horizontal: .front,
                vertical: .high,
                tip: .alveolar,
                tension: .tense
            ),
            lipShape: .neutral,
            jawOpening: .narrow,
            voicing: .voiced,
            airflowType: .nasal,
            articulationPoint: .alveolar,
            mannerOfArticulation: .nasal,
            description: "Tongue tip at alveolar ridge, air flows through nose",
            visualHints: [
                VisualHint(text: "Tongue touches alveolar ridge", highlightArea: .alveolarRidge, animationType: .pulse),
                VisualHint(text: "Air through nose", highlightArea: .velum, animationType: .arrow)
            ],
            commonMistakes: ["Not touching alveolar ridge fully", "Confusion with /m/ or /ŋ/"],
            tips: ["Tongue position same as /t/ or /d/", "Can hum this with tongue up"],
            confusedWith: ["m", "ŋ"],
            difficultyLevel: .easy,
            category: .consonantNasal
        ))

        phonemes.append(PhonemeVisual(
            id: "ŋ",
            symbol: "ŋ",
            name: "Voiced Velar Nasal (NG)",
            examples: ["sing", "thinking", "long"],
            exampleIPA: ["sɪŋ", "ˈθɪŋkɪŋ", "lɔŋ"],
            tongueConfig: TongueConfiguration(
                horizontal: .back,
                vertical: .high,
                tip: .down,
                tension: .tense
            ),
            lipShape: .neutral,
            jawOpening: .narrow,
            voicing: .voiced,
            airflowType: .nasal,
            articulationPoint: .velar,
            mannerOfArticulation: .nasal,
            description: "Back of tongue touches soft palate, air through nose",
            visualHints: [
                VisualHint(text: "Back of tongue to soft palate", highlightArea: .softPalate, animationType: .pulse),
                VisualHint(text: "Nasal airflow", highlightArea: .velum, animationType: .arrow)
            ],
            commonMistakes: ["Adding /g/ at end (sing-guh)", "Substituting /n/", "Not raising back of tongue"],
            tips: ["Never at start of English words", "Common at end of -ing words", "Tongue position like /k/ or /g/"],
            confusedWith: ["n", "nk", "ng"],
            difficultyLevel: .medium,
            category: .consonantNasal
        ))

        // LIQUIDS
        phonemes.append(PhonemeVisual(
            id: "l",
            symbol: "l",
            name: "Voiced Alveolar Lateral Approximant (L)",
            examples: ["light", "hello", "feel"],
            exampleIPA: ["laɪt", "hɛˈloʊ", "fiːl"],
            tongueConfig: TongueConfiguration(
                horizontal: .front,
                vertical: .high,
                tip: .alveolar,
                tension: .tense
            ),
            lipShape: .neutral,
            jawOpening: .narrow,
            voicing: .voiced,
            airflowType: .oral,
            articulationPoint: .alveolar,
            mannerOfArticulation: .lateralApproximant,
            description: "Tongue tip at alveolar ridge, air flows around sides",
            visualHints: [
                VisualHint(text: "Tongue tip touches alveolar ridge", highlightArea: .alveolarRidge, animationType: .pulse),
                VisualHint(text: "Air flows around sides of tongue", highlightArea: .tongue, animationType: .arrow)
            ],
            commonMistakes: ["Substituting /r/", "Making dark L everywhere", "Not touching alveolar ridge"],
            tips: ["Tongue tip must touch roof of mouth", "Light L at start, dark L at end", "Air flows sideways"],
            confusedWith: ["r", "ɹ"],
            difficultyLevel: .medium,
            category: .consonantLiquid
        ))

        phonemes.append(PhonemeVisual(
            id: "ɹ",
            symbol: "ɹ",
            name: "Voiced Alveolar Approximant (R)",
            examples: ["red", "very", "car"],
            exampleIPA: ["ɹɛd", "ˈvɛɹi", "kɑɹ"],
            tongueConfig: TongueConfiguration(
                horizontal: .central,
                vertical: .mid,
                tip: .retroflex,
                tension: .tense
            ),
            lipShape: .neutral,
            jawOpening: .narrow,
            voicing: .voiced,
            airflowType: .oral,
            articulationPoint: .postalveolar,
            mannerOfArticulation: .approximant,
            description: "Tongue tip curls back or bunches up, doesn't touch roof",
            visualHints: [
                VisualHint(text: "Curl tongue tip back", highlightArea: .tongue, animationType: .arrow),
                VisualHint(text: "Tongue doesn't touch anything", highlightArea: .alveolarRidge, animationType: .circle)
            ],
            commonMistakes: ["Substituting /l/", "Tapping or trilling", "Not enough retroflexion"],
            tips: ["Two ways: curl tip back OR bunch tongue up", "Most difficult sound for many learners", "Lips may be slightly rounded"],
            confusedWith: ["l", "w"],
            difficultyLevel: .hard,
            category: .consonantLiquid
        ))

        // GLIDES/SEMIVOWELS
        phonemes.append(PhonemeVisual(
            id: "w",
            symbol: "w",
            name: "Voiced Labio-Velar Approximant (W)",
            examples: ["we", "away", "quick"],
            exampleIPA: ["wiː", "əˈweɪ", "kwɪk"],
            tongueConfig: TongueConfiguration(
                horizontal: .back,
                vertical: .high,
                tip: .down,
                tension: .tense
            ),
            lipShape: .rounded,
            jawOpening: .narrow,
            voicing: .voiced,
            airflowType: .oral,
            articulationPoint: .velar,
            mannerOfArticulation: .approximant,
            description: "Round lips tightly, back of tongue high, glide into vowel",
            visualHints: [
                VisualHint(text: "Round and protrude lips", highlightArea: .lips, animationType: .pulse),
                VisualHint(text: "Back of tongue raised", highlightArea: .softPalate, animationType: .pulse)
            ],
            commonMistakes: ["Substituting /v/", "Not rounding lips enough", "Confusion with /ʍ/ (wh)"],
            tips: ["Should look like blowing a kiss", "Very rounded lips", "Glides quickly into next vowel"],
            confusedWith: ["v", "u"],
            difficultyLevel: .medium,
            category: .consonantGlide
        ))

        phonemes.append(PhonemeVisual(
            id: "j",
            symbol: "j",
            name: "Voiced Palatal Approximant (Y)",
            examples: ["yes", "you", "beyond"],
            exampleIPA: ["jɛs", "juː", "biˈjɑnd"],
            tongueConfig: TongueConfiguration(
                horizontal: .front,
                vertical: .high,
                tip: .down,
                tension: .tense
            ),
            lipShape: .spread,
            jawOpening: .narrow,
            voicing: .voiced,
            airflowType: .oral,
            articulationPoint: .palatal,
            mannerOfArticulation: .approximant,
            description: "Tongue high and forward, glide into vowel",
            visualHints: [
                VisualHint(text: "Raise tongue toward hard palate", highlightArea: .hardPalate, animationType: .pulse),
                VisualHint(text: "Glide quickly to vowel", highlightArea: .tongue, animationType: .arrow)
            ],
            commonMistakes: ["Substituting /dʒ/ (judge)", "Not raising tongue high enough"],
            tips: ["Like /i/ but shorter", "Never spelled with J in English", "Quick glide"],
            confusedWith: ["dʒ", "i"],
            difficultyLevel: .medium,
            category: .consonantGlide
        ))

        // VOWELS - Close
        phonemes.append(PhonemeVisual(
            id: "iː",
            symbol: "iː",
            name: "Close Front Unrounded Vowel (Long E)",
            examples: ["sheep", "see", "machine"],
            exampleIPA: ["ʃiːp", "siː", "məˈʃiːn"],
            tongueConfig: TongueConfiguration(
                horizontal: .front,
                vertical: .high,
                tip: .down,
                tension: .tense
            ),
            lipShape: .spread,
            jawOpening: .narrow,
            voicing: .voiced,
            airflowType: .oral,
            articulationPoint: .palatal,
            mannerOfArticulation: .vowel,
            description: "Tongue very high and front, lips spread, tense vowel",
            visualHints: [
                VisualHint(text: "Tongue high and forward", highlightArea: .tongue, animationType: .pulse),
                VisualHint(text: "Spread lips like smiling", highlightArea: .lips, animationType: .pulse)
            ],
            commonMistakes: ["Making it too short like /ɪ/", "Not tensing tongue", "Adding /j/ glide"],
            tips: ["Should feel tense", "Smile while saying it", "Long duration"],
            confusedWith: ["ɪ", "eɪ"],
            difficultyLevel: .medium,
            category: .vowelClose
        ))

        phonemes.append(PhonemeVisual(
            id: "ɪ",
            symbol: "ɪ",
            name: "Near-Close Near-Front Unrounded Vowel (Short I)",
            examples: ["ship", "bit", "women"],
            exampleIPA: ["ʃɪp", "bɪt", "ˈwɪmɪn"],
            tongueConfig: TongueConfiguration(
                horizontal: .nearFront,
                vertical: .nearHigh,
                tip: .down,
                tension: .lax
            ),
            lipShape: .neutral,
            jawOpening: .narrow,
            voicing: .voiced,
            airflowType: .oral,
            articulationPoint: .palatal,
            mannerOfArticulation: .vowel,
            description: "Tongue high but more relaxed than /iː/, shorter duration",
            visualHints: [
                VisualHint(text: "Tongue slightly lower than /iː/", highlightArea: .tongue, animationType: .pulse),
                VisualHint(text: "More relaxed lips", highlightArea: .lips, animationType: .circle)
            ],
            commonMistakes: ["Making it too long like /iː/", "Tensing too much"],
            tips: ["Shorter and more relaxed", "Very common vowel", "Jaw slightly more open than /iː/"],
            confusedWith: ["iː", "ɛ"],
            difficultyLevel: .hard,
            category: .vowelClose
        ))

        phonemes.append(PhonemeVisual(
            id: "uː",
            symbol: "uː",
            name: "Close Back Rounded Vowel (Long OO)",
            examples: ["food", "blue", "through"],
            exampleIPA: ["fuːd", "bluː", "θɹuː"],
            tongueConfig: TongueConfiguration(
                horizontal: .back,
                vertical: .high,
                tip: .down,
                tension: .tense
            ),
            lipShape: .rounded,
            jawOpening: .narrow,
            voicing: .voiced,
            airflowType: .oral,
            articulationPoint: .velar,
            mannerOfArticulation: .vowel,
            description: "Tongue high and back, lips very rounded, tense",
            visualHints: [
                VisualHint(text: "Tongue high and back", highlightArea: .softPalate, animationType: .pulse),
                VisualHint(text: "Round lips tightly", highlightArea: .lips, animationType: .pulse)
            ],
            commonMistakes: ["Not rounding lips enough", "Making it too short like /ʊ/"],
            tips: ["Very round lips", "Tense and long", "Like blowing"],
            confusedWith: ["ʊ", "oʊ"],
            difficultyLevel: .easy,
            category: .vowelClose
        ))

        phonemes.append(PhonemeVisual(
            id: "ʊ",
            symbol: "ʊ",
            name: "Near-Close Near-Back Rounded Vowel (Short OO)",
            examples: ["book", "put", "good"],
            exampleIPA: ["bʊk", "pʊt", "ɡʊd"],
            tongueConfig: TongueConfiguration(
                horizontal: .nearBack,
                vertical: .nearHigh,
                tip: .down,
                tension: .lax
            ),
            lipShape: .rounded,
            jawOpening: .narrow,
            voicing: .voiced,
            airflowType: .oral,
            articulationPoint: .velar,
            mannerOfArticulation: .vowel,
            description: "Tongue high and back but more relaxed than /uː/",
            visualHints: [
                VisualHint(text: "Tongue slightly lower than /uː/", highlightArea: .tongue, animationType: .pulse),
                VisualHint(text: "Less rounded lips", highlightArea: .lips, animationType: .circle)
            ],
            commonMistakes: ["Making it /uː/", "Not rounding enough", "Confusion with /ʌ/"],
            tips: ["Shorter than /uː/", "More relaxed", "Less lip rounding"],
            confusedWith: ["uː", "ʌ"],
            difficultyLevel: .medium,
            category: .vowelClose
        ))

        // MID VOWELS
        phonemes.append(PhonemeVisual(
            id: "ɛ",
            symbol: "ɛ",
            name: "Open-Mid Front Unrounded Vowel (Short E)",
            examples: ["bed", "head", "said"],
            exampleIPA: ["bɛd", "hɛd", "sɛd"],
            tongueConfig: TongueConfiguration(
                horizontal: .front,
                vertical: .lowMid,
                tip: .down,
                tension: .lax
            ),
            lipShape: .neutral,
            jawOpening: .mid,
            voicing: .voiced,
            airflowType: .oral,
            articulationPoint: .palatal,
            mannerOfArticulation: .vowel,
            description: "Tongue mid-front, jaw more open than /ɪ/",
            visualHints: [
                VisualHint(text: "Tongue mid-height, front", highlightArea: .tongue, animationType: .pulse),
                VisualHint(text: "Jaw more open than /ɪ/", highlightArea: .jaw, animationType: .arrow)
            ],
            commonMistakes: ["Making it /æ/", "Confusion with /ɪ/"],
            tips: ["Like saying 'eh'", "Jaw drops more than /ɪ/"],
            confusedWith: ["æ", "ɪ"],
            difficultyLevel: .medium,
            category: .vowelMid
        ))

        phonemes.append(PhonemeVisual(
            id: "ə",
            symbol: "ə",
            name: "Mid Central Vowel (Schwa)",
            examples: ["about", "sofa", "banana"],
            exampleIPA: ["əˈbaʊt", "ˈsoʊfə", "bəˈnænə"],
            tongueConfig: TongueConfiguration(
                horizontal: .central,
                vertical: .mid,
                tip: .down,
                tension: .lax
            ),
            lipShape: .neutral,
            jawOpening: .mid,
            voicing: .voiced,
            airflowType: .oral,
            articulationPoint: .palatal,
            mannerOfArticulation: .vowel,
            description: "Most neutral vowel position, completely relaxed",
            visualHints: [
                VisualHint(text: "Completely neutral tongue position", highlightArea: .tongue, animationType: .pulse),
                VisualHint(text: "Relaxed everything", highlightArea: .lips, animationType: .circle)
            ],
            commonMistakes: ["Over-pronouncing in unstressed syllables", "Making it other vowels"],
            tips: ["Most common vowel in English", "Always unstressed", "Very short"],
            confusedWith: ["ʌ"],
            difficultyLevel: .medium,
            category: .vowelMid
        ))

        phonemes.append(PhonemeVisual(
            id: "ʌ",
            symbol: "ʌ",
            name: "Open-Mid Back Unrounded Vowel (Short U)",
            examples: ["cup", "love", "money"],
            exampleIPA: ["kʌp", "lʌv", "ˈmʌni"],
            tongueConfig: TongueConfiguration(
                horizontal: .central,
                vertical: .lowMid,
                tip: .down,
                tension: .lax
            ),
            lipShape: .neutral,
            jawOpening: .mid,
            voicing: .voiced,
            airflowType: .oral,
            articulationPoint: .velar,
            mannerOfArticulation: .vowel,
            description: "Mid-central, slightly lower than schwa, stressed",
            visualHints: [
                VisualHint(text: "Tongue mid-central", highlightArea: .tongue, animationType: .pulse),
                VisualHint(text: "Jaw moderately open", highlightArea: .jaw, animationType: .pulse)
            ],
            commonMistakes: ["Making it /ʊ/", "Confusion with /ə/"],
            tips: ["Stressed version of schwa", "NOT like 'boot'", "Jaw drops"],
            confusedWith: ["ʊ", "ə", "ɔː"],
            difficultyLevel: .hard,
            category: .vowelMid
        ))

        // OPEN VOWELS
        phonemes.append(PhonemeVisual(
            id: "æ",
            symbol: "æ",
            name: "Near-Open Front Unrounded Vowel (Short A)",
            examples: ["cat", "bad", "man"],
            exampleIPA: ["kæt", "bæd", "mæn"],
            tongueConfig: TongueConfiguration(
                horizontal: .front,
                vertical: .nearLow,
                tip: .down,
                tension: .lax
            ),
            lipShape: .spread,
            jawOpening: .wide,
            voicing: .voiced,
            airflowType: .oral,
            articulationPoint: .palatal,
            mannerOfArticulation: .vowel,
            description: "Tongue low and front, jaw very open",
            visualHints: [
                VisualHint(text: "Lower tongue, front position", highlightArea: .tongue, animationType: .pulse),
                VisualHint(text: "Open jaw wide", highlightArea: .jaw, animationType: .arrow)
            ],
            commonMistakes: ["Making it /ɛ/", "Not opening jaw enough", "Confusion with /a/"],
            tips: ["Jaw drops low", "Like saying 'ah' at dentist", "Very front tongue"],
            confusedWith: ["ɛ", "ɑː"],
            difficultyLevel: .hard,
            category: .vowelOpen
        ))

        phonemes.append(PhonemeVisual(
            id: "ɑː",
            symbol: "ɑː",
            name: "Open Back Unrounded Vowel (Long A)",
            examples: ["father", "car", "palm"],
            exampleIPA: ["ˈfɑːðɚ", "kɑːɹ", "pɑːm"],
            tongueConfig: TongueConfiguration(
                horizontal: .back,
                vertical: .low,
                tip: .down,
                tension: .lax
            ),
            lipShape: .neutral,
            jawOpening: .veryWide,
            voicing: .voiced,
            airflowType: .oral,
            articulationPoint: .pharyngeal,
            mannerOfArticulation: .vowel,
            description: "Tongue low and back, jaw maximally open",
            visualHints: [
                VisualHint(text: "Tongue low and back", highlightArea: .tongue, animationType: .pulse),
                VisualHint(text: "Maximum jaw opening", highlightArea: .jaw, animationType: .arrow)
            ],
            commonMistakes: ["Not opening jaw enough", "Making it too short"],
            tips: ["Widest jaw opening", "Say 'ahhh' at doctor", "Long duration"],
            confusedWith: ["æ", "ɔː"],
            difficultyLevel: .medium,
            category: .vowelOpen
        ))

        phonemes.append(PhonemeVisual(
            id: "ɔː",
            symbol: "ɔː",
            name: "Open-Mid Back Rounded Vowel (Long O)",
            examples: ["thought", "caught", "law"],
            exampleIPA: ["θɔːt", "kɔːt", "lɔː"],
            tongueConfig: TongueConfiguration(
                horizontal: .back,
                vertical: .lowMid,
                tip: .down,
                tension: .tense
            ),
            lipShape: .rounded,
            jawOpening: .wide,
            voicing: .voiced,
            airflowType: .oral,
            articulationPoint: .velar,
            mannerOfArticulation: .vowel,
            description: "Tongue back and low-mid, lips rounded, jaw open",
            visualHints: [
                VisualHint(text: "Tongue back, mid-low", highlightArea: .softPalate, animationType: .pulse),
                VisualHint(text: "Round lips, open jaw", highlightArea: .lips, animationType: .pulse)
            ],
            commonMistakes: ["Making it /oʊ/", "Not rounding lips", "Regional variations"],
            tips: ["Round lips but jaw still open", "Often merges with /ɑː/ in some dialects"],
            confusedWith: ["oʊ", "ɑː"],
            difficultyLevel: .hard,
            category: .vowelOpen
        ))

        // DIPHTHONGS
        phonemes.append(PhonemeVisual(
            id: "eɪ",
            symbol: "eɪ",
            name: "Close-Mid Front to Close Front Diphthong (Long A)",
            examples: ["day", "make", "great"],
            exampleIPA: ["deɪ", "meɪk", "ɡɹeɪt"],
            tongueConfig: TongueConfiguration(
                horizontal: .front,
                vertical: .highMid,
                tip: .down,
                tension: .tense
            ),
            lipShape: .spread,
            jawOpening: .narrow,
            voicing: .voiced,
            airflowType: .oral,
            articulationPoint: .palatal,
            mannerOfArticulation: .vowel,
            description: "Starts at /ɛ/, glides toward /ɪ/",
            visualHints: [
                VisualHint(text: "Start mid-front, move higher", highlightArea: .tongue, animationType: .arrow),
                VisualHint(text: "Gliding movement", highlightArea: .tongue, animationType: .pulse)
            ],
            commonMistakes: ["Making it monophthong /e/", "Not completing glide"],
            tips: ["Two sounds blended", "Tongue rises during sound", "Common in spellings"],
            confusedWith: ["ɛ", "iː"],
            difficultyLevel: .medium,
            category: .diphthong
        ))

        phonemes.append(PhonemeVisual(
            id: "aɪ",
            symbol: "aɪ",
            name: "Open to Close Front Diphthong (Long I)",
            examples: ["my", "time", "height"],
            exampleIPA: ["maɪ", "taɪm", "haɪt"],
            tongueConfig: TongueConfiguration(
                horizontal: .front,
                vertical: .low,
                tip: .down,
                tension: .lax
            ),
            lipShape: .spread,
            jawOpening: .wide,
            voicing: .voiced,
            airflowType: .oral,
            articulationPoint: .palatal,
            mannerOfArticulation: .vowel,
            description: "Starts at /ɑ/, glides toward /ɪ/",
            visualHints: [
                VisualHint(text: "Start low and back, move to front-high", highlightArea: .tongue, animationType: .arrow),
                VisualHint(text: "Large jaw movement", highlightArea: .jaw, animationType: .arrow)
            ],
            commonMistakes: ["Not opening jaw enough at start", "Making monophthong"],
            tips: ["Jaw closes during glide", "Very common diphthong"],
            confusedWith: ["ɑː", "ɔɪ"],
            difficultyLevel: .medium,
            category: .diphthong
        ))

        phonemes.append(PhonemeVisual(
            id: "ɔɪ",
            symbol: "ɔɪ",
            name: "Open-Mid Back to Close Front Diphthong (OI)",
            examples: ["boy", "coin", "voice"],
            exampleIPA: ["bɔɪ", "kɔɪn", "vɔɪs"],
            tongueConfig: TongueConfiguration(
                horizontal: .back,
                vertical: .lowMid,
                tip: .down,
                tension: .lax
            ),
            lipShape: .rounded,
            jawOpening: .mid,
            voicing: .voiced,
            airflowType: .oral,
            articulationPoint: .velar,
            mannerOfArticulation: .vowel,
            description: "Starts at /ɔ/ with rounded lips, glides to /ɪ/ unrounded",
            visualHints: [
                VisualHint(text: "Start back-rounded, move to front-unrounded", highlightArea: .tongue, animationType: .arrow),
                VisualHint(text: "Lips unround during glide", highlightArea: .lips, animationType: .arrow)
            ],
            commonMistakes: ["Not rounding lips at start", "Weak glide"],
            tips: ["Lips change from rounded to spread", "Tongue moves front"],
            confusedWith: ["aɪ"],
            difficultyLevel: .medium,
            category: .diphthong
        ))

        phonemes.append(PhonemeVisual(
            id: "aʊ",
            symbol: "aʊ",
            name: "Open to Close-Mid Back Diphthong (OW)",
            examples: ["now", "house", "about"],
            exampleIPA: ["naʊ", "haʊs", "əˈbaʊt"],
            tongueConfig: TongueConfiguration(
                horizontal: .central,
                vertical: .low,
                tip: .down,
                tension: .lax
            ),
            lipShape: .neutral,
            jawOpening: .wide,
            voicing: .voiced,
            airflowType: .oral,
            articulationPoint: .velar,
            mannerOfArticulation: .vowel,
            description: "Starts at /ɑ/, glides toward /ʊ/",
            visualHints: [
                VisualHint(text: "Start low-central, move to back-high", highlightArea: .tongue, animationType: .arrow),
                VisualHint(text: "Lips round at end", highlightArea: .lips, animationType: .pulse)
            ],
            commonMistakes: ["Not rounding lips at end", "Weak glide"],
            tips: ["Like saying 'ow' in pain", "Lips become rounded"],
            confusedWith: ["oʊ"],
            difficultyLevel: .medium,
            category: .diphthong
        ))

        phonemes.append(PhonemeVisual(
            id: "oʊ",
            symbol: "oʊ",
            name: "Close-Mid Back to Close Back Diphthong (Long O)",
            examples: ["go", "home", "show"],
            exampleIPA: ["ɡoʊ", "hoʊm", "ʃoʊ"],
            tongueConfig: TongueConfiguration(
                horizontal: .back,
                vertical: .highMid,
                tip: .down,
                tension: .tense
            ),
            lipShape: .rounded,
            jawOpening: .narrow,
            voicing: .voiced,
            airflowType: .oral,
            articulationPoint: .velar,
            mannerOfArticulation: .vowel,
            description: "Starts at /o/, glides toward /ʊ/",
            visualHints: [
                VisualHint(text: "Start mid-back, move higher", highlightArea: .tongue, animationType: .arrow),
                VisualHint(text: "Increase lip rounding", highlightArea: .lips, animationType: .pulse)
            ],
            commonMistakes: ["Making it monophthong /o/", "Not enough lip rounding"],
            tips: ["Lips get more rounded during glide", "Very common in English"],
            confusedWith: ["ɔː", "aʊ"],
            difficultyLevel: .easy,
            category: .diphthong
        ))

        return phonemes
    }

    // MARK: - Common Comparison Pairs
    func getComparisonPairs() -> [PhonemeComparisonPair] {
        var pairs: [PhonemeComparisonPair] = []

        // TH sounds
        if let th_voiceless = phoneme(symbol: "θ"),
           let th_voiced = phoneme(symbol: "ð") {
            pairs.append(PhonemeComparisonPair(
                id: "θ-ð",
                phoneme1: th_voiceless,
                phoneme2: th_voiced,
                title: "Voiceless TH vs Voiced TH",
                keyDifferences: [
                    "θ has no vocal cord vibration, ð does",
                    "Both have tongue between teeth",
                    "ð is more common in English"
                ],
                practiceExamples: [
                    ("think", "this"),
                    ("ether", "either"),
                    ("thigh", "thy")
                ]
            ))
        }

        // TH vs S
        if let th = phoneme(symbol: "θ"),
           let s = phoneme(symbol: "s") {
            pairs.append(PhonemeComparisonPair(
                id: "θ-s",
                phoneme1: th,
                phoneme2: s,
                title: "TH vs S",
                keyDifferences: [
                    "θ: tongue between teeth",
                    "s: tongue at alveolar ridge",
                    "s is more hissing, θ is softer"
                ],
                practiceExamples: [
                    ("think", "sink"),
                    ("bath", "bass"),
                    ("thumb", "sum")
                ]
            ))
        }

        // R vs L
        if let r = phoneme(symbol: "ɹ"),
           let l = phoneme(symbol: "l") {
            pairs.append(PhonemeComparisonPair(
                id: "ɹ-l",
                phoneme1: r,
                phoneme2: l,
                title: "R vs L",
                keyDifferences: [
                    "ɹ: tongue doesn't touch anything (curled or bunched)",
                    "l: tongue tip touches alveolar ridge",
                    "l: air flows around sides, ɹ: air flows over tongue"
                ],
                practiceExamples: [
                    ("right", "light"),
                    ("red", "led"),
                    ("pray", "play")
                ]
            ))
        }

        // V vs W
        if let v = phoneme(symbol: "v"),
           let w = phoneme(symbol: "w") {
            pairs.append(PhonemeComparisonPair(
                id: "v-w",
                phoneme1: v,
                phoneme2: w,
                title: "V vs W",
                keyDifferences: [
                    "v: lower lip touches upper teeth",
                    "w: both lips rounded, no teeth contact",
                    "w glides quickly into vowel"
                ],
                practiceExamples: [
                    ("van", "wan"),
                    ("vine", "wine"),
                    ("vest", "west")
                ]
            ))
        }

        // Long E vs Short I
        if let longE = phoneme(symbol: "iː"),
           let shortI = phoneme(symbol: "ɪ") {
            pairs.append(PhonemeComparisonPair(
                id: "iː-ɪ",
                phoneme1: longE,
                phoneme2: shortI,
                title: "Long E vs Short I",
                keyDifferences: [
                    "iː: tense, high, spread lips",
                    "ɪ: lax, slightly lower, neutral lips",
                    "iː is longer duration"
                ],
                practiceExamples: [
                    ("sheep", "ship"),
                    ("feet", "fit"),
                    ("beat", "bit")
                ]
            ))
        }

        // Short A vs Short E
        if let shortA = phoneme(symbol: "æ"),
           let shortE = phoneme(symbol: "ɛ") {
            pairs.append(PhonemeComparisonPair(
                id: "æ-ɛ",
                phoneme1: shortA,
                phoneme2: shortE,
                title: "Short A vs Short E",
                keyDifferences: [
                    "æ: lower tongue, wider jaw",
                    "ɛ: mid-low tongue, less jaw opening",
                    "æ has more front tongue position"
                ],
                practiceExamples: [
                    ("bad", "bed"),
                    ("cat", "ket"),
                    ("mat", "met")
                ]
            ))
        }

        return pairs
    }
}
