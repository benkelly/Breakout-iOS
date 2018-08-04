//
//  SettingsVC.swift
//  Breakout
//
//  Created by benjamin kelly on 28/03/2018.
//  Copyright © 2018 COMP41550_47390. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {
    
    @IBOutlet weak var numberOfBallsControler: UISegmentedControl!
    @IBOutlet weak var numberOfBricksLabel: UILabel!
    @IBOutlet weak var numberofBricksControler: UIStepper!
    @IBOutlet weak var bouncinessControler: UISlider!
    @IBOutlet weak var paddleSizeControler: UISlider!
    @IBOutlet weak var resetHighScore: UIButton!
    
    @IBAction func numberOfBallsChanged(_ sender: UISegmentedControl) {
        let defaults = UserDefaults.standard
        defaults.set(Int(sender.titleForSegment(at: sender.selectedSegmentIndex)!), forKey: "balls")
    }
    
    @IBAction func numberofBricksControler(_ sender: UIStepper) {
        numberOfBricksLabel.text = Int(sender.value).description
        let defaults = UserDefaults.standard
        defaults.set(Int(sender.value), forKey: "bricks")
    }
    
    @IBAction func bouncinessChanged(_ sender: UISlider) {
        let defaults = UserDefaults.standard
        defaults.set(sender.value.roundToDecimal(2), forKey: "bounciness")
    }
    
    @IBAction func paddleSizeChanged(_ sender: UISlider) {
        let defaults = UserDefaults.standard
        defaults.set(sender.value, forKey: "paddleSize")
    }
    
    @IBAction func resetHighScorePressed(_ sender: UIButton) {
        let defaults = UserDefaults.standard
        defaults.set(0, forKey: "highScore")
    }
    
    override func viewDidLoad() {
        let defaults = UserDefaults.standard
        if let numBricks = defaults.object(forKey: "bricks") as? Int {
            numberofBricksControler.value = Double(numBricks);
            numberOfBricksLabel.text = numBricks.description
        }
        if let numBalls = defaults.object(forKey: "balls") as? Int {
            numberOfBallsControler.selectedSegmentIndex = numBalls-1
        }
        if let bounciness = defaults.object(forKey: "bounciness") as? Float {
            bouncinessControler.value = bounciness
        }
        if let size = defaults.object(forKey: "paddleSize") as? Float {
            paddleSizeControler.value = size
        }
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

