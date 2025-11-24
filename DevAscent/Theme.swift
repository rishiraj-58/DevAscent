//
//  Theme.swift
//  DevAscent
//
//  Created by Rishiraj on 24/11/25.
//

import SwiftUI

/// The "Zen Coder" Design System
/// A cyber-minimalist color palette inspired by GitHub Dark and VS Code themes
extension Color {
    /// Deep GitHub Dark - Primary background color for all screens
    static let background = Color(hex: "#0D1117")
    
    /// Lighter Dark - Background for cards, lists, and elevated surfaces
    static let cardBackground = Color(hex: "#161B22")
    
    /// Git Commit Green - Primary accent for buttons, active states, and success indicators
    static let primaryAccent = Color(hex: "#238636")
    
    /// VS Code Blue - Headers, highlights, and interactive elements
    static let neonText = Color(hex: "#58A6FF")
    
    /// Muted Gray - Secondary text and disabled states
    static let textSecondary = Color(hex: "#8B949E")
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
