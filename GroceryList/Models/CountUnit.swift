import Foundation

enum CountUnit: Int, CaseIterable, Codable {
    case quantify = 0
    case kilogram = 1
    case gram = 2
    case liter = 3
    case milliliter = 4
    
    var name: String {
        switch self {
        case .quantify:
            return "шт"
        case .kilogram:
            return "кг"
        case .gram:
            return "г"
        case .liter:
            return "л"
        case .milliliter:
            return "мл"
        }
    }
}
