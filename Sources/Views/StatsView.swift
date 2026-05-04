import SwiftUI

// MARK: - Stats View (Per-Exercise Statistics Dashboard)

struct StatsView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var selectedExercise: ExerciseType = .squat
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Exercise selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(ExerciseType.allCases) { exercise in
                                FilterChip(
                                    label: exercise.displayName,
                                    isSelected: exercise == selectedExercise
                                ) {
                                    selectedExercise = exercise
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    let stats = dataStore.sessionStats(for: selectedExercise)

                    // Adaptive grid for iPad vs iPhone
                    let columns: [GridItem] = sizeClass == .regular
                        ? Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)
                        : Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)

                    LazyVGrid(columns: columns, spacing: 12) {
                        LargeStatCard(
                            icon: "number",
                            label: "Total Sessions",
                            value: "\(stats.totalSessions)",
                            accent: .forgeAmber
                        )
                        LargeStatCard(
                            icon: "repeat",
                            label: "Total Reps",
                            value: "\(stats.totalReps)",
                            accent: .forgeAmber
                        )
                        LargeStatCard(
                            icon: "chart.bar.fill",
                            label: "Avg Form",
                            value: String(format: "%.0f%%", stats.averageFormScore),
                            accent: Color.formScoreColor(for: stats.averageFormScore)
                        )
                        LargeStatCard(
                            icon: "star.fill",
                            label: "Best Form",
                            value: String(format: "%.0f%%", stats.bestFormScore),
                            accent: Color.formScoreColor(for: stats.bestFormScore)
                        )
                        LargeStatCard(
                            icon: "clock.fill",
                            label: "Total Time",
                            value: stats.totalDurationString,
                            accent: .forgeAmber
                        )
                        LargeStatCard(
                            icon: "calendar",
                            label: "This Week",
                            value: "\(stats.sessionsThisWeek)",
                            accent: .forgeAmber
                        )
                        LargeStatCard(
                            icon: "calendar.badge.clock",
                            label: "This Month",
                            value: "\(stats.sessionsThisMonth)",
                            accent: .forgeAmber
                        )
                    }
                    .padding(.horizontal, 16)

                    // Recent sessions for this exercise
                    let recentSessions = dataStore.sessionsForExercise(selectedExercise).prefix(10)
                    if !recentSessions.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Recent \(selectedExercise.displayName) Sessions")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)

                            ForEach(Array(recentSessions)) { session in
                                SessionRow(session: session)
                                    .padding(.horizontal, 16)
                            }
                        }
                    }

                    Spacer(minLength: 32)
                }
                .padding(.top, 12)
            }
            .background(Color.forgeBlack)
            .navigationTitle("Statistics")
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Large Stat Card

struct LargeStatCard: View {
    let icon: String
    let label: String
    let value: String
    let accent: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(accent)

            Text(value)
                .font(.system(.title2, design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(label)
                .font(.caption)
                .foregroundColor(.forgeMediumGray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.forgeStatsBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

#Preview {
    StatsView()
        .environmentObject(DataStore.shared)
}
