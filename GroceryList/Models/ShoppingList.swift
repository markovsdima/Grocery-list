import Foundation
import SwiftData

@Model
final class ShoppingList {
    // MARK: - Properties
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var colorRawValue: Int
    var iconRawValue: Int
    var sortOrder: Int
    @Relationship(deleteRule: .cascade) var products: [Product]
    // cached properties
    private(set) var totalProducts: Int = 0
    private(set) var purchasedProducts: Int = 0
    
    // MARK: - Computed Properties
    var color: ListColor? {
        get {
            ListColor(rawValue: colorRawValue)
        }
        set {
            colorRawValue = newValue?.rawValue ?? 0
        }
    }
    
    var icon: ListIcon? {
        get {
            ListIcon(rawValue: iconRawValue)
        }
        set {
            iconRawValue = newValue?.rawValue ?? 0
        }
    }
    
    // MARK: - Init
    init(name: String, color: ListColor, icon: ListIcon, sortOrder: Int) {
        self.name = name
        self.colorRawValue = color.rawValue
        self.iconRawValue = icon.rawValue
        self.sortOrder = sortOrder
        self.products = []
        updateCache()
    }
    
    // MARK: - Public Methods
    func updateCache() {
        totalProducts = products.count
        purchasedProducts = products.filter { $0.purchased }.count
    }
}
