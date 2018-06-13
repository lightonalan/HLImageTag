//
//  TagLocation.swift
//  HLImageTag
//
//  Created by Nguyen Xuan Hieu on 6/12/18.
//  Copyright © 2018 Nguyen Xuan Hieu. All rights reserved.
//

import UIKit

class TagLocation: Decodable {

    /// The value of the x-axis.
    var x: CGFloat!
    
    /// The value of the y-axis.
    var y: CGFloat!
    init(point: CGPoint) {
        self.x = point.x
        self.y = point.y
    }
}
