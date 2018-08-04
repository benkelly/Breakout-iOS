//
//  ViewController.swift
//  Breakout
//
//  Created by benjamin kelly on 28/03/2018.
//  Copyright © 2018 COMP41550_47390. All rights reserved.
//

import UIKit

class BreakoutGameVC: UIViewController, UIDynamicAnimatorDelegate, CollisionDelegate, UIAlertViewDelegate {
    @IBOutlet weak var scoreNumLable: UILabel!
    @IBOutlet weak var highScoreNumLabel: UILabel!
    @IBOutlet weak var gameView: UIView!
    
    private var paddle: PaddleView?
    private var startTime: NSDate? //
    private var bricks = [Int: BrickView]()
    private var balls = [BallView]()
    
    private lazy var behavior: BehaviourModel = {
        var behavior = BehaviourModel()
        behavior.collisionDelegate = self
        return behavior
    }()
    
    @IBAction func panGest(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        var cordX = paddle!.center.x + translation.x
        let halfPaddleWidth = paddle!.bounds.width / 2
        if cordX - halfPaddleWidth < gameView.bounds.origin.x {
            cordX = gameView.bounds.origin.x + halfPaddleWidth
        } else if cordX + halfPaddleWidth > gameView.bounds.width {
            cordX = gameView.bounds.width - halfPaddleWidth
        }
        paddle!.center = CGPoint(x:cordX, y:paddle!.center.y)
        behavior.remove(Paddle: paddle!)
        behavior.add(Paddle: paddle!)
        sender.setTranslation(CGPoint(), in: self.view)
    }
    
    @IBAction func tapGest(_ sender: UITapGestureRecognizer) {
        let closeBall = GameModel.getClosestBall(atPoint: sender.location(in: gameView), forBalls: balls)
        behavior.itemBehavior.addLinearVelocity(CGPoint(x: Int(arc4random_uniform(400))-200, y: -150), for: closeBall)
    }
    
    private lazy var animator: UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: self.gameView)
        animator.addBehavior(self.behavior)
        return animator
    }()
    
    private var brickHeight: CGFloat = 20
    private var brickWidth: CGFloat {
        get {
            return self.gameView.bounds.width/5;
        }
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        refresh()
    }
    
    func clear() {
        paddle = nil
        behavior.clear()
        for view in gameView.subviews {
            view.removeFromSuperview()
        }
        bricks.removeAll()
        balls.removeAll()
        startTime = nil
    }
    func refresh() {
        clear()
        behavior.getBoundary(frame: gameView.bounds)
        let defaults = UserDefaults.standard
        let highScore = defaults.object(forKey: "highScore") as? Int ?? Int()
        scoreNumLable.text = String(00)
        highScoreNumLabel.text = String(highScore)
        
        if let bounciness = (defaults.object(forKey: "bounciness") ?? 1) as? Float {
            behavior.itemBehavior.elasticity = CGFloat(bounciness)
        }
        addbricks()
        addPaddle()
        addBalls()
        startTime = NSDate();
    }

    func addbricks() {
        let defaults = UserDefaults.standard
        if let numbricks = (defaults.object(forKey: "bricks") ?? 25) as? Int {
            let numRows = numbricks / 5;
            for j in 0..<numRows {
                for i in 0...4 {
                    var frame = CGRect()
                    frame.origin = CGPoint(x: CGFloat(i) * brickWidth, y: CGFloat(j) * brickHeight)
                    frame.size = CGSize(width: brickWidth - 1, height: brickHeight - 1)
                    let brick = BrickView(frame: frame)
                    let id = bricks.count
                    bricks[id]=brick
                    behavior.add(Brick: brick, ID: id as NSCopying)
                }
            }
        }
    }
    
    func addBalls() {
        let ballWidth = gameView.bounds.width / 40;
        let ballHeight = ballWidth;
        let defaults = UserDefaults.standard
        if let numBalls = (defaults.object(forKey: "balls") ?? 2) as? Int {
            for _ in 1...numBalls {
                var frame = CGRect()
                frame.origin = CGPoint(x: gameView.center.x, y: gameView.center.y)
                frame.size = CGSize(width: ballWidth, height: ballHeight)
                let ball = BallView(frame: frame)
                balls.append(ball)
                behavior.add(Ball: ball)
            }
        }
    }
    
    func addPaddle() {
        let defaults = UserDefaults.standard
        let paddleDiv: CGFloat = CGFloat(((defaults.object(forKey: "paddleSize") ?? 0.25) as? CGFloat)!)
        let paddleWidth: CGFloat = gameView.bounds.width * paddleDiv
        let paddleHeight = CGFloat(10)
        var frame = CGRect()
        frame.origin = CGPoint(x: gameView.center.x - (paddleWidth / 2), y: gameView.bounds.height - paddleHeight)
        frame.size = CGSize(width: paddleWidth, height: paddleHeight)
        paddle = PaddleView(frame: frame)
        behavior.add(Paddle: paddle!)
    }
    
    func ballCollidedBrick(brickId: NSCopying) {
        if let id = brickId as? Int {
            if id >= 0 && bricks.keys.contains(id) {
                behavior.remove(Brick: bricks[id]!, ID: id as NSCopying)
                bricks.removeValue(forKey: id)
            }
            scoreNumLable.text = String(GameModel.calculateScore(bricksLeft: bricks.count))
            let defaults = UserDefaults.standard
            let highScore = defaults.object(forKey: "highScore") as? Int ?? Int()
            highScoreNumLabel.text = String(highScore)
            if bricks.count == 0 {
                let alert = UIAlertController(title: "You Win", message: "Level Clear!!\nScore: \(GameModel.calculateScore(bricksLeft: bricks.count)) \nTime: \(NSDate().timeIntervalSince(startTime! as Date).rounded()) Seconds", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "New Game", style: UIAlertActionStyle.default, handler: reactToAlert))
                self.present(alert, animated: true) {}
                alert.addAction(UIAlertAction(title:"Settings", style: .default, handler:{ action in self.performSegue(withIdentifier: "breakoutToTVC", sender: self) }))
            }
        }
    }
    func ballOutOfBoundaries(ball: BallView) {
        behavior.remove(Ball: ball)
        if let index = balls.index(of: ball) {
            balls.remove(at: index)
        }
        if balls.count == 0 {
            let alert = UIAlertController(title: "Game Over", message: "No balls left... \nScore: \(GameModel.calculateScore(bricksLeft: bricks.count)) \nTime: \(NSDate().timeIntervalSince(startTime! as Date).rounded()) Seconds", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "New Game", style: UIAlertActionStyle.default, handler: reactToAlert))
            self.present(alert, animated: true) {}
            alert.addAction(UIAlertAction(title:"Settings", style: .default, handler:{ action in self.performSegue(withIdentifier: "breakoutToTVC", sender: self) }))
        }
    }
    func reactToAlert (action: UIAlertAction) {
        refresh()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        self.refresh()
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.clear()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

