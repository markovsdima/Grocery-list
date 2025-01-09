import Foundation
import SwiftData

@Model
final class Product {
    // MARK: - Properties
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var count: Double?
    var countUnitRawValue: Int?
    var purchased: Bool
    var sortOrder: Int
    @Relationship var shoppingList: ShoppingList?
    
    // MARK: - Computed Properties
    var countUnit: CountUnit? {
        get {
            guard let rawValue = countUnitRawValue else {
                return nil
            }
            return CountUnit(rawValue: rawValue)
        }
        set {
            countUnitRawValue = newValue?.rawValue
        }
    }
    
    // MARK: - Init
    init(
        name: String,
        count: Double? = nil,
        countUnit: CountUnit? = nil,
        purchased: Bool = false,
        sortOrder: Int
    ) {
        self.name = name
        self.count = count
        self.countUnitRawValue = countUnit?.rawValue
        self.purchased = purchased
        self.sortOrder = sortOrder
        self.shoppingList = shoppingList
    }
}
