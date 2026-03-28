import Foundation

// MARK: - Data Store (Session Persistence)

class DataStore: ObservableObject {
    static let shared = DataStore()

    @Published var sessions: [Session] = []
    @Published var currentSession: Session?

    private let fileManager = FileManager.default

    private lazy var documentsDirectory: URL = {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }()

    private lazy var sessionsDirectory: URL = {
        let url = documentsDirectory.appendingPathComponent("FoundryFormSessions", isDirectory: true)
        try? fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        return url
    }()

    private var sessionsFileURL: URL {
        sessionsDirectory.appendingPathComponent("sessions.json")
    }

    init() {
        loadSessions()
    }

    // MARK: - Session Management

    @discardableResult
    func createSession(exerciseType: ExerciseType) -> Session {
        let session = Session(
            exerciseType: exerciseType,
            startTime: Date()
        )
        currentSession = session
        return session
    }

    func endCurrentSession(reps: Int, averageScore: Float, peakScore: Float) {
        guard let current = currentSession else { return }

        let completed = Session(
            id: current.id,
            exerciseType: current.exerciseType,
            startTime: current.startTime,
            endTime: Date(),
            totalReps: reps,
            averageFormScore: averageScore,
            peakFormScore: peakScore,
            videoURL: nil,
            frameCount: 0
        )

        sessions.insert(completed, at: 0) // Most recent first
        saveSessions()
        currentSession = nil
    }

    func cancelCurrentSession() {
        currentSession = nil
    }

    // MARK: - Session Queries

    func sessionsForExercise(_ exercise: ExerciseType) -> [Session] {
        sessions.filter { $0.exerciseType == exercise }
    }

    func sessionStats() -> SessionStats {
        SessionStats(sessions: sessions)
    }

    func sessionStats(for exercise: ExerciseType) -> SessionStats {
        SessionStats(sessions: sessionsForExercise(exercise))
    }

    // MARK: - Deletion

    func deleteSession(_ session: Session) {
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions.remove(at: index)
            saveSessions()
        }
    }

    func deleteAllSessions() {
        sessions.removeAll()
        saveSessions()
    }

    // MARK: - Persistence

    private func saveSessions() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(sessions)
            try data.write(to: sessionsFileURL, options: .atomic)
        } catch {
            print("[DataStore] Failed to save sessions: \(error.localizedDescription)")
        }
    }

    private func loadSessions() {
        guard fileManager.fileExists(atPath: sessionsFileURL.path) else { return }

        do {
            let data = try Data(contentsOf: sessionsFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            sessions = try decoder.decode([Session].self, from: data)
        } catch {
            print("[DataStore] Failed to load sessions: \(error.localizedDescription)")
            sessions = []
        }
    }
}
