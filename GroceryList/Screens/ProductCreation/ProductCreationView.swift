import SwiftUI

struct ProductCreationView: View {
    // MARK: - Public Properties
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var systemColorScheme
    @State var selectedUnit: CountUnit = .quantify
    var onProductCreated: (() -> Void)?
    
    // MARK: - Private Properties
    @StateObject private var vm: ProductCreationViewModel
    @FocusState private var focusedField: FocusField?
    @State private var isPickerPresented = false
    @State private var blur: CGFloat = 0
    @State private var recommendationsOpacity: CGFloat = 0
    @State private var darkeningLayerOpacity: CGFloat = 0
    private enum FocusField {
        case name, amount, unit
    }
    private var darkeningOpacity: CGFloat {
        systemColorScheme == .light ? 0.15 : 0.30
    }
    private var blurRadius: CGFloat {
        showRecommendations ? (systemColorScheme == .light ? 4 : 8) : 0
    }
    private var showRecommendations: Bool {
        vm.recommendations.count > 0 && focusedField == .name
    }
    
    // MARK: - Init
    init(vm: ProductCreationViewModel, onProductCreated: (() -> Void)? = nil) {
        _vm = StateObject(wrappedValue: vm)
        self.onProductCreated = onProductCreated
    }
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .top) {
            Color.glBackground.ignoresSafeArea()
                .onTapGesture {
                    hideKeyboard()
                }
                .overlay {
                    if showRecommendations {
                        darkeningLayer()
                    }
                }
            
            VStack {
                header()
                textField()
                    .padding(.top, 14)
                
                HStack(spacing: 0) {
                    decimalField()
                        .padding(.leading)
                        .padding(.trailing, 8)
                        .frame(maxWidth: .infinity)
                    
                    countUnitField()
                        .padding(.leading, 8)
                        .padding(.trailing)
                        .frame(maxWidth: .infinity, maxHeight: 60)
                }
                .padding(.top, 10)
                .blur(radius: blur)
                
                Spacer()
            }
            
            if showRecommendations {
                recommendations()
            }
        }
        .onChange(of: systemColorScheme) {
            withAnimation(.easeInOut(duration: 0.3)) {
                blur = blurRadius
                darkeningLayerOpacity = darkeningOpacity
            }
        }
    }
    
    // MARK: - View Components
    @ViewBuilder private func darkeningLayer() -> some View {
        Rectangle()
            .fill(Color.black.opacity(darkeningLayerOpacity))
            .onTapGesture { focusedField = nil }
            .edgesIgnoringSafeArea(.all)
            .opacity(recommendationsOpacity)
    }
    
    @ViewBuilder private func header() -> some View {
        HStack {
            Button(action: {dismiss()}) {
                Text("Отменить")
                    .foregroundStyle(.glHintGray)
            }
            Spacer()
            Text(vm.editing ? "Редактировать" : "Создание товара")
                .fontWeight(.bold)
            Spacer()
            Button(action: {create()}) {
                Text("Готово")
                    .fontWeight(.bold)
                    .foregroundStyle((!vm.allowCreate) ? .glHintGray : .glTurquoise)
            }
            .disabled((!vm.allowCreate) ? true : false)
        }
        .padding(.horizontal)
        .padding(.top, 22)
    }
    
    @ViewBuilder private func textField() -> some View {
        TextFieldWithErrorTitle(
            errorTitle: $vm.productNameErrorTitle,
            textFieldText: $vm.productName,
            fieldState: $vm.productNameState,
            textFieldHolder: "Название товара"
        )
        .autocorrectionDisabled()
        .focused($focusedField, equals: .name)
        .padding(.horizontal)
    }
    
    @ViewBuilder private func decimalField() -> some View {
        DecimalTextField(
            count: $vm.productCount,
            allowDouble: $vm.allowDouble,
            countError: $vm.countError,
            decimalFieldHolder: "Количество"
        )
        .overlay {
            if showRecommendations {
                Rectangle()
                    .fill(Color.black.opacity(darkeningLayerOpacity))
                    .onTapGesture { focusedField = nil }
                    .edgesIgnoringSafeArea(.all)
                    .opacity(recommendationsOpacity)
            }
        }
    }
    
    @ViewBuilder private func countUnitField() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(.glWhite)
            
            HStack {
                Text("Ед.изм.:")
                    .foregroundStyle(.gray)
                    .padding(.leading)
                Spacer()
                Picker("Ед.изм.", selection: $vm.countUnit) {
                    ForEach(CountUnit.allCases, id: \.self) { unit in
                        Text(unit.name)
                            .tag(unit)
                    }
                }
                .pickerStyle(.menu)
                .tint(.glTurquoise)
                .foregroundStyle(.gray)
            }
        }
        .overlay {
            if showRecommendations {
                Rectangle()
                    .fill(Color.black.opacity(darkeningLayerOpacity))
                    .onTapGesture { focusedField = nil }
                    .edgesIgnoringSafeArea(.all)
                    .opacity(recommendationsOpacity)
            }
        }
    }
    
    @ViewBuilder private func recommendations() -> some View {
        VStack(spacing: 0) {
            ForEach(vm.recommendations, id: \.self) { recommendation in
                HStack {
                    Text(recommendation)
                        .padding(.leading)
                    Spacer()
                }
                .frame(height: 44)
                .contentShape(.rect)
                .onTapGesture {
                    vm.productName = recommendation
                    focusedField = nil
                }
                Divider()
                    .padding(.horizontal)
                    .opacity(recommendation == vm.recommendations.last ? 0 : 1)
            }
        }
        .background(Color.glWhite)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .offset(y: 136)
        .opacity(recommendationsOpacity)
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.easeInOut, value: vm.recommendations.count)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3)) {
                blur = blurRadius
                darkeningLayerOpacity = darkeningOpacity
                recommendationsOpacity = 1
            }
        }
        .onDisappear {
            withAnimation(.easeInOut(duration: 0.2)) {
                blur = 0
                recommendationsOpacity = 0
            }
        }
    }
    
    // MARK: - Private Methods
    private func create() {
        if !vm.editing {
            guard let validate = vm.validateProductCreation() else { return }
            if validate {
                vm.createNewProduct()
                onProductCreated?()
                dismiss()
            }
        } else {
            guard let editing = vm.validateProductEditing() else { return }
            if editing {
                vm.updateExistingProduct()
                onProductCreated?()
                dismiss()
            }
        }
    }
}

