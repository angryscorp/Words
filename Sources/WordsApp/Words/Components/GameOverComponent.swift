import UIKit
import GameOverScene
import Domain

struct GameOverComponent {

    let parent: GameComponent
    
    func makeGameOver(gameResult: GameResult) {
        GameOverScene.create(
            presentViewController: { parent.parent.window.rootViewController = $0 },
            gameResult: gameResult,
            makeNewGame: makeNewGame,
            makeExit: { exit(0) }
        )
    }
    
    private func makeNewGame() {
        GameComponent(parent: parent.parent)
            .makeGame()
    }
}
