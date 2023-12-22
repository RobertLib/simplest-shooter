//
//  WavesOfEnemies.swift
//  Simplest Shooter
//
//  Created by Robert Libšanský on 30.12.2023.
//

import SpriteKit

func enemyStraightDownWave(_ scene: GameScene, x: CGFloat, count: Int) -> SKAction {
    let enemyRun = SKAction.run() {
        let enemy = Enemy(
            position: CGPoint(x: x, y: SCREEN_HEIGHT / 2),
            state: .straightDown
        )

        scene.addChild(enemy)
    }

    return .repeat(.sequence([enemyRun, .wait(forDuration: 0.5)]), count: count)
}

func wavesOfEnemies(_ scene: GameScene) -> SKAction {
    .sequence([
        .wait(forDuration: 1),
        scene.transitionToNextLevel(),
        .wait(forDuration: 1),
        enemyStraightDownWave(scene, x: -SCREEN_WIDTH / 4, count: 2),
        .wait(forDuration: 2),
        enemyStraightDownWave(scene, x: -SCREEN_WIDTH / 4, count: 2),
        .wait(forDuration: 3),
        enemyStraightDownWave(scene, x: SCREEN_WIDTH / 4, count: 2),
        .wait(forDuration: 2),
        enemyStraightDownWave(scene, x: SCREEN_WIDTH / 4, count: 2),
        .wait(forDuration: 3),
        enemyStraightDownWave(scene, x: 0, count: 2),
        .wait(forDuration: 2),
        enemyStraightDownWave(scene, x: 0, count: 2),
        .wait(forDuration: 4),
        scene.transitionToNextLevel(),
        .wait(forDuration: 1),
        enemyStraightDownWave(scene, x: -SCREEN_WIDTH / 4, count: 3),
        .wait(forDuration: 2),
        enemyStraightDownWave(scene, x: -SCREEN_WIDTH / 4, count: 3),
        .wait(forDuration: 3),
        enemyStraightDownWave(scene, x: SCREEN_WIDTH / 4, count: 3),
        .wait(forDuration: 2),
        enemyStraightDownWave(scene, x: SCREEN_WIDTH / 4, count: 3),
        .wait(forDuration: 3),
        enemyStraightDownWave(scene, x: 0, count: 3),
        .wait(forDuration: 2),
        enemyStraightDownWave(scene, x: 0, count: 3),
        .wait(forDuration: 4),
        scene.transitionToNextLevel(),
        .wait(forDuration: 1),
        enemyStraightDownWave(scene, x: -SCREEN_WIDTH / 4, count: 4),
        .wait(forDuration: 2),
        enemyStraightDownWave(scene, x: -SCREEN_WIDTH / 4, count: 4),
        .wait(forDuration: 3),
        enemyStraightDownWave(scene, x: SCREEN_WIDTH / 4, count: 4),
        .wait(forDuration: 2),
        enemyStraightDownWave(scene, x: SCREEN_WIDTH / 4, count: 4),
        .wait(forDuration: 3),
        enemyStraightDownWave(scene, x: 0, count: 4),
        .wait(forDuration: 2),
        enemyStraightDownWave(scene, x: 0, count: 4),
        .wait(forDuration: 4)
    ])
}
