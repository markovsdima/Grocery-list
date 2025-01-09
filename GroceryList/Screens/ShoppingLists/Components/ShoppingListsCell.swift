import SwiftUI

struct ShoppingListsCell: View {
    // MARK: - Public Properties
    let list: ShoppingListUI
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 0) {
            icon()
            name()
            Spacer()
            progress()
        }
        .padding(.horizontal)
        .frame(height: 84)
        .background(Color.glWhite)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.leading)
    }
    
    // MARK: - View Components
    @ViewBuilder private func icon() -> some View {
        ZStack {
            Circle()
                .fill(list.color?.color ?? .white)
                .frame(width: 48, height: 48)
            list.icon?.icon
                .renderingMode(.template)
                .foregroundStyle(.glBlackStatic)
        }
    }
    
    @ViewBuilder private func name() -> some View {
        Text(list.name)
            .font(.title3)
            .fontWeight(.semibold)
            .padding(.leading, 12)
    }
    
    @ViewBuilder private func progress() -> some View {
        HStack(spacing: 0) {
            Text("\(list.purchasedProducts)")
                .font(.title3)
            Text("/")
                .padding(.bottom, 3)
                .padding(.horizontal, 1)
            Text("\(list.totalProducts)")
                .font(.title3)
                .fontWeight(.semibold)
        }
        .padding(.trailing, 16)
    }
}

// MARK: - Previews
#if DEBUG
#Preview {
    ZStack {
        Color.glBackground
        ShoppingListsCell(list: mockList)
    }
}

fileprivate let mockList = ShoppingListUI(
    swiftDataId: UUID(),
    name: "List name",
    color: ListColor.green,
    icon: ListIcon.car,
    totalProducts: 2,
    purchasedProducts: 1
)
#endif


