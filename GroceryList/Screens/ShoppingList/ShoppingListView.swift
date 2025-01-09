import SwiftUI

struct ShoppingListView: View {
    // MARK: - Public Properties
    @State var draggingItem: ProductUI?
    
    // MARK: - Private Properties
    @State private var isPresentingCreateProductView = false
    @StateObject private var vm: ShoppingListViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var alert: AlertConfig = .init()
    @State private var navigateToProductEditing = false
    @State private var productForEditing: ProductUI?
    
    // MARK: - Init
    init(shoppingListUI: ShoppingListUI) {
        _vm = StateObject(wrappedValue: ShoppingListViewModel(shoppingListUI: shoppingListUI))
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.glBackground.ignoresSafeArea()
                .onTapGesture {
                    hideKeyboard()
                }
            
            VStack(spacing: 0) {
                navBar()
                
                if vm.showPlug {
                    plug()
                } else {
                    searchBar()
                }
                
                ScrollView {
                    Rectangle()
                        .frame(width: 100, height: 10)
                        .foregroundStyle(.clear)
                    LazyVStack(spacing: 0) {
                        ForEach(vm.productsUI, id: \.self) { product in
                            listItem(product: product)
                        }
                    }
                    .onAppear {
                        vm.fetchProducts()
                    }
                }
                .onTapGesture {
                    hideKeyboard()
                }
                
                createButton()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $isPresentingCreateProductView) {
            ProductCreationView(
                vm: ProductCreationViewModel(
                    shoppingListId: vm.shoppingListUI.swiftDataId,
                    productForEditing: productForEditing
                ),
                onProductCreated: { vm.fetchProducts() }
            )
        }
        .sheet(item: $productForEditing) { product in
            ProductCreationView(
                vm: ProductCreationViewModel(
                    shoppingListId: vm.shoppingListUI.swiftDataId,
                    productForEditing: product
                ),
                onProductCreated: { vm.fetchProducts() }
            )
        }
        .sheet(isPresented: $vm.showShareSheet) {
            ActivityView(activityItems: [vm.shareText])
        }
        .alert(alertConfig: $alert) {
            AlertBody(title: "Удаление купленных товаров",
                      description: "Вы действительно хотите удалить все купленные товары?",
                      leadingButtonText: "Отменить",
                      leadingButtonAction: {alert.dismiss()},
                      trailingButtonText: "Удалить",
                      trailingButtonAction: {deletePurchasedProducts()},
                      isTrailingButtonDestructive: true)
        }
    }
    
    // MARK: - View Components
    @ViewBuilder private func navBar() -> some View {
        NavBar(title: vm.shoppingListUI.name,
               withOptions: true,
               onBack: {dismiss()},
               menuContent: {
            AnyView(
                Section {
                    Button(action: {
                        vm.sortProductsAlphabetically()
                    }) {
                        Label(
                            "Сортировать по алфавиту",
                            systemImage: "arrow.up.arrow.down"
                        )
                    }
                    
                    Button(action: {
                        vm.share()
                    }) {
                        Label(
                            "Поделиться",
                            systemImage: "square.and.arrow.up"
                        )
                    }
                    
                    Button(action: {
                        vm.uncheckAllProducts()
                    }) {
                        Label(
                            "Снять отметки со\nвсех товаров",
                            systemImage: "arrow.triangle.2.circlepath"
                        )
                    }
                    
                    Button(role: .destructive, action: {
                        alert.present()
                        //vm.deletePurchasedProducts()
                    }) {
                        Label(
                            "Удалить купленные товары",
                            systemImage: "trash"
                        )
                    }.foregroundStyle(.glRed)
                }
            )
        })
    }
    
    @ViewBuilder private func plug() -> some View {
        Image(.shoppingList)
            .padding(.top, 110)
        Text("Давайте спланируем покупки!")
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundStyle(.glBlack)
        Text("Начните добавлять товары")
            .foregroundStyle(.glBlack)
            .padding(.top, 6)
        Spacer()
    }
    
    @ViewBuilder private func searchBar() -> some View {
        SearchBarView(searchText: $vm.searchText)
            .padding(.top, 6)
            .onChange(of: vm.searchText) { _, _ in
                vm.fetchProducts()
            }
    }
    
    @ViewBuilder private func listItem(product: ProductUI) -> some View {
        SwipeActionsContainer(cornerRadius: 0) {
            ProductCell(product: product, onToggle: {
                vm.updateProductPurchaseStatus(product: product, purchased: !product.purchased)
            })
            .draggable(product) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial)
                    .frame(width: 1, height: 1)
                    .onAppear {
                        draggingItem = product
                    }
            }
            .dropDestination(for: ProductUI.self) { items, location in
                draggingItem = nil
                return false
            } isTargeted: { status in
                if let draggingItem, status, draggingItem != product {
                    if let sourceIndex = vm.productsUI.firstIndex(of: draggingItem),
                       let destinationIndex = vm.productsUI.firstIndex(of: product) {
                        
                        withAnimation(.bouncy) {
                            let sourceItem = vm.productsUI.remove(at: sourceIndex)
                            vm.productsUI.insert(sourceItem, at: destinationIndex)
                        }
                        vm.updateSortOrder(from: vm.productsUI)
                    }
                }
            }
        } actions: {
            Action(
                tint: .white,
                background: .glSystemLightGray,
                icon: "square.and.pencil"
            ) {
                productForEditing = product
            }
            
            Action(
                tint: .white,
                background: .red,
                icon: "trash"
            ) {
                vm.deleteProduct(product)
            }
        }
    }
    
    @ViewBuilder private func createButton() -> some View {
        WideButton(isActive: .constant(true), title: "Добавить товар")
            .onTapGesture {
                isPresentingCreateProductView = true
            }
    }
    
    // MARK: - Private Methods
    private func deletePurchasedProducts() {
        vm.deletePurchasedProducts()
        alert.dismiss()
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
