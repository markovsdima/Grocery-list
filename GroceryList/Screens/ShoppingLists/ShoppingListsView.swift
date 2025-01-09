import SwiftUI

struct ShoppingListsView: View {
    // MARK: - Public Properties
    @StateObject var vm = ShoppingListsViewModel()
    @State var draggingItem: ShoppingListUI?
    
    // MARK: - Private Properties
    @State private var navigateToListEditing = false
    @State private var listForEditing: ShoppingListUI?
    @State private var showDeleteAlert = false
    @State private var listToDelete: ShoppingListUI?
    @State private var alert: AlertConfig = .init()
    @State private var theme: Int = 0
    @AppStorage("appearance") private var appearance: Appearance = .system
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            topBar()
            if vm.shoppingListsUI.isEmpty {
                plug()
            }
            ScrollView {
                Rectangle()
                    .frame(width: 100, height: 10)
                    .foregroundStyle(.clear)
                LazyVStack {
                    ForEach(vm.shoppingListsUI, id: \.self) { list in
                        listCell(list)
                    }
                }
                .onAppear {
                    vm.fetchLists()
                    theme = appearance.pickerTag
                }
            }
            Spacer()
            createButton()
        }
        .background(.glBackground)
        .onTapGesture {
            hideKeyboard()
        }
        .navigationDestination(isPresented: $navigateToListEditing) {
            if let listForEditing {
                ListCreationView(vm: ListCreationViewModel(listForEditing: listForEditing))
            }
        }
        .alert(alertConfig: $alert) {
            AlertBody(title: "Удаление списка",
                      description: "Вы действительно хотите удалить список?",
                      leadingButtonText: "Отменить",
                      leadingButtonAction: {alert.dismiss()},
                      trailingButtonText: "Удалить",
                      trailingButtonAction: {deleteList()},
                      isTrailingButtonDestructive: true)
        }
    }
    
    // MARK: - View Components
    @ViewBuilder private func topBar() -> some View {
        HStack {
            Text("Мои списки")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundStyle(.glBlack)
            Spacer()
            topBarMenu()
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder private func topBarMenu() -> some View {
        Menu {
            Menu {
                Picker("Theme options", selection: $theme) {
                    Text("Светлая").tag(0)
                    Text("Темная").tag(1)
                    Text("Системная").tag(2)
                }
                .onChange(of: theme) { oldValue, newValue in
                    switch newValue {
                    case 0:
                        appearance = .light
                    case 1:
                        appearance = .dark
                    case 2:
                        appearance = .system
                    default:
                        break
                    }
                }
            } label: {
                Text("Установить тему")
                Image(systemName: "circle.lefthalf.filled")
                    .foregroundStyle(.glBlack)
            }
            // Sort
            Section {
                Button(action: {
                    vm.sortShoppingListsAlphabetically()
                }) {
                    Label("Сортировать по алфавиту", systemImage: "arrow.up.arrow.down")
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .resizable()
                .frame(width: 24, height: 24)
        }
        .frame(width: 44, height: 44)
        .buttonStyle(.plain)
        .foregroundStyle(.glBlack)
    }
    
    @ViewBuilder private func plug() -> some View {
        Spacer()
        Image(.listsList)
            .padding(.top, 110)
        
        Text("Давайте спланируем покупки!")
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundStyle(.glBlack)
            .padding(.top, 28)
        
        Text("Создайте свой первый список")
            .foregroundStyle(.glBlack)
            .padding(.top, 6)
        Spacer()
    }
    
    @ViewBuilder private func listCell(_ list: ShoppingListUI) -> some View {
        
        NavigationLink(destination: ShoppingListView(shoppingListUI: list)) {
            SwipeActionsContainer() {
                ShoppingListsCell(list: list)
                
            } actions: {
                Action(
                    tint: .white,
                    background: .glSystemLightGray,
                    icon: "square.and.pencil"
                ) {
                    // edit list
                    listForEditing = list
                    navigateToListEditing = true
                }
                
                Action(
                    tint: .white,
                    background: .orange,
                    icon: "square.on.square"
                ) {
                    vm.duplicateList(list)
                }
                Action(
                    tint: .white,
                    background: .red,
                    icon: "trash"
                ) {
                    // delete list
                    listToDelete = list
                    alert.present()
                }
            }
            .transition(.blurReplace)
            .padding(.trailing)
            
        }
        .buttonStyle(PlainButtonStyle())
        .draggable(list) {
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .frame(width: 1, height: 1)
                .onAppear {
                    draggingItem = list
                }
        }
        .dropDestination(for: ShoppingListUI.self) { items, location in
            draggingItem = nil
            return false
        } isTargeted: { status in
            if let draggingItem, status, draggingItem != list {
                
                if let sourceIndex = vm.shoppingListsUI.firstIndex(of: draggingItem),
                   let destinationIndex = vm.shoppingListsUI.firstIndex(of: list) {
                    
                    withAnimation(.bouncy) {
                        let sourceItem = vm.shoppingListsUI.remove(at: sourceIndex)
                        vm.shoppingListsUI.insert(sourceItem, at: destinationIndex)
                    }
                    vm.updateSortOrder(from: vm.shoppingListsUI)
                }
            }
        }
    }
    
    @ViewBuilder private func createButton() -> some View {
        NavigationLink(destination: ListCreationView(vm: ListCreationViewModel())) {
            WideButton(isActive: .constant(true), title: "Создать список")
        }
    }
    
    // MARK: - Private Methods
    private func deleteList() {
        guard let listToDelete else { return }
        print("Шаг 1. Имя listToDelete: \(listToDelete.name)")
        vm.deleteList(listToDelete)
        self.listToDelete = nil
        alert.dismiss()
    }
}
