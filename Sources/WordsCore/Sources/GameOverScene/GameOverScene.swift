import Domain
import UIKit

public enum GameOverScene {
    public static func create(
        presentViewController: (UIViewController) -> Void,
        gameResult: GameResult,
        makeNewGame: @escaping () -> Void,
        makeExit: @escaping () -> Void
    ) {
        let vc = GameOverViewController(
            gameResult: gameResult,
            makeNewGame: makeNewGame,
            makeExit: makeExit
        )
        presentViewController(vc)
    }
}
