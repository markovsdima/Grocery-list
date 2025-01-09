import SwiftUI

enum ListColor: Int, CaseIterable, Codable {
    case green = 0
    case purple = 1
    case blue = 2
    case red = 3
    case yellow = 4
    
    var color: Color {
        switch self {
        case .green:
            return .listGreen
        case .purple:
            return .listPurple
        case .blue:
            return .listBlue
        case .red:
            return .listRed
        case .yellow:
            return .listYellow
        }
    }
}
