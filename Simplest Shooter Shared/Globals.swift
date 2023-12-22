//
//  Globals.swift
//  Simplest Shooter
//
//  Created by Robert Libšanský on 25.12.2023.
//

import Foundation

#if os(iOS)
//import CoreMotion
//
//let motionManager = CMMotionManager()
#endif

let SCREEN_WIDTH = 750.0
let SCREEN_HEIGHT = 1334.0

var score = 0 {
    didSet {
        if score > highScore {
            highScore = score
        }
    }
}

var highScore = UserDefaults.standard.integer(forKey: "highScore") {
    didSet {
        UserDefaults.standard.setValue(highScore, forKey: "highScore")
    }
}

let initLifeCount = 3

var lives = initLifeCount
var level = 0
var shotsFired = 0

func lerp(_ start: CGFloat, _ end: CGFloat, _ t: CGFloat) -> CGFloat {
    return start + (end - start) * t
}
