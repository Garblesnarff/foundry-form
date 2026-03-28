import Foundation

// MARK: - Session Model (for history tracking)

struct Session: Identifiable, Codable {
    let id: UUID
    let exerciseType: ExerciseType
    let startTime: Date
    let endTime: Date?
    let totalReps: Int
    let averageFormScore: Float
    let peakFormScore: Float
    let videoURL: URL?
    let frameCount: Int

    init(
        id: UUID = UUID(),
        exerciseType: ExerciseType,
        startTime: Date = Date(),
        endTime: Date? = nil,
        totalReps: Int = 0,
        averageFormScore: Float = 0,
        peakFormScore: Float = 0,
        videoURL: URL? = nil,
        frameCount: Int = 0
    ) {
        self.id = id
        self.exerciseType = exerciseType
        self.startTime = startTime
        self.endTime = endTime
        self.totalReps = totalReps
        self.averageFormScore = averageFormScore
        self.peakFormScore = peakFormScore
        self.videoURL = videoURL
        self.frameCount = frameCount
    }

    // MARK: - Computed Properties

    var duration: TimeInterval? {
        guard let endTime = endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }

    var durationString: String {
        guard let duration = duration else { return "In progress" }
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        if minutes == 0 {
            return String(format: "%ds", seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }

    var formScorePercentage: String {
        String(format: "%.0f%%", averageFormScore)
    }

    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: startTime)
    }

    var isComplete: Bool {
        endTime != nil
    }
}

// MARK: - Session Statistics

struct SessionStats {
    let totalSessions: Int
    let totalReps: Int
    let averageFormScore: Float
    let bestFormScore: Float
    let totalDuration: TimeInterval
    let sessionsThisWeek: Int
    let sessionsThisMonth: Int

    init(sessions: [Session]) {
        self.totalSessions = sessions.count
        self.totalReps = sessions.reduce(0) { $0 + $1.totalReps }
        self.averageFormScore = sessions.isEmpty
            ? 0
            : sessions.reduce(Float(0)) { $0 + $1.averageFormScore } / Float(sessions.count)
        self.bestFormScore = sessions.isEmpty
            ? 0
            : sessions.map(\.peakFormScore).max() ?? 0
        self.totalDuration = sessions.compactMap(\.duration).reduce(0, +)

        let now = Date()
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now
        let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: now) ?? now

        self.sessionsThisWeek = sessions.filter { $0.startTime >= weekAgo }.count
        self.sessionsThisMonth = sessions.filter { $0.startTime >= monthAgo }.count
    }

    var totalDurationString: String {
        let hours = Int(totalDuration) / 3600
        let minutes = (Int(totalDuration) % 3600) / 60
        if hours == 0 {
            return String(format: "%d min", minutes)
        }
        return String(format: "%d hr %d min", hours, minutes)
    }
}
