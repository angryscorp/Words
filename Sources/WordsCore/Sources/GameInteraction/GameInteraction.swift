import Combine
import Domain
import Foundation
import WordsGenerator

private enum UserInput {
    case userChoice(Bool)
    case timeIsExpired
    
    var isCorrect: Bool? {
        switch self {
        case let .userChoice(isCorrect):
            return isCorrect
            
        case .timeIsExpired:
            return nil
        }
    }
}

public final class GameViewModel {
    
    private static let totalRounds = 15
    private static let totalFailures = 3
    private static let timeLimitInSeconds = 5.0

    public var state: AnyPublisher<GameState, Never> {
        stateSubject
            .handleEvents(receiveOutput: { [weak self] in self?.startTimer($0) })
            .eraseToAnyPublisher()
    }

    private let stateSubject: CurrentValueSubject<GameState, Never>
    private let wordsGenerator: WordsGenerator
    
    public init(wordsGenerator: WordsGenerator) {
        self.wordsGenerator = wordsGenerator
        self.stateSubject = .init(.init(mode: .next(wordsGenerator.generate()), totalFailures: 0, totalRounds: 0))
    }
    
    public func userFeedback(isCorrect: Bool) {
        userFeedback(.userChoice(isCorrect))
    }
    
    private func userFeedback(_ userInput: UserInput) {
        guard case let .next(currentState) = stateSubject.value.mode else {
            assertionFailure("Unexpected State mode")
            return
        }
        
        let totalRounds = stateSubject.value.totalRounds + 1
        let userAnswerIsCorrect = userInput.isCorrect.map { currentState.isCorrect == $0 } ?? false
        let totalFailures = stateSubject.value.totalFailures + (userAnswerIsCorrect ? 0 : 1)
        
        if totalFailures == Self.totalFailures || totalRounds == Self.totalRounds {
            let newState = GameState(
                mode: .gameOver,
                totalFailures: totalFailures,
                totalRounds: totalRounds
            )
            stateSubject.send(newState)
            stateSubject.send(completion: .finished)
        } else {
            let newState = GameState(
                mode: .next(wordsGenerator.generate()),
                totalFailures: totalFailures,
                totalRounds: totalRounds
            )
            stateSubject.send(newState)
        }
    }
        
    private func startTimer(_ gameState: GameState) {
        guard case .next = gameState.mode else {
            return
        }
        Timer.scheduledTimer(
            timeInterval: Self.timeLimitInSeconds,
            target: self,
            selector: #selector(stopTimer),
            userInfo: gameState,
            repeats: false
        )
    }
    
    @objc
    private func stopTimer(timer: Timer) {
        guard
            let gameState = timer.userInfo as? GameState,
            gameState == stateSubject.value
        else { return }
        userFeedback(.timeIsExpired)
    }
}
