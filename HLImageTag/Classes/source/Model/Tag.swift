//
//  Tag.swift
//  HLImageTag
//
//  Created by Nguyen Xuan Hieu on 6/12/18.
//  Copyright © 2018 Nguyen Xuan Hieu. All rights reserved.
//

import UIKit

class Tag: Decodable {
    var id: String!
    var user: TaggableUser!
    var location: TagLocation!
    
    func generateTagViewWith(superView: UIView, delegate: HLTagViewDelegate, ratio: CGFloat, paddingTop: CGFloat = 0)->TagView{
        let tagView = TagView.init(frame: CGRect(x: location.x, y: location.y, width: 0, height: 0))
        _ = tagView.becomeFirstResponder()
        tagView.delegate = delegate
        tagView.tagId = self.id
        tagView.ratio = ratio
        
        //minimum slide x = 20px
        let locationX = max(min(location.x/ratio, superView.frame.size.width - 20), 20)
        //default height of tagview is 40, then all tags need to greater than 40
        let locationY = max(min(location.y/ratio - paddingTop, superView.frame.size.height), 40)
        
        let point = CGPoint(x: locationX, y: locationY)
        tagView.presentPopoverFromPoint(point,inView: superView, permittedArrowDirections: UIPopoverArrowDirection.down, animated: true)
        tagView.setupUser(user)
        return tagView
    }
    
    init(user: TaggableUser, location: TagLocation) {
        self.user = user
        self.location = location
    }
}
