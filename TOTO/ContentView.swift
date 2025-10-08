import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = BudgetViewModel()
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.black.opacity(0.9), .indigo.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        header
                        reminderBanner
                        ForEach(viewModel.categories) { category in
                            CategoryCard(category: category) {
                                viewModel.activeCategory = category
                                showingAddSheet = true
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("TOTO Finance")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.activeCategory = viewModel.categories.first
                        showingAddSheet = true
                    } label: {
                        Label("Thêm chi tiêu", systemImage: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddSheet, onDismiss: { viewModel.activeCategory = nil }) {
            if let category = viewModel.activeCategory {
                AddExpenseSheet(category: category) { amount, note, date in
                    viewModel.addExpense(amount: amount, note: note, date: date, to: category)
                }
                .presentationDetents([.medium, .large])
            }
        }
        .onAppear {
            viewModel.prepareAudioSession()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Xin chào, \(viewModel.userName) ✨")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
            Text("Theo dõi chi tiêu mỗi ngày với nhắc nhở đáng yêu từ TOTO và Dynamic Island.")
                .font(.callout)
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var reminderBanner: some View {
        Group {
            if let reminder = viewModel.lastReminder {
                VStack(alignment: .leading, spacing: 8) {
                    Label(reminder.title, systemImage: "bubble.left.and.bubble.right.fill")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(reminder.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(reminder.tone.accentColor.opacity(0.65), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Hôm nay bạn muốn khám phá hạng mục nào?", systemImage: "sparkles")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("TOTO sẽ nhẹ nhàng nhắc nhở khi chi tiêu vượt kế hoạch. Bắt đầu bằng cách thêm giao dịch đầu tiên nhé!")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
        }
    }
}

private struct CategoryCard: View {
    var category: BudgetCategory
    var onAddExpense: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(category.color.opacity(0.7), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.name)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(category.friendlyLimitDescription)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
                Spacer()
                Button(action: onAddExpense) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.white)
                        .font(.title2)
                        .shadow(radius: 4)
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 12) {
                ProgressView(value: category.progress)
                    .tint(category.color)
                    .progressViewStyle(.linear)
                    .frame(height: 10)
                    .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Đã chi")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                        Text(category.spent, format: .currency(code: Locale.current.currency?.identifier ?? "VND"))
                            .font(.callout.bold())
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Còn lại")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                        Text(category.remaining, format: .currency(code: Locale.current.currency?.identifier ?? "VND"))
                            .font(.callout.bold())
                            .foregroundStyle(.white)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Giao dịch gần đây")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                if category.expenses.isEmpty {
                    Text("Chưa có giao dịch nào. Thêm mới để TOTO cổ vũ bạn nhé!")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                } else {
                    ForEach(category.expenses.prefix(3)) { expense in
                        ExpenseRow(expense: expense)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}

private struct ExpenseRow: View {
    var expense: Expense

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.white.opacity(0.25))
                .frame(width: 34, height: 34)
                .overlay(
                    Image(systemName: "sparkle")
                        .font(.footnote)
                        .foregroundStyle(.white)
                )
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.note)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                Text(expense.date, style: .time)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
            Spacer()
            Text(expense.amount, format: .currency(code: Locale.current.currency?.identifier ?? "VND"))
                .font(.subheadline.bold())
                .foregroundStyle(.white)
        }
        .padding(.vertical, 4)
    }
}

private struct AddExpenseSheet: View {
    @Environment(\.dismiss) private var dismiss
    var category: BudgetCategory
    var onSave: (Double, String, Date) -> Void

    @State private var amount: Double = 100_000
    @State private var note: String = ""
    @State private var date: Date = .now

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Chi tiêu cho \(category.name)")) {
                    TextField("Ghi chú", text: $note)
                    HStack {
                        Text("Số tiền")
                        Spacer()
                        TextField("0", value: $amount, format: .currency(code: Locale.current.currency?.identifier ?? "VND"))
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                    }
                    DatePicker("Thời gian", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
            }
            .navigationTitle("Thêm chi tiêu")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Đóng") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") {
                        onSave(amount, note.isEmpty ? "Chi tiêu dễ thương" : note, date)
                        dismiss()
                    }
                    .disabled(amount <= 0)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
