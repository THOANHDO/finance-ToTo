import Foundation

struct Asset: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var value: Decimal
    var type: AssetType
    var associatedAccount: Account?
    var notes: String

    init(
        id: UUID = UUID(),
        name: String,
        value: Decimal,
        type: AssetType,
        associatedAccount: Account? = nil,
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.value = value
        self.type = type
        self.associatedAccount = associatedAccount
        self.notes = notes
    }
}

enum AssetType: String, CaseIterable, Codable, Identifiable {
    case cash
    case deposit
    case investment
    case realEstate
    case vehicle
    case retirement
    case other

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .cash: return String(localized: "Cash")
        case .deposit: return String(localized: "Deposit")
        case .investment: return String(localized: "Investment")
        case .realEstate: return String(localized: "Real Estate")
        case .vehicle: return String(localized: "Vehicle")
        case .retirement: return String(localized: "Retirement")
        case .other: return String(localized: "Other")
        }
    }
}
