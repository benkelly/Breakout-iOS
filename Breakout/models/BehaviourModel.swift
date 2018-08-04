//
//  BehaviourModel.swift
//  Breakout
//
//  Created by benjamin kelly on 28/03/2018.
//  Copyright © 2018 COMP41550_47390. All rights reserved.
//
import UIKit

protocol CollisionDelegate {
    func ballCollidedBrick(brickId: NSCopying) -> Void
    func ballOutOfBoundaries(ball: BallView) -> Void
}
struct Boundaries {
    static let left = "boundaryLeft"
    static let right = "boundaryRight"
    static let top = "boundaryTop"
    static let paddle = "paddle"
}

class BehaviourModel: UIDynamicBehavior, UICollisionBehaviorDelegate {
    
    var collisionDelegate: CollisionDelegate?
    
    lazy var gravityBehavior: UIGravityBehavior = {
        let gravityBehavior = UIGravityBehavior()
        gravityBehavior.gravityDirection = CGVector(dx: 0, dy: 0.4)
        return gravityBehavior
    }()
    
    private lazy var collider: UICollisionBehavior = {
        let collider = UICollisionBehavior()
        collider.translatesReferenceBoundsIntoBoundary = false
        collider.collisionDelegate = self
        collider.action = { [unowned self] in
            for item in collider.items {
                if let ball = item as? BallView {
                    if !(self.dynamicAnimator?.referenceView?.bounds)!.intersects(ball.frame) {
                        self.collisionDelegate?.ballOutOfBoundaries(ball: ball)
                    }
                }
            }
        }
        return collider
    }()
    
    lazy var itemBehavior: UIDynamicItemBehavior = {
        let itemBehaviour =  UIDynamicItemBehavior()
        itemBehaviour.allowsRotation = true
        itemBehaviour.resistance = 0
        itemBehaviour.friction = 0
        let defaults = UserDefaults.standard
        if let bounciness = (defaults.object(forKey: "bounciness") ?? 1) as? Float {
            itemBehaviour.elasticity = CGFloat(bounciness)
        }
        return itemBehaviour
    }()
    
    override init() {
        super.init()
        addChildBehavior(gravityBehavior)
        addChildBehavior(collider)
        addChildBehavior(itemBehavior)
    }
    
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        if (identifier != nil) {
            if identifier as? String == Boundaries.left {
                if itemBehavior.linearVelocity(for: item).x < 20 {
                    itemBehavior.addLinearVelocity(CGPoint(x: 10, y: -10), for: item)
                }
            } else if identifier as? String == Boundaries.right {
                if itemBehavior.linearVelocity(for: item).x > -20 {
                    itemBehavior.addLinearVelocity(CGPoint(x: -10, y: -10), for: item)
                }
            } else if identifier as? String == Boundaries.top {
                if itemBehavior.linearVelocity(for: item).y > -20 && itemBehavior.linearVelocity(for: item).y < 20 {
                    itemBehavior.addLinearVelocity(CGPoint(x: 0, y: 25), for: item)
                }
            } else if identifier as? String == Boundaries.paddle {
                if itemBehavior.linearVelocity(for: item).y > -20 && itemBehavior.linearVelocity(for: item).y < 20 {
                    itemBehavior.addLinearVelocity(CGPoint(x: 0, y: -40), for: item)
                }
            }
            collisionDelegate?.ballCollidedBrick(brickId: identifier!)
        }
    }
    
    func add(Ball ball: BallView) {
        dynamicAnimator?.referenceView?.addSubview(ball)
        collider.addItem(ball)
        itemBehavior.addItem(ball)
        itemBehavior.addLinearVelocity(CGPoint(x: Int(arc4random_uniform(400))-200,y: -400), for: ball)
        gravityBehavior.addItem(ball);
    }
    func remove(Ball ball: BallView) {
        ball.removeFromSuperview()
        itemBehavior.removeItem(ball)
        collider.removeItem(ball)
    }
    
    func add(Paddle paddle: PaddleView) {
        dynamicAnimator?.referenceView?.addSubview(paddle)
        collider.addBoundary(withIdentifier: Boundaries.paddle as NSCopying, for: paddle.collisionBoundingPath)
    }
    func remove(Paddle paddle: PaddleView) {
        paddle.removeFromSuperview()
        collider.removeBoundary(withIdentifier: Boundaries.paddle as NSCopying)
    }
    
    
    func add(Brick brick: BrickView, ID id: NSCopying) {
        dynamicAnimator?.referenceView?.addSubview(brick)
        collider.addBoundary(withIdentifier: id, for: brick.collisionBoundingPath)
    }
    func remove(Brick brick: BrickView, ID id: NSCopying) {
        collider.removeBoundary(withIdentifier: id)
        UIView.transition(with: brick, duration: 0.2,
                          options: .transitionCrossDissolve,
                          animations: {
                            brick.alpha = 0
        },
                          completion: { (success) -> Void in
                            brick.removeFromSuperview()
        }
        )
    }
    
    func getBoundary(frame: CGRect) {
        collider.removeBoundary(withIdentifier: Boundaries.left as NSCopying)
        collider.removeBoundary(withIdentifier: Boundaries.right as NSCopying)
        collider.removeBoundary(withIdentifier: Boundaries.top as NSCopying)
        
        
        collider.addBoundary(withIdentifier: Boundaries.left as NSCopying,
                             from: CGPoint(x: frame.origin.x, y: frame.origin.y + frame.height),
                             to: frame.origin)
        collider.addBoundary(withIdentifier: Boundaries.right as NSCopying,
                             from: frame.origin,
                             to: CGPoint(x: frame.origin.x + frame.width, y: frame.origin.y))
        collider.addBoundary(withIdentifier: Boundaries.top as NSCopying,
                             from: CGPoint(x: frame.origin.x + frame.width, y: frame.origin.y),
                             to: CGPoint(x: frame.origin.x + frame.width, y: frame.origin.y + frame.height))
    }
    
    func clear() {
        for item in collider.items {
            collider.removeItem(item)
        }
        for item in itemBehavior.items {
            itemBehavior.removeItem(item)
        }
        if let boundaries = collider.boundaryIdentifiers {
            for boundary in boundaries {
                collider.removeBoundary(withIdentifier: boundary)
            }
        }
    }
}

