import Foundation
import Combine

@MainActor
final class TranslationViewModel: ObservableObject {
    @Published var inputText = ""
    @Published var translatedText = ""
    @Published var sourceLanguage: LanguageOption = .english
    @Published var targetLanguage: LanguageOption = .spanish
    @Published var history: [TranslationRecord] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""

    private let apiService = TranslationAPIService()
    private let historyStore: TranslationHistoryStoring

    init(historyStore: TranslationHistoryStoring = TranslationHistoryStore()) {
        self.historyStore = historyStore
    }

    func translate() async {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let output = try await apiService.translate(
                text: inputText,
                from: sourceLanguage.rawValue,
                to: targetLanguage.rawValue
            )

            translatedText = output

            let record = TranslationRecord(
                sourceText: inputText,
                translatedText: output,
                sourceLanguage: sourceLanguage.rawValue,
                targetLanguage: targetLanguage.rawValue
            )

            try await historyStore.save(record)
            history.insert(record, at: 0)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func loadHistory() async {
        do {
            history = try await historyStore.fetchHistory()
        } catch {
            errorMessage = "Could not load translation history."
            showError = true
        }
    }

    func clearHistory() async {
        do {
            try await historyStore.clearHistory()
            history = []
        } catch {
            errorMessage = "Could not clear translation history."
            showError = true
        }
    }

    func clearCurrentTranslation() {
        inputText = ""
        translatedText = ""
    }
}
