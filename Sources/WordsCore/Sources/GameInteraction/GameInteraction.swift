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
    
    public var state: AnyPublisher<GameState, Never> {
        stateSubject
            .handleEvents(receiveOutput: { [weak self] in self?.startTimer($0) })
            .eraseToAnyPublisher()
    }

    private let stateSubject: CurrentValueSubject<GameState, Never>
    private let wordsGenerator: WordsGenerator
    private let gameSettings: GameSettings
    
    public init(wordsGenerator: WordsGenerator, gameSettings: GameSettings = .default) {
        self.wordsGenerator = wordsGenerator
        self.gameSettings = gameSettings
        self.stateSubject = .init(.init(mode: .idle))
    }
    
    public func userFeedback(isCorrect: Bool) {
        userFeedback(.userChoice(isCorrect))
    }
    
    public func start() {
        pushNextRound(totalFailures: 0, totalRounds: 0)
    }
    
    private func pushNextRound(totalFailures: Int, totalRounds: Int) {
        let round = GameState.Round(
            wordsPair: wordsGenerator.generate(),
            timeForAnswer: gameSettings.timeLimitInSeconds,
            totalFailures: totalFailures,
            totalRounds: totalRounds
        )
        stateSubject.send(.init(mode: .next(round)))
    }
    
    private func userFeedback(_ userInput: UserInput) {
        guard case let .next(currentState) = stateSubject.value.mode else {
            assertionFailure("Unexpected State mode")
            return
        }
        
        let totalRounds = currentState.totalRounds + 1
        let userAnswerIsCorrect = userInput.isCorrect.map { currentState.wordsPair.isCorrect == $0 } ?? false
        let totalFailures = currentState.totalFailures + (userAnswerIsCorrect ? 0 : 1)
        
        if totalFailures == gameSettings.totalFailures || totalRounds == gameSettings.totalRounds {
            let gameResult = GameResult(totalRounds: totalRounds, totalFailures: totalFailures)
            stateSubject.send(.init(mode: .gameOver(gameResult)))
            stateSubject.send(completion: .finished)
        } else {
            pushNextRound(totalFailures: totalFailures, totalRounds: totalRounds)
        }
    }
        
    private func startTimer(_ gameState: GameState) {
        guard case .next = gameState.mode else {
            return
        }
        Timer.scheduledTimer(
            timeInterval: gameSettings.timeLimitInSeconds,
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
