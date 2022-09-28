import Domain
import Foundation

public struct GameState: Equatable {
    
    public enum Mode: Equatable {
        case next(WordsPair)
        case gameOver
    }
    
    public let mode: Mode
    public let totalFailures: Int
    public let totalRounds: Int
}
