import Foundation
import CoreLocation

@MainActor
final class AddTransactionViewModel: ObservableObject {
    @Published var amount: Decimal = 0
    @Published var date: Date = .now
    @Published var category: TransactionCategory = .foodAndDining
    @Published var merchant: String = ""
    @Published var notes: String = ""
    @Published var isIncome: Bool = false
    @Published var receipt: Receipt?
    @Published var location: CLLocationCoordinate2D?

    private var financeStore: FinanceDataStore?
    private let receiptScanner: ReceiptScannerService

    init(receiptScanner: ReceiptScannerService = ReceiptScannerService()) {
        self.receiptScanner = receiptScanner
    }

    func configure(with financeStore: FinanceDataStore) {
        self.financeStore = financeStore
    }

    func save() {
        guard let financeStore else { return }
        let transaction = Transaction(
            date: date,
            amount: amount,
            category: category,
            merchant: merchant,
            notes: notes,
            receipt: receipt,
            location: location,
            isIncome: isIncome
        )
        financeStore.addTransaction(transaction)
    }

    func processReceipt(data: Data, url: URL) async {
        do {
            let result = try await receiptScanner.process(imageData: data)
            if let total = result.total {
                amount = total
            }
            if let merchantName = result.merchant {
                merchant = merchantName
            }
            if let purchaseDate = result.purchaseDate {
                date = purchaseDate
            }
            receipt = Receipt(fileURL: url, extractedText: result.text, total: result.total, merchantName: result.merchant, purchaseDate: result.purchaseDate)
        } catch {
            print("Failed to process receipt: \(error)")
        }
    }
}
