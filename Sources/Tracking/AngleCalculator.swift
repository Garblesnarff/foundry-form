import Foundation
import CoreGraphics

// MARK: - Angle Calculator

enum AngleCalculator {

    // MARK: - Core Angle Calculation

    /// Calculate angle at the vertex formed by three points, in degrees (0–180).
    /// - Parameters:
    ///   - point1: First endpoint
    ///   - vertex: The vertex (middle joint)
    ///   - point3: Second endpoint
    /// - Returns: Angle in degrees
    static func calculateAngle(point1: CGPoint, vertex: CGPoint, point3: CGPoint) -> Float {
        let v1 = CGVector(dx: point1.x - vertex.x, dy: point1.y - vertex.y)
        let v2 = CGVector(dx: point3.x - vertex.x, dy: point3.y - vertex.y)

        let mag1 = sqrt(v1.dx * v1.dx + v1.dy * v1.dy)
        let mag2 = sqrt(v2.dx * v2.dx + v2.dy * v2.dy)

        guard mag1 > 0, mag2 > 0 else { return 0 }

        let dot = v1.dx * v2.dx + v1.dy * v2.dy
        let cosAngle = max(-1.0, min(1.0, dot / (mag1 * mag2)))
        let radians = acos(cosAngle)

        return Float(radians * 180.0 / .pi)
    }

    // MARK: - Exercise-Specific Angle Extraction

    /// Squat: knee + hip angles (averaged across both sides)
    static func extractSquatAngles(from pose: PoseData) -> SquatAngles {
        let leftKnee = calculateAngle(point1: pose.leftHip, vertex: pose.leftKnee, point3: pose.leftAnkle)
        let rightKnee = calculateAngle(point1: pose.rightHip, vertex: pose.rightKnee, point3: pose.rightAnkle)
        let knee = (leftKnee + rightKnee) / 2

        let leftHip = calculateAngle(point1: pose.leftShoulder, vertex: pose.leftHip, point3: pose.leftKnee)
        let rightHip = calculateAngle(point1: pose.rightShoulder, vertex: pose.rightHip, point3: pose.rightKnee)
        let hip = (leftHip + rightHip) / 2

        return SquatAngles(kneeAngle: knee, hipAngle: hip)
    }

    /// Deadlift: knee + hip + back angles
    static func extractDeadliftAngles(from pose: PoseData) -> DeadliftAngles {
        let leftKnee = calculateAngle(point1: pose.leftHip, vertex: pose.leftKnee, point3: pose.leftAnkle)
        let rightKnee = calculateAngle(point1: pose.rightHip, vertex: pose.rightKnee, point3: pose.rightAnkle)
        let knee = (leftKnee + rightKnee) / 2

        let leftHip = calculateAngle(point1: pose.leftShoulder, vertex: pose.leftHip, point3: pose.leftKnee)
        let rightHip = calculateAngle(point1: pose.rightShoulder, vertex: pose.rightHip, point3: pose.rightKnee)
        let hip = (leftHip + rightHip) / 2

        let back = calculateAngle(point1: pose.leftShoulder, vertex: pose.leftHip, point3: pose.leftAnkle)

        return DeadliftAngles(kneeAngle: knee, hipAngle: hip, backAngle: back)
    }

    /// Bicep Curl: elbow angle + shoulder height
    static func extractBicepCurlAngles(from pose: PoseData) -> BicepCurlAngles {
        let leftElbow = calculateAngle(point1: pose.leftShoulder, vertex: pose.leftElbow, point3: pose.leftWrist)
        let rightElbow = calculateAngle(point1: pose.rightShoulder, vertex: pose.rightElbow, point3: pose.rightWrist)
        let elbow = (leftElbow + rightElbow) / 2

        let shoulderHeight = Float((pose.leftShoulder.y + pose.rightShoulder.y) / 2)

        return BicepCurlAngles(elbowAngle: elbow, shoulderHeight: shoulderHeight)
    }

    /// Push-Up: elbow + shoulder abduction + hip alignment
    static func extractPushUpAngles(from pose: PoseData) -> PushUpAngles {
        let leftElbow = calculateAngle(point1: pose.leftShoulder, vertex: pose.leftElbow, point3: pose.leftWrist)
        let rightElbow = calculateAngle(point1: pose.rightShoulder, vertex: pose.rightElbow, point3: pose.rightWrist)
        let elbow = (leftElbow + rightElbow) / 2

        let shoulder = calculateAngle(point1: pose.leftWrist, vertex: pose.leftShoulder, point3: pose.rightShoulder)

        let hipLevel = Float((pose.leftHip.y + pose.rightHip.y) / 2)
        let shoulderLevel = Float((pose.leftShoulder.y + pose.rightShoulder.y) / 2)
        let ankleLevel = Float((pose.leftAnkle.y + pose.rightAnkle.y) / 2)
        let alignment = abs(shoulderLevel - hipLevel) + abs(hipLevel - ankleLevel)

        return PushUpAngles(elbowAngle: elbow, shoulderAngle: shoulder, hipAlignment: alignment)
    }

    /// Plank: elbow angle + body alignment (deviation from straight line)
    static func extractPlankAngles(from pose: PoseData) -> PlankAngles {
        let shoulderY = Float((pose.leftShoulder.y + pose.rightShoulder.y) / 2)
        let hipY = Float((pose.leftHip.y + pose.rightHip.y) / 2)
        let ankleY = Float((pose.leftAnkle.y + pose.rightAnkle.y) / 2)
        let alignment = abs(shoulderY - hipY) + abs(hipY - ankleY)

        let leftElbow = calculateAngle(point1: pose.leftShoulder, vertex: pose.leftElbow, point3: pose.leftWrist)
        let rightElbow = calculateAngle(point1: pose.rightShoulder, vertex: pose.rightElbow, point3: pose.rightWrist)
        let elbow = (leftElbow + rightElbow) / 2

        return PlankAngles(elbowAngle: elbow, bodyAlignment: alignment)
    }

    /// Golf Swing: wrist angle + shoulder rotation + knee flex
    static func extractGolfSwingAngles(from pose: PoseData) -> GolfSwingAngles {
        let wrist = calculateAngle(point1: pose.leftElbow, vertex: pose.leftWrist, point3: pose.rightWrist)

        let shoulderRotation = calculateAngle(
            point1: pose.leftWrist,
            vertex: pose.leftShoulder,
            point3: pose.rightShoulder
        )

        let leftKnee = calculateAngle(point1: pose.leftHip, vertex: pose.leftKnee, point3: pose.leftAnkle)
        let rightKnee = calculateAngle(point1: pose.rightHip, vertex: pose.rightKnee, point3: pose.rightAnkle)
        let knee = (leftKnee + rightKnee) / 2

        return GolfSwingAngles(wristAngle: wrist, shoulderRotation: shoulderRotation, kneeAngle: knee)
    }
}

// MARK: - Exercise-Specific Angle Structures

struct SquatAngles {
    let kneeAngle: Float
    let hipAngle: Float
    var primaryAngle: Float { kneeAngle }
}

struct DeadliftAngles {
    let kneeAngle: Float
    let hipAngle: Float
    let backAngle: Float
    var primaryAngle: Float { kneeAngle }
}

struct BicepCurlAngles {
    let elbowAngle: Float
    let shoulderHeight: Float
    var primaryAngle: Float { elbowAngle }
}

struct PushUpAngles {
    let elbowAngle: Float
    let shoulderAngle: Float
    let hipAlignment: Float
    var primaryAngle: Float { elbowAngle }
}

struct PlankAngles {
    let elbowAngle: Float
    let bodyAlignment: Float
    var primaryAngle: Float { elbowAngle }
}

struct GolfSwingAngles {
    let wristAngle: Float
    let shoulderRotation: Float
    let kneeAngle: Float
    var primaryAngle: Float { wristAngle }
}
