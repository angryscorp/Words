public struct WordsPair: Equatable {
    public let origin: String
    public let translate: String
    public let isCorrect: Bool

    public init(origin: String, translate: String, isCorrect: Bool) {
        self.origin = origin
        self.translate = translate
        self.isCorrect = isCorrect
    }
}
