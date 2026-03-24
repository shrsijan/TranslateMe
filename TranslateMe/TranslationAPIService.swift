import Foundation

struct TranslationAPIService {
    func translate(text: String, from sourceLanguage: String, to targetLanguage: String) async throws -> String {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return ""
        }

        var components = URLComponents(string: "https://api.mymemory.translated.net/get")
        components?.queryItems = [
            URLQueryItem(name: "q", value: text),
            URLQueryItem(name: "langpair", value: "\(sourceLanguage)|\(targetLanguage)")
        ]

        guard let url = components?.url else {
            throw TranslationError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw TranslationError.networkFailure
        }

        let decodedResponse = try JSONDecoder().decode(MyMemoryResponse.self, from: data)
        let rawResult = decodedResponse.responseData.translatedText
        let result = normalize(rawResult)

        if result.isEmpty {
            throw TranslationError.emptyResponse
        }

        return result
    }

    private func normalize(_ value: String) -> String {
        let plusToSpace = value.replacingOccurrences(of: "+", with: " ")
        let decoded = plusToSpace.removingPercentEncoding ?? plusToSpace
        return decoded.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private struct MyMemoryResponse: Decodable {
    let responseData: MyMemoryResponseData
}

private struct MyMemoryResponseData: Decodable {
    let translatedText: String
}

enum TranslationError: LocalizedError {
    case invalidURL
    case networkFailure
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL could not be created."
        case .networkFailure:
            return "The translation service is currently unavailable."
        case .emptyResponse:
            return "The service returned an empty translation."
        }
    }
}
