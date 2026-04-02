import XCTest
@testable import FoundryForm

final class FormAnalyzerTests: XCTestCase {

    var analyzer: FormAnalyzer!

    override func setUp() {
        super.setUp()
        analyzer = FormAnalyzer()
    }

    override func tearDown() {
        analyzer = nil
        super.tearDown()
    }

    // MARK: - Invalid Pose

    func testInvalidPoseReturnsZeroScore() {
        let invalidPose = PoseData(
            nose: .zero, leftEye: .zero, rightEye: .zero,
            leftEar: .zero, rightEar: .zero,
            leftShoulder: .zero, rightShoulder: .zero,
            leftElbow: .zero, rightElbow: .zero,
            leftWrist: .zero, rightWrist: .zero,
            leftHip: .zero, rightHip: .zero,
            leftKnee: .zero, rightKnee: .zero,
            leftAnkle: .zero, rightAnkle: .zero,
            isValid: false
        )

        analyzer.analyzeForm(pose: invalidPose, for: .squat)
        XCTAssertEqual(analyzer.formScore, 0)
        XCTAssertFalse(analyzer.formFeedback.isEmpty)
    }

    // MARK: - Score Range

    func testScoreIsClampedToValidRange() {
        let pose = makeStandingPose()

        for exercise in ExerciseType.allCases {
            analyzer.analyzeForm(pose: pose, for: exercise)
            XCTAssertGreaterThanOrEqual(analyzer.formScore, 0, "\(exercise) score should be >= 0")
            XCTAssertLessThanOrEqual(analyzer.formScore, 100, "\(exercise) score should be <= 100")
        }
    }

    // MARK: - Feedback Text

    func testFeedbackIsGenerated() {
        let pose = makeStandingPose()
        analyzer.analyzeForm(pose: pose, for: .squat)
        XCTAssertFalse(analyzer.formFeedback.isEmpty)
    }

    // MARK: - History

    func testAverageFormScore() {
        let pose = makeStandingPose()
        for _ in 0..<5 {
            analyzer.analyzeForm(pose: pose, for: .squat)
        }
        let avg = analyzer.averageFormScore()
        XCTAssertGreaterThan(avg, 0)
    }

    func testBestFormScore() {
        let pose = makeStandingPose()
        analyzer.analyzeForm(pose: pose, for: .squat)
        let best = analyzer.bestFormScore()
        XCTAssertGreaterThanOrEqual(best, 0)
    }

    func testResetHistory() {
        let pose = makeStandingPose()
        analyzer.analyzeForm(pose: pose, for: .squat)
        analyzer.resetHistory()
        XCTAssertEqual(analyzer.formScore, 0)
        XCTAssertEqual(analyzer.averageFormScore(), 0)
    }

    // MARK: - All Exercises Produce Output

    func testAllExercisesAnalyze() {
        let pose = makeStandingPose()
        for exercise in ExerciseType.allCases {
            analyzer.resetHistory()
            analyzer.analyzeForm(pose: pose, for: exercise)
            // Just verify it doesn't crash and produces some output
            XCTAssertFalse(analyzer.formFeedback.isEmpty, "\(exercise) should produce feedback")
        }
    }

    // MARK: - Helpers

    private func makeStandingPose() -> PoseData {
        PoseData(
            nose: CGPoint(x: 0.5, y: 0.1),
            leftEye: CGPoint(x: 0.48, y: 0.09),
            rightEye: CGPoint(x: 0.52, y: 0.09),
            leftEar: CGPoint(x: 0.45, y: 0.1),
            rightEar: CGPoint(x: 0.55, y: 0.1),
            leftShoulder: CGPoint(x: 0.4, y: 0.25),
            rightShoulder: CGPoint(x: 0.6, y: 0.25),
            leftElbow: CGPoint(x: 0.35, y: 0.4),
            rightElbow: CGPoint(x: 0.65, y: 0.4),
            leftWrist: CGPoint(x: 0.35, y: 0.55),
            rightWrist: CGPoint(x: 0.65, y: 0.55),
            leftHip: CGPoint(x: 0.43, y: 0.55),
            rightHip: CGPoint(x: 0.57, y: 0.55),
            leftKnee: CGPoint(x: 0.43, y: 0.75),
            rightKnee: CGPoint(x: 0.57, y: 0.75),
            leftAnkle: CGPoint(x: 0.43, y: 0.95),
            rightAnkle: CGPoint(x: 0.57, y: 0.95)
        )
    }
}
