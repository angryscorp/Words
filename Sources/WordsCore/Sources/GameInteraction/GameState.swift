import Domain
import Foundation

public struct GameState: Equatable {
    public let wordsPair: WordsPair
    public let totalFailures: Int
    public let totalRounds: Int
}
