import Foundation
import SwiftData

@Model
final class ProductRecommendation {
    // MARK: - Properties
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var count: Int
    
    // MARK: - Init
    init(name: String, count: Int) {
        self.name = name
        self.count = count
    }
}
