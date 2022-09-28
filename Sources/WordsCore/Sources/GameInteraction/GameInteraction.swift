import Combine
import Domain
import Foundation
import WordsGenerator

public final class GameViewModel {
    
    public var state: AnyPublisher<GameState, Never> { stateSubject.eraseToAnyPublisher() }

    private let stateSubject: CurrentValueSubject<GameState, Never>
    private let wordsGenerator: WordsGenerator
    
    public init(wordsGenerator: WordsGenerator) {
        self.wordsGenerator = wordsGenerator
        self.stateSubject = .init(.init(wordsPair: wordsGenerator.generate(), totalFailures: 0, totalRounds: 0))
    }
    
    public func userFeedback(isCorrect: Bool) {
        let totalRounds = stateSubject.value.totalRounds + 1
        let userAnswerIsCorrect = stateSubject.value.wordsPair.isCorrect == isCorrect
        let totalFailures = stateSubject.value.totalFailures + (userAnswerIsCorrect ? 0 : 1)
        
        let newState = GameState(
            wordsPair: wordsGenerator.generate(),
            totalFailures: totalFailures,
            totalRounds: totalRounds
        )
        stateSubject.send(newState)
    }
}
