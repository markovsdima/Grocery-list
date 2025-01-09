import SwiftUI

struct ColorPickerView: View {
    // MARK: - Public Properties
    @Binding var selectedColor: ListColor?
    
    // MARK: - Private Properties
    private let rows = [GridItem(.flexible())]
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.glWhite
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 0) {
                title()
                
                grid()
                    .frame(maxWidth: .infinity, maxHeight: 48)
                    .padding(.vertical, 12)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
        .padding(.horizontal)
        .frame(height: 105)
    }
    
    // MARK: - View Components
    @ViewBuilder private func title() -> some View {
        Text("Выберите цвет")
            .font(.callout)
            .padding(.top, 12)
            .foregroundStyle(Color.glBlack)
    }
    
    @ViewBuilder private func grid() -> some View {
        LazyHGrid(rows: rows, spacing: 12) {
            ForEach(ListColor.allCases, id: \.self) { colorCase in
                gridItem(colorCase: colorCase)
            }
        }
    }
    
    @ViewBuilder private func gridItem(colorCase: ListColor) -> some View {
        Button(action: {
            selectedColor = colorCase
        }) {
            itemButtonContent(colorCase: colorCase)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder private func itemButtonContent(colorCase: ListColor) -> some View {
        ZStack {
            Circle()
                .fill(colorCase.color)
                .frame(width: 48, height: 48)
                .overlay(
                    ZStack {
                        Circle()
                            .stroke(Color.glWhite, lineWidth: 7)
                        
                        Circle()
                            .stroke(
                                selectedColor == colorCase ?
                                    Color.glTurquoise : Color.clear, lineWidth: 2
                            )
                    }
                )
        }
    }
}

// MARK: - Previews
#if DEBUG
#Preview {
    @Previewable @State var previewSelectedColor: ListColor? = .red
    
    ZStack {
        Color.glBackground.ignoresSafeArea()
        
        ColorPickerView(selectedColor: $previewSelectedColor)
    }
}
#endif
