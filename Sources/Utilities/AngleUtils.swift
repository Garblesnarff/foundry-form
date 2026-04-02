import Foundation
import CoreGraphics

// MARK: - Angle Utilities

/// Shared utility functions for angle calculations and conversions.
enum AngleUtils {

    /// Convert radians to degrees.
    static func radiansToDegrees(_ radians: Double) -> Double {
        radians * 180.0 / .pi
    }

    /// Convert degrees to radians.
    static func degreesToRadians(_ degrees: Double) -> Double {
        degrees * .pi / 180.0
    }

    /// Calculate the angle at the vertex formed by three points, in degrees (0–180).
    static func angleBetween(
        _ pointA: CGPoint,
        vertex: CGPoint,
        _ pointB: CGPoint
    ) -> Float {
        AngleCalculator.calculateAngle(point1: pointA, vertex: vertex, point3: pointB)
    }

    /// Normalize an angle to the 0–360° range.
    static func normalize(_ degrees: Float) -> Float {
        var d = degrees.truncatingRemainder(dividingBy: 360)
        if d < 0 { d += 360 }
        return d
    }

    /// Clamp a value to a given range.
    static func clamp<T: Comparable>(_ value: T, min lo: T, max hi: T) -> T {
        Swift.min(hi, Swift.max(lo, value))
    }
}
