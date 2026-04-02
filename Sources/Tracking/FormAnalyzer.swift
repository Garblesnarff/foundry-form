import Foundation

// MARK: - Form Analyzer Observable

class FormAnalyzer: ObservableObject {
    @Published var formScore: Float = 0
    @Published var formFeedback: String = ""
    @Published var jointFeedback: [String: String] = [:]

    private var scoreHistory: [Float] = []
    private let historySize = 10

    // MARK: - Analyze Form

    func analyzeForm(pose: PoseData, for exercise: ExerciseType) {
        guard pose.isValid else {
            formScore = 0
            formFeedback = "Unable to detect form. Please position yourself in the frame."
            return
        }

        let score: Float

        switch exercise {
        case .squat:
            score = analyzeSquat(pose: pose)
        case .deadlift:
            score = analyzeDeadlift(pose: pose)
        case .bicepCurl:
            score = analyzeBicepCurl(pose: pose)
        case .pushUp:
            score = analyzePushUp(pose: pose)
        case .plank:
            score = analyzePlank(pose: pose)
        case .golfSwing:
            score = analyzeGolfSwing(pose: pose)
        }

        formScore = score
        scoreHistory.append(score)
        if scoreHistory.count > historySize {
            scoreHistory.removeFirst()
        }

        updateFeedback(for: exercise, score: score)
    }

    // MARK: - Exercise-Specific Analysis

    private func analyzeSquat(pose: PoseData) -> Float {
        let angles = AngleCalculator.extractSquatAngles(from: pose)
        let ref = ExerciseType.squat.referenceAngles

        let kneeContribution = jointScore(
            userAngle: angles.kneeAngle,
            reference: ref.primary
        )
        let hipContribution = jointScore(
            userAngle: angles.hipAngle,
            reference: ref.secondary
        )

        let score = (kneeContribution + hipContribution) * 100

        jointFeedback["knee"] = "Knee: \(Int(angles.kneeAngle))° (target: \(Int(ref.primary.degrees))°)"
        jointFeedback["hip"] = "Hip: \(Int(angles.hipAngle))° (target: \(Int(ref.secondary.degrees))°)"

        return clampScore(score)
    }

    private func analyzeDeadlift(pose: PoseData) -> Float {
        let angles = AngleCalculator.extractDeadliftAngles(from: pose)
        let ref = ExerciseType.deadlift.referenceAngles

        let kneeContribution = jointScore(userAngle: angles.kneeAngle, reference: ref.primary)
        let hipContribution = jointScore(userAngle: angles.hipAngle, reference: ref.secondary)
        let backContribution = ref.tertiary.map { jointScore(userAngle: angles.backAngle, reference: $0) } ?? 0

        let score = (kneeContribution + hipContribution + backContribution) * 100

        jointFeedback["knee"] = "Knee: \(Int(angles.kneeAngle))° (target: \(Int(ref.primary.degrees))°)"
        jointFeedback["hip"] = "Hip: \(Int(angles.hipAngle))° (target: \(Int(ref.secondary.degrees))°)"
        jointFeedback["back"] = "Back: \(Int(angles.backAngle))° (target: \(Int(ref.tertiary?.degrees ?? 20))°)"

        return clampScore(score)
    }

    private func analyzeBicepCurl(pose: PoseData) -> Float {
        let angles = AngleCalculator.extractBicepCurlAngles(from: pose)
        let ref = ExerciseType.bicepCurl.referenceAngles

        let elbowContribution = jointScore(userAngle: angles.elbowAngle, reference: ref.primary)

        // Shoulder stability — penalize if shoulders rise significantly
        let shoulderStability = Float(1.0 - min(1.0, abs(angles.shoulderHeight) * 0.5))
        let shoulderContribution = shoulderStability * ref.secondary.weight

        let score = (elbowContribution + shoulderContribution) * 100

        jointFeedback["elbow"] = "Elbow: \(Int(angles.elbowAngle))° (target: \(Int(ref.primary.degrees))°)"
        jointFeedback["shoulder"] = "Keep shoulders stable"

        return clampScore(score)
    }

    private func analyzePushUp(pose: PoseData) -> Float {
        let angles = AngleCalculator.extractPushUpAngles(from: pose)
        let ref = ExerciseType.pushUp.referenceAngles

        let elbowContribution = jointScore(userAngle: angles.elbowAngle, reference: ref.primary)
        let shoulderContribution = jointScore(userAngle: angles.shoulderAngle, reference: ref.secondary)

        // Hip alignment — lower penalty means better form
        let alignmentPenalty = Float(min(1.0, angles.hipAlignment * 0.2))
        let hipContribution = (1.0 - alignmentPenalty) * (ref.tertiary?.weight ?? 0.3)

        let score = (elbowContribution + shoulderContribution + hipContribution) * 100

        jointFeedback["elbow"] = "Elbow: \(Int(angles.elbowAngle))° (target: \(Int(ref.primary.degrees))°)"
        jointFeedback["body"] = alignmentPenalty > 0.3 ? "Hips sagging — engage core" : "Good body alignment"

        return clampScore(score)
    }

    private func analyzePlank(pose: PoseData) -> Float {
        let angles = AngleCalculator.extractPlankAngles(from: pose)

        // Alignment should be minimal (perfect alignment = 0)
        let alignmentScore = max(0, Float(100) - Float(angles.bodyAlignment) * 500)
        let elbowError = abs(angles.elbowAngle - 90)
        let elbowScore = max(0, 100 - elbowError * 2)

        let score = alignmentScore * 0.7 + elbowScore * 0.3

        jointFeedback["alignment"] = "Body alignment: \(String(format: "%.1f", angles.bodyAlignment))"
        jointFeedback["elbow"] = "Elbow: \(Int(angles.elbowAngle))°"

        return clampScore(score)
    }

    private func analyzeGolfSwing(pose: PoseData) -> Float {
        let angles = AngleCalculator.extractGolfSwingAngles(from: pose)
        let ref = ExerciseType.golfSwing.referenceAngles

        let wristContribution = jointScore(userAngle: angles.wristAngle, reference: ref.primary)
        let rotationScore = min(100, angles.shoulderRotation) / 100 * ref.secondary.weight
        let kneeContribution = ref.tertiary.map { jointScore(userAngle: angles.kneeAngle, reference: $0) } ?? 0

        let score = (wristContribution + rotationScore + kneeContribution) * 100

        jointFeedback["wrist"] = "Wrist: \(Int(angles.wristAngle))° (target: \(Int(ref.primary.degrees))°)"
        jointFeedback["shoulder"] = "Shoulder rotation: \(Int(angles.shoulderRotation))°"
        jointFeedback["knee"] = "Knee flex: \(Int(angles.kneeAngle))° (target: \(Int(ref.tertiary?.degrees ?? 15))°)"

        return clampScore(score)
    }

    // MARK: - Scoring Helpers

    /// Calculate weighted joint contribution for a single joint.
    private func jointScore(userAngle: Float, reference: JointAngleReference) -> Float {
        let error = abs(userAngle - reference.degrees)
        let delta = max(0, reference.tolerance - error)
        return (delta / reference.tolerance) * reference.weight
    }

    private func clampScore(_ score: Float) -> Float {
        min(100, max(0, score))
    }

    // MARK: - Feedback Generation

    private func updateFeedback(for exercise: ExerciseType, score: Float) {
        if score >= 80 {
            formFeedback = "Great form! Keep it up."
        } else if score >= 60 {
            formFeedback = "Good form. Minor adjustments needed."
        } else if score >= 40 {
            formFeedback = "Form degrading. Check your alignment."
        } else {
            formFeedback = "Poor form. Reset and try again."
        }
    }

    // MARK: - Statistics

    func averageFormScore() -> Float {
        guard !scoreHistory.isEmpty else { return 0 }
        return scoreHistory.reduce(0, +) / Float(scoreHistory.count)
    }

    func bestFormScore() -> Float {
        scoreHistory.max() ?? 0
    }

    func resetHistory() {
        scoreHistory.removeAll()
        formScore = 0
        formFeedback = ""
        jointFeedback.removeAll()
    }
}
