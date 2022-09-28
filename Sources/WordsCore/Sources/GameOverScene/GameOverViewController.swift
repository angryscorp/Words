import Domain
import UIKit

final class GameOverViewController: UIViewController {
    
    private let titleLabel = UILabel()
    private let totalRoundsLabel = UILabel()
    private let totalFailuresLabel = UILabel()
    private let totalScoresLabel = UILabel()
    private let restartButton = UIButton(type: .system)
    private let exitButton = UIButton(type: .system)
    
    private let gameResult: GameResult
    private let makeNewGame: () -> Void
    private let makeExit: () -> Void
    
    init(
        gameResult: GameResult,
        makeNewGame: @escaping () -> Void,
        makeExit: @escaping () -> Void
    ) {
        self.gameResult = gameResult
        self.makeNewGame = makeNewGame
        self.makeExit = makeExit
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
    }
    
    private func setup() {
        view.backgroundColor = .systemBackground
        
        titleLabel.text = "Game Over"
        totalRoundsLabel.text = "Total rounds: \(gameResult.totalRounds)"
        totalFailuresLabel.text = "Total failures: \(gameResult.totalFailures)"
        totalScoresLabel.text = "Total scores: \(gameResult.totalScores)"
        
        titleLabel.font = .boldSystemFont(ofSize: 28)
        
        [totalRoundsLabel, totalFailuresLabel, totalScoresLabel].forEach { subview in
            subview.font = .systemFont(ofSize: 16)
        }
        
        restartButton.setTitle("New Game", for: .normal)
        exitButton.setTitle("Exit", for: .normal)
        
        [restartButton, exitButton].forEach { button in
            button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        }
        
        restartButton.addTarget(self, action: #selector(newGameTap), for: .touchUpInside)
        exitButton.addTarget(self, action: #selector(goHomeTap), for: .touchUpInside)
    }
    
    private func layout() {
        [titleLabel, totalRoundsLabel, totalFailuresLabel, totalScoresLabel, restartButton, exitButton].forEach { subview in
            view.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            totalRoundsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 48),
            totalFailuresLabel.topAnchor.constraint(equalTo: totalRoundsLabel.bottomAnchor, constant: 16),
            totalScoresLabel.topAnchor.constraint(equalTo: totalFailuresLabel.bottomAnchor, constant: 16),
            restartButton.topAnchor.constraint(equalTo: totalScoresLabel.bottomAnchor, constant: 48),
            exitButton.topAnchor.constraint(equalTo: restartButton.bottomAnchor, constant: 16)
        ] + [titleLabel, totalRoundsLabel, totalFailuresLabel, totalScoresLabel, restartButton, exitButton]
            .map { $0.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor) }
        )
    }

    @objc
    private func newGameTap() {
        makeNewGame()
    }

    @objc
    private func goHomeTap() {
        makeExit()
    }
}
