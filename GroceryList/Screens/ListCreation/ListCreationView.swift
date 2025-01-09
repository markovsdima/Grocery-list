import SwiftUI

struct ListCreationView: View {
    // MARK: - Public Properties
    @StateObject var vm: ListCreationViewModel
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Init
    init(vm: ListCreationViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.glBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                navBar()
                    .padding(.bottom, 12)
                textField()
                    .padding(.bottom, 24)
                ColorPickerView(selectedColor: $vm.selectedColor)
                    .padding(.bottom, 24)
                IconPickerView(selectedIcon: $vm.selectedIcon, selectedColor: $vm.selectedColor)
                Spacer()
                createButton()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onTapGesture {
            hideKeyboard()
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    // MARK: - View Components
    @ViewBuilder private func navBar() -> some View {
        NavBar(title: vm.editing ? "Редактировать список" : "Создать список",
               withOptions: false,
               onBack: {dismiss()},
               menuContent: nil
        )
    }
    
    @ViewBuilder private func textField() -> some View {
        TextFieldWithErrorTitle(
            errorTitle: $vm.listNameErrorTitle,
            textFieldText: $vm.listName,
            fieldState: $vm.listNameState,
            textFieldHolder: "Введите название списка"
        )
        .autocorrectionDisabled()
        .padding(.horizontal)
    }
    
    @ViewBuilder private func createButton() -> some View {
        WideButton(isActive: $vm.isCreateButtonActive,
                   title: vm.editing ? "Сохранить" : "Создать"
        )
        .onTapGesture {
            if vm.isCreateButtonActive {
                if vm.editing == false {
                    guard let validateListCreationScreen = vm.validateListCreationScreen() else { return }
                    if validateListCreationScreen {
                        vm.createNewList()
                        dismiss()
                    }
                } else {
                    guard let validateListEditingScreen = vm.validateListEditingScreen() else { return }
                    if validateListEditingScreen {
                        vm.updateExistingList()
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Previews
#Preview {
    ListCreationView(vm: ListCreationViewModel())
}
