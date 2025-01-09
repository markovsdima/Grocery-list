import SwiftUI

struct ProductCell: View {
    // MARK: - Public Properties
    var product: ProductUI
    var onToggle: (() -> Void)?
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(minHeight: 1)
            HStack(spacing: 8) {
                Checkbox(isChecked: product.purchased, onToggle: onToggle)
                Text(product.name)
                    .foregroundStyle(product.purchased ? .glHintGray : .glBlack)
                    .padding(.leading, 8)
                Spacer()
                if let count = product.count {
                    Text(count == floor(count) ? String(format: "%.0f", count) : String(count))
                        .foregroundStyle(product.purchased ? .glHintGray : .glBlack)
                }
                if product.count != nil, let countUnit = product.countUnit {
                    Text(countUnit.name)
                        .foregroundStyle(product.purchased ? .glHintGray : .glBlack)
                }
            }
            .padding(.horizontal, 16)
            
            Spacer()
                .frame(minHeight: 1)
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.glSystemLightGray)
        }
        .frame(height: 52)
        .background(.glBackground)
    }
}

// MARK: - Previews
#if DEBUG
#Preview {
    ProductCell(product: mockProduct)
}
fileprivate let mockProduct = ProductUI(
    swiftDataId: UUID(),
    name: "Чайник",
    count: 3,
    countUnit: .quantify,
    purchased: false)
#endif
