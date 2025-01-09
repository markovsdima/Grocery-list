import SwiftUI

struct WideButton: View {
    // MARK: - Public Properties
    @Binding var isActive: Bool
    @State var title: String
    
    // MARK: - Body
    var body: some View {
        buttonView
    }
    
    // MARK: - View Components
    private var buttonView: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(isActive ? .white : .glHintGray)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(isActive ? .glTurquoise : .glButtonGray)
            .cornerRadius(100)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
    }
}

// MARK: - Previews
#if DEBUG
#Preview("Active") {
    WideButton(isActive: .constant(true), title: "Title")
}

#Preview("Inactive") {
    WideButton(isActive: .constant(false), title: "Title")
}
#endif
