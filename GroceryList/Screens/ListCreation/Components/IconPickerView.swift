import SwiftUI

struct IconPickerView: View {
    // MARK: - Public Properties
    @Binding var selectedIcon: ListIcon?
    @Binding var selectedColor: ListColor?
    
    // MARK: - Private Properties
    private let rows = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.glWhite
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 0) {
                title()
                grid()
                    .frame(maxWidth: .infinity, maxHeight: 168)
                    .padding(.vertical, 12)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
        .padding(.horizontal, 16)
        .frame(height: 225)
    }
    
    // MARK: - View Components
    @ViewBuilder private func title() -> some View {
        Text("Выберите дизайн")
            .font(.callout)
            .padding(.top, 12)
            .foregroundStyle(Color.glBlack)
    }
    
    @ViewBuilder private func grid() -> some View {
        LazyHGrid(rows: rows, spacing: 12) {
            ForEach(ListIcon.allCases, id: \.self) { iconCase in
                Button(action: {
                    selectedIcon = iconCase
                }) {
                    ZStack {
                        Circle()
                            .fill(iconCase == selectedIcon ?
                                  (selectedColor?.color ?? .gray) : .glIconBackground
                            )
                            .frame(width: 48, height: 48)
                        
                        iconCase.icon
                            .renderingMode(.template)
                            .foregroundStyle(iconCase == selectedIcon ?
                                .glBlackStatic : .glWhite
                            )
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Previews
#if DEBUG
#Preview {
    @Previewable @State var previewSelectedIcon: ListIcon? = .airplane
    @Previewable @State var previewSelectedColor: ListColor? = nil
    
    ZStack {
        Color.glBackground.ignoresSafeArea()
        
        IconPickerView(
            selectedIcon: $previewSelectedIcon,
            selectedColor: $previewSelectedColor
        )
    }
}
#endif
