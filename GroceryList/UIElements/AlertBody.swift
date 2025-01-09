import SwiftUI

struct AlertBody: View {
    // MARK: - Public Properties
    let title: String
    let description: String
    let leadingButtonText: String
    let leadingButtonAction: () -> Void
    let trailingButtonText: String
    let trailingButtonAction: () -> Void
    let isTrailingButtonDestructive: Bool
    
    // MARK: - Body
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(.regularMaterial)
                .frame(width: 270)
            VStack(spacing: 0) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.top, 16)
                Text(description)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                Spacer(minLength: 16)
                Divider()
                HStack(spacing: 0) {
                    Button {
                        leadingButtonAction()
                    } label: {
                        Text(leadingButtonText)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .tint(.glTurquoise)
                    .frame(maxWidth: .infinity)
                    
                    Divider()
                    
                    Button {
                        trailingButtonAction()
                    } label: {
                        Text(trailingButtonText)
                            .font(.headline)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .tint(isTrailingButtonDestructive ? .glRed : .glTurquoise)
                }
                .frame(height: 44)
            }
            .padding(.bottom, 0)
        }
        .frame(width: 270)
    }
}

// MARK: - Previews
#if DEBUG
#Preview("WithDestructive") {
    AlertBody(
        title: "Title",
        description: "Description",
        leadingButtonText: "leadingButton",
        leadingButtonAction: {},
        trailingButtonText: "trailingButton",
        trailingButtonAction: {},
        isTrailingButtonDestructive: true)
    .frame(height: 50)
}

#Preview("WithoutDestructive") {
    AlertBody(
        title: "Title",
        description: "Description",
        leadingButtonText: "leadingButton",
        leadingButtonAction: {},
        trailingButtonText: "trailingButton",
        trailingButtonAction: {},
        isTrailingButtonDestructive: false)
    .frame(height: 50)
}
#endif
