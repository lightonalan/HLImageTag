//
//  UIImage+Tag.swift
//  HLImageTag
//
//  Created by Nguyen Xuan Hieu on 6/12/18.
//  Copyright © 2018 Nguyen Xuan Hieu. All rights reserved.
//

import UIKit

class UIImage_Tag: UIImageView {
    var tagList = [Tag]()
    var tagViews = [TagView]()
    
    fileprivate var isAddingTag = false
    
    override func awakeFromNib() {
        isUserInteractionEnabled = true // IMPORTANT
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapImage(_:))))
    }
    
    @objc func didTapImage(_ gesture: UIGestureRecognizer) {
//        for subview in tagViews{
//            for recognizer in subview.gestureRecognizers ?? [] {
//                subview.removeGestureRecognizer(recognizer)
//            }
//            subview.removeFromSuperview()
//        }
//        tagViews.removeAll()
        
        isAddingTag = true
        let point = gesture.location(in: self)
        
        let searchVC = HLSearchViewController(nibName: "HLSearchViewController", bundle: nil)
        searchVC.delegate = self
        searchVC.location = TagLocation(point:point)
        var topVC = UIApplication.shared.keyWindow?.rootViewController
        while((topVC!.presentedViewController) != nil){
            topVC = topVC!.presentedViewController
        }
        topVC!.present(searchVC, animated: true, completion: nil)
    }
    
    
    //call update tag user after select user
    func updateTagUser(_ tag: Tag){
//        for (index, tag) in tagList.enumerated(){
//            if tag.user == nil{
//                tagList.remove(at: index)
//            }
//        }
//        for t in tagList{
            if tag.user.id > 0{
                tagList.append(tag)
                let tagView = tag.generateTagViewWith(superView: self, delegate: self)
                
                let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(_:)))
                tagView.addGestureRecognizer(gesture)
                tagViews.append(tagView)
            }
//        }
    
    }
    
    @objc func wasDragged(_ gesture: UIPanGestureRecognizer) {
        if let tagView = gesture.view as? TagView{
            for t in tagList{
                if t.user.id == tagView.tag{
                    let translation = gesture.translation(in: self)
                    
                    tagView.repositionInRect(CGRect(x: translation.x + t.location.x, y: translation.y + t.location.y, width: tagView.frame.width, height: tagView.frame.height))
                    if gesture.state == .ended{
                        t.location = tagView.convertToLocation()
                    }
                    return
                }
            }
            
        }
       
    }
    
    
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
}
extension UIImage_Tag: HLTagViewDelegate{
    func removeTagView(_ tagView: TagView) {
        for (index, t) in tagList.enumerated(){
            if t.user.id == tagView.tag{
                tagList.remove(at: index)
                tagViews.remove(at: index)
                tagView.removeFromSuperview()
                return
            }
        }
    }
}

extension UIImage_Tag: HLSearchViewControllerDelegate{
    func selecctedTagUser(_ tag: Tag) {
        for p in tagList{
            if tag.user.id == p.user.id{
                return
            }
        }
        updateTagUser(tag)
    }
}