import SwiftUI

extension Color {
    static let primaryColor = Color(red: 0.74, green: 0.17, blue: 0.22)
    static let primaryGradientStart = Color(red: 0.86, green: 0.28, blue: 0.24)
    static let primaryGradientEnd = Color(red: 0.62, green: 0.11, blue: 0.19)
    static let secondaryColor = Color(red: 0.88, green: 0.74, blue: 0.44)
    static let surface = Color(uiColor: .systemGroupedBackground)
    static let surfaceContainerLow = Color(uiColor: .secondarySystemGroupedBackground)
    static let surfaceContainerHigh = Color(uiColor: .tertiarySystemGroupedBackground)
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary
}

extension LinearGradient {
    static let primaryButtonGradient = LinearGradient(
        gradient: Gradient(colors: [.primaryGradientStart, .primaryGradientEnd]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
