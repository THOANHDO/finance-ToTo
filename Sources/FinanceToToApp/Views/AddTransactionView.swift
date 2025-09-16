import SwiftUI
#if canImport(PhotosUI)
import PhotosUI
#endif

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var financeStore: FinanceDataStore
    @StateObject private var viewModel = AddTransactionViewModel()
    #if canImport(PhotosUI)
    @State private var selectedItem: PhotosPickerItem?
    #endif

    var body: some View {
        Form {
            Section(String(localized: "Details")) {
                TextField(String(localized: "Merchant"), text: $viewModel.merchant)
                TextField(String(localized: "Amount"), value: $viewModel.amount, format: .currency(code: Locale.current.currencyCode ?? "USD"))
                #if os(iOS)
                    .keyboardType(.decimalPad)
                #endif
                Toggle(String(localized: "Income"), isOn: $viewModel.isIncome)
                Picker(String(localized: "Category"), selection: $viewModel.category) {
                    ForEach(TransactionCategory.allCases) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                DatePicker(String(localized: "Date"), selection: $viewModel.date, displayedComponents: [.date, .hourAndMinute])
                TextField(String(localized: "Notes"), text: $viewModel.notes, axis: .vertical)
            }

            #if canImport(PhotosUI)
            Section(String(localized: "Receipt")) {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label(String(localized: "Scan Receipt"), systemImage: "doc.viewfinder")
                }
                if let receipt = viewModel.receipt {
                    VStack(alignment: .leading) {
                        Text(String(localized: "Detected Total: \(receipt.total?.currencyString ?? "-")"))
                        Text(receipt.extractedText)
                            .font(.caption)
                            .lineLimit(4)
                    }
                }
            }
            #endif
        }
        .navigationTitle(String(localized: "Add Transaction"))
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(String(localized: "Cancel")) { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(String(localized: "Save")) {
                    viewModel.save()
                    dismiss()
                }
                .disabled(viewModel.merchant.isEmpty || viewModel.amount <= 0)
            }
        }
        .onAppear {
            viewModel.configure(with: financeStore)
        }
        #if canImport(PhotosUI)
        .onChange(of: selectedItem) { newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString + ".jpg")
                    try? data.write(to: url)
                    await viewModel.processReceipt(data: data, url: url)
                }
            }
        }
        #endif
    }
}
