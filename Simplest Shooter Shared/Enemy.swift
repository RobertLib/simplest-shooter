//
//  Enemy.swift
//  Simplest Shooter
//
//  Created by Robert Libšanský on 24.12.2023.
//

import SpriteKit
import AudioToolbox

enum EnemyState {
    case straightDown
}

class Enemy: Entity {
    static let bitMask: UInt32 = 1 << 2

    private var state: EnemyState!

    convenience init(position: CGPoint, state: EnemyState) {
        self.init(imageNamed: "asteroid")

        name = "Enemy"

        self.position = position
        self.size = CGSize(width: 75, height: 75)

        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = Enemy.bitMask
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = Bullet.bitMask | Player.bitMask

        self.state = state

        let motionBlurShader = SKShader(fileNamed: "MotionBlurShader.fsh")
        shader = motionBlurShader

        switch state {
        case .straightDown:
            let move = SKAction.move(
                to: CGPoint(x: position.x, y: -SCREEN_HEIGHT / 2),
                duration: 4
            )

            let sequence = SKAction.sequence([move, .removeFromParent()])

            let group = SKAction.group([
                .rotate(byAngle: CGFloat.random(in: -.pi * 4...(.pi * 4)), duration: 10),
                sequence
            ])

            run(group)
        }
    }

    override func onCollision(_ node: SKNode?) {
        (scene as? GameScene)?.addScore(100)

        if let explosion = SKEmitterNode(fileNamed: "ExplosionParticle") {
            explosion.position = position
            scene?.addChild(explosion)

            explosion.run(.sequence([.wait(forDuration: 1), .removeFromParent()]))
        }

        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))

        removeFromParent()
    }
}
