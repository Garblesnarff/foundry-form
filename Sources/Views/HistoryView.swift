import SwiftUI

// MARK: - History View

struct HistoryView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var selectedSession: Session?
    @State private var filterExercise: ExerciseType?
    @State private var showDeleteAllConfirmation = false

    private var filteredSessions: [Session] {
        if let exercise = filterExercise {
            return dataStore.sessions.filter { $0.exerciseType == exercise }
        }
        return dataStore.sessions
    }

    private var stats: SessionStats {
        SessionStats(sessions: filteredSessions)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter & Stats Header
                VStack(spacing: 12) {
                    // Exercise Filter Picker
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(label: "All", isSelected: filterExercise == nil) {
                                filterExercise = nil
                            }
                            ForEach(ExerciseType.allCases) { exercise in
                                FilterChip(
                                    label: exercise.displayName,
                                    isSelected: filterExercise == exercise
                                ) {
                                    filterExercise = exercise
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // Stats Summary
                    StatsGrid(stats: stats)
                        .padding(.horizontal, 16)
                }
                .padding(.vertical, 12)
                .background(Color.forgeBlack)

                // Sessions List
                if filteredSessions.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(filteredSessions) { session in
                            SessionRow(session: session)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedSession = session
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        dataStore.deleteSession(session)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .listRowBackground(Color.forgeBlack)
                                .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.forgeBlack)
                }
            }
            .background(Color.forgeBlack)
            .navigationTitle("History")
            .toolbar {
                if !filteredSessions.isEmpty {
                    ToolbarItem(placement: .automatic) {
                        Button {
                            showDeleteAllConfirmation = true
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.formRed)
                        }
                        .accessibilityLabel("Delete all sessions")
                    }
                }
            }
            .confirmationDialog(
                "Delete All Sessions?",
                isPresented: $showDeleteAllConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete All", role: .destructive) {
                    dataStore.deleteAllSessions()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently remove all session history. This cannot be undone.")
            }
            .sheet(item: $selectedSession) { session in
                SessionDetailView(session: session)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "dumbbell")
                .font(.system(size: 48))
                .foregroundColor(.forgeMediumGray)
            Text("No sessions yet")
                .font(.headline)
                .foregroundColor(.white)
            Text("Start your first workout to build your form history.")
                .font(.subheadline)
                .foregroundColor(.forgeMediumGray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.forgeBlack)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : .forgeMediumGray)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.forgeAmber : Color.forgeDarkGray)
                .clipShape(Capsule())
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Stats Grid

struct StatsGrid: View {
    let stats: SessionStats

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                StatCard(label: "Sessions", value: "\(stats.totalSessions)", icon: "number")
                StatCard(label: "Total Reps", value: "\(stats.totalReps)", icon: "repeat")
                StatCard(label: "Avg Form", value: String(format: "%.0f%%", stats.averageFormScore), icon: "chart.bar")
            }
            HStack(spacing: 8) {
                StatCard(label: "Best Form", value: String(format: "%.0f%%", stats.bestFormScore), icon: "star")
                StatCard(label: "This Week", value: "\(stats.sessionsThisWeek)", icon: "calendar")
                StatCard(label: "Total Time", value: stats.totalDurationString, icon: "clock")
            }
        }
    }
}

struct StatCard: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.headline, design: .monospaced))
                .foregroundColor(.forgeAmber)
            Text(label)
                .font(.caption2)
                .foregroundColor(.forgeMediumGray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.forgeStatsBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

// MARK: - Session Row

struct SessionRow: View {
    let session: Session

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: session.exerciseType.iconName)
                            .font(.caption)
                            .foregroundColor(.forgeAmber)
                        Text(session.exerciseType.displayName)
                            .font(.headline)
                            .foregroundColor(.white)
                    }

                    HStack(spacing: 12) {
                        Label("\(session.totalReps) reps", systemImage: "repeat")
                        Label(session.durationString, systemImage: "clock")
                    }
                    .font(.caption)
                    .foregroundColor(.forgeMediumGray)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(session.formScorePercentage)
                        .font(.headline)
                        .foregroundColor(Color.formScoreColor(for: session.averageFormScore))

                    Text(session.dateString)
                        .font(.caption2)
                        .foregroundColor(.forgeMediumGray)
                }
            }

            ProgressView(value: Double(session.averageFormScore) / 100.0)
                .tint(Color.formScoreColor(for: session.averageFormScore))
        }
        .padding(12)
        .background(Color.forgeCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(session.exerciseType.displayName), \(session.totalReps) reps, form \(session.formScorePercentage), \(session.dateString)")
    }
}

// MARK: - Session Detail View

struct SessionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let session: Session

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Header card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Image(systemName: session.exerciseType.iconName)
                                        .foregroundColor(.forgeAmber)
                                    Text(session.exerciseType.displayName)
                                        .font(.headline)
                                }
                                Text(session.dateString)
                                    .font(.caption)
                                    .foregroundColor(.forgeMediumGray)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                Text(session.formScorePercentage)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.forgeAmber)
                                Text("Form Score")
                                    .font(.caption)
                                    .foregroundColor(.forgeMediumGray)
                            }
                        }

                        Divider()
                            .overlay(Color.forgeDarkGray)

                        VStack(spacing: 12) {
                            DetailRow(label: "Total Reps", value: "\(session.totalReps)")
                            DetailRow(label: "Duration", value: session.durationString)
                            DetailRow(label: "Peak Form", value: String(format: "%.0f%%", session.peakFormScore))
                            DetailRow(label: "Frames Captured", value: "\(session.frameCount)")
                        }
                    }
                    .padding(16)
                    .background(Color.forgeCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Share Button
                    ShareLink(
                        item: sessionSummaryText,
                        subject: Text("Foundry Form Session"),
                        message: Text("Check out my workout!")
                    ) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Session")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.forgeAmber))
                    }

                    Button {
                        dismiss()
                    } label: {
                        Text("Close")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.forgeDarkGray))
                    }
                }
                .padding(16)
            }
            .background(Color.forgeBlack)
            .navigationTitle("Session Details")
        }
        .preferredColorScheme(.dark)
    }

    private var sessionSummaryText: String {
        """
        Foundry Form — \(session.exerciseType.displayName)
        Date: \(session.dateString)
        Reps: \(session.totalReps)
        Form Score: \(session.formScorePercentage)
        Duration: \(session.durationString)
        #ForgeYourForm
        """
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.forgeMediumGray)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Previews

#Preview("History") {
    HistoryView()
        .environmentObject(DataStore.shared)
}

#Preview("Session Detail") {
    SessionDetailView(session: Session(
        exerciseType: .squat,
        startTime: Date().addingTimeInterval(-300),
        endTime: Date(),
        totalReps: 15,
        averageFormScore: 82,
        peakFormScore: 95,
        frameCount: 4500
    ))
}
