import UIKit
import Domain
import WordsGenerator
import GameInteraction

public enum GameScene {
    public static func create(
        presentViewController: (UIViewController) -> Void,
        wordsGenerator: WordsGenerator
    ) {
        let viewModel = GameViewModel(wordsGenerator: wordsGenerator)
        
        let vc = GameViewController()
        vc.bind(viewModel.state, viewModel: viewModel)
        
        presentViewController(vc)
    }
}
