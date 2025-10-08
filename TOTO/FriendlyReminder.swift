import Foundation
import AVFoundation
import SwiftUI

enum ReminderTone {
    case celebrate
    case gentle
    case warning

    var accentColor: Color {
        switch self {
        case .celebrate:
            return .green
        case .gentle:
            return .orange
        case .warning:
            return .red
        }
    }
}

struct FriendlyReminderMessage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let voiceLine: String
    let tone: ReminderTone

    var compactMessage: String {
        "\(title) • \(subtitle)"
    }
}

struct FriendlyReminder {
    static func message(for category: BudgetCategory, newExpense: Double, userName: String) -> FriendlyReminderMessage {
        let spent = category.spent
        let limit = category.limit
        let percent = limit > 0 ? spent / limit : 0
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = Locale.current.currency?.identifier ?? "VND"
        let amountText = currencyFormatter.string(from: NSNumber(value: newExpense)) ?? "\(newExpense)"
        let spentText = currencyFormatter.string(from: NSNumber(value: spent)) ?? "\(spent)"
        let limitText = currencyFormatter.string(from: NSNumber(value: limit)) ?? "\(limit)"

        if spent > limit {
            let title = "Ôi không! Chi tiêu vượt \(category.name) mất rồi"
            let subtitle = "Tổng chi hiện tại là \(spentText)/\(limitText). Cùng hít thở và cân nhắc tiết chế nhé \(userName)!"
            let voice = "Bạn \(userName) ơi, hạt dẻ nhỏ của TOTO đã vượt mức cho \(category.name) rồi nè. Mình cùng nghỉ ngơi một chút nhé!"
            return FriendlyReminderMessage(title: title, subtitle: subtitle, voiceLine: voice, tone: .warning)
        } else if percent > 0.85 {
            let title = "Sắp chạm giới hạn \(category.name) rồi"
            let subtitle = "Bạn đã tiêu \(spentText) trong khi giới hạn là \(limitText). TOTO tin bạn sẽ điều chỉnh hợp lý!"
            let voice = "Ui chao, chỉ còn chút xíu nữa thôi là chạm trần \(category.name) rồi đó \(userName)! Cố lên nè!"
            return FriendlyReminderMessage(title: title, subtitle: subtitle, voiceLine: voice, tone: .gentle)
        } else {
            let title = "\(category.name) thêm một niềm vui mới"
            let subtitle = "Bạn vừa tiêu \(amountText). Tổng chi hiện tại: \(spentText)/\(limitText)."
            let voice = "Yeah! \(amountText) cho \(category.name) nghe thật đáng yêu đó \(userName)! Hãy tận hưởng nhưng vẫn nhớ kế hoạch nha."
            return FriendlyReminderMessage(title: title, subtitle: subtitle, voiceLine: voice, tone: .celebrate)
        }
    }
}

final class FriendlySpeaker {
    private let synthesizer = AVSpeechSynthesizer()
    private var isPrepared = false

    func prepare() {
        guard !isPrepared else { return }
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio, options: [.mixWithOthers])
        try? session.setActive(true, options: [])
        isPrepared = true
    }

    func speak(_ text: String) {
        guard !text.isEmpty else { return }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "vi-VN")
        utterance.pitchMultiplier = 1.1
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }
}
