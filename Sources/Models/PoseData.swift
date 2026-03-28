import Foundation
import CoreGraphics

// MARK: - Pose Data Model (19 Landmarks from Vision Framework)

struct PoseData: Equatable {
    // Head & Neck
    let nose: CGPoint
    let leftEye: CGPoint
    let rightEye: CGPoint
    let leftEar: CGPoint
    let rightEar: CGPoint

    // Upper Body
    let leftShoulder: CGPoint
    let rightShoulder: CGPoint
    let leftElbow: CGPoint
    let rightElbow: CGPoint
    let leftWrist: CGPoint
    let rightWrist: CGPoint

    // Lower Body
    let leftHip: CGPoint
    let rightHip: CGPoint
    let leftKnee: CGPoint
    let rightKnee: CGPoint
    let leftAnkle: CGPoint
    let rightAnkle: CGPoint

    // Timestamp & confidence
    let timestamp: Date
    let isValid: Bool

    init(
        nose: CGPoint,
        leftEye: CGPoint,
        rightEye: CGPoint,
        leftEar: CGPoint,
        rightEar: CGPoint,
        leftShoulder: CGPoint,
        rightShoulder: CGPoint,
        leftElbow: CGPoint,
        rightElbow: CGPoint,
        leftWrist: CGPoint,
        rightWrist: CGPoint,
        leftHip: CGPoint,
        rightHip: CGPoint,
        leftKnee: CGPoint,
        rightKnee: CGPoint,
        leftAnkle: CGPoint,
        rightAnkle: CGPoint,
        timestamp: Date = Date(),
        isValid: Bool = true
    ) {
        self.nose = nose
        self.leftEye = leftEye
        self.rightEye = rightEye
        self.leftEar = leftEar
        self.rightEar = rightEar
        self.leftShoulder = leftShoulder
        self.rightShoulder = rightShoulder
        self.leftElbow = leftElbow
        self.rightElbow = rightElbow
        self.leftWrist = leftWrist
        self.rightWrist = rightWrist
        self.leftHip = leftHip
        self.rightHip = rightHip
        self.leftKnee = leftKnee
        self.rightKnee = rightKnee
        self.leftAnkle = leftAnkle
        self.rightAnkle = rightAnkle
        self.timestamp = timestamp
        self.isValid = isValid
    }

    // MARK: - Accessible Landmark Array

    /// All 17 core landmarks as an ordered array.
    var allLandmarks: [CGPoint] {
        [
            nose, leftEye, rightEye, leftEar, rightEar,
            leftShoulder, rightShoulder,
            leftElbow, rightElbow,
            leftWrist, rightWrist,
            leftHip, rightHip,
            leftKnee, rightKnee,
            leftAnkle, rightAnkle
        ]
    }

    /// Body skeleton connections (pairs of landmark indices into `allLandmarks`).
    static let connections: [(Int, Int)] = [
        // Head
        (3, 4),   // leftEar – rightEar
        (1, 2),   // leftEye – rightEye
        (0, 1),   // nose – leftEye
        (0, 2),   // nose – rightEye
        // Torso
        (5, 6),   // leftShoulder – rightShoulder
        (5, 11),  // leftShoulder – leftHip
        (6, 12),  // rightShoulder – rightHip
        (11, 12), // leftHip – rightHip
        // Left arm
        (5, 7),   // leftShoulder – leftElbow
        (7, 9),   // leftElbow – leftWrist
        // Right arm
        (6, 8),   // rightShoulder – rightElbow
        (8, 10),  // rightElbow – rightWrist
        // Left leg
        (11, 13), // leftHip – leftKnee
        (13, 15), // leftKnee – leftAnkle
        // Right leg
        (12, 14), // rightHip – rightKnee
        (14, 16)  // rightKnee – rightAnkle
    ]

    // MARK: - Equatable

    static func == (lhs: PoseData, rhs: PoseData) -> Bool {
        lhs.timestamp == rhs.timestamp &&
        lhs.nose == rhs.nose &&
        lhs.isValid == rhs.isValid
    }
}

// MARK: - Codable Support

extension PoseData: Codable {
    enum CodingKeys: String, CodingKey {
        case nose, leftEye, rightEye, leftEar, rightEar
        case leftShoulder, rightShoulder
        case leftElbow, rightElbow
        case leftWrist, rightWrist
        case leftHip, rightHip
        case leftKnee, rightKnee
        case leftAnkle, rightAnkle
        case timestamp, isValid
    }

    // CGPoint is not Codable by default on all platforms,
    // so we encode each point as a two-element array [x, y].

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(CodablePoint(nose), forKey: .nose)
        try container.encode(CodablePoint(leftEye), forKey: .leftEye)
        try container.encode(CodablePoint(rightEye), forKey: .rightEye)
        try container.encode(CodablePoint(leftEar), forKey: .leftEar)
        try container.encode(CodablePoint(rightEar), forKey: .rightEar)
        try container.encode(CodablePoint(leftShoulder), forKey: .leftShoulder)
        try container.encode(CodablePoint(rightShoulder), forKey: .rightShoulder)
        try container.encode(CodablePoint(leftElbow), forKey: .leftElbow)
        try container.encode(CodablePoint(rightElbow), forKey: .rightElbow)
        try container.encode(CodablePoint(leftWrist), forKey: .leftWrist)
        try container.encode(CodablePoint(rightWrist), forKey: .rightWrist)
        try container.encode(CodablePoint(leftHip), forKey: .leftHip)
        try container.encode(CodablePoint(rightHip), forKey: .rightHip)
        try container.encode(CodablePoint(leftKnee), forKey: .leftKnee)
        try container.encode(CodablePoint(rightKnee), forKey: .rightKnee)
        try container.encode(CodablePoint(leftAnkle), forKey: .leftAnkle)
        try container.encode(CodablePoint(rightAnkle), forKey: .rightAnkle)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(isValid, forKey: .isValid)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        nose = try container.decode(CodablePoint.self, forKey: .nose).point
        leftEye = try container.decode(CodablePoint.self, forKey: .leftEye).point
        rightEye = try container.decode(CodablePoint.self, forKey: .rightEye).point
        leftEar = try container.decode(CodablePoint.self, forKey: .leftEar).point
        rightEar = try container.decode(CodablePoint.self, forKey: .rightEar).point
        leftShoulder = try container.decode(CodablePoint.self, forKey: .leftShoulder).point
        rightShoulder = try container.decode(CodablePoint.self, forKey: .rightShoulder).point
        leftElbow = try container.decode(CodablePoint.self, forKey: .leftElbow).point
        rightElbow = try container.decode(CodablePoint.self, forKey: .rightElbow).point
        leftWrist = try container.decode(CodablePoint.self, forKey: .leftWrist).point
        rightWrist = try container.decode(CodablePoint.self, forKey: .rightWrist).point
        leftHip = try container.decode(CodablePoint.self, forKey: .leftHip).point
        rightHip = try container.decode(CodablePoint.self, forKey: .rightHip).point
        leftKnee = try container.decode(CodablePoint.self, forKey: .leftKnee).point
        rightKnee = try container.decode(CodablePoint.self, forKey: .rightKnee).point
        leftAnkle = try container.decode(CodablePoint.self, forKey: .leftAnkle).point
        rightAnkle = try container.decode(CodablePoint.self, forKey: .rightAnkle).point
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        isValid = try container.decode(Bool.self, forKey: .isValid)
    }
}

// MARK: - CodablePoint Helper

/// Wrapper to make CGPoint Codable without extending a system type.
struct CodablePoint: Codable {
    let x: CGFloat
    let y: CGFloat

    var point: CGPoint { CGPoint(x: x, y: y) }

    init(_ point: CGPoint) {
        self.x = point.x
        self.y = point.y
    }
}
