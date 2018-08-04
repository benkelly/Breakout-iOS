//
//  PaddleView.swift
//  Breakout
//
//  Created by benjamin kelly on 28/03/2018.
//  Copyright © 2018 COMP41550_47390. All rights reserved.
//

import UIKit

class PaddleView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.random
        layer.cornerRadius = min(frame.size.width, frame.size.height) / 5
    }
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .path
    }
    override var collisionBoundingPath: UIBezierPath {
        return UIBezierPath(rect: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
