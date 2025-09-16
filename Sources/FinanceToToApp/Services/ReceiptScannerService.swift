import Foundation
#if canImport(VisionKit)
import VisionKit
#endif
import Vision

struct ReceiptScanResult {
    let text: String
    let total: Decimal?
    let merchant: String?
    let purchaseDate: Date?
}

@MainActor
final class ReceiptScannerService: NSObject, ObservableObject {
    @Published var lastResult: ReceiptScanResult?

    func process(imageData: Data) async throws -> ReceiptScanResult {
        let handler = VNImageRequestHandler(data: imageData, options: [:])
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        try handler.perform([request])
        let text = request.results?
            .compactMap { $0.topCandidates(1).first?.string }
            .joined(separator: "\n") ?? ""
        let parsed = parse(text: text)
        let result = ReceiptScanResult(text: text, total: parsed.total, merchant: parsed.merchant, purchaseDate: parsed.date)
        lastResult = result
        return result
    }

    private func parse(text: String) -> (total: Decimal?, merchant: String?, date: Date?) {
        let lines = text.split(separator: "\n").map(String.init)
        let currencyRegex = try? NSRegularExpression(pattern: "([0-9]+[.,][0-9]{2})")
        let dateDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
        var total: Decimal?
        var merchant: String?
        var purchaseDate: Date?

        for line in lines {
            if merchant == nil && line.count > 3 && line.range(of: "total", options: .caseInsensitive) == nil {
                merchant = line.trimmingCharacters(in: .whitespaces)
            }
            if total == nil, let regex = currencyRegex, let match = regex.firstMatch(in: line, range: NSRange(location: 0, length: line.utf16.count)) {
                let value = (line as NSString).substring(with: match.range)
                    .replacingOccurrences(of: ",", with: ".")
                total = Decimal(string: value)
            }
            if purchaseDate == nil, let detector = dateDetector {
                let matches = detector.matches(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count))
                purchaseDate = matches.first?.date
            }
        }
        return (total, merchant, purchaseDate)
    }
}
