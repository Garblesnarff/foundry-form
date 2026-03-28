import XCTest
@testable import FoundryForm

final class RepCounterTests: XCTestCase {

    // MARK: - Basic Rep Counting

    func testInitialRepCountIsZero() {
        let counter = RepCounter(config: .init(minAngle: 40, maxAngle: 170, required: true))
        XCTAssertEqual(counter.repCount, 0)
    }

    func testSingleRep() {
        let counter = RepCounter(config: .init(minAngle: 40, maxAngle: 170, required: true))

        // Simulate: standing (170°) → squat (30°) → standing (175°)
        counter.updateWithAngle(170)
        counter.updateWithAngle(120)
        counter.updateWithAngle(80)
        counter.updateWithAngle(30)  // Below min → descending
        counter.updateWithAngle(80)
        counter.updateWithAngle(120)
        counter.updateWithAngle(175) // Above max → rep counted

        XCTAssertEqual(counter.repCount, 1, "Should count exactly 1 rep")
    }

    func testMultipleReps() {
        let counter = RepCounter(config: .init(minAngle: 40, maxAngle: 170, required: true))

        for _ in 0..<5 {
            counter.updateWithAngle(30)  // Below min
            counter.updateWithAngle(175) // Above max → rep
        }

        XCTAssertEqual(counter.repCount, 5, "Should count 5 reps")
    }

    func testPartialRepNotCounted() {
        let counter = RepCounter(config: .init(minAngle: 40, maxAngle: 170, required: true))

        // Go below min but don't go all the way back up
        counter.updateWithAngle(30)
        counter.updateWithAngle(100) // Not above maxAngle

        XCTAssertEqual(counter.repCount, 0, "Partial rep should not be counted")
    }

    func testNotRequiredExercise() {
        let counter = RepCounter(config: .init(minAngle: 170, maxAngle: 180, required: false))

        counter.updateWithAngle(175)
        counter.updateWithAngle(185)

        XCTAssertEqual(counter.repCount, 0, "Non-required exercises should not count reps")
    }

    func testReset() {
        let counter = RepCounter(config: .init(minAngle: 40, maxAngle: 170, required: true))

        counter.updateWithAngle(30)
        counter.updateWithAngle(175)
        XCTAssertEqual(counter.repCount, 1)

        counter.reset()
        XCTAssertEqual(counter.repCount, 0, "Reset should zero the count")
        XCTAssertFalse(counter.inRepMotion)
    }

    // MARK: - Factory

    func testFactoryCreatesForAllExercises() {
        for exercise in ExerciseType.allCases {
            let counter = RepCounterFactory.create(for: exercise)
            XCTAssertEqual(counter.repCount, 0)
        }
    }
}
