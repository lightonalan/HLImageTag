//
//  UIImage+Tag.swift
//  HLImageTag
//
//  Created by Nguyen Xuan Hieu on 6/12/18.
//  Copyright © 2018 Nguyen Xuan Hieu. All rights reserved.
//

import UIKit
protocol UIImage_TagDelegate {
    func didStartTagAtPoint(_ point: CGPoint)
    func gotoUserInfo(_ userId: String)
    func setupTag()
    func removeTag(_ tag : Tag)
    func onShowHideTags()
}
class UIImage_Tag: UIImageView {
    var tagList = [Tag]()
    var tagViews = [TagView]()
    var realImage: UIImage!
    fileprivate var isAddingTag = false
    var isUserTagEnabled: Bool! = true
    var delegate: UIImage_TagDelegate!
    
    override func awakeFromNib() {
        //enable tap to tag
        isUserInteractionEnabled = true
        clipsToBounds = true
        layer.masksToBounds = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapImage(_:))))
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        //enable tap to tag
        isUserInteractionEnabled = true
        clipsToBounds = true
        layer.masksToBounds = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapImage(_:))))
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //user tap into image action
    @objc func didTapImage(_ gesture: UIGestureRecognizer) {
        //if image is showing and not allowed to add tag, then make an action to show or hide tagged user
        if isUserTagEnabled == false {
            if realImage != nil {
                delegate.onShowHideTags()
            }
            return
        }
        //tags is adding into image
        isAddingTag = true
        let point = gesture.location(in: self)
        delegate.didStartTagAtPoint(point)
    }
    
    //add all tagged users
    func insertAllTagView(_ isFirstImage: Bool = false, ratio: CGFloat){
        removeAllTagView()
        tagViews.removeAll()
        if isFirstImage && tagList.count == 0{
            tagViews.append(generateFirstTagViewWith())
        }
        for tag in tagList{
            if tag.user.id != nil{
                
                //generate tag view also enable to drag tags
                let tagView = tag.generateTagViewWith(superView: self, delegate: self, ratio: ratio, paddingTop: heighPhoto())
                
                let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(_:)))
                tagView.addGestureRecognizer(gesture)
                 //check tags overlap with superview after add
                tagView.checkOverlapWithSuperView()
                tagViews.append(tagView)
                
                //check tags overlap with others after add
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    for subview in self.tagViews{
                        if subview.tagUser.id != tagView.tagUser.id{
                            tagView.checkOverlapWith(subview)
                        }else{
                            break
                        }
                    }
                }
            }
        }
    }
    
    func heighPhoto() -> CGFloat {
        if realImage == nil{
            return 0
        }
        let width = realImage.size.width
        let height = realImage.size.height
        let ratio = CGFloat(height)/CGFloat(width)
        let realHeight = bounds.size.width * ratio
        return (realHeight - self.bounds.size.height)/2
    }
    
    //remove all tagview (hide tags)
    func removeAllTagView(){
        for t in tagViews{
            removeTagView(t)
        }
        tagViews.removeAll()
    }
    
    //remove first tagview (showed when no user tagged)
    func removeFirstTagView(){
        if let t = tagViews.first{
            if t.tagUser.fullName == "Tap to tag"{
                t.removeFromSuperview()
                tagViews.removeFirst()
            }
        }
        if let t = tagList.first{
            if t.user.fullName == "Tap to tag"{
                tagList.removeFirst()
            }
        }
    }
    
    //call update tag user after select user
    func updateTagUser(_ tag: Tag, ratio: CGFloat){
        removeFirstTagView()
        if tag.user.id != ""{
            tag.id = tag.user.id
            tagList.append(tag)
            let tagView = tag.generateTagViewWith(superView: self, delegate: self, ratio: ratio)
            let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(_:)))
            tagView.addGestureRecognizer(gesture)
            tagViews.append(tagView)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                for subview in self.tagViews{
                    if subview.tagUser.id != tagView.tagUser.id{
                        tagView.checkOverlapWith(subview)
                    }else{
                        break
                    }
                }
            }
            
        }
    }
    
    //drag action
    @objc func wasDragged(_ gesture: UIPanGestureRecognizer) {
        if isUserTagEnabled == false{
            return
        }
        if let tagView = gesture.view as? TagView{
            self.bringSubview(toFront: tagView)
            tagView.reset()
            for t in tagList{
                if t.user.id == tagView.tagUser.id{
                    let translation = gesture.translation(in: self)
                    if tagView.center.x + translation.x + 15 < frame.size.width &&
                        tagView.center.y + translation.y + tagView.frame.size.height < frame.size.height &&
                        tagView.center.x + translation.x - 15 > 0 &&
                        tagView.center.y + translation.y > 0 {
                        tagView.center = CGPoint(x: tagView.center.x + translation.x, y: tagView.center.y + translation.y)
                        gesture.setTranslation(CGPoint.zero, in: self)
                    }

                    if gesture.state == .began{
                        //reset all overlaped tags
                        for subview in tagViews{
                            if subview.tagUser.id != tagView.tagUser.id && tagView.overlapTag.contains(subview.tagUser.id) && subview.isSuperviewOverlapped == false{
                                subview.reset()
                                subview.setNeedsDisplay()
                            }
                        }
                        tagView.overlapTag.removeAll()
                        tagView.reset()
                        //zoom in tag view
                        UIView.animate(withDuration: 0.2, animations: {
                            tagView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                        }, completion: nil)
                    }else if gesture.state == .ended{
                        //zoom out tag view
                        UIView.animate(withDuration: 0.2, animations: {
                            tagView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        }) { (success) in
                            //check tags overlap with others
                            t.location = tagView.convertToLocation()
                            for subview in self.tagViews{
                                if subview.tagUser.id != tagView.tagUser.id{
                                    tagView.checkOverlapWith(subview)
                                }
                            }
                            //check tags overlap with superview
                            tagView.checkOverlapWithSuperView()
                            self.delegate.setupTag()
                        }
                    }
                    return
                }
            }
        }
       
    }
    
    //get new image size depend on devices
    func imageSizeAspectFit() -> CGSize {
        var newwidth: CGFloat
        var newheight: CGFloat
        let image: UIImage = self.image!
        
        if image.size.height >= image.size.width {
            newheight = self.frame.size.height;
            newwidth = (image.size.width / image.size.height) * newheight
            if newwidth > self.frame.size.width {
                let diff: CGFloat = self.frame.size.width - newwidth
                newheight = newheight + diff / newheight * newheight
                newwidth = self.frame.size.width
            }
        }
        else {
            newwidth = self.frame.size.width
            newheight = (image.size.height / image.size.width) * newwidth
            if newheight > self.frame.size.height {
                let diff: CGFloat = self.frame.size.height - newheight
                newwidth = newwidth + diff / newwidth * newwidth
                newheight = self.frame.size.height
            }
        }
        //adapt UIImageView size to image size
        return CGSize(width: newwidth, height: newheight)
    }
    
    //add tag user into image with ratio to render with multiple devices
    func addTagUser(_ tag: Tag, ratio: CGFloat) {
        for (index, t) in tagViews.enumerated(){
            if tag.user.id == t.tagUser.id{
                removeTagView(tagViews[index])
            }
        }
        updateTagUser(tag, ratio: ratio)
    }
    
    //add default tag view when no user tagged
    func generateFirstTagViewWith()->TagView{
        removeFirstTagView()
        let user = TaggableUser()
        user.fullName = "Tap to tag"
        let location = TagLocation.init(point: CGPoint(x: frame.size.width / 2, y: frame.size.height / 2))
        
        let tag = Tag(user: user, location: location)
        tagList.append(tag)
        
        let tagView = tag.generateTagViewWith(superView: self, delegate: self, ratio: 1)
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(_:)))
        tagView.addGestureRecognizer(gesture)
        tagViews.append(tagView)
        return tagView
    }
}
extension UIImage_Tag: HLTagViewDelegate{
    //remove tag view
    func removeTagView(_ tagView: TagView) {
        for (index, t) in tagList.enumerated(){
            if t.user.id == tagView.tagUser.id{
                if tagViews.count > index && tagViews[index].tagId == t.user.id{
                    tagViews.remove(at: index)
                }
                tagList.remove(at: index)
                tagView.removeFromSuperview()
                delegate.removeTag(t)
                break
            }
        }
    }
    //update tag view
    func tagIsUpdated(_ tagView: TagView, gesture: UITapGestureRecognizer) {
        tagView.reset()
        tagView.tagTextfield.rightViewMode = .never
        tagView.tagTextfield.isUserInteractionEnabled = false
        bringSubview(toFront: tagView)
        
        if isUserTagEnabled == true {
            tagView.edittingTagMode(gesture)
        }else if tagView.tagUser.id == "0" {
            showTagAlertAction(tagView)
        }else {
            delegate.gotoUserInfo(tagView.tagUser.id)
        }
        for t in tagViews{
            if tagView.tagUser.id == nil{
                return
            }
            if let index = t.overlapTag.index(of: tagView.tagUser.id){
                t.overlapTag.remove(at: index)
            }
        }
        if tagView.isCancelling == false{
            return
        }
        for subview in tagViews{
            if subview.tagUser.id != tagView.tagUser.id{
                tagView.checkOverlapWith(subview)
            }
        }
        
    }
    
    //when user tap to self-tag in view-only mode
    fileprivate func showTagAlertAction(_ tagView: TagView){
        
        let alert = UIAlertController(title: "It's your tag", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Go to My Profile", style: .cancel, handler: { action in
            self.delegate.gotoUserInfo(tagView.tagUser.id)
        }))
        alert.addAction(UIAlertAction(title: "Delete tag", style: .default, handler: { action in
            self.removeTag(tagView)
        }))
        getViewController()?.present(alert, animated: true, completion: nil)
    }
    
    //remove tag
    func removeTag(_ tagView: TagView){
        removeTagView(tagView)
    }
    
}


extension UIView{
    //get parent view controller
    func getViewController() -> UIViewController? {
        
        var responder = self as UIResponder
        
        while (true) {
            if let viewController = responder as? UIViewController {
                return viewController
            }
            if responder.next == nil{
                return nil
            }
            responder = responder.next!
        }
        
    }
}
