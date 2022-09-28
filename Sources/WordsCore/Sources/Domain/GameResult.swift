public struct GameResult: Equatable {
    public let totalRounds: Int
    public let totalFailures: Int
    public var totalScores: Int { totalRounds - totalFailures }
    
    public init(totalRounds: Int, totalFailures: Int) {
        self.totalRounds = totalRounds
        self.totalFailures = totalFailures
    }
}
