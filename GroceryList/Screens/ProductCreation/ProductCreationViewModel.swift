import Foundation
import Combine

final class ProductCreationViewModel: ObservableObject {
    // MARK: - Public Properties
    let shoppingListId: UUID
    var productForEditing: ProductUI?
    @Published var editing: Bool = false
    @Published var allowDouble: Bool = false
    @Published var allowCreate = false
    @Published var recommendations: [String] = []
    @Published var productName = "" {
        didSet {
            if productNameError != nil {
                productNameError = nil
                productNameState = .default
            }
        }
    }
    @Published var productNameState: TextFieldWithErrorTitle.FieldState = .default
    @Published var productNameError: ProductCreationError? {
        didSet {
            if let error = productNameError {
                productNameErrorTitle = error.rawValue
                productNameState = .error
            } else {
                productNameErrorTitle = ""
            }
        }
    }
    @Published var productNameErrorTitle = ""
    @Published var productCount: Double?
    @Published var countUnit: CountUnit = .quantify {
        didSet {
            if countUnit == .quantify {
                allowDouble = false
            } else {
                allowDouble = true
            }
        }
    }
    @Published var countError: Bool = false // error if enter fractional number and switch to "шт"
    
    // MARK: - Private Properties
    private let storageManager: StorageManagerProtocol?
    private var allRecommendations: [String] = []
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(storageManager: StorageManagerProtocol? = StorageManager.shared,
         shoppingListId: UUID,
         productForEditing: ProductUI? = nil
    ) {
        self.storageManager = storageManager
        self.shoppingListId = shoppingListId
        self.productForEditing = productForEditing
        
        if productForEditing != nil {
            editing = true
            prepareEditing()
        }
        
        Task { @MainActor in
            fetchRecommendations()
        }
        
        $productName
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.filterRecommendations(for: text)
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest($productName, $countError)
            .map { productName, countError in
                !productName.isEmpty && countError == false
            }
            .assign(to: &$allowCreate)
    }
    
    // MARK: - Public Methods
    @MainActor
    func validateProductCreation() -> Bool? {
        guard let storageManager else { return nil }
        if storageManager.doesProductExistIn(list: shoppingListId, named: productName) {
            productNameError = .alreadyUsed
            return false
        }
        return true
    }
    
    @MainActor
    func validateProductEditing() -> Bool? {
        guard let storageManager else { return nil }
        if productName == productForEditing?.name {
            return true
        } else if storageManager.doesProductExistIn(list: shoppingListId, named: productName) {
            productNameError = .alreadyUsed
            return false
        }
        return true
    }
    
    func createNewProduct() {
        Task { @MainActor in
            guard let storageManager else { return }
            let currentProductsCount = try storageManager.fetchProducts(from: shoppingListId, searchText: nil).count
            let newSortOrder = currentProductsCount + 1
            
            var checkedCount: Double?
            if productCount == 0 {
                checkedCount = nil
            } else {
                checkedCount = productCount
            }
            
            let newProduct = Product(name: productName, count: checkedCount, countUnit: countUnit, sortOrder: newSortOrder)
            try storageManager.addNewProductToList(listId: shoppingListId, newProduct: newProduct)
            try storageManager.updateRecommendation(name: newProduct.name)
        }
    }
    
    @MainActor
    func updateExistingProduct() {
        if let product = productForEditing {
            var checkedCount: Double?
            if productCount == 0 {
                checkedCount = nil
            } else {
                checkedCount = productCount
            }
            do {
                try storageManager?.updateProductInList(
                    listId: shoppingListId,
                    productId: product.swiftDataId,
                    newName: productName,
                    newCount: checkedCount,
                    newCountUnit: countUnit)
            } catch {
                print("storageManager.updateProduct error: \(error)")
            }
        }
    }
    
    func prepareEditing() {
        if let name = productForEditing?.name {
            productName = name
        }
        if let count = productForEditing?.count {
            self.productCount = count
        }
        if let unit = productForEditing?.countUnit {
            countUnit = unit
        }
    }
    
    // MARK: - Private Methods
    @MainActor
    private func fetchRecommendations() {
        guard let storageManager else { return }
        allRecommendations = storageManager.fetchRecommendations()
    }
    
    private func filterRecommendations(for text: String) {
        guard !text.isEmpty else {
            recommendations = []
            return
        }
        
        recommendations = allRecommendations
            .filter { $0.lowercased().hasPrefix(text.lowercased()) }
            .prefix(3)
            .map { $0 }
    }
}
