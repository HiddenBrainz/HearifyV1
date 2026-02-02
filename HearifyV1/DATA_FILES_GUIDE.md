# 📚 Auditory Training Data Files - Complete Guide

## Overview
This document describes all the CSV data files used in your auditory training app and what linguistic principles they follow.

---

## 🎯 **Matched Pairs CSV Files**

### 1. **SyllablesData.csv** (110 pairs)
**Purpose:** Train users to distinguish words based on syllable count differences

**Categories:**
- 1 syllable vs 2 syllables (40 pairs)
  - Example: "Ball" vs "Pizza", "Cat" vs "Pencil"
- 1 syllable vs 3 syllables (30 pairs)
  - Example: "Dog" vs "Dinosaur", "Cup" vs "Hamburger"
- 2 syllables vs 3 syllables (30 pairs)
  - Example: "Tiger" vs "Butterfly", "Pizza" vs "Hamburger"
- 2 syllables vs 4+ syllables (10 pairs)
  - Example: "Apple" vs "Watermelon", "Tiger" vs "Rhinoceros"

**Clinical Rationale:** Syllable discrimination is foundational for speech perception and helps users develop temporal processing skills.

---

### 2. **PDData.csv** - Phonetically Different (95 pairs)
**Purpose:** Train users to distinguish minimal pairs that differ by single phonemes

**Categories:**

#### PD1 - Place of Articulation Contrasts (30 pairs)
- Bilabial vs Alveolar: "Bat" vs "Mat", "Pet" vs "Met"
- Alveolar vs Velar: "Tea" vs "Sea", "Tin" vs "Sin"
- Velar vs Glottal: "Cat" vs "Hat", "Cap" vs "Gap"

#### PD1 - Voicing Contrasts (15 pairs)
- Voiced vs Voiceless: "Pig" vs "Big", "Kill" vs "Gill"
- Fricatives: "Sue" vs "Zoo", "Fan" vs "Van"

#### PD2 - Manner of Articulation Contrasts (25 pairs)
- Stop vs Nasal: "Mat" vs "Pat", "Ban" vs "Pan"
- Fricative vs Approximant: "Rice" vs "Lice", "Rake" vs "Lake"
- Affricate vs Fricative: "Sheep" vs "Cheap", "Chain" vs "Train"

#### Additional Minimal Pairs (25 pairs)
- Mixed phonetic contrasts for advanced training

**Clinical Rationale:** Phoneme discrimination is essential for speech understanding, especially in challenging listening environments.

---

### 3. **Vowels.csv** (180 pairs)
**Purpose:** Train vowel discrimination - one of the most challenging aspects of auditory training

**Categories:**

#### Wide Vowel Contrasts (wv) - 40 pairs
Large acoustic differences, easier to distinguish:
- /i/ vs /u/: "Bee" vs "Boo", "See" vs "Sue"
- /æ/ vs /oʊ/: "Bat" vs "Boat", "Map" vs "Mop"
- /ɑ/ vs /æ/: "Hot" vs "Hat", "Pot" vs "Pat"

#### Narrow Vowel Contrasts (nv) - 140 pairs
Small acoustic differences, challenging:
- /i/ vs /ɪ/: "Pete" vs "Pit", "Meat" vs "Mitt"
- /ɛ/ vs /ɪ/: "Pen" vs "Pin", "Ten" vs "Tin"
- /ɛ/ vs /æ/: "Beg" vs "Bag", "Bed" vs "Bad"
- /ɑ/ vs /oʊ/: "Cot" vs "Coat", "Sock" vs "Soak"
- /ɑ/ vs /ʌ/: "Hot" vs "Hut", "Cot" vs "Cut"
- /u/ vs /oʊ/: "Boot" vs "Boat", "Pool" vs "Pole"
- Diphthong contrasts: "Bite" vs "Bet", "Kite" vs "Kit"

**Clinical Rationale:** Vowel perception is critical for word recognition and often the first aspect to degrade in hearing loss.

---

### 4. **Consonants.csv** (129 pairs)
**Purpose:** Initial consonant discrimination training

**Categories:**
- Manner contrasts (stops, fricatives, affricates, nasals, liquids)
- Place contrasts (bilabial, alveolar, velar, palatal)
- Voicing contrasts (voiced vs voiceless)

**Examples:**
- "Moon" vs "June", "Red" vs "Jed", "Lake" vs "Jake"
- "Vine" vs "Line", "Seed" vs "Read", "Sam" vs "Lamb"
- "Mad" vs "Sad", "Bun" vs "Run", "Dog" vs "Log"

**Clinical Rationale:** Initial consonants carry significant information for word recognition.

---

### 5. **FinalConsonants.csv** (NEW - 150 pairs)
**Purpose:** Final consonant discrimination - often more challenging than initial consonants

**Categories:**
- /p/ vs /b/: "Cap" vs "Cab", "Rip" vs "Rib"
- /t/ vs /d/: "Bat" vs "Bad", "Seat" vs "Seed"
- /k/ vs /g/: "Sack" vs "Sag", "Duck" vs "Dug"
- /s/ vs /z/: "Ice" vs "Eyes", "Race" vs "Rays"
- /f/ vs /v/: "Leaf" vs "Leave", "Proof" vs "Prove"
- /th/ voiceless vs voiced: "Breath" vs "Breathe"
- /ch/ vs /j/: "Batch" vs "Badge", "Reach" vs "Ridge"
- /m/ vs /n/: "Beam" vs "Bean", "Sum" vs "Sun"
- /n/ vs /ng/: "Sin" vs "Sing", "Win" vs "Wing"
- /l/ vs /r/: "Seal" vs "Seer", "Ball" vs "Bore"
- Final consonant clusters: "Bent" vs "Bend", "Melt" vs "Meld"

**Clinical Rationale:** Final consonant perception is crucial for morphology (plurals, past tense) and word boundaries.

---

## 📝 **Word Recognition CSV Files**

### 6. **WordRecognitionData.csv** (200 words)
**Purpose:** Closed-set word recognition with phonetically similar foils

**Format:** Each word has 4 choices (the target word + 3 phonetically similar distractors)

**Word Types:**
- Simple monosyllabic words (cat, dog, sun, rain)
- Common bisyllabic words (tiger, table, water, pizza)
- Multisyllabic words (monster, chicken, spider, dragon)
- Morphologically complex words (broken, spoken, frozen, chosen)

**Distractor Design:**
- Rhyming words: "cat" → bat, hat, mat
- Initial consonant changes: "phone" → bone, cone, stone
- Vowel changes: "shoe" → blue, true, glue
- Minimal phonetic changes

**Clinical Rationale:** Trains closed-set word recognition, simulating real-world listening tasks like multiple-choice comprehension.

---

## 💬 **Sentence Comprehension CSV Files**

### 7. **SentenceComprehensionData.csv** (100 sentences)
**Purpose:** Sentence-level comprehension in quiet

**Sentence Types:**
- Simple declarative: "The cat is sleeping on the couch"
- Questions: "Can you help me find my keys"
- Commands/requests: "Please turn off the lights before leaving"
- Complex sentences with subordinate clauses
- Various verb tenses and aspects

**Choice Design:**
- Semantic distractors (meaning changes)
- Lexical distractors (word substitutions)
- Syntactic distractors (structure changes)
- Temporal distractors (time reference changes)

**Clinical Rationale:** Sentences require integration of phonemes, words, grammar, and meaning - simulating real communication.

---

### 8. **SentencesInNoiseData.csv** (NEW - 80 sentences)
**Purpose:** Sentence comprehension with background noise

**Special Features:**
- Designed for use with café, restaurant, traffic, or crowd noise
- Everyday communication scenarios
- High-frequency vocabulary
- Natural speech patterns

**Example Contexts:**
- Instructions: "Please wash your hands before dinner"
- Information: "The train departs at noon"
- Questions: "Can you help me with my homework"
- Descriptions: "The dog is barking at the mailman"

**Clinical Rationale:** Most real-world listening occurs in noisy environments. This trains signal-in-noise perception, the most common complaint of hearing aid users.

---

## 📊 **Total Dataset Size**

- **Matched Pairs:** ~664 pairs across 5 categories
- **Word Recognition:** 200 words with 800 total choices
- **Sentence Comprehension:** 180 sentences with 720 total choices

**Grand Total:** Over 2,000+ individual listening items

---

## 🔧 **Adding More Data**

### To add matched pairs:
1. Open the appropriate CSV file (SyllablesData.csv, Vowels.csv, etc.)
2. Follow the format: `firstWord,lastWord,category`
3. Ensure the category matches (syllables, wv, nv, PD1, PD2, consonants, fc)

### To add words:
1. Open WordRecognitionData.csv
2. Format: `word,choice1,choice2,choice3,choice4,category`
3. choice1 should be the correct answer
4. Other choices should be phonetically similar

### To add sentences:
1. Open SentenceComprehensionData.csv or SentencesInNoiseData.csv
2. Format: `sentence,choice1,choice2,choice3,choice4,category`
3. choice1 is the correct sentence
4. Other choices should differ in meaningful ways
5. Use category: `sentenceComprehension` or `sentencesInNoise`

---

## 🎓 **Linguistic Principles Used**

1. **Minimal Pairs:** Words differing by one phoneme for targeted training
2. **Phonetic Distance:** Gradual progression from easy (large acoustic differences) to hard (small differences)
3. **Syllable Structure:** Simple to complex syllable patterns (CV, CVC, CCVC, etc.)
4. **Frequency Effects:** Mix of high-frequency and low-frequency words
5. **Phonotactic Probability:** Real English words with valid sound combinations
6. **Semantic Field Diversity:** Words from various categories to maintain engagement

---

## 📱 **Clinical Applications**

These data files support:
- **Cochlear implant rehabilitation**
- **Hearing aid fitting validation**
- **Auditory processing disorder therapy**
- **Second language pronunciation training**
- **Speech-language pathology**
- **Audiology clinical practice**

---

**Last Updated:** January 2026
**Format Version:** CSV 1.0
**Encoding:** UTF-8
