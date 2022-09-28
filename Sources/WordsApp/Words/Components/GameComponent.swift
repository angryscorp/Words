import UIKit
import GameScene
import WordsGenerator
import WordsGeneratorImpl
import Domain

struct GameComponent {

    let parent: RootComponent
    let wordsGenerator: WordsGenerator = WordsGeneratorImpl()
    
    func makeGame() {
        GameScene.create(
            presentViewController: { parent.window.rootViewController = $0 },
            wordsGenerator: wordsGenerator,
            makeGameOver: makeGameOver
        )
    }
    
    private func makeGameOver() {
        exit(0)
    }
}
