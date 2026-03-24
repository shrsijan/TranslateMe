import Foundation

struct TranslationRecord: Identifiable, Codable {
    var id: String
    let sourceText: String
    let translatedText: String
    let sourceLanguage: String
    let targetLanguage: String
    let createdAt: Date

    init(
        id: String = UUID().uuidString,
        sourceText: String,
        translatedText: String,
        sourceLanguage: String,
        targetLanguage: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.sourceText = sourceText
        self.translatedText = translatedText
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.createdAt = createdAt
    }
}

enum LanguageOption: String, CaseIterable, Identifiable {
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case italian = "it"
    case nepali = "ne"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Spanish"
        case .french: return "French"
        case .german: return "German"
        case .italian: return "Italian"
        case .nepali: return "Nepali"
        }
    }
}
