import SwiftUI

enum Appearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark
    
    var id: String { self.rawValue }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    var pickerTag: Int {
        switch self {
        case .system: return 2
        case .light: return 0
        case .dark: return 1
        }
    }
}
