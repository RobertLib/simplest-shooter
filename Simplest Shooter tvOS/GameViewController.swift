//
//  GameViewController.swift
//  Simplest Shooter tvOS
//
//  Created by Robert Libšanský on 22.12.2023.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = OpeningScene.newOpeningScene()
        
        // Present the scene
        let skView = self.view as! SKView
        skView.presentScene(scene)
        
        skView.ignoresSiblingOrder = true
        
        #if DEBUG
        skView.showsFPS = true
        skView.showsNodeCount = true
        #endif
    }

}
