//
//  SummaryScene.swift
//  Simplest Shooter
//
//  Created by Robert Libšanský on 24.12.2023.
//

import SpriteKit

#if os(OSX)
import Carbon.HIToolbox
#endif

class SummaryScene: SKScene {
    fileprivate var scoreLabel: SKLabelNode?
    fileprivate var highScoreLabel: SKLabelNode?
    fileprivate var levelLabel: SKLabelNode?
    fileprivate var shotsFiredLabel: SKLabelNode?

    private var backgroundMusic: SKAudioNode!

    class func newSummaryScene() -> SummaryScene {
        // Load 'SummaryScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "SummaryScene") as? SummaryScene else {
            print("Failed to load SummaryScene.sks")
            abort()
        }

        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFit

        return scene
    }

    private func goToOpeningScene() {
        let openingScene = OpeningScene.newOpeningScene()
        let transition = SKTransition.fade(with: .black, duration: 1)

        view?.presentScene(openingScene, transition: transition)
    }

    func setUpScene() {
        scoreLabel = childNode(withName: "//Score") as? SKLabelNode
        highScoreLabel = childNode(withName: "//HighScore") as? SKLabelNode
        levelLabel = childNode(withName: "//Level") as? SKLabelNode
        shotsFiredLabel = childNode(withName: "//ShotsFired") as? SKLabelNode

        scoreLabel?.text = "SCORE: \(score)"
        highScoreLabel?.text = "HIGH SCORE: \(highScore)"
        levelLabel?.text = "LEVEL: \(level)"
        shotsFiredLabel?.text = "SHOTS FIRED: \(shotsFired)"

        if let musicURL = Bundle.main.url(forResource: "SummaryMusic", withExtension: "mp3") {
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
extension SummaryScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        goToOpeningScene()
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
extension SummaryScene {

    override func mouseDown(with event: NSEvent) {

    }

    override func mouseDragged(with event: NSEvent) {

    }

    override func mouseUp(with event: NSEvent) {

    }

    override func keyDown(with event: NSEvent) {
        switch Int(event.keyCode) {
        case kVK_Space, kVK_Return:
            goToOpeningScene()
        default:
            break
        }
    }

    override func keyUp(with event: NSEvent) {

    }

}
#endif

