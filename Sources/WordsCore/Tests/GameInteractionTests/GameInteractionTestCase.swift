import Combine
import Domain
@testable import GameInteraction
import WordsGenerator
import XCTest

final class GameInteractionTestCase: XCTestCase {
    
    private var subscriptions = Set<AnyCancellable>()
    
    func test_initial_state() {
        let completed = expectation(description: String(describing: Self.self))

        let gameViewModel = GameViewModel(wordsGenerator: WordsGeneratorMock())
        gameViewModel.state
            .first()
            .sink { state in
                completed.fulfill()
                XCTAssertEqual(state, .init(mode: .idle))
            }
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 1)
    }
    
    func test_start_interaction() {
        let completed = expectation(description: String(describing: Self.self))

        let gameViewModel = GameViewModel(wordsGenerator: WordsGeneratorMock())
        gameViewModel.start()
        gameViewModel.state
            .first()
            .sink { state in
                completed.fulfill()
                let round = GameState.Round(
                    wordsPair: .mock,
                    timeForAnswer: GameSettings.default.timeLimitInSeconds,
                    totalFailures: 0,
                    totalRounds: 0
                )
                XCTAssertEqual(state, .init(mode: .next(round)))
            }
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 1)
    }
    
    func test_failures_limitations() {
        let completed = expectation(description: String(describing: Self.self))

        let gameViewModel = GameViewModel(wordsGenerator: WordsGeneratorMock())
        gameViewModel.start()
        gameViewModel.state
            .last()
            .sink { state in
                completed.fulfill()
                let gameResult = GameResult(
                    totalRounds: GameSettings.default.totalFailures,
                    totalFailures: GameSettings.default.totalFailures
                )
                XCTAssertEqual(state, GameState(mode: .gameOver(gameResult)))
            }
            .store(in: &subscriptions)

        (1...GameSettings.default.totalFailures)
            .forEach { _ in gameViewModel.userFeedback(isCorrect: false) }

        waitForExpectations(timeout: 1)
    }

    func test_rounds_limitations() {
        let completed = expectation(description: String(describing: Self.self))

        let gameViewModel = GameViewModel(wordsGenerator: WordsGeneratorMock())
        gameViewModel.start()
        gameViewModel.state
            .last()
            .sink { state in
                completed.fulfill()
                let gameResult = GameResult(
                    totalRounds: GameSettings.default.totalRounds,
                    totalFailures: 0
                )
                XCTAssertEqual(state, GameState(mode: .gameOver(gameResult)))
            }
            .store(in: &subscriptions)

        (1...GameSettings.default.totalRounds)
            .forEach { _ in gameViewModel.userFeedback(isCorrect: true) }

        waitForExpectations(timeout: 1)
    }

    func test_full_game() {
        let completed = expectation(description: String(describing: Self.self))

        let gameViewModel = GameViewModel(wordsGenerator: WordsGeneratorMock())
        gameViewModel.start()
        gameViewModel.state
            .last()
            .sink { state in
                completed.fulfill()
                let gameResult = GameResult(
                    totalRounds: GameSettings.default.totalRounds,
                    totalFailures: 1
                )
                XCTAssertEqual(state, GameState(mode: .gameOver(gameResult)))
            }
            .store(in: &subscriptions)

        gameViewModel.userFeedback(isCorrect: false)
        (2...GameSettings.default.totalRounds)
            .forEach { _ in gameViewModel.userFeedback(isCorrect: true) }

        waitForExpectations(timeout: 1)
    }

    func test_timer() {
        let completed = expectation(description: String(describing: Self.self))

        let gameViewModel = GameViewModel(
            wordsGenerator: WordsGeneratorMock(),
            gameSettings: .init(totalRounds: 5, totalFailures: 2, timeLimitInSeconds: 0.1)
        )
        gameViewModel.start()
        gameViewModel.state
            .last()
            .sink { state in
                completed.fulfill()
                let gameResult = GameResult(totalRounds: 2, totalFailures: 2)
                XCTAssertEqual(state, GameState(mode: .gameOver(gameResult)))
            }
            .store(in: &subscriptions)

        waitForExpectations(timeout: 1)
    }

    func test_state() {
        let completed = expectation(description: String(describing: Self.self))

        let gameViewModel = GameViewModel(wordsGenerator: WordsGeneratorMock())
        gameViewModel.start()
        gameViewModel.state
            .dropFirst(3)
            .sink { state in
                completed.fulfill()
                let round = GameState.Round(
                    wordsPair: .mock,
                    timeForAnswer: GameSettings.default.timeLimitInSeconds,
                    totalFailures: 2, totalRounds: 3
                )
                XCTAssertEqual(state, GameState(mode: .next(round)))
            }
            .store(in: &subscriptions)

        gameViewModel.userFeedback(isCorrect: true)
        gameViewModel.userFeedback(isCorrect: false)
        gameViewModel.userFeedback(isCorrect: false)

        waitForExpectations(timeout: 1)
    }
}

final class WordsGeneratorMock: WordsGenerator {
    func generate() -> WordsPair {
        .mock
    }
}

extension WordsPair {
    static var mock: WordsPair {
        .init(origin: "", translate: "", isCorrect: true)
    }
}
