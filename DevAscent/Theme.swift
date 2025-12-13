//
//  Theme.swift
//  DevAscent
//
//  Created by Rishiraj on 24/11/25.
//

import SwiftUI

/// The "Zen Operator" Design System
/// A cyber-minimalist palette for the Mission Control interface
/// Dark mode only, OLED-friendly, high contrast neon accents
extension Color {
    // MARK: - Backgrounds
    
    /// Almost pure black - Primary background for all screens (OLED friendly)
    static let background = Color(hex: "#050505")
    
    /// Surface color for cards and elevated elements with thin border
    static let cardBackground = Color(hex: "#121212")
    
    /// Border color for panels and cards
    static let border = Color(hex: "#333333")
    
    // MARK: - Accent Colors
    
    /// Cyber Green - Success states, offers, primary buttons
    static let primaryAccent = Color(hex: "#00FF9D")
    
    /// Neon Cyan - Headers, active tabs, interactive elements
    static let neonText = Color(hex: "#00F0FF")
    
    /// Neon Red - Warnings, alerts, rejected status
    static let alertRed = Color(hex: "#FF0055")
    
    // MARK: - Text Colors
    
    /// Primary text - Pure white for maximum contrast
    static let textPrimary = Color.white
    
    /// Secondary text - Muted gray for labels and descriptions
    static let textSecondary = Color(hex: "#888888")
    
    // MARK: - Status Colors (for Intel Pipeline)
    
    /// Applied status - Blue
    static let statusApplied = Color(hex: "#3B82F6")
    
    /// OA/Assessment status - Yellow
    static let statusOA = Color(hex: "#EAB308")
    
    /// Interviewing status - Purple (used with pulsing animation)
    static let statusInterview = Color(hex: "#A855F7")
    
    /// Offer status - Uses primaryAccent (Cyber Green)
    static let statusOffer = Color(hex: "#00FF9D")
    
    /// Rejected status - Muted red
    static let statusRejected = Color(hex: "#991B1B")
}

// MARK: - Hex Color Extension
/// Utility extension to create Color from hex strings
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Typography Extensions
extension Font {
    /// Monospaced header font for terminal aesthetic
    static func operatorHeader(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .monospaced)
    }
    
    /// Monospaced label font with tracking
    static func operatorLabel(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }
}

// MARK: - View Modifiers
extension View {
    /// Standard card styling with border
    func operatorCard() -> some View {
        self
            .background(Color.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.border, lineWidth: 1)
            )
    }
    
    /// Glowing accent border for highlighted elements
    func glowBorder(color: Color = .primaryAccent, radius: CGFloat = 12) -> some View {
        self
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(color, lineWidth: 1)
            )
            .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 0)
    }
}
