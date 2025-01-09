import SwiftUI

struct ProductUI: Hashable, Transferable, Codable, Identifiable {
    var id: UUID { swiftDataId }
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .productUI)
    }
    
    let swiftDataId: UUID
    let name: String
    let count: Double?
    let countUnit: CountUnit?
    var purchased: Bool
}
