//
//  GameScene.swift
//  Simplest Shooter Shared
//
//  Created by Robert Libšanský on 22.12.2023.
//

import SpriteKit

#if os(OSX)
import Carbon.HIToolbox
#endif

class GameScene: SKScene, SKPhysicsContactDelegate {
    let OVERHEAT_THRESHOLD: CGFloat = 6.5

    fileprivate var player: Player?
    fileprivate var scoreLabel: SKLabelNode?
    fileprivate var livesLabel: SKLabelNode?
    fileprivate var levelLabel: SKLabelNode?

    private var backgroundMusic: SKAudioNode!
    private var lastUpdate: TimeInterval!

    var dt: TimeInterval = 0

    var readyLabel: SKLabelNode?
    var overheatingBar: SKShapeNode?
    var overheatingBarStartPos: CGPoint = .zero
    var overheatValue: CGFloat = .zero

    var leftPressed = false
    var rightPressed = false
    var upPressed = false
    var downPressed = false
    var actionPressed = false

    var isTransitionToNextLevel = false

    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }

        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFit

        return scene
    }

    private func goToSummaryScene() {
        let summaryScene = SummaryScene.newSummaryScene()
        let transition = SKTransition.fade(with: .black, duration: 1)

        view?.presentScene(summaryScene, transition: transition)
    }

    private func overheatingBarUpdate() {
        overheatingBar?.xScale = lerp(
            overheatingBar?.xScale ?? 0,
            overheatValue,
            dt
        )

        let red = lerp(
            overheatingBar?.fillColor.sRGBAComponents.red ?? 0,
            overheatValue / OVERHEAT_THRESHOLD,
            dt
        )

        let alpha = lerp(
            overheatingBar?.fillColor.sRGBAComponents.alpha ?? 0,
            overheatValue / OVERHEAT_THRESHOLD,
            dt
        )

        overheatingBar?.fillColor = SKColor(
            red: red,
            green: 0.4,
            blue: 0.4,
            alpha: alpha
        )

        if overheatValue > OVERHEAT_THRESHOLD {
            overheatValue = OVERHEAT_THRESHOLD

            player?.takeDamage()
        }

        if overheatValue > 0 {
            overheatValue -= dt
        }
    }

    func addOverheatingValue(_ value: CGFloat) {
        if overheatValue < OVERHEAT_THRESHOLD {
            overheatValue += dt * value
        }
    }

    func addScore(_ value: Int) {
        score += value

        scoreLabel?.text = "SCORE: \(score)"
    }

    func shakeWithOverheatingBar() {
        overheatingBar?.run(
            .move(
                to: CGPoint(
                    x: overheatingBarStartPos.x +
                        CGFloat.random(in: -overheatValue...overheatValue),
                    y: overheatingBarStartPos.y +
                        CGFloat.random(in: -overheatValue...overheatValue)
                ),
                duration: 0.1
            )
        )
    }

    func takeLife() {
        if lives > 1 {
            lives -= 1

            livesLabel?.text = "LIVES: \(lives)"
        } else {
            goToSummaryScene()
        }
    }

    func transitionToNextLevel() -> SKAction {
        self.isTransitionToNextLevel = true

        let showLabel = SKAction.run {
            level += 1

            self.levelLabel?.text = "LEVEL \(level)"
            self.levelLabel?.run(.fadeIn(withDuration: 0.2))
        }

        let hideLabel = SKAction.run {
            self.levelLabel?.run(.fadeOut(withDuration: 0.2)) {
                self.isTransitionToNextLevel = false
            }
        }

        return .sequence([
            showLabel,
            .wait(forDuration: 3),
            hideLabel
        ])
    }

    func setUpScene() {
        player = childNode(withName: "//Player") as? Player
        scoreLabel = childNode(withName: "//Score") as? SKLabelNode
        livesLabel = childNode(withName: "//Lives") as? SKLabelNode
        levelLabel = childNode(withName: "//Level") as? SKLabelNode
        readyLabel = childNode(withName: "//Ready") as? SKLabelNode
        overheatingBar = childNode(withName: "//Overheating") as? SKShapeNode

        score = 0
        lives = initLifeCount
        level = 0
        shotsFired = 0

        overheatingBar?.xScale = 0
        overheatingBarStartPos = overheatingBar?.position ?? .zero

        run(wavesOfEnemies(self)) {
            self.goToSummaryScene()
        }

        if let musicURL = Bundle.main.url(forResource: "GameSceneMusic", withExtension: "mp3") {
            backgroundMusic = SKAudioNode(url: musicURL)
            addChild(backgroundMusic)
        }
    }

    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self

#if os(iOS)
//        motionManager.startAccelerometerUpdates()
#endif

        setUpScene()
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered

        defer { lastUpdate = currentTime }

        guard lastUpdate != nil else {
            return
        }

        dt = currentTime - lastUpdate

        guard dt < 1 else {
            return
        }

        overheatingBarUpdate()

        player?.update()
    }

    func didBegin(_ contact: SKPhysicsContact) {
        if let nodeA = contact.bodyA.node {
            if nodeA is Entity {
                if (nodeA as? Entity)?.isActive == false {
                    return
                }

                (nodeA as? Entity)?.onCollision(contact.bodyB.node)
            }
        }

        if let nodeB = contact.bodyB.node {
            if nodeB is Entity {
                if (nodeB as? Entity)?.isActive == false {
                    return
                }

                (nodeB as? Entity)?.onCollision(contact.bodyA.node)
            }
        }
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if player?.isActive == true {
            player?.isShooting = true
        }

        for t in touches {
            let location = t.location(in: self)

            let nodeNames = nodes(at: location).map { node in
                node.name
            }

            if nodeNames.contains("Player") && location.y < 0 && player?.isActive == true {
                player?.inTouch = true

                player?.run(.group([
                    .scale(to: 1.1, duration: 0.5),
                    .move(to: location, duration: 0.2)
                ]))
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let location = t.location(in: self)

            if location.y < 0 && player?.isActive == true && player?.inTouch == true {
                player?.run(.move(to: location, duration: 0.1))
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        player?.isShooting = false
        player?.inTouch = false

        if player?.isActive == true {
            player?.run(.group([
                .scale(to: 1, duration: 0.5),
                .move(to: player?.startPos ?? CGPointZero, duration: 0.2)
            ]))
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {

    }


}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {

    override func mouseDown(with event: NSEvent) {

    }

    override func mouseDragged(with event: NSEvent) {

    }

    override func mouseUp(with event: NSEvent) {

    }

    override func keyDown(with event: NSEvent) {
        switch Int(event.keyCode) {
        case kVK_LeftArrow:
            leftPressed = true
        case kVK_RightArrow:
            rightPressed = true
        case kVK_UpArrow:
            upPressed = true
        case kVK_DownArrow:
            downPressed = true
        case kVK_Space:
            actionPressed = true
        default:
            break
        }
    }

    override func keyUp(with event: NSEvent) {
        switch Int(event.keyCode) {
        case kVK_LeftArrow:
            leftPressed = false
        case kVK_RightArrow:
            rightPressed = false
        case kVK_UpArrow:
            upPressed = false
        case kVK_DownArrow:
            downPressed = false
        case kVK_Space:
            actionPressed = false
        default:
            break
        }
    }

}
#endif

