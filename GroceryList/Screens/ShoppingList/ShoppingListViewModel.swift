import SwiftUI

final class ShoppingListViewModel: ObservableObject {
    // MARK: - Public Properties
    @Published var searchText: String = ""
    @Published var shoppingListUI: ShoppingListUI
    @Published var showPlug: Bool = false
    @Published var shareText: String = ""
    @Published var showShareSheet = false
    @Published var productsUI: [ProductUI] = []
    @Published var listName: String = ""
    var products: [Product] = [] {
        didSet {
            productsUI = convertToUIProducts(from: products)
        }
    }
    
    // MARK: - Private Properties
    private let storageManager: StorageManagerProtocol?
    
    // MARK: - Init
    init(storageManager: StorageManagerProtocol? = StorageManager.shared, shoppingListUI: ShoppingListUI) {
        self.storageManager = storageManager
        self.shoppingListUI = shoppingListUI
    }
    
    // MARK: - Public Methods
    func share() {
        shareText = createShareText()
        showShareSheet = true
    }
    
    func convertToUIProducts(from dataProducts: [Product]) -> [ProductUI] {
        var uiProducts: [ProductUI] = []
        for product in dataProducts {
            let productsItem = ProductUI(
                swiftDataId: product.id,
                name: product.name,
                count: product.count,
                countUnit: product.countUnit,
                purchased: product.purchased
            )
            uiProducts.append(productsItem)
        }
        
        return uiProducts
    }
    
    func fetchProducts() {
        Task { @MainActor in
            do {
                guard let storageManager else { return }
                try products = storageManager.fetchProducts(from: shoppingListUI.swiftDataId, searchText: searchText)
                if searchText == "" && products.count == 0 {
                    showPlug = true
                } else {
                    showPlug = false
                }
            }
        }
    }
    
    func deleteProduct(_ product: ProductUI) {
        Task { @MainActor in
            try storageManager?.deleteProductFromList(
                listId: shoppingListUI.swiftDataId,
                productId: product.swiftDataId
            )
            
            withAnimation(.easeInOut) {
                if let index = productsUI.firstIndex(where: { $0.swiftDataId == product.swiftDataId }) {
                    productsUI.remove(at: index)
                }
            }
        }
    }
    
    func updateProductPurchaseStatus(product: ProductUI, purchased: Bool) {
        Task { @MainActor in
            guard let index = productsUI.firstIndex(where: { $0.swiftDataId == product.swiftDataId }) else { return }
            
            productsUI[index].purchased = purchased
            
            do {
                try storageManager?.updateProductPurchaseStatus(
                    listId: shoppingListUI.swiftDataId,
                    productId: product.swiftDataId,
                    purchased: purchased
                )
            } catch {
                print("Ошибка обновления статуса покупки: \(error)")
            }
        }
    }
    
    func uncheckAllProducts() {
        for index in productsUI.indices {
            withAnimation(.easeInOut) {
                productsUI[index].purchased = false
            }
        }
        Task { @MainActor in
            do {
                try storageManager?.resetAllProductsInListToNotPurchased(listId: shoppingListUI.swiftDataId)
            } catch {
                print("Ошибка снятия отметок купленности со всех продуктов списка в базе данных: \(error)")
            }
        }
    }
    
    func deletePurchasedProducts() {
        withAnimation(.easeInOut) {
            productsUI.removeAll { $0.purchased }
        }
        
        Task { @MainActor in
            do {
                try storageManager?.deletePurchasedProducts(from: shoppingListUI.swiftDataId)
            } catch {
                print("Ошибка удаления купленных продуктов из базы данных: \(error)")
            }
        }
    }
    
    func updateSortOrder(from updatedProductsUI: [ProductUI]) {
        Task { @MainActor in
            for (index, uiItem) in updatedProductsUI.enumerated() {
                if let product = products.first(where: { $0.id == uiItem.swiftDataId }) {
                    product.sortOrder = index + 1
                }
            }
            
            do {
                try storageManager?.saveContext()
            } catch {
                print("Ошибка при сохранении сортировки: \(error.localizedDescription)")
            }
        }
    }
    
    func sortProductsAlphabetically() {
        let sortedProducts = productsUI.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        
        updateSortOrder(from: sortedProducts)
        withAnimation(.easeInOut) {
            productsUI = sortedProducts
        }
    }
    
    // MARK: - Private Methods
    private func createShareText() -> String {
        var text = "Список \"" + shoppingListUI.name + "\":\n"
        
        for product in productsUI {
            var string = ""
            string += product.purchased ? "[✓] " : "[ ] "
            string += product.name
            if let count = product.count {
                string += " " + (count == floor(count) ? String(format: "%.0f", count) : String(count))
                if let unit = product.countUnit {
                    string += " \(unit.name)"
                }
            }
            
            string += "\n"
            text += string
        }
        print(text)
        return text
    }
}
