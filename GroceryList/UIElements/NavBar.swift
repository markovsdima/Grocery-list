import SwiftUI

struct NavBar: View {
    // MARK: - Public Properties
    let title: String
    let withOptions: Bool
    let onBack: () -> Void
    let menuContent: (() -> AnyView)?
    
    // MARK: - Body
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            button()
            Text(title)
                .font(.headline)
            Spacer()
            if withOptions, let content = menuContent {
                menu(content: content)
            }
        }
    }
    
    // MARK: - View Components
    @ViewBuilder private func button() -> some View {
        Button(action: { onBack() }) {
            Image(.navBack)
                .renderingMode(.template)
                .foregroundStyle(.glBlack)
        }
        .frame(width: 44, height: 44)
        .padding(.leading, 8)
    }
    
    @ViewBuilder private func menu(content: (() -> AnyView)) -> some View {
        Menu {
            menuContent?()
        } label: {
            Image(.optionsIcon)
                .renderingMode(.template)
                .foregroundStyle(.glBlack)
                .padding(.trailing)
        }
    }
}

// MARK: - Previews
#Preview {
    NavBar(title: "Создать список", withOptions: true, onBack: {}, menuContent: nil)
    Spacer()
}
