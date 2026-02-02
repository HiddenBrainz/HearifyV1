//
//  ModuleProgramView.swift
//  HearifyV1
//
//  Displays the program structure and manual for each module
//

import SwiftUI

struct ModuleProgramView: View {
    let program: ModuleProgram
    let onDismiss: () -> Void
    let onStartTraining: () -> Void
    @State private var expandedPhases: Set<Int> = [] // All phases collapsed by default for better performance

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: AppTheme.spacingL, pinnedViews: []) {
                // Header
                headerSection

                // Description
                descriptionSection

                // Objectives
                objectivesSection

                // Program Structure
                structureSection

                // Tips
                tipsSection

                // Footer
                footerSection
            }
            .padding(AppTheme.spacingM)
        }
        .background(AppTheme.backgroundPrimary.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: onDismiss) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(AppTheme.primaryBlue)
                }
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        ModernCard {
            HStack(spacing: AppTheme.spacingM) {
                Image(systemName: program.icon)
                    .font(.system(size: 50))
                    .foregroundColor(moduleColor)

                VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                    Text("Module \(program.moduleNumber)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.textSecondary)
                        .textCase(.uppercase)

                    Text(program.moduleName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                        Text(program.estimatedDuration)
                            .font(.system(size: 12))
                    }
                    .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()
            }
        }
    }

    // MARK: - Description Section
    private var descriptionSection: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                Label("Program Overview", systemImage: "doc.text")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                Text(program.description)
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Objectives Section
    private var objectivesSection: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                Label("Learning Objectives", systemImage: "target")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                    ForEach(Array(program.objectives.enumerated()), id: \.offset) { index, objective in
                        HStack(alignment: .top, spacing: AppTheme.spacingS) {
                            Text("\(index + 1).")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(moduleColor)
                                .frame(width: 20, alignment: .leading)

                            Text(objective)
                                .font(.system(size: 15))
                                .foregroundColor(AppTheme.textSecondary)
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Structure Section
    private var structureSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingM) {
            Text("Program Structure")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
                .padding(.horizontal, AppTheme.spacingS)

            ForEach(program.structure) { phase in
                phaseCard(phase)
                    .id(phase.id)
            }
        }
    }

    // MARK: - Phase Card
    private func phaseCard(_ phase: ProgramPhase) -> some View {
        let isExpanded = expandedPhases.contains(phase.phaseNumber)

        return ModernCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                // Phase Header
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        if isExpanded {
                            expandedPhases.remove(phase.phaseNumber)
                        } else {
                            expandedPhases.insert(phase.phaseNumber)
                        }
                    }
                }) {
                    HStack {
                        // Phase Number Badge
                        ZStack {
                            Circle()
                                .fill(moduleColor)
                                .frame(width: 40, height: 40)

                            Text("\(phase.phaseNumber)")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Phase \(phase.phaseNumber)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                                .textCase(.uppercase)

                            Text(phase.title)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                        }

                        Spacer()

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 14))
                            .foregroundColor(moduleColor)
                    }
                }
                .buttonStyle(PlainButtonStyle())

                // Expanded Content
                if isExpanded {
                    VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                        Divider()

                        // Description
                        Text(phase.description)
                            .font(.system(size: 15))
                            .foregroundColor(AppTheme.textSecondary)
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)

                        // Exercises
                        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                            Label("Exercises", systemImage: "list.bullet")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)

                            ForEach(phase.exercises, id: \.self) { exercise in
                                HStack(alignment: .top, spacing: AppTheme.spacingS) {
                                    Circle()
                                        .fill(moduleColor.opacity(0.6))
                                        .frame(width: 6, height: 6)
                                        .padding(.top, 6)

                                    Text(exercise)
                                        .font(.system(size: 14))
                                        .foregroundColor(AppTheme.textSecondary)
                                        .lineLimit(nil)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                        }

                        // Duration & Success Criteria
                        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(moduleColor)
                                    .padding(.top, 2)

                                Text(phase.duration)
                                    .font(.system(size: 13))
                                    .foregroundColor(AppTheme.textSecondary)
                                    .lineLimit(nil)
                            }

                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.success)
                                    .padding(.top, 2)

                                Text("Success: \(phase.successCriteria)")
                                    .font(.system(size: 13))
                                    .foregroundColor(AppTheme.textSecondary)
                                    .lineLimit(nil)
                            }
                        }
                        .padding(.vertical, AppTheme.spacingS)
                        .padding(.horizontal, AppTheme.spacingS)
                        .background(AppTheme.backgroundSecondary)
                        .cornerRadius(AppTheme.radiusSmall)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }

    // MARK: - Tips Section
    private var tipsSection: some View {
        ModernCard(backgroundColor: moduleColor.opacity(0.1)) {
            VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                Label("Helpful Tips", systemImage: "lightbulb.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(moduleColor)

                VStack(alignment: .leading, spacing: AppTheme.spacingS) {
                    ForEach(Array(program.tips.enumerated()), id: \.offset) { index, tip in
                        HStack(alignment: .top, spacing: AppTheme.spacingS) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(moduleColor)
                                .padding(.top, 3)

                            Text(tip)
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.textPrimary)
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Footer Section
    private var footerSection: some View {
        VStack(spacing: AppTheme.spacingM) {
            Text("Remember: This is a recommended program structure. Feel free to adjust the pace based on your individual needs and progress. Discuss your results with your audiologist for personalized guidance.")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding()

            Button(action: {
                onStartTraining()
                onDismiss()
            }) {
                Text("Start Training")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(moduleColor)
                    .cornerRadius(AppTheme.radiusMedium)
            }
        }
        .padding(.bottom, AppTheme.spacingL)
    }

    // MARK: - Helper Properties
    private var moduleColor: Color {
        switch program.moduleNumber {
        case 1:
            return AppTheme.primaryBlue
        case 2:
            return AppTheme.accentPurple
        case 3:
            return Color(red: 0.2, green: 0.8, blue: 0.6)
        default:
            return AppTheme.primaryBlue
        }
    }
}

// MARK: - Preview
struct ModuleProgramView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ModuleProgramView(
                program: ModuleProgram.module1,
                onDismiss: {},
                onStartTraining: {}
            )
        }
    }
}
