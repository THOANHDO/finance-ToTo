import SwiftUI

struct PaymentReminderList: View {
    let reminders: [PaymentReminder]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(reminders) { reminder in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(reminder.title)
                            .font(.headline)
                        Text(reminder.dueDate.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(reminder.amount.currencyString)
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                }
                .padding()
                .background(Color.financeBackground)
                .cornerRadius(16)
            }
        }
    }
}
