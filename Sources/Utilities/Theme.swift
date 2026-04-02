import SwiftUI

// MARK: - Foundry Design System Colors

extension Color {
    /// Forge Black #141210 — Primary background color
    static let forgeBlack = Color(red: 0.078, green: 0.071, blue: 0.063)

    /// Forge Amber #E8A849 — Primary accent / CTA color
    static let forgeAmber = Color(red: 0.91, green: 0.66, blue: 0.29)

    /// Forge Dark Gray #25241F — Secondary backgrounds, separators
    static let forgeDarkGray = Color(red: 0.145, green: 0.141, blue: 0.122)

    /// Medium Gray #6B6A67 — Secondary text, disabled elements
    static let forgeMediumGray = Color(red: 0.420, green: 0.416, blue: 0.404)

    /// Card Background — Slightly lighter than Forge Black
    static let forgeCardBackground = Color(red: 0.15, green: 0.14, blue: 0.12)

    /// Stats Card Background — Slightly darker
    static let forgeStatsBackground = Color(red: 0.102, green: 0.098, blue: 0.082)

    // MARK: - Form Score Colors

    /// Success Green #22C55E — Good form (80–100%)
    static let formGreen = Color(red: 0.133, green: 0.773, blue: 0.369)

    /// Warning Yellow #FBBF24 — Acceptable form (60–79%)
    static let formYellow = Color(red: 0.984, green: 0.749, blue: 0.141)

    /// Error Red #EF4444 — Poor form (0–59%)
    static let formRed = Color(red: 0.937, green: 0.267, blue: 0.267)

    /// Returns the appropriate form score color for a given percentage.
    static func formScoreColor(for score: Float) -> Color {
        if score >= 80 {
            return .formGreen
        } else if score >= 60 {
            return .formYellow
        } else {
            return .formRed
        }
    }
}

// MARK: - Foundry Button Styles

struct ForgeButtonStyle: ButtonStyle {
    var isDestructive = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .font(.headline)
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isDestructive ? Color.formRed : Color.forgeAmber)
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct ForgeSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .font(.headline)
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.forgeDarkGray)
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

// MARK: - Foundry View Modifiers

struct ForgeNavigationModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .preferredColorScheme(.dark)
    }
}

extension View {
    /// Apply the standard Foundry dark forge appearance.
    func forgeStyle() -> some View {
        modifier(ForgeNavigationModifier())
    }
}
