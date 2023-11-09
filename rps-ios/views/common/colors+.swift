//
//  Color.swift
//  rps-ios
//
//  Created by serika on 2023/11/7.
//

import SwiftUI

extension Color {
    var uiColor: UIColor {
        return UIColor(self)
    }
    
    var cgColor: CGColor {
        return uiColor.cgColor
    }
}

extension Color {
    static var main: Color {
        return Color(hex: "#3D7FFF")
    }
    
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
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    static func hex(_ v: String) -> Color { Color(hex: v) }
}

extension Color {
    enum view {
        static var background: Color { return Color(hex: "#F9F9F9") }
        static var divider: Color { return Color(hex: "#B4B3B1") }
    }
}

extension Color {
    enum text {
        static var main: Color { return .main }
        static var gray3: Color { return Color(hex: "#333333") }
        static var gray6: Color { return Color(hex: "#666666") }
        static var gray9: Color { return Color(hex: "#999999") }
    }
}

