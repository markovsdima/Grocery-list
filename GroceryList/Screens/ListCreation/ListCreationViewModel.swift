import SwiftUI
import Combine

final class ListCreationViewModel: ObservableObject {
    // MARK: - Public Properties
    var listForEditing: ShoppingListUI?
    @Published var editing: Bool = false
    @Published var listName = "" {
        didSet {
            if listNameError != nil {
                listNameError = nil
                listNameState = .default
            }
        }
    }
    @Published var listNameState: TextFieldWithErrorTitle.FieldState = .default
    @Published var listNameError: ListCreationError? {
        didSet {
            if let error = listNameError {
                listNameErrorTitle = error.rawValue
            } else {
                listNameErrorTitle = ""
            }
        }
    }
    @Published var listNameErrorTitle = ""
    @Published var selectedColor: ListColor? = nil
    @Published var selectedIcon: ListIcon? = nil
    @Published var isCreateButtonActive: Bool = false
    
    // MARK: - Private Properties
    private let storageManager: StorageManagerProtocol?
    private let cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(storageManager: StorageManagerProtocol? = StorageManager.shared, listForEditing: ShoppingListUI? = nil) {
        self.storageManager = storageManager
        self.listForEditing = listForEditing
        
        if listForEditing != nil {
            editing = true
            prepareEditing()
        }
        
        Publishers.CombineLatest4($listName, $selectedColor, $selectedIcon, $listNameError)
            .map { listName, selectedColor, selectedIcon, listNameError in
                !listName.trimmingCharacters(in: .whitespaces).isEmpty &&
                selectedColor != nil &&
                selectedIcon != nil &&
                listNameError == nil
            }
            .assign(to: &$isCreateButtonActive)
    }
    
    // MARK: - Public Methods
    @MainActor
    func validateListCreationScreen() -> Bool? {
        guard let storageManager else { return nil }
        if storageManager.doesListExist(named: listName) {
            listNameError = .alreadyUsed
            listNameState = .error
            return false
        }
        return true
    }
    
    @MainActor
    func validateListEditingScreen() -> Bool? {
        guard let storageManager else { return nil }
        if listName == listForEditing?.name {
            return true
        } else if storageManager.doesListExist(named: listName) {
            listNameError = .alreadyUsed
            listNameState = .error
            return false
        }
        return true
    }
    
    func createNewList() {
        Task { @MainActor in
            guard let storageManager else { return }
            let currentListCount = try await storageManager.fetchShoppingLists().count
            let newSortOrder = currentListCount + 1
            
            let newList = ShoppingList(
                name: listName,
                color: selectedColor ?? .green,
                icon: selectedIcon ?? .balloon,
                sortOrder: newSortOrder)
            
            storageManager.createNewList(newList)
        }
    }
    
    @MainActor
    func updateExistingList() {
        if let list = listForEditing {
            do {
                try storageManager?.updateList(
                    id: list.swiftDataId,
                    newName: listName,
                    newColor: selectedColor ?? .green,
                    newIcon: selectedIcon ?? .balloon)
            } catch {
                print("storageManager.updateList error: \(error)")
            }
        }
    }
    
    // MARK: - Private Methods
    // prepare for editing existing list
    private func prepareEditing() {
        if let name = listForEditing?.name {
            listName = name
        }
        if let color = listForEditing?.color {
            selectedColor = color
        }
        if let icon = listForEditing?.icon {
            selectedIcon = icon
        }
    }
}
