//
//  Tag.swift
//  HLImageTag
//
//  Created by Nguyen Xuan Hieu on 6/12/18.
//  Copyright © 2018 Nguyen Xuan Hieu. All rights reserved.
//

import UIKit

class Tag: Decodable {
    var user: TaggableUser!
    var location: TagLocation!
    func generateTagViewWith(superView: UIView, delegate: HLTagViewDelegate)->TagView{
        let tagView = TagView.init(frame: CGRect(x: location.x, y: location.y, width: 0, height: 0))
        _ = tagView.becomeFirstResponder()
        tagView.delegate = delegate
        let point = CGPoint(x: location.x, y: location.y)
        tagView.presentPopoverFromPoint(point,inView: superView, permittedArrowDirections: UIPopoverArrowDirection.down, animated: true)
        tagView.setupUser(user)
        tagView.tag = user.id
        return tagView
    }
    init(user: TaggableUser, location: TagLocation) {
        self.user = user
        self.location = location
    }
}
