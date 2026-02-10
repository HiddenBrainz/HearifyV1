//
//  HearingTypeSelectionView.swift
//  HearifyV1
//
//  View for selecting user's hearing loss type during onboarding
//

import SwiftUI

struct HearingTypeSelectionView: View {
    @ObservedObject var profileManager: HearingProfileManager
    @State private var selectedType: TrainingModuleType?
    var onComplete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection

            ScrollView {
                VStack(spacing: AppTheme.spacingL) {
                    // Welcome message
                    welcomeSection

                    // Type selection cards
                    VStack(spacing: AppTheme.spacingM) {
                        ForEach(TrainingModuleType.allCases, id: \.self) { type in
                            typeSelectionCard(type)
                        }
                    }

                    // Continue button
                    if selectedType != nil {
                        continueButton
                    }
                }
                .padding(AppTheme.spacingL)
            }
            .background(AppTheme.backgroundPrimary.ignoresSafeArea())
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: AppTheme.spacingS) {
            Image(systemName: "person.badge.key.fill")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.primaryBlue)
                .padding(.top, AppTheme.spacingL)

            Text("Personalize Your Training")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)

            Text("Select your hearing situation to get customized training")
                .font(.system(size: 15))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.spacingL)
        }
        .padding(.bottom, AppTheme.spacingM)
        .background(Color.white)
    }

    // MARK: - Welcome Section
    private var welcomeSection: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(AppTheme.info)
                    Text("Why we ask this")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                }

                Text("We'll customize your training program and educational content based on your specific hearing situation. You can change this anytime in Settings.")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Type Selection Card
    private func typeSelectionCard(_ type: TrainingModuleType) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedType = type
            }
        }) {
            ModernCard(
                padding: AppTheme.spacingL,
                backgroundColor: selectedType == type ? type.color.opacity(0.1) : .white
            ) {
                HStack(spacing: AppTheme.spacingM) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(type.color.opacity(0.15))
                            .frame(width: 70, height: 70)

                        Image(systemName: type.icon)
                            .font(.system(size: 35))
                            .foregroundColor(type.color)
                    }

                    // Content
                    VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                        Text(type.rawValue)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)

                        Text(type.description)
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    // Selection indicator
                    if selectedType == type {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(type.color)
                    } else {
                        Image(systemName: "circle")
                            .font(.system(size: 30))
                            .foregroundColor(AppTheme.textTertiary)
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedType == type ? type.color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Continue Button
    private var continueButton: some View {
        Button(action: {
            if let type = selectedType {
                profileManager.setHearingType(type)
                onComplete()
            }
        }) {
            HStack {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold))
                Image(systemName: "arrow.right")
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(selectedType?.color ?? AppTheme.primaryBlue)
            .cornerRadius(AppTheme.radiusMedium)
            .shadow(color: (selectedType?.color ?? AppTheme.primaryBlue).opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .transition(.scale.combined(with: .opacity))
    }
}

// MARK: - Preview
struct HearingTypeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        HearingTypeSelectionView(
            profileManager: HearingProfileManager(),
            onComplete: {}
        )
    }
}
