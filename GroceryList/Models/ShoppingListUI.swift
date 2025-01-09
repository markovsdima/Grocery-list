import SwiftUI

struct ShoppingListUI: Hashable, Transferable, Codable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .shoppingListUI)
    }
    
    let swiftDataId: UUID
    let name: String
    let color: ListColor?
    let icon: ListIcon?
    let totalProducts: Int
    let purchasedProducts: Int
}
