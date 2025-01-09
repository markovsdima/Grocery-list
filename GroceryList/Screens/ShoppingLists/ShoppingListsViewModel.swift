import SwiftUI

final class ShoppingListsViewModel: ObservableObject {
    // MARK: - Public Properties
    @Published var shoppingListsUI: [ShoppingListUI] = []
    
    // MARK: - Private Properties
    private let storageManager: StorageManagerProtocol?
    private var shoppingLists: [ShoppingList] = [] {
        didSet {
            shoppingListsUI = convertToUIList(from: shoppingLists)
        }
    }
    
    // MARK: - Init
    init(storageManager: StorageManagerProtocol? = StorageManager.shared) {
        self.storageManager = storageManager
    }
    
    // MARK: - Public Methods
    func fetchLists() {
        Task { @MainActor in
            guard let storageManager else { return }
            shoppingLists = try await storageManager.fetchShoppingLists()
        }
    }
    
    func updateSortOrder(from updatedUIList: [ShoppingListUI]) {
        Task { @MainActor in
            for (index, uiItem) in updatedUIList.enumerated() {
                if let list = shoppingLists.first(where: { $0.id == uiItem.swiftDataId }) {
                    list.sortOrder = index + 1
                }
            }
            do {
                try storageManager?.saveContext()
            } catch {
                print("Ошибка при сохранении сортировки: \(error.localizedDescription)")
            }
        }
    }
    
    func sortShoppingListsAlphabetically() {
        let sortedList = shoppingListsUI.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        
        updateSortOrder(from: sortedList)
        withAnimation(.easeInOut) {
            shoppingListsUI = sortedList
        }
    }
    
    func deleteList(_ list: ShoppingListUI) {
        Task { @MainActor in
            storageManager?.deleteList(by: list.swiftDataId)
            
            if let index = shoppingLists.firstIndex(where: { $0.id == list.swiftDataId }) {
                shoppingLists.remove(at: index)
                shoppingLists.sort { $0.sortOrder < $1.sortOrder } // Сохраняем порядок
                shoppingListsUI = convertToUIList(from: shoppingLists)
            }
        }
    }
    
    func duplicateList(_ list: ShoppingListUI) {
        Task { @MainActor in
            // 1. get original list by id
            guard let originalList = shoppingLists.first(where: { $0.id == list.swiftDataId }) else {
                print("Оригинальный список не найден")
                return
            }
            
            // 2. extract original list name (without "Копия N")
            let originalName = extractOriginalName(from: originalList.name)
            
            // 3. find all existing copies for the original name
            let existingCopies = shoppingLists.filter { shoppingList in
                shoppingList.name.starts(with: "Копия ") && shoppingList.name.contains(originalName)
            }
            
            // 4. determine maximum suffix
            let regex = try! NSRegularExpression(pattern: #"Копия(?: (\d+))? \#(originalName)"#)
            var maxCopyNumber = 0
            
            for copy in existingCopies {
                if let match = regex.firstMatch(in: copy.name, range: NSRange(copy.name.startIndex..., in: copy.name)),
                   let numberRange = Range(match.range(at: 1), in: copy.name),
                   let number = Int(copy.name[numberRange]) {
                    maxCopyNumber = max(maxCopyNumber, number)
                } else {
                    maxCopyNumber = max(maxCopyNumber, 1) // "Копия" без числа считается "Копия 1"
                }
            }
            
            // 5. form new name
            let newCopyNumber = maxCopyNumber + 1
            let newName = newCopyNumber == 1 ? "Копия \(originalName)" : "Копия \(newCopyNumber) \(originalName)"
            
            // 6. shift sortOrder for following lists
            for shoppingList in shoppingLists where shoppingList.sortOrder > originalList.sortOrder {
                shoppingList.sortOrder += 1
            }
            
            // 7. create new list
            let newList = ShoppingList(
                name: newName,
                color: originalList.color ?? .green,
                icon: originalList.icon ?? .balloon,
                sortOrder: originalList.sortOrder + 1
            )
            
            // 8. copy products
            let copiedProducts = originalList.products.map { originalProduct in
                Product(
                    name: originalProduct.name,
                    count: originalProduct.count,
                    countUnit: originalProduct.countUnit,
                    purchased: originalProduct.purchased,
                    sortOrder: originalProduct.sortOrder
                )
            }
            newList.products.append(contentsOf: copiedProducts)
            
            // 9. add new list
            shoppingLists.append(newList)
            storageManager?.createNewList(newList)
            
            // 10. update ui
            shoppingLists.sort { $0.sortOrder < $1.sortOrder }
            shoppingListsUI = convertToUIList(from: shoppingLists)
        }
    }
    
    // MARK: - Private Methods
    private func convertToUIList(from dataList: [ShoppingList]) -> [ShoppingListUI] {
        var uiList: [ShoppingListUI] = []
        for list in dataList {
            let listItem = ShoppingListUI(
                swiftDataId: list.id,
                name: list.name,
                color: list.color,
                icon: list.icon,
                totalProducts: list.totalProducts,
                purchasedProducts: list.purchasedProducts)
            uiList.append(listItem)
        }
        return uiList
    }
    
    private func extractOriginalName(from name: String) -> String {
        let regex = try! NSRegularExpression(pattern: #"^(Копия(?: \d+)? )(.+)$"#)
        if let match = regex.firstMatch(in: name, range: NSRange(name.startIndex..., in: name)),
           let range = Range(match.range(at: 2), in: name) {
            return String(name[range])
        }
        return name
    }
}
