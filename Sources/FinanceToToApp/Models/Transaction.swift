import Foundation
import CoreLocation

struct Transaction: Identifiable, Codable, Hashable {
    let id: UUID
    var date: Date
    var amount: Decimal
    var category: TransactionCategory
    var merchant: String
    var notes: String
    var receipt: Receipt?
    var location: CLLocationCoordinate2D?
    var isIncome: Bool

    private enum CodingKeys: String, CodingKey {
        case id
        case date
        case amount
        case category
        case merchant
        case notes
        case receipt
        case location
        case isIncome
    }

    private enum LocationCodingKeys: String, CodingKey {
        case latitude
        case longitude
    }

    init(
        id: UUID = UUID(),
        date: Date = .now,
        amount: Decimal,
        category: TransactionCategory,
        merchant: String,
        notes: String = "",
        receipt: Receipt? = nil,
        location: CLLocationCoordinate2D? = nil,
        isIncome: Bool = false
    ) {
        self.id = id
        self.date = date
        self.amount = amount
        self.category = category
        self.merchant = merchant
        self.notes = notes
        self.receipt = receipt
        self.location = location
        self.isIncome = isIncome
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        amount = try container.decode(Decimal.self, forKey: .amount)
        category = try container.decode(TransactionCategory.self, forKey: .category)
        merchant = try container.decode(String.self, forKey: .merchant)
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
        receipt = try container.decodeIfPresent(Receipt.self, forKey: .receipt)

        if container.contains(.location) {
            let locationContainer = try container.nestedContainer(keyedBy: LocationCodingKeys.self, forKey: .location)
            let latitude = try locationContainer.decode(CLLocationDegrees.self, forKey: .latitude)
            let longitude = try locationContainer.decode(CLLocationDegrees.self, forKey: .longitude)
            location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            location = nil
        }

        isIncome = try container.decodeIfPresent(Bool.self, forKey: .isIncome) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(amount, forKey: .amount)
        try container.encode(category, forKey: .category)
        try container.encode(merchant, forKey: .merchant)
        try container.encode(notes, forKey: .notes)
        try container.encodeIfPresent(receipt, forKey: .receipt)

        if let location {
            var locationContainer = container.nestedContainer(keyedBy: LocationCodingKeys.self, forKey: .location)
            try locationContainer.encode(location.latitude, forKey: .latitude)
            try locationContainer.encode(location.longitude, forKey: .longitude)
        }

        try container.encode(isIncome, forKey: .isIncome)
    }
}

extension Transaction {
    var signedAmount: Decimal { isIncome ? amount : -amount }
}
