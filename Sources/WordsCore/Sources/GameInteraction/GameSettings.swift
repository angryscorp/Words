import Foundation

public struct GameSettings {
    let totalRounds: Int
    let totalFailures: Int
    let timeLimitInSeconds: TimeInterval
}

public extension GameSettings {
    static var `default`: GameSettings {
        .init(
            totalRounds: 15,
            totalFailures: 3,
            timeLimitInSeconds: 5
        )
    }
}
