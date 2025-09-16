import Foundation

struct Receipt: Identifiable, Codable, Hashable {
    let id: UUID
    var fileURL: URL
    var extractedText: String
    var total: Decimal?
    var merchantName: String?
    var purchaseDate: Date?

    init(
        id: UUID = UUID(),
        fileURL: URL,
        extractedText: String,
        total: Decimal? = nil,
        merchantName: String? = nil,
        purchaseDate: Date? = nil
    ) {
        self.id = id
        self.fileURL = fileURL
        self.extractedText = extractedText
        self.total = total
        self.merchantName = merchantName
        self.purchaseDate = purchaseDate
    }
}
