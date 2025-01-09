/// Based on youtube lesson "SwiftUI Custom Alert View - iOS 17 - Xcode 15" by Kavsoft

import SwiftUI

// MARK: - Alert Configuration
struct AlertConfig {
    fileprivate var enableBackgroundBlur: Bool = false
    fileprivate var disableOutsideTap: Bool = true
    fileprivate var show: Bool = false
    fileprivate var showView: Bool = false
    
    init(enableBackgroundBlur: Bool = false, disableOutsideTap: Bool = true) {
        self.enableBackgroundBlur = enableBackgroundBlur
        self.disableOutsideTap = disableOutsideTap
    }
    // Alert present/dismiss methods
    mutating func present() {
        show = true
    }
    mutating func dismiss() {
        show = false
    }
}

@Observable
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        
        config.delegateClass = SceneDelegate.self
        return config
    }
}

@Observable
class SceneDelegate: NSObject, UIWindowSceneDelegate {
    weak var windowScene: UIWindowScene?
    var overlayWindow: UIWindow?
    var tag: Int = 0
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        windowScene = scene as? UIWindowScene
        setupOverlayWindow()
    }
    
    private func setupOverlayWindow() {
        guard let windowScene = windowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.isHidden = true
        window.isUserInteractionEnabled = false
        self.overlayWindow = window
    }
    
    fileprivate func alert<Content: View>(config: Binding<AlertConfig>, @ViewBuilder content: @escaping () -> Content, viewTag: @escaping (Int) -> ()) {
        guard let alertWindow = overlayWindow else { return }
        
        let viewController = UIHostingController(rootView: AlertView(config: config, tag: tag, content: {
            content()
        }))
        viewController.view.backgroundColor = .clear
        viewController.view.tag = tag
        viewTag(tag)
        tag += 1
        
        if alertWindow.rootViewController == nil {
            alertWindow.rootViewController = viewController
            alertWindow.isHidden = false
            alertWindow.isUserInteractionEnabled = true
        } else {
            print("Existing alert is still present")
        }
    }
}

// Custom view extensions
extension View {
    @ViewBuilder
    func alert<Content: View>(alertConfig: Binding<AlertConfig>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self
            .modifier(AlertModifier(config: alertConfig, alertContent: content))
    }
}

// Alert handling view modifier
/// A private modifier that handles the present and dismisses actions for the alert
fileprivate struct AlertModifier<AlertContent: View>: ViewModifier {
    @Binding var config: AlertConfig
    @ViewBuilder var alertContent: () -> AlertContent
    /// Scene delegate
    @Environment(SceneDelegate.self) private var sceneDelegate
    /// View tag
    @State private var viewTag: Int = 0
    func body(content: Content) -> some View {
        content
            .onChange(of: config.show, initial: false) { oldValue, newValue in
                if newValue {
                    sceneDelegate.alert(config: $config, content: alertContent) { tag in
                        viewTag = tag
                    }
                } else {
                    guard let alertWindow = sceneDelegate.overlayWindow else { return }
                    if config.showView {
                        withAnimation(.smooth(duration: 0.35, extraBounce: 0)) {
                            config.showView = false
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            alertWindow.rootViewController = nil
                            alertWindow.isHidden = true
                            alertWindow.isUserInteractionEnabled = false
                        }
                    }
                }
            }
    }
}

fileprivate struct AlertView<Content: View>: View {
    // MARK: - Public Properties
    @Binding var config: AlertConfig
    /// View tag
    var tag: Int
    @ViewBuilder var content: () -> Content
    @State private var showView: Bool = false
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if config.enableBackgroundBlur {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                } else {
                    Rectangle()
                        .fill(.primary.opacity(0.25))
                }
            }
            .ignoresSafeArea()
            .contentShape(.rect)
            .onTapGesture {
                if !config.disableOutsideTap {
                    config.dismiss()
                }
            }
            .opacity(showView ? 1 : 0)
            
            VStack {
                content()
                    .fixedSize(horizontal: false, vertical: true) // disable vertical stretching
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .opacity(showView ? 1 : 0)
        }
        .onAppear {
            config.showView = true
        }
        .onChange(of: config.showView) { oldValue, newValue in
            withAnimation(.smooth(duration: 0.35, extraBounce: 0)) {
                showView = newValue
            }
        }
    }
}
