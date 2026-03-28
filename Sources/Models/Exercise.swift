import Foundation

// MARK: - Exercise Type & Configuration

enum ExerciseType: String, CaseIterable, Identifiable, Codable {
    case squat
    case deadlift
    case bicepCurl
    case pushUp
    case plank
    case golfSwing

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .squat: return "Squat"
        case .deadlift: return "Deadlift"
        case .bicepCurl: return "Bicep Curl"
        case .pushUp: return "Push-Up"
        case .plank: return "Plank"
        case .golfSwing: return "Golf Swing"
        }
    }

    var description: String {
        switch self {
        case .squat:
            return "Lower your body by bending knees and hips, keeping chest upright. Go as deep as comfortable."
        case .deadlift:
            return "Lift weight from ground by extending hips and knees. Keep back straight throughout."
        case .bicepCurl:
            return "Bend elbows to bring hands toward shoulders. Full range of motion from straight arms."
        case .pushUp:
            return "Lower body until chest near ground, then push back up. Keep body in straight line."
        case .plank:
            return "Hold body in straight line, supported by forearms. Engage core throughout."
        case .golfSwing:
            return "Swing club from address position, keeping wrists stable through impact."
        }
    }

    var iconName: String {
        switch self {
        case .squat: return "figure.strengthtraining.traditional"
        case .deadlift: return "figure.strengthtraining.functional"
        case .bicepCurl: return "dumbbell.fill"
        case .pushUp: return "figure.core.training"
        case .plank: return "figure.pilates"
        case .golfSwing: return "figure.golf"
        }
    }

    /// Whether the exercise is rep-based (vs. isometric hold like plank).
    var isRepBased: Bool {
        self != .plank
    }

    // Reference joint angles (in degrees) for good form
    var referenceAngles: ExerciseReferenceAngles {
        switch self {
        case .squat:
            return ExerciseReferenceAngles(
                primary: .init(name: "knee", degrees: 70, tolerance: 20, weight: 0.7),
                secondary: .init(name: "hip", degrees: 60, tolerance: 20, weight: 0.3)
            )
        case .deadlift:
            return ExerciseReferenceAngles(
                primary: .init(name: "knee", degrees: 40, tolerance: 25, weight: 0.4),
                secondary: .init(name: "hip", degrees: 25, tolerance: 25, weight: 0.3),
                tertiary: .init(name: "back", degrees: 20, tolerance: 20, weight: 0.3)
            )
        case .bicepCurl:
            return ExerciseReferenceAngles(
                primary: .init(name: "elbow", degrees: 90, tolerance: 20, weight: 0.7),
                secondary: .init(name: "shoulder", degrees: 0, tolerance: 10, weight: 0.3)
            )
        case .pushUp:
            return ExerciseReferenceAngles(
                primary: .init(name: "elbow", degrees: 90, tolerance: 20, weight: 0.5),
                secondary: .init(name: "shoulder", degrees: 45, tolerance: 15, weight: 0.2),
                tertiary: .init(name: "hip", degrees: 180, tolerance: 10, weight: 0.3)
            )
        case .plank:
            return ExerciseReferenceAngles(
                primary: .init(name: "elbow", degrees: 90, tolerance: 10, weight: 0.3),
                secondary: .init(name: "hip", degrees: 180, tolerance: 5, weight: 0.7)
            )
        case .golfSwing:
            return ExerciseReferenceAngles(
                primary: .init(name: "wrist", degrees: 20, tolerance: 15, weight: 0.4),
                secondary: .init(name: "shoulder", degrees: 90, tolerance: 20, weight: 0.4),
                tertiary: .init(name: "knee", degrees: 15, tolerance: 10, weight: 0.2)
            )
        }
    }

    // Rep detection thresholds (angle ranges to count a rep)
    var repDetectionThresholds: RepDetectionConfig {
        switch self {
        case .squat:
            return RepDetectionConfig(minAngle: 70, maxAngle: 170, required: true)
        case .deadlift:
            return RepDetectionConfig(minAngle: 20, maxAngle: 170, required: true)
        case .bicepCurl:
            return RepDetectionConfig(minAngle: 40, maxAngle: 170, required: true)
        case .pushUp:
            return RepDetectionConfig(minAngle: 50, maxAngle: 160, required: true)
        case .plank:
            return RepDetectionConfig(minAngle: 170, maxAngle: 180, required: false)
        case .golfSwing:
            return RepDetectionConfig(minAngle: 10, maxAngle: 180, required: true)
        }
    }
}

// MARK: - Reference Angle Entry

struct JointAngleReference: Codable, Equatable {
    let name: String
    let degrees: Float
    let tolerance: Float
    let weight: Float

    init(name: String, degrees: Float, tolerance: Float = 20, weight: Float = 1.0) {
        self.name = name
        self.degrees = degrees
        self.tolerance = tolerance
        self.weight = weight
    }
}

// MARK: - Reference Angles Structure

struct ExerciseReferenceAngles: Codable, Equatable {
    let primary: JointAngleReference
    let secondary: JointAngleReference
    let tertiary: JointAngleReference?

    init(
        primary: JointAngleReference,
        secondary: JointAngleReference,
        tertiary: JointAngleReference? = nil
    ) {
        self.primary = primary
        self.secondary = secondary
        self.tertiary = tertiary
    }
}

// MARK: - Rep Detection Configuration

struct RepDetectionConfig: Codable, Equatable {
    let minAngle: Float
    let maxAngle: Float
    let required: Bool
}
