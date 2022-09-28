import Domain
import Foundation

public struct GameState: Equatable {
    
    public struct Round: Equatable {
        public let wordsPair: WordsPair
        public let timeForAnswer: TimeInterval
        public let totalFailures: Int
        public let totalRounds: Int
    }
    
    public enum Mode: Equatable {
        case next(Round)
        case gameOver(GameResult)
        case idle
    }
    
    public let mode: Mode
}
