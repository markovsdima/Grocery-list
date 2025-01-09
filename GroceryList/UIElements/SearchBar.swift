import SwiftUI

struct SearchBarView: View {
    // MARK: - Public Properties
    @Binding var searchText: String
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .padding(.leading, 8)
                .foregroundStyle(.glHintGray)
            TextField(
                "",
                text: $searchText,
                prompt:
                    Text("Поиск")
                    .foregroundStyle(.glHintGray)
            )
            .autocorrectionDisabled()
            .frame(height: 38)
            if searchText != "" {
                Image(.closeButton)
                    .frame(width: 38, height: 38)
                    .onTapGesture {
                        searchText = ""
                    }
            }
        }
        .background(.glSearchBarBackground)
        .cornerRadius(10)
        .frame(height: 38)
        .padding([.horizontal])
    }
}

// MARK: - Previews
#if DEBUG
#Preview {
    SearchBarView(searchText: .constant(""))
}
#endif
