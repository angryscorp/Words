import Domain
import Foundation
import WordsGenerator

public final class WordsGeneratorImpl: WordsGenerator {
    
    private static let correctWordPairProbability = 0.25
    
    private let words: [Words]
    private let allOriginWords: [String]
    private let allTranslateWords: [String]
    
    public init() {
        words = Bundle.loadWords()
        allOriginWords = words.map { $0.origin }
        allTranslateWords = words.map { $0.translate }
    }
    
    public func generate() -> WordsPair {
        if Double.random(in: 0...1) <= Self.correctWordPairProbability {
            let pair = words.randomElement()!
            return .init(origin: pair.origin, translate: pair.translate, isCorrect: true)
        } else {
            let origin = allOriginWords.randomElement()!
            let translate = allTranslateWords.randomElement()!
            return .init(
                origin: origin,
                translate: translate,
                isCorrect: words.contains(where: { $0.origin == origin && $0.translate == translate })
            )
        }
    }
}

private struct Words: Codable {
    let origin: String
    let translate: String
    
    enum CodingKeys: String, CodingKey {
        case origin = "text_eng"
        case translate = "text_spa"
    }
}

private extension Bundle {
    static func loadWords() -> [Words] {
        guard let url = Bundle.module.url(forResource: "words", withExtension: "json") else {
            assertionFailure("File `words.json` has not been found.")
            return []
        }
        guard let words = try? JSONDecoder().decode([Words].self, from: Data.init(contentsOf: url)) else {
            assertionFailure("Decoding error: `words.json`")
            return []
        }
        if words.isEmpty {
            assertionFailure("File `words.json` is empty")
        }
        return words
    }
}
