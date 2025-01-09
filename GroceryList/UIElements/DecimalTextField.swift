import SwiftUI

struct DecimalTextField: View {
    // MARK: - Public Properties
    @Binding var count: Double?
    @Binding var allowDouble: Bool
    @Binding var countError: Bool
    var decimalFieldHolder: String
    
    // MARK: - Private Properties
    @State private var countText: String = ""
    @FocusState private var isFocused: Bool
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .leading) {
                hiddenTextInputField()
                formattedTextDisplay()
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 60)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.glWhite)
            )
            .overlay {
                if countError {
                    errorOverlay()
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: countError)
        .onAppear {
            if let count = count {
                countText = count == floor(count) ? String(format: "%.0f", count) : String(count)
            }
        }
        .onChange(of: countText) { _, newValue in
            handleInputChange(newValue: newValue)
        }
        .onChange(of: allowDouble) { oldValue, newValue in
            if oldValue && !newValue && countText.contains(".") {
                countError = true
                isFocused = false
            } else {
                countError = false
            }
        }
    }
    
    // MARK: - View Components
    @ViewBuilder private func hiddenTextInputField() -> some View {
        TextField("", text: $countText, prompt: Text(decimalFieldHolder).foregroundColor(.gray))
            .keyboardType(.decimalPad)
            .font(.system(size: 18, weight: .medium))
            .foregroundColor(.clear)
            .accentColor(.clear)
            .padding(.horizontal)
            .focused($isFocused)
    }
    
    @ViewBuilder private func formattedTextDisplay() -> some View {
        HStack(spacing: 0) {
            if let (wholePart, fractionalPart) = splitDecimal(countText) {
                // whole part
                Text(wholePart)
                    .foregroundColor(.primary)
                    .font(.system(size: 18, weight: .medium))
                
                // fractional part
                if !fractionalPart.isEmpty || countText.hasSuffix(".") {
                    Text(".\(fractionalPart)")
                        .foregroundColor(countError ? .red : .primary) // error highlighting
                        .font(.system(size: 18, weight: .medium))
                }
            } else {
                Text(countText)
                    .foregroundColor(.primary)
                    .font(.system(size: 18, weight: .medium))
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder private func errorOverlay() -> some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.clear, .red.opacity(0.5)]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .cornerRadius(8)
            .transition(.opacity)
            
            Image(systemName: "xmark.circle")
                .foregroundStyle(.glRed)
                .contentShape(.rect)
                .frame(width: 30, height: 30)
                .onTapGesture {
                    removeFractionalPart()
                }
        }
    }
    
    // MARK: - Private Methods
    private func splitDecimal(_ text: String) -> (wholePart: String, fractionalPart: String)? {
        // looking for a dot
        if let dotIndex = text.firstIndex(of: ".") {
            let wholePart = String(text[..<dotIndex]) // whole part
            let fractionalPart = String(text[text.index(after: dotIndex)...]) // fractional part
            return (wholePart, fractionalPart)
        } else {
            // if there is no dot, the whole string is considered to be an integer part
            return (text, "")
        }
    }
    
    private func handleInputChange(newValue: String) {
        // replace commas with periods
        let normalizedText = newValue.replacingOccurrences(of: ",", with: ".")
        
        var filtered = ""
        if allowDouble {
            filtered = normalizedText.filter { "0123456789.".contains($0) }
        } else {
            filtered = normalizedText.filter { "0123456789".contains($0) }
        }
        
        // remove extra points if there is more than one point
        let dotCount = filtered.filter { $0 == "." }.count
        if dotCount > 1 {
            let firstPart = filtered.prefix { $0 != "." }
            let remainingPart = filtered.dropFirst(firstPart.count + 1).replacingOccurrences(of: ".", with: "")
            countText = firstPart + "." + remainingPart
        } else {
            countText = filtered
        }
        
        // convert string to double
        if let number = Double(countText) {
            count = number
        } else {
            count = 0
        }
    }
    
    private func removeFractionalPart() {
        if let currentCount = count {
            count = floor(currentCount) // remove fractional part
            countText = String(format: "%.0f", floor(currentCount))
            countError = false // reset error
        }
    }
}

// MARK: - Previews
#if DEBUG
#Preview("Default") {
    ZStack {
        Color.glBackground.ignoresSafeArea()
        
        DecimalTextField(
            count: .constant(1.5),
            allowDouble: .constant(true),
            countError: .constant(false),
            decimalFieldHolder: "Количество")
        .frame(width: 160)
    }
}

#Preview("Error") {
    ZStack {
        Color.glBackground.ignoresSafeArea()
        
        DecimalTextField(
            count: .constant(1.5),
            allowDouble: .constant(true),
            countError: .constant(true),
            decimalFieldHolder: "Количество")
        .frame(width: 160)
    }
}
#endif
