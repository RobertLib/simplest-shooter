//
//  Bullet.swift
//  Simplest Shooter
//
//  Created by Robert Libšanský on 23.12.2023.
//

import SpriteKit

class Bullet: Entity {
    static let bitMask: UInt32 = 1 << 1

    convenience init(_ position: CGPoint) {
        self.init(color: .white, size: CGSize(width: 5, height: 20))

        name = "Bullet"

        self.position = position

        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = Bullet.bitMask
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = Enemy.bitMask

        let move = SKAction.move(to: CGPoint(x: position.x, y: SCREEN_HEIGHT / 2), duration: 0.5)
        let sequence = SKAction.sequence([move, .removeFromParent()])

        run(sequence)
    }

    override func onCollision(_ node: SKNode?) {
        removeFromParent()
    }
}
