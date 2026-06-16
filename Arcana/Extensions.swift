import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        self.init(.sRGB,
                  red:   Double(r) / 255,
                  green: Double(g) / 255,
                  blue:  Double(b) / 255,
                  opacity: 1)
    }
}

// Convenience gold gradient used in multiple places
extension LinearGradient {
    static let gold = LinearGradient(
        colors: [Color(hex: "FFD700"), Color(hex: "E8820C")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let goldBorder = LinearGradient(
        colors: [Color(hex: "FFD700"), Color(hex: "8B6914"), Color(hex: "FFD700")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let darkBg = LinearGradient(
        colors: [Color(hex: "080812"), Color(hex: "15052E")],
        startPoint: .top, endPoint: .bottom
    )
}
