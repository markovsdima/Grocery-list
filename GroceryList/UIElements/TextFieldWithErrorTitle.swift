import SwiftUI

struct TextFieldWithErrorTitle: View {
    // MARK: - Public Properties
    enum FieldState {
        case `default`, focused, error
    }
    @Binding var errorTitle: String
    @Binding var textFieldText: String
    @Binding var fieldState: FieldState
    var textFieldHolder: String
    
    // MARK: - Private Properties
    @FocusState private var isFocused: Bool
    private var stateBorderColor: Color {
        switch $fieldState.wrappedValue {
        case .default:
            return .clear
        case .focused:
            return .clear
        case .error:
            return .red
        }
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                textField()
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.glWhite)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(lineWidth: 1)
                    .foregroundStyle(stateBorderColor)
            )
            if fieldState == .error {
                Text(errorTitle)
                    .font(.footnote)
                    .foregroundStyle(.glRed)
            }
        }
    }
    
    // MARK: - View Components
    @ViewBuilder func textField() -> some View {
        TextField(
            "",
            text: $textFieldText,
            prompt: Text(textFieldHolder)
                .foregroundColor(.gray)
                .fontWeight(.regular)
        )
        .font(.system(size: 18, weight: .medium))
        .foregroundStyle(.glBlack)
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 60)
        .focused($isFocused)
        
        if textFieldText != "" && isFocused {
            Image(.closeButton)
                .frame(width: 52, height: 60)
                .onTapGesture {
                    textFieldText = ""
                }
        }
    }
}

// MARK: - Previews
#if DEBUG
#Preview("Default") {
    ZStack {
        Color.glBackground.ignoresSafeArea()
        
        TextFieldWithErrorTitle(
            errorTitle: .constant(""),
            textFieldText: .constant(""),
            fieldState: .constant(.default),
            textFieldHolder: "Введите название списка"
        )
        .padding(16)
    }
}

#Preview("Focus") {
    ZStack {
        Color.glBackground.ignoresSafeArea()
        
        TextFieldWithErrorTitle(
            errorTitle: .constant(""),
            textFieldText: .constant(""),
            fieldState: .constant(.focused),
            textFieldHolder: "Введите название списка"
        )
        .padding(16)
    }
}

#Preview("Error") {
    ZStack {
        Color.glBackground.ignoresSafeArea()
        
        TextFieldWithErrorTitle(
            errorTitle: .constant("Это название уже используется, пожалуйста, измените его."),
            textFieldText: .constant("Новый год"),
            fieldState: .constant(.error),
            textFieldHolder: "Введите название списка"
        )
        .padding(16)
    }
}
#endif
