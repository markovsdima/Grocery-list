import SwiftUI
import SwiftData

@main
struct GroceryListApp: App {
    // MARK: - Properties
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
    @AppStorage("appearance") private var appearance: Appearance = .system
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    
    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if isFirstLaunch {
                    LaunchScreenView(isFirstLaunch: $isFirstLaunch)
                } else {
                    ShoppingListsView()
                }
            }
            .preferredColorScheme(appearance.colorScheme)
        }
    }
}
