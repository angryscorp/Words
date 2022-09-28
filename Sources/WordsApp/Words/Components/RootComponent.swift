import UIKit

struct RootComponent {
    
    let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func makeRoot() {
        GameComponent(parent: self).makeGame()
        window.makeKeyAndVisible()
    }
}
