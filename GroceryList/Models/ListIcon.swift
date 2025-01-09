import SwiftUI

enum ListIcon: Int, CaseIterable, Codable {
    case snow = 0
    case airplane = 1
    case alert = 2
    case balloon = 3
    case bandage = 4
    case barbell = 5
    case bed = 6
    case briefcase = 7
    case build = 8
    case business = 9
    case calendarNumber = 10
    case gift = 11
    case colorPalette = 12
    case cart = 13
    case car = 14
    case fastFood = 15
    case paw = 16
    case gameController = 17
    
    var icon: Image {
        switch self {
        case .snow:
            return Image(.snow)
        case .airplane:
            return Image(.airplane)
        case .alert:
            return Image(.alert)
        case .balloon:
            return Image(.balloon)
        case .bandage:
            return Image(.bandage)
        case .barbell:
            return Image(.barbell)
        case .bed:
            return Image(.bed)
        case .briefcase:
            return Image(.briefcase)
        case .build:
            return Image(.build)
        case .business:
            return Image(.business)
        case .calendarNumber:
            return Image(.calendarNumber)
        case .gift:
            return Image(.gift)
        case .colorPalette:
            return Image(.colorPalette)
        case .cart:
            return Image(.cart)
        case .car:
            return Image(.car)
        case .fastFood:
            return Image(.fastFood)
        case .paw:
            return Image(.paw)
        case .gameController:
            return Image(.gameController)
        }
    }
}
