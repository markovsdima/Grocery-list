import Foundation
import SwiftData

protocol StorageManagerProtocol {
    @MainActor func saveContext() throws
    @MainActor func fetchShoppingLists() async throws -> [ShoppingList]
    @MainActor func createNewList(_ list: ShoppingList)
    @MainActor func updateList(id: UUID, newName: String, newColor: ListColor, newIcon: ListIcon) throws
    @MainActor func deleteList(by id: UUID)
    @MainActor func doesListExist(named name: String) -> Bool
    @MainActor func fetchProducts(from listId: UUID, searchText: String?) throws -> [Product]
    @MainActor func addNewProductToList(listId: UUID, newProduct: Product) throws
    @MainActor func doesProductExistIn(list id: UUID, named name: String) -> Bool
    @MainActor func updateProductPurchaseStatus(listId: UUID, productId: UUID, purchased: Bool) throws
    @MainActor func resetAllProductsInListToNotPurchased(listId: UUID) throws
    @MainActor func deletePurchasedProducts(from listId: UUID) throws
    @MainActor func deleteProductFromList(listId: UUID, productId: UUID) throws
    @MainActor func updateProductInList(
        listId: UUID,
        productId: UUID,
        newName: String,
        newCount: Double?,
        newCountUnit: CountUnit?
    ) throws
    @MainActor func fetchRecommendations() -> [String]
    @MainActor func updateRecommendation(name: String) throws
}

final class StorageManager: StorageManagerProtocol {
    // MARK: - Public Properties
    static let shared = try? StorageManager()
    
    // MARK: - Private Properties
    private let container: ModelContainer
    
    // MARK: - Init
    private init() throws {
        container = try ModelContainer(for: ShoppingList.self, Product.self, ProductRecommendation.self)
    }
    
    // MARK: - Save Context
    @MainActor
    func saveContext() throws {
        let context = container.mainContext
        try context.save()
    }
    
    // MARK: - Shopping lists Public Methods
    @MainActor
    func fetchShoppingLists() async throws -> [ShoppingList] {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<ShoppingList>(
            sortBy: [SortDescriptor(\.sortOrder, order: .forward)]
        )
        return try context.fetch(fetchDescriptor)
    }
    
    @MainActor
    func createNewList(_ list: ShoppingList) {
        insert(list)
        do {
            try saveContext()
            updateCache(for: list)
        } catch {
            print("Ошибка сохранения: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func updateList(id: UUID, newName: String, newColor: ListColor, newIcon: ListIcon) throws {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<ShoppingList>(
            predicate: #Predicate { $0.id == id }
        )
        
        do {
            if let listToUpdate = try context.fetch(fetchDescriptor).first {
                listToUpdate.name = newName
                listToUpdate.color = newColor
                listToUpdate.icon = newIcon
                
                try context.save()
            } else {
                throw NSError(
                    domain: "StorageManager",
                    code: 2,
                    userInfo: [NSLocalizedDescriptionKey: "Список с указанным ID не найден"]
                )
            }
        } catch {
            print("Ошибка обновления: \(error.localizedDescription)")
            throw error
        }
    }
    
    @MainActor
    func deleteList(by id: UUID) {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<ShoppingList>(
            predicate: #Predicate { $0.id == id }
        )
        
        do {
            if let listToDelete = try context.fetch(fetchDescriptor).first {
                delete(listToDelete)
                try context.save()
            } else {
                print("Список с id \(id) не найден")
            }
        } catch {
            print("Ошибка удаления: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func doesListExist(named name: String) -> Bool {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<ShoppingList>(
            predicate: #Predicate { $0.name == name }
        )
        do {
            let results = try context.fetch(fetchDescriptor)
            return !results.isEmpty
        } catch {
            print("Ошибка при проверке существования списка: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Products Public Methods
    @MainActor
    func fetchProducts(from listId: UUID, searchText: String? = nil) throws -> [Product] {
        let context = container.mainContext
        let listDescriptor = FetchDescriptor<ShoppingList>(
            predicate: #Predicate { $0.id == listId }
        )
        
        guard let shoppingList = try context.fetch(listDescriptor).first else {
            throw NSError(
                domain: "StorageManager",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Список с указанным ID не найден"]
            )
        }
        
        var filteredProducts = shoppingList.products
        
        if let query = searchText, !query.isEmpty {
            filteredProducts = filteredProducts.filter { $0.name.localizedCaseInsensitiveContains(query) }
        }
        
        return filteredProducts.sorted(by: { $0.sortOrder < $1.sortOrder })
    }
    
    @MainActor
    func addNewProductToList(listId: UUID, newProduct: Product) throws {
        let context = container.mainContext
        let descriptor = FetchDescriptor<ShoppingList>(
            predicate: #Predicate { $0.id == listId }
        )
        
        guard let shoppingList = try? context.fetch(descriptor).first else {
            throw NSError(domain: "StorageManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Список с указанным ID не найден"])
        }
        
        newProduct.shoppingList = shoppingList
        shoppingList.products.append(newProduct)
        
        context.insert(newProduct)
        updateCache(for: shoppingList)
        try context.save()
        
    }
    
    @MainActor
    func doesProductExistIn(list id: UUID, named name: String) -> Bool {
        let context = container.mainContext
        let listDescriptor = FetchDescriptor<ShoppingList>(
            predicate: #Predicate { $0.id == id }
        )
        
        do {
            guard let shoppingList = try context.fetch(listDescriptor).first else {
                print("Список с ID \(id) не найден")
                return false
            }
            
            return shoppingList.products.contains { $0.name == name }
        } catch {
            print("Ошибка при проверке продукта: \(error.localizedDescription)")
            return false
        }
    }
    
    @MainActor
    func updateProductPurchaseStatus(listId: UUID, productId: UUID, purchased: Bool) throws {
        let context = container.mainContext
        let listDescriptor = FetchDescriptor<ShoppingList>(
            predicate: #Predicate { $0.id == listId }
        )
        
        guard let shoppingList = try context.fetch(listDescriptor).first else {
            throw NSError(domain: "StorageManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Список не найден"])
        }
        
        guard let productIndex = shoppingList.products.firstIndex(where: { $0.id == productId }) else {
            throw NSError(domain: "StorageManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Продукт не найден"])
        }
        
        shoppingList.products[productIndex].purchased = purchased
        updateCache(for: shoppingList)
        do {
            try context.save()
        } catch {
            throw NSError(domain: "StorageManager", code: 500, userInfo: [NSLocalizedDescriptionKey: "Ошибка сохранения статуса покупки"])
        }
    }
    
    @MainActor
    func resetAllProductsInListToNotPurchased(listId: UUID) throws {
        let context = container.mainContext
        let listDescriptor = FetchDescriptor<ShoppingList>(
            predicate: #Predicate { $0.id == listId }
        )
        
        guard let shoppingList = try context.fetch(listDescriptor).first else {
            throw NSError(
                domain: "StorageManager",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Список с указанным ID не найден"]
            )
        }
        
        for product in shoppingList.products {
            product.purchased = false
        }
        
        updateCache(for: shoppingList)
        
        do {
            try context.save()
        } catch {
            throw NSError(
                domain: "StorageManager",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Ошибка сохранения после сброса статуса продуктов"]
            )
        }
    }
    
    @MainActor
    func deletePurchasedProducts(from listId: UUID) throws {
        let context = container.mainContext
        let listDescriptor = FetchDescriptor<ShoppingList>(
            predicate: #Predicate { $0.id == listId }
        )
        
        guard let shoppingList = try context.fetch(listDescriptor).first else {
            throw NSError(
                domain: "StorageManager",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Список с указанным ID не найден"]
            )
        }
        
        let purchasedProducts = shoppingList.products.filter { $0.purchased }
        
        for product in purchasedProducts {
            shoppingList.products.removeAll { $0.id == product.id }
            delete(product)
        }
        updateCache(for: shoppingList)
        do {
            try context.save()
        } catch {
            throw NSError(
                domain: "StorageManager",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Ошибка сохранения после удаления продуктов"]
            )
        }
    }
    
    @MainActor
    func deleteProductFromList(listId: UUID, productId: UUID) throws {
        let context = container.mainContext
        let listDescriptor = FetchDescriptor<ShoppingList>(
            predicate: #Predicate { $0.id == listId }
        )
        
        guard let shoppingList = try context.fetch(listDescriptor).first else {
            throw NSError(
                domain: "StorageManager",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Список с указанным ID не найден"]
            )
        }
        
        guard let productToDeleteIndex = shoppingList.products.firstIndex(where: { $0.id == productId }) else {
            throw NSError(
                domain: "StorageManager",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Продукт с указанным ID не найден в списке"]
            )
        }
        
        let productToDelete = shoppingList.products[productToDeleteIndex]
        
        shoppingList.products.remove(at: productToDeleteIndex)
        delete(productToDelete)
        updateCache(for: shoppingList)
        
        do {
            try context.save()
        } catch {
            throw NSError(
                domain: "StorageManager",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Ошибка сохранения после удаления продукта"]
            )
        }
    }
    
    @MainActor
    func updateProductInList(
        listId: UUID,
        productId: UUID,
        newName: String,
        newCount: Double?,
        newCountUnit: CountUnit?
    ) throws {
        let context = container.mainContext
        let listDescriptor = FetchDescriptor<ShoppingList>(
            predicate: #Predicate { $0.id == listId }
        )
        
        // find list by id
        guard let shoppingList = try context.fetch(listDescriptor).first else {
            throw NSError(
                domain: "StorageManager",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Список с указанным ID не найден"]
            )
        }
        
        // find product in list by id
        guard let productIndex = shoppingList.products.firstIndex(where: { $0.id == productId }) else {
            throw NSError(
                domain: "StorageManager",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Продукт с указанным ID не найден"]
            )
        }
        
        // update product fields
        let productToUpdate = shoppingList.products[productIndex]
        productToUpdate.name = newName
        productToUpdate.count = newCount
        productToUpdate.countUnit = newCountUnit
        
        do {
            try context.save()
        } catch {
            throw NSError(
                domain: "StorageManager",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Ошибка сохранения после обновления продукта"]
            )
        }
    }
    
    // MARK: - Recommendations Public Methods
    @MainActor
    func fetchRecommendations() -> [String] {
        let context = container.mainContext
        do {
            let fetchDescriptor = FetchDescriptor<ProductRecommendation>()
            let recommendations = try context.fetch(fetchDescriptor)
            print("Все рекоммендации: \(recommendations)")
            return recommendations.map { $0.name }
        } catch {
            print("Ошибка загрузки рекомендаций: \(error.localizedDescription)")
            return []
        }
    }
    
    @MainActor
    func updateRecommendation(name: String) throws {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<ProductRecommendation>(
            predicate: #Predicate { $0.name == name }
        )
        do {
            if let existingRecommendation = try context.fetch(fetchDescriptor).first {
                existingRecommendation.count += 1
                try context.save()
            } else {
                addRecommendation(name: name)
            }
        } catch {
            print("Ошибка обновления рекомендации: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Recommendations Private Methods
    @MainActor
    private func addRecommendation(name: String) {
        let recommendation = ProductRecommendation(name: name, count: 1)
        insert(recommendation)
        do {
            try saveContext()
            print("Рекомендация сохранена.")
        } catch {
            print("Ошибка сохранения рекомендации: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Cache
    @MainActor
    private func updateCache(for shoppingList: ShoppingList) {
        shoppingList.updateCache()
        do {
            try saveContext()
        } catch {
            print("Ошибка сохранения кэша: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Methods
    @MainActor
    private func insert<T: PersistentModel>(_ model: T) {
        let context = container.mainContext
        context.insert(model)
    }
    
    @MainActor
    private func delete<T: PersistentModel>(_ model: T) {
        let context = container.mainContext
        context.delete(model)
    }
}
