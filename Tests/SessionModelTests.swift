import XCTest
@testable import FoundryForm

final class SessionModelTests: XCTestCase {

    // MARK: - Session

    func testSessionDuration() {
        let start = Date()
        let end = start.addingTimeInterval(300) // 5 minutes
        let session = Session(
            exerciseType: .squat,
            startTime: start,
            endTime: end,
            totalReps: 20,
            averageFormScore: 85
        )
        XCTAssertEqual(session.duration, 300, accuracy: 0.1)
        XCTAssertEqual(session.durationString, "5:00")
        XCTAssertTrue(session.isComplete)
    }

    func testInProgressSession() {
        let session = Session(exerciseType: .bicepCurl)
        XCTAssertNil(session.duration)
        XCTAssertEqual(session.durationString, "In progress")
        XCTAssertFalse(session.isComplete)
    }

    func testFormScorePercentage() {
        let session = Session(exerciseType: .squat, averageFormScore: 82.7)
        XCTAssertEqual(session.formScorePercentage, "83%")
    }

    // MARK: - Session Stats

    func testStatsFromEmptySessions() {
        let stats = SessionStats(sessions: [])
        XCTAssertEqual(stats.totalSessions, 0)
        XCTAssertEqual(stats.totalReps, 0)
        XCTAssertEqual(stats.averageFormScore, 0)
        XCTAssertEqual(stats.bestFormScore, 0)
    }

    func testStatsFromSessions() {
        let sessions = [
            Session(exerciseType: .squat, startTime: Date(), endTime: Date().addingTimeInterval(300), totalReps: 15, averageFormScore: 80, peakFormScore: 95),
            Session(exerciseType: .deadlift, startTime: Date(), endTime: Date().addingTimeInterval(600), totalReps: 10, averageFormScore: 70, peakFormScore: 88),
        ]
        let stats = SessionStats(sessions: sessions)
        XCTAssertEqual(stats.totalSessions, 2)
        XCTAssertEqual(stats.totalReps, 25)
        XCTAssertEqual(stats.averageFormScore, 75, accuracy: 0.1)
        XCTAssertEqual(stats.bestFormScore, 95, accuracy: 0.1)
    }

    // MARK: - Exercise Type

    func testExerciseTypeIdentifiable() {
        for exercise in ExerciseType.allCases {
            XCTAssertFalse(exercise.displayName.isEmpty)
            XCTAssertFalse(exercise.description.isEmpty)
            XCTAssertFalse(exercise.iconName.isEmpty)
        }
    }

    func testExerciseReferenceAngles() {
        for exercise in ExerciseType.allCases {
            let ref = exercise.referenceAngles
            XCTAssertGreaterThan(ref.primary.tolerance, 0)
            XCTAssertGreaterThan(ref.primary.weight, 0)
            XCTAssertGreaterThan(ref.secondary.tolerance, 0)
        }
    }

    func testPlankIsNotRepBased() {
        XCTAssertFalse(ExerciseType.plank.isRepBased)
        XCTAssertTrue(ExerciseType.squat.isRepBased)
    }

    // MARK: - Codable Round-Trip

    func testSessionCodable() throws {
        let original = Session(
            exerciseType: .squat,
            startTime: Date(),
            endTime: Date().addingTimeInterval(300),
            totalReps: 12,
            averageFormScore: 85,
            peakFormScore: 97,
            frameCount: 9000
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(Session.self, from: data)

        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.exerciseType, original.exerciseType)
        XCTAssertEqual(decoded.totalReps, original.totalReps)
        XCTAssertEqual(decoded.averageFormScore, original.averageFormScore)
    }
}
