import Foundation

protocol ExpenseStorage {
    func loadExpenses() -> [Expense]
    func save(expenses: [Expense])
}

struct FileExpenseStorage: ExpenseStorage {
    private let url: URL
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(filename: String = "expenses.json") {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        url = documentsURL.appendingPathComponent(filename)
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    func loadExpenses() -> [Expense] {
        guard let data = try? Data(contentsOf: url) else { return [] }
        return (try? decoder.decode([Expense].self, from: data)) ?? []
    }

    func save(expenses: [Expense]) {
        guard let data = try? encoder.encode(expenses) else { return }
        try? data.write(to: url)
    }
}

struct InMemoryExpenseStorage: ExpenseStorage {
    private var sampleExpenses: [Expense]

    init() {
        sampleExpenses = [
            Expense(title: "Boba Joy", category: .treats, amount: 8.5, date: .now.addingTimeInterval(-3600)),
            Expense(title: "Mini Spa Day", category: .wellness, amount: 62, date: .now.addingTimeInterval(-86400)),
            Expense(title: "Books & Chill", category: .learning, amount: 28, date: .now.addingTimeInterval(-172800))
        ]
    }

    func loadExpenses() -> [Expense] { sampleExpenses }

    func save(expenses: [Expense]) { }
}
