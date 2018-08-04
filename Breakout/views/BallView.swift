//
//  BallView.swift
//  Breakout
//
//  Created by benjamin kelly on 28/03/2018.
//  Copyright © 2018 COMP41550_47390. All rights reserved.
//

import UIKit

class BallView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.random
        layer.cornerRadius = frame.size.width / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .ellipse
    }
}
