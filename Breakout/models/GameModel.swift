//
//  GameModel.swift
//  Breakout
//
//  Created by benjamin kelly on 28/03/2018.
//  Copyright © 2018 COMP41550_47390. All rights reserved.
//

import UIKit

class GameModel: NSObject {
    
    static func calculateScore(bricksLeft: Int) -> Int {
        let numBlocks = (UserDefaults.standard.object(forKey: "bricks") ?? 6) as? Int
        let hitBricks = Float(numBlocks! - bricksLeft)
        let score = Int(hitBricks * 10)
        let defaults = UserDefaults.standard
        let highScore = defaults.object(forKey: "highScore") as? Int ?? Int()
        if(score > highScore) {
            defaults.setValue(score, forKey: "highScore")
        }
        return score
    }
    
    static func getClosestBall(atPoint point: CGPoint, forBalls balls: [BallView]) -> BallView {
        var currentMinDist = max((balls[0].superview?.bounds.width)!, (balls[0].superview?.bounds.height)!)
        var currentMinBall = balls[0]
        for ball in balls {
            let dist = sqrt(pow(ball.center.x - point.x, 2) + pow(ball.center.y - point.y, 2))
            if dist < currentMinDist {
                currentMinDist = dist
                currentMinBall = ball
            }
        }
        return currentMinBall
    }
    
    
}
