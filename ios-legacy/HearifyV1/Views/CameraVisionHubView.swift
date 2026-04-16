//
//  CameraVisionHubView.swift
//  HearifyV1
//
//  Camera Vision Module: Vision Analysis Hub
//  Main menu for camera-based pronunciation practice
//

import SwiftUI

struct CameraVisionHubView: View {
    // Use shared instance to avoid creating duplicates (performance issue)
    @ObservedObject private var gamificationManager = GamificationManager.shared
    @State private var selectedExercise: CameraExercise?
    var onDismiss: () -> Void = {}

    // Camera practice exercises organized by mouth features
    struct CameraExercise: Identifiable {
        let id = UUID()
        let title: String
        let phoneme: String
        let description: String
        let exampleWord: String
        let difficulty: String
        let category: ExerciseCategory

        enum ExerciseCategory: String {
            case lipSpread = "Lip Spread"
            case lipRounding = "Lip Rounding"
            case jawOpening = "Jaw Opening"
            case combined = "Combined"
        }
    }

    // Exercise library
    let exercises: [CameraExercise] = [
        // Lip Spread Exercises
        CameraExercise(
            title: "Wide Smile Practice",
            phoneme: "iː",
            description: "Practice spreading lips wide like smiling",
            exampleWord: "sheep",
            difficulty: "Easy",
            category: .lipSpread
        ),
        CameraExercise(
            title: "Short I Sound",
            phoneme: "ɪ",
            description: "Slightly spread lips, less than /iː/",
            exampleWord: "ship",
            difficulty: "Medium",
            category: .lipSpread
        ),

        // Lip Rounding Exercises
        CameraExercise(
            title: "Full Lip Rounding",
            phoneme: "uː",
            description: "Round lips fully like blowing a kiss",
            exampleWord: "food",
            difficulty: "Easy",
            category: .lipRounding
        ),
        CameraExercise(
            title: "Relaxed Rounding",
            phoneme: "ʊ",
            description: "Slightly rounded, less tense than /uː/",
            exampleWord: "book",
            difficulty: "Medium",
            category: .lipRounding
        ),

        // Jaw Opening Exercises
        CameraExercise(
            title: "Wide Mouth Opening",
            phoneme: "æ",
            description: "Open mouth wide with spread lips",
            exampleWord: "cat",
            difficulty: "Easy",
            category: .jawOpening
        ),
        CameraExercise(
            title: "Very Wide Opening",
            phoneme: "ɑː",
            description: "Maximum mouth opening, relaxed jaw",
            exampleWord: "father",
            difficulty: "Medium",
            category: .jawOpening
        ),

        // Combined Exercises
        CameraExercise(
            title: "Mid Vowel Position",
            phoneme: "ə",
            description: "Neutral mouth position - central vowel",
            exampleWord: "about",
            difficulty: "Easy",
            category: .combined
        ),
        CameraExercise(
            title: "Open-Mid Front",
            phoneme: "ɛ",
            description: "Moderate opening with slight spread",
            exampleWord: "bed",
            difficulty: "Medium",
            category: .combined
        )
    ]

    var body: some View {
        Group {
            if let exercise = selectedExercise {
                // Full-screen camera view ONLY
                CameraPracticeView(
                    exerciseText: exercise.exampleWord,
                    phoneme: exercise.phoneme,
                    onDismiss: {
                        // Dismiss with slight delay to ensure clean state transition
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            selectedExercise = nil
                        }
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.all, edges: .all)
                .id(exercise.id) // Force view recreation for each exercise
            } else {
                // Exercise list with header
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: {
                            onDismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                        }

                        Spacer()

                        VStack(spacing: 2) {
                            Text("Camera Vision")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)

                            Text("Camera Vision Module")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                        }

                        Spacer()

                        VStack(spacing: 2) {
                            Image(systemName: "camera.fill")
                                .foregroundColor(.white)
                            Text("AI")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 50)
                    .padding(.bottom, 16)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.2, green: 0.8, blue: 0.6), Color(red: 0.1, green: 0.7, blue: 0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                    // Exercise list
                    ScrollView {
                        VStack(spacing: 20) {
                            // Welcome Card
                            welcomeCard

                            // Exercise Categories
                            VStack(spacing: 16) {
                                Text("Choose Exercise Type")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)

                                // Lip Spread Exercises
                                categorySection(category: .lipSpread)

                                // Lip Rounding Exercises
                                categorySection(category: .lipRounding)

                                // Jaw Opening Exercises
                                categorySection(category: .jawOpening)

                                // Combined Exercises
                                categorySection(category: .combined)
                            }

                            // Features Info
                            featuresInfo
                        }
                        .padding()
                    }
                    .background(AppTheme.backgroundPrimary)
                }
            }
        }
    }

    // MARK: - Welcome Card
    private var welcomeCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "camera.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.6))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Visual Pronunciation Analysis")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)

                    Text("Use your camera to analyze mouth position in real-time")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()
            }

            // Info boxes
            HStack(spacing: 12) {
                infoBox(icon: "face.smiling", text: "Face Detection", color: Color(red: 0.2, green: 0.8, blue: 0.6))
                infoBox(icon: "mouth", text: "Mouth Analysis", color: Color(red: 0.1, green: 0.7, blue: 0.5))
                infoBox(icon: "checkmark.circle", text: "Live Feedback", color: Color(red: 0.15, green: 0.75, blue: 0.55))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4)
    }

    // MARK: - Category Section
    private func categorySection(category: CameraExercise.ExerciseCategory) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(category.rawValue)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
                .padding(.horizontal)

            VStack(spacing: 8) {
                ForEach(exercises.filter { $0.category == category }) { exercise in
                    exerciseCard(exercise: exercise)
                }
            }
        }
    }

    // MARK: - Exercise Card
    private func exerciseCard(exercise: CameraExercise) -> some View {
        Button(action: {
            selectedExercise = exercise
        }) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color(red: 0.2, green: 0.8, blue: 0.6).opacity(0.15))
                        .frame(width: 50, height: 50)

                    Text(exercise.phoneme)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.7, blue: 0.5))
                }

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(exercise.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)

                        Spacer()

                        // Difficulty badge
                        Text(exercise.difficulty)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(difficultyColor(exercise.difficulty))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(difficultyColor(exercise.difficulty).opacity(0.15))
                            .cornerRadius(4)
                    }

                    Text(exercise.description)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        Image(systemName: "text.quote")
                            .font(.system(size: 11))
                        Text(exercise.exampleWord)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.6))
                }

                Image(systemName: "camera.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.6).opacity(0.5))
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Features Info
    private var featuresInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How It Works")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)

            VStack(spacing: 8) {
                featureBullet(
                    icon: "camera.viewfinder",
                    text: "Position your face in front of the camera",
                    color: Color(red: 0.2, green: 0.8, blue: 0.6)
                )
                featureBullet(
                    icon: "face.smiling",
                    text: "AI detects your face and mouth landmarks",
                    color: Color(red: 0.15, green: 0.75, blue: 0.55)
                )
                featureBullet(
                    icon: "chart.bar.fill",
                    text: "Real-time comparison with target pronunciation",
                    color: Color(red: 0.1, green: 0.7, blue: 0.5)
                )
                featureBullet(
                    icon: "checkmark.circle.fill",
                    text: "Instant visual feedback with color-coded scoring",
                    color: Color(red: 0.05, green: 0.65, blue: 0.45)
                )
                featureBullet(
                    icon: "lightbulb.fill",
                    text: "Helpful tips to improve your mouth position",
                    color: Color(red: 0.0, green: 0.6, blue: 0.4)
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4)
    }

    // MARK: - Helper Views
    private func infoBox(icon: String, text: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            Text(text)
                .font(.system(size: 11))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }

    private func featureBullet(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)

            Text(text)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)

            Spacer()
        }
    }

    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "Easy": return AppTheme.success
        case "Medium": return AppTheme.warning
        case "Hard": return AppTheme.error
        default: return AppTheme.textSecondary
        }
    }
}
