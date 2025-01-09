import SwiftUI

struct Checkbox: View {
    // MARK: - Public Properties
    @State var isChecked: Bool
    var onToggle: (() -> Void)? = nil
    
    // MARK: - Body
    var body: some View {
        Button(action: {
            onToggle?()
        }) {
            Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(isChecked ? .glTurquoise : .gray)
        }
        .buttonStyle(.plain)
        .frame(width: 44, height: 44)
    }
}

// MARK: - Previews
#if DEBUG
#Preview("Checked") {
    Checkbox(isChecked: true)
}

#Preview("Unchecked") {
    Checkbox(isChecked: false)
}
#endif
