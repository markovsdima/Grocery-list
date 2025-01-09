import SwiftUI

struct LaunchScreenView: View {
    // MARK: - Public Properties
    @Binding var isFirstLaunch: Bool
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.glBackground.ignoresSafeArea()
            
            VStack() {
                welcomeSlide()
                startButton()
            }
        }
    }
    
    // MARK: - View Components
    @ViewBuilder private func welcomeSlide() -> some View {
        VStack {
            Text("Добро пожаловать!")
                .font(.largeTitle)
            Image(.launchScreen)
                .padding(.vertical, 40)
            Text("Никогда не забывайте,\nчто нужно купить")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            Text("Создавайте списки\nи не переживайте о покупках")
                .multilineTextAlignment(.center)
                .padding(.top, 12)
        }
        .frame(maxHeight: .infinity)
    }
    
    @ViewBuilder private func startButton() -> some View {
        WideButton(isActive: .constant(true), title: "Начать")
            .onTapGesture {
                isFirstLaunch = false
            }
    }
}

// MARK: - Previews
#if DEBUG
#Preview {
    LaunchScreenView(isFirstLaunch: .constant(true))
}
#endif
