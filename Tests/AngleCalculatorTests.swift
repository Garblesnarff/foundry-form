import XCTest
@testable import FoundryForm

final class AngleCalculatorTests: XCTestCase {

    // MARK: - Core Angle Calculation

    func testStraightLineAngle() {
        // Three points in a straight line → 180°
        let angle = AngleCalculator.calculateAngle(
            point1: CGPoint(x: 0, y: 0),
            vertex: CGPoint(x: 0.5, y: 0),
            point3: CGPoint(x: 1.0, y: 0)
        )
        XCTAssertEqual(angle, 180, accuracy: 0.5, "Straight line should be 180°")
    }

    func testRightAngle() {
        // 90° angle
        let angle = AngleCalculator.calculateAngle(
            point1: CGPoint(x: 0, y: 1),
            vertex: CGPoint(x: 0, y: 0),
            point3: CGPoint(x: 1, y: 0)
        )
        XCTAssertEqual(angle, 90, accuracy: 0.5, "Right angle should be 90°")
    }

    func testZeroAngle() {
        // Same direction → 0°
        let angle = AngleCalculator.calculateAngle(
            point1: CGPoint(x: 1, y: 0),
            vertex: CGPoint(x: 0, y: 0),
            point3: CGPoint(x: 2, y: 0)
        )
        XCTAssertEqual(angle, 0, accuracy: 0.5, "Same direction should be 0°")
    }

    func testZeroLengthVectors() {
        // Vertex same as one endpoint → 0° (guarded)
        let angle = AngleCalculator.calculateAngle(
            point1: CGPoint(x: 1, y: 1),
            vertex: CGPoint(x: 1, y: 1),
            point3: CGPoint(x: 2, y: 2)
        )
        XCTAssertEqual(angle, 0, "Zero-length vector should return 0")
    }

    func test45DegreeAngle() {
        let angle = AngleCalculator.calculateAngle(
            point1: CGPoint(x: 1, y: 0),
            vertex: CGPoint(x: 0, y: 0),
            point3: CGPoint(x: 1, y: 1)
        )
        XCTAssertEqual(angle, 45, accuracy: 0.5, "Should be 45°")
    }

    func test60DegreeAngle() {
        let angle = AngleCalculator.calculateAngle(
            point1: CGPoint(x: 1, y: 0),
            vertex: CGPoint(x: 0, y: 0),
            point3: CGPoint(x: 0.5, y: CGFloat(sqrt(3.0) / 2.0))
        )
        XCTAssertEqual(angle, 60, accuracy: 0.5, "Should be 60°")
    }

    // MARK: - Squat Angle Extraction

    func testSquatAngleExtraction() {
        let pose = makeStandingPose()
        let angles = AngleCalculator.extractSquatAngles(from: pose)
        XCTAssertGreaterThan(angles.kneeAngle, 0, "Knee angle should be > 0")
        XCTAssertGreaterThan(angles.hipAngle, 0, "Hip angle should be > 0")
    }

    // MARK: - Bicep Curl Angle Extraction

    func testBicepCurlAngleExtraction() {
        let pose = makeStandingPose()
        let angles = AngleCalculator.extractBicepCurlAngles(from: pose)
        XCTAssertGreaterThan(angles.elbowAngle, 0, "Elbow angle should be > 0")
    }

    // MARK: - Helpers

    /// Create a realistic standing pose (all joints visible).
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
