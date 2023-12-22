//
//  OpeningScene.swift
//  Simplest Shooter
//
//  Created by Robert Libšanský on 23.12.2023.
//

import SpriteKit

#if os(OSX)
import Carbon.HIToolbox
#endif

class OpeningScene: SKScene {
    fileprivate var start: SKSpriteNode?

    private var backgroundMusic: SKAudioNode!

    class func newOpeningScene() -> OpeningScene {
        // Load 'OpeningScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "OpeningScene") as? OpeningScene else {
            print("Failed to load OpeningScene.sks")
            abort()
        }

        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFit

        return scene
    }

    private func goToGameScene() {
        let gameScene = GameScene.newGameScene()
        let transition = SKTransition.fade(with: .black, duration: 1)

        view?.presentScene(gameScene, transition: transition)
    }

    func setUpScene() {
        start = childNode(withName: "//Start") as? SKSpriteNode

        if let musicURL = Bundle.main.url(forResource: "OpeningMusic", withExtension: "mp3") {
            backgroundMusic = SKAudioNode(url: musicURL)
            addChild(backgroundMusic)
        }
    }

    override func didMove(to view: SKView) {
        setUpScene()
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension OpeningScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let location = t.location(in: self)
            guard let node = nodes(at: location).first else { return }

            if node.name == "Start" {
                start?.run(.init(named: "Bounce")!) {
                    self.goToGameScene()
                }
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {

    }


}
#endif

#if os(OSX)
// Mouse-based event handling
extension OpeningScene {

    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        guard let node = nodes(at: location).first else { return }

        if node.name == "Start" {
            start?.run(.init(named: "Bounce")!) {
                self.goToGameScene()
            }
        }
    }

    override func mouseDragged(with event: NSEvent) {

    }

    override func mouseUp(with event: NSEvent) {

    }

    override func keyDown(with event: NSEvent) {
        switch Int(event.keyCode) {
        case kVK_Space, kVK_Return:
            goToGameScene()
        default:
            break
        }
    }

    override func keyUp(with event: NSEvent) {

    }

}
#endif

