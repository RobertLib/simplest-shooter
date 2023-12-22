//
//  Player.swift
//  Simplest Shooter
//
//  Created by Robert Libšanský on 23.12.2023.
//

import SpriteKit

class Player: Entity {
    static let bitMask: UInt32 = 1

    fileprivate var circleNode: SKSpriteNode?
    fileprivate var damageNode: SKNode?

    private let SPEED = 400.0

    private var lastMovementTime: TimeInterval = 0
    private var lastPosition: CGPoint = .zero
    private var canShoot = true
    private var thrustsReady = false

    var startPos: CGPoint = .zero
    var isShooting = false
    var inTouch = false

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        circleNode = childNode(withName: "//Circle") as? SKSpriteNode
        damageNode = childNode(withName: "//Damage")

        startPos = position

        physicsBody?.categoryBitMask = Player.bitMask
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = Enemy.bitMask
    }

    private func flyOutFromBelow(waitForDuration: TimeInterval = 0) {
        isActive = false

        removeFires()

        removeAllActions()

        circleNode?.removeAllActions()
        circleNode?.alpha = 0
        circleNode?.setScale(0)

        let moveToBelow = SKAction.move(
            to: CGPoint(x: startPos.x, y: startPos.y - 225),
            duration: 0
        )

        let moveToStartPos = SKAction.move(to: startPos, duration: 0.5)
        moveToStartPos.timingMode = .easeInEaseOut

        let showReady = SKAction.run {
            if waitForDuration > 0 && (self.scene as? GameScene)?.isTransitionToNextLevel == false {
                (self.scene as? GameScene)?.readyLabel?.run(.fadeIn(withDuration: 0.2))
            }
        }

        let hideReady = SKAction.run {
            if waitForDuration > 0 && (self.scene as? GameScene)?.isTransitionToNextLevel == false {
                (self.scene as? GameScene)?.readyLabel?.run(.fadeOut(withDuration: 0.2))
            }
        }

        run(.sequence([
            moveToBelow,
            .fadeAlpha(to: 0.5, duration: 0),
            .wait(forDuration: waitForDuration / 4),
            showReady,
            .wait(forDuration: waitForDuration / 2),
            hideReady,
            .wait(forDuration: waitForDuration / 4),
            moveToStartPos,
            .wait(forDuration: 1),
            .fadeAlpha(to: 1, duration: 0.5)
        ])) {
            self.isActive = true
            self.canShoot = true
            self.lastMovementTime = NSDate().timeIntervalSince1970
        }
    }

    private func newFire(_ position: CGPoint) {
        guard let emitter = SKEmitterNode(fileNamed: "FireParticle.sks") else {
            return
        }

        emitter.name = "Fire"
        emitter.position = position
        emitter.targetNode = scene

        addChild(emitter)
    }

    private func removeFires() {
        enumerateChildNodes(withName: "Fire") { node, _ in
            node.removeFromParent()
        }
    }

    private func newThrust(_ position: CGPoint) {
        guard let emitter = SKEmitterNode(fileNamed: "ThrustParticle.sks") else {
            return
        }

        emitter.name = "Thrust"
        emitter.position = position
        emitter.targetNode = scene

        addChild(emitter)
    }

    private func shoot() {
        guard canShoot else { return }

        guard let scene = (scene as? GameScene) else { return }

        canShoot = false

        shotsFired += 1

        scene.addOverheatingValue(32.5)

        if let barrel = childNode(withName: "//Barrel") {
            let bullet = Bullet(convert(barrel.position, to: scene))

            scene.addChild(bullet)

            barrel.run(.sequence([
                .move(by: CGVector(dx: 0, dy: -10), duration: 0.05),
                .move(by: CGVector(dx: 0, dy: 10), duration: 0.05)
            ]))
        }

        let soundAction = SKAction.playSoundFileNamed(
            "LaserShootSound.wav",
            waitForCompletion: false
        )

        run(.sequence([
            soundAction,
            .move(by: CGVector(dx: 0, dy: -5), duration: 0.1),
            .move(by: CGVector(dx: 0, dy: 5), duration: 0.1)
        ])) {
            self.canShoot = true
        }
    }

    func takeDamage() {
        isActive = false

        if let damageNode = damageNode {
            for fireNode in damageNode.children {
                newFire(fireNode.position)
            }
        }

        run(.wait(forDuration: 1)) {
            if let explosion = SKEmitterNode(fileNamed: "ExplosionParticle") {
                explosion.position = self.position
                self.scene?.addChild(explosion)

                explosion.run(.sequence([.wait(forDuration: 1), .removeFromParent()])) {
                    (self.scene as? GameScene)?.takeLife()
                }
            }

            self.flyOutFromBelow(waitForDuration: 4)
        }
    }

    override func onCollision(_ node: SKNode?) {
        takeDamage()
    }

    func update() {
        if !thrustsReady {
            newThrust(CGPoint(x: -62, y: -32))
            newThrust(CGPoint(x: 62, y: -32))

            thrustsReady = true
        }

        guard isActive else { return }

        guard let scene = (scene as? GameScene) else { return }

        let currentTime = NSDate().timeIntervalSince1970

        if scene.leftPressed == true {
            position.x -= SPEED * scene.dt

            run(.scaleX(to: 0.9, duration: 0.5)) {
                self.run(.scaleX(to: 1, duration: 0.5))
            }
        }

        if scene.rightPressed == true {
            position.x += SPEED * scene.dt

            run(.scaleX(to: 0.9, duration: 0.5)) {
                self.run(.scaleX(to: 1, duration: 0.5))
            }
        }

        if scene.upPressed == true {
            position.y += SPEED * scene.dt

            run(.scaleY(to: 0.9, duration: 0.5)) {
                self.run(.scaleY(to: 1, duration: 0.5))
            }
        }

        if scene.downPressed == true {
            position.y -= SPEED * scene.dt

            run(.scaleY(to: 0.9, duration: 0.5)) {
                self.run(.scaleY(to: 1, duration: 0.5))
            }
        }

        #if os(OSX)
        isShooting = scene.actionPressed
        #endif

        if isShooting {
            shoot()

            scene.shakeWithOverheatingBar()
        }

#if os(iOS)
//        if let accelerometerData = motionManager.accelerometerData {
//            position.x += CGFloat(accelerometerData.acceleration.x * 50)
//        }
#endif

        if position.x < -SCREEN_WIDTH / 2 + size.width / 2 {
            position.x = -SCREEN_WIDTH / 2 + size.width / 2
        }

        if position.x > SCREEN_WIDTH / 2 - size.width / 2 {
            position.x = SCREEN_WIDTH / 2 - size.width / 2
        }

        if position.y < -SCREEN_HEIGHT / 2 + size.height / 2 {
            position.y = -SCREEN_HEIGHT / 2 + size.height / 2
        }

        if position.y > -size.height / 2 {
            position.y = -size.height / 2
        }

        #if os(iOS)
        if position != lastPosition {
            lastMovementTime = currentTime
            lastPosition = position

            if circleNode?.hasActions() == true {
                circleNode?.run(.group([
                    .fadeOut(withDuration: 0.5),
                    .scale(to: 0, duration: 0.5)
                ])) {
                    self.circleNode?.removeAllActions()
                }
            }
        } else if currentTime - lastMovementTime >= 3 {
            if circleNode?.hasActions() == false {
                circleNode?.run(.group([
                    .repeatForever(.rotate(byAngle: -.pi, duration: 10)),
                    .sequence([
                        .group([
                            .fadeIn(withDuration: 0.5),
                            .scale(to: 1, duration: 0.5)
                        ]),
                        .repeatForever(.sequence([
                            .scale(to: 1.2, duration: 0.1),
                            .scale(to: 1.0, duration: 0.1),
                            .wait(forDuration: 2)
                        ]))
                    ])
                ]))
            }
        }
        #endif
    }
}
