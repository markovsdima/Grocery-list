/// Based on youtube lesson "Swipe Actions For ScrollView - No Gestures! - iOS 17 Scroll APIs - Xcode 15" by Kavsoft

import SwiftUI

struct SwipeActionsContainer<Content: View>: View {
    // MARK: - Public Properties
    var roundedCorners: Bool = true
    var buttonWidth: CGFloat = 74
    var cornerRadius: CGFloat = 16
    var direction: SwipeDirection = .trailing
    @ViewBuilder var content: Content
    @ActionBuilder var actions: [Action]
    
    // MARK: - Private Properties
    @State private var isEnabled: Bool = true
    @State private var scrollOffset: CGFloat = .zero
    private let viewID = UUID()
    
    // MARK: - Body
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    content
                        .containerRelativeFrame(.horizontal)
                        .background {
                            if actions.first != nil {
                                Rectangle()
                                    .fill(Color.glWhite)
                                    .padding(.leading, 70)
                                    .opacity(scrollOffset == .zero ? 0 : 1)
                            }
                        }
                        .id(viewID)
                        .overlay {
                            GeometryReader {
                                let minX = $0.frame(in: .scrollView(axis: .horizontal)).minX
                                
                                Color.clear
                                    .preference(key: OffsetKey.self, value: minX)
                                    .onPreferenceChange(OffsetKey.self) {
                                        scrollOffset = $0
                                    }
                            }
                        }
                    actionButtons {
                        withAnimation(.snappy) {
                            scrollProxy.scrollTo(viewID, anchor: direction == .trailing ? .topLeading : .topTrailing)
                        }
                    }
                    .opacity(scrollOffset == .zero ? 0 : 1)
                }
                .scrollTargetLayout()
                .visualEffect { content, geometryProxy in
                    let offsetValue: CGFloat = {
                        let minX = geometryProxy.frame(in: .scrollView(axis: .horizontal)).minX
                        return direction == .trailing ? (minX > 0 ? -minX : 0) : (minX < 0 ? -minX : 0)
                    }()
                    
                    return content.offset(x: offsetValue)
                }
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .background {
                if let lastAction = actions.last {
                    Rectangle()
                        .fill(lastAction.background)
                        .padding(.leading, 70)
                        .opacity(scrollOffset == .zero ? 0 : 1)
                }
            }
            .clipShape(
                UnevenRoundedRectangle(
                    cornerRadii: RectangleCornerRadii(
                        bottomTrailing: cornerRadius,
                        topTrailing: cornerRadius
                    )
                )
            )
        }
        .allowsHitTesting(isEnabled)
    }
    
    // MARK: - View Components
    @ViewBuilder
    func actionButtons(resetPosition: @escaping () -> ()) -> some View {
        Rectangle()
            .fill(.clear)
            .frame(width: CGFloat(actions.count) * buttonWidth)
            .overlay(alignment: direction.alignment) {
                HStack(spacing: 0) {
                    ForEach(actions) { button in
                        actionButton(button: button, resetPosition: resetPosition)
                    }
                }
            }
    }
    
    @ViewBuilder
    func actionButton(button: Action, resetPosition: @escaping () -> ()) -> some View {
        Button(action: {
            Task {
                isEnabled = false
                resetPosition()
                try? await Task.sleep(for: .seconds(0.25))
                
                button.action()
                
                try? await Task.sleep(for: .seconds(0.1))
                isEnabled = true
            }
        }) {
            Image(systemName: button.icon)
                .foregroundStyle(button.tint)
                .frame(width: buttonWidth)
                .frame(maxHeight: .infinity)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .background(button.background)
    }
}

// Offset Key
struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

enum SwipeDirection {
    case leading
    case trailing
    
    var alignment: Alignment {
        switch self {
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        }
    }
}

// Action Model
struct Action: Identifiable {
    private(set) var id: UUID = .init()
    var tint: Color
    var background: Color
    var icon: String
    var action: () -> Void
}

@resultBuilder
struct ActionBuilder {
    static func buildBlock(_ components: Action...) -> [Action] {
        return components
    }
}
