import Foundation
#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

protocol TranslationHistoryStoring {
    func fetchHistory() async throws -> [TranslationRecord]
    func save(_ record: TranslationRecord) async throws
    func clearHistory() async throws
}

final class TranslationHistoryStore: TranslationHistoryStoring {
    private let fallbackStore = LocalTranslationHistoryStore()

    #if canImport(FirebaseFirestore)
    private let db = Firestore.firestore()
    private let collectionName = "translations"
    #endif

    func fetchHistory() async throws -> [TranslationRecord] {
        #if canImport(FirebaseFirestore)
        do {
            let snapshot = try await db
                .collection(collectionName)
                .order(by: "createdAt", descending: true)
                .getDocuments()

            let records = snapshot.documents.compactMap { document -> TranslationRecord? in
                let data = document.data()

                guard
                    let sourceText = data["sourceText"] as? String,
                    let translatedText = data["translatedText"] as? String,
                    let sourceLanguage = data["sourceLanguage"] as? String,
                    let targetLanguage = data["targetLanguage"] as? String
                else {
                    return nil
                }

                let createdAt: Date
                if let timestamp = data["createdAt"] as? Timestamp {
                    createdAt = timestamp.dateValue()
                } else {
                    createdAt = Date()
                }

                return TranslationRecord(
                    id: document.documentID,
                    sourceText: sourceText,
                    translatedText: translatedText,
                    sourceLanguage: sourceLanguage,
                    targetLanguage: targetLanguage,
                    createdAt: createdAt
                )
            }

            try await fallbackStore.replace(with: records)
            return records
        } catch {
            return try await fallbackStore.fetchHistory()
        }
        #else
        return try await fallbackStore.fetchHistory()
        #endif
    }

    func save(_ record: TranslationRecord) async throws {
        #if canImport(FirebaseFirestore)
        do {
            try await db.collection(collectionName).document(record.id).setData([
                "sourceText": record.sourceText,
                "translatedText": record.translatedText,
                "sourceLanguage": record.sourceLanguage,
                "targetLanguage": record.targetLanguage,
                "createdAt": Timestamp(date: record.createdAt)
            ])
        } catch {
            try await fallbackStore.save(record)
        }
        #else
        try await fallbackStore.save(record)
        #endif
    }

    func clearHistory() async throws {
        #if canImport(FirebaseFirestore)
        do {
            let snapshot = try await db.collection(collectionName).getDocuments()
            for document in snapshot.documents {
                try await db.collection(collectionName).document(document.documentID).delete()
            }
            try await fallbackStore.clearHistory()
        } catch {
            try await fallbackStore.clearHistory()
        }
        #else
        try await fallbackStore.clearHistory()
        #endif
    }
}

final class LocalTranslationHistoryStore: TranslationHistoryStoring {
    private let key = "translation_history"
    private let defaults = UserDefaults.standard

    func fetchHistory() async throws -> [TranslationRecord] {
        guard let data = defaults.data(forKey: key) else {
            return []
        }

        return try JSONDecoder().decode([TranslationRecord].self, from: data)
            .sorted(by: { $0.createdAt > $1.createdAt })
    }

    func save(_ record: TranslationRecord) async throws {
        var current = try await fetchHistory()
        current.insert(record, at: 0)
        let data = try JSONEncoder().encode(current)
        defaults.set(data, forKey: key)
    }

    func clearHistory() async throws {
        defaults.removeObject(forKey: key)
    }

    func replace(with records: [TranslationRecord]) async throws {
        let data = try JSONEncoder().encode(records)
        defaults.set(data, forKey: key)
    }
}
