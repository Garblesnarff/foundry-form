import Foundation

// MARK: - Rep Counter State Machine

class RepCounter: ObservableObject {
    @Published var repCount = 0
    @Published var inRepMotion = false

    private var previousAngle: Float = 0
    private var state: CountingState = .waiting
    private let config: RepDetectionConfig

    private enum CountingState {
        case waiting     // Waiting for movement to start
        case descending  // Moving toward minimum angle
        case ascending   // Moving back to maximum angle
    }

    init(config: RepDetectionConfig) {
        self.config = config
    }

    // MARK: - Update Angle

    /// Feed a new primary angle value. The state machine detects rep completion
    /// when the angle oscillates from min → max (or max → min depending on exercise).
    func updateWithAngle(_ angle: Float) {
        guard config.required else { return }

        let angleChange = angle - previousAngle
        inRepMotion = abs(angleChange) > 5  // Significant movement detected

        switch state {
        case .waiting:
            if angle <= config.minAngle {
                state = .descending
            }

        case .descending:
            if angle >= config.maxAngle {
                repCount += 1
                state = .ascending
            }

        case .ascending:
            if angle <= config.minAngle {
                state = .descending
            }
        }

        previousAngle = angle
    }

    // MARK: - Reset

    func reset() {
        repCount = 0
        previousAngle = 0
        state = .waiting
        inRepMotion = false
    }
}

// MARK: - Rep Counter Factory

enum RepCounterFactory {
    static func create(for exercise: ExerciseType) -> RepCounter {
        RepCounter(config: exercise.repDetectionThresholds)
    }
}
