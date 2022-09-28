import Combine
import Domain
import GameInteraction
import UIKit

final class GameViewController: UIViewController {
    
    private let totalAttempts = UILabel()
    private let totalFailures = UILabel()
    private let originLabel = UILabel()
    private let translateLabel = UILabel()
    private let translateIsCorrectButton = UIButton(type: .system)
    private let translateIsWrongButton = UIButton(type: .system)
    
    private let makeGameOver: (GameResult) -> Void
    private var subscriptions = Set<AnyCancellable>()
    private var viewModel: GameViewModel?
    private var translateLabelConstraint: NSLayoutConstraint?
    
    init(makeGameOver: @escaping (GameResult) -> Void) {
        self.makeGameOver = makeGameOver
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(_ state: AnyPublisher<GameState, Never>, viewModel: GameViewModel) {
        self.viewModel = viewModel
        
        state
            .sink { [weak self] state in
                switch state.mode {
                case let .next(round):
                    self?.handleRound(round)

                case let .gameOver(gameResult):
                    self?.makeGameOver(gameResult)
                    
                case .idle:
                    break
                }
            }
            .store(in: &subscriptions)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.start()
    }
    
    private func setup() {
        view.backgroundColor = .systemBackground
        
        [totalAttempts, totalFailures].forEach { label in
            label.textAlignment = .right
            label.font = .boldSystemFont(ofSize: 12)
        }
        
        [translateLabel, originLabel].forEach { label in
            label.textAlignment = .center
            label.numberOfLines = 0
        }
        
        translateLabel.font = .boldSystemFont(ofSize: 24)
        originLabel.font = .systemFont(ofSize: 18)
        
        translateIsCorrectButton.setTitle("Correct", for: .normal)
        translateIsWrongButton.setTitle("Wrong", for: .normal)
        
        translateIsCorrectButton.addTarget(self, action: #selector(translateIsCorrectTap), for: .touchUpInside)
        translateIsWrongButton.addTarget(self, action: #selector(translateIsWrongTap), for: .touchUpInside)
        
        [translateIsCorrectButton, translateIsWrongButton].forEach { button in
            button.backgroundColor = .systemBlue
            button.layer.cornerRadius = 8
            button.setTitleColor(.black, for: .normal)
        }
    }
    
    private func layout() {
        [totalAttempts, totalFailures, originLabel, translateLabel, translateIsCorrectButton, translateIsWrongButton].forEach { subview in
            subview.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subview)
        }
        
        translateLabelConstraint = translateLabel.bottomAnchor.constraint(equalTo: originLabel.topAnchor, constant: -32)
        translateLabelConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            totalAttempts.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            totalAttempts.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            totalFailures.topAnchor.constraint(equalTo: totalAttempts.bottomAnchor, constant: 8),
            totalFailures.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            translateLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            translateLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            translateLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            originLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            originLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            originLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            originLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            translateIsCorrectButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            translateIsWrongButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            translateIsCorrectButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            translateIsWrongButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            translateIsCorrectButton.rightAnchor.constraint(equalTo: translateIsWrongButton.leftAnchor, constant: -16),
            translateIsCorrectButton.widthAnchor.constraint(equalTo: translateIsWrongButton.widthAnchor),
            translateIsCorrectButton.heightAnchor.constraint(equalTo: translateIsCorrectButton.widthAnchor, multiplier: 0.4),
            translateIsCorrectButton.heightAnchor.constraint(equalTo: translateIsWrongButton.heightAnchor)
        ])
    }
    
    private func handleRound(_ round: GameState.Round) {
        originLabel.text = round.wordsPair.origin
        translateLabel.text = round.wordsPair.translate
        totalAttempts.text = "Correct attemts: \(round.totalRounds - round.totalFailures)"
        totalFailures.text = "Wrong attemts: \(round.totalFailures)"

        translateLabelConstraint?.constant -= translateLabel.frame.maxY
        translateLabel.layer.removeAllAnimations()
        view.layoutIfNeeded()

        translateLabelConstraint?.constant = -32
        UIView.animate(withDuration: round.timeForAnswer, delay: 0, options: [.curveEaseIn]) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    private func translateIsCorrectTap() {
        viewModel?.userFeedback(isCorrect: true)
    }
    
    @objc
    private func translateIsWrongTap() {
        viewModel?.userFeedback(isCorrect: false)
    }
}
