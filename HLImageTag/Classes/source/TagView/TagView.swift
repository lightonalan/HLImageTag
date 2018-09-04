//
//  TagView.swift
//  HLImageTag
//
//  Created by Nguyen Xuan Hieu on 6/12/18.
//  Copyright © 2018 Nguyen Xuan Hieu. All rights reserved.
//

import UIKit

protocol HLTagViewDelegate {
    func removeTagView(_ tagView: TagView)
    func tagIsUpdated(_ tagView: TagView, gesture: UITapGestureRecognizer)
}

class TagView: UIView {
    var tagUser: TaggableUser!
    var tagId: String!{
        didSet{
            loadGestureRecognizers()
        }
    }
    var contentView: UIView!
    var tagTextfield: UITextField!
    var cancelButton: UIButton!
    var textFont: UIFont! = UIFont.systemFont(ofSize: 10)
    var delegate: HLTagViewDelegate!
    var ratio: CGFloat! = 1
    var overlapTag = [String]()
    fileprivate var minimumTextFieldSize: CGSize!
    fileprivate var minimumTextFieldSizeWhileEditing: CGSize!
    fileprivate var maximumTextLength: Int! = 20
    var normalizedArrowPoint: CGPoint! = CGPoint.zero
    var normalizedArrowOffset: CGPoint! = CGPoint.zero
    
    var overlapSize: CGFloat! = 0
    var isSuperviewOverlapped = false
    let minimumArrowX:CGFloat = 17.0
    let radius:CGFloat = 12.0
    let topRadius:CGFloat = 16.0
    let arrowHeight:CGFloat = 5.0
    let arrowWidth:CGFloat = 6.0
    var singleTapGesture : UITapGestureRecognizer!
    var isCancelling: Bool! = false {
        didSet{
            if isCancelling == true{
                tagTextfield.rightViewMode = .always
                tagTextfield.isUserInteractionEnabled = true
            }else{
                tagTextfield.rightViewMode = .never
                tagTextfield.isUserInteractionEnabled = false
            }
            resizeTextField()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize(){
        loadContentView()
        loadGestureRecognizers()
        
        let tagInsets = CGSize(width: -7, height: 6)
        var tagBounds = contentView.bounds.insetBy(dx: tagInsets.width, dy: tagInsets.height)
        tagBounds.size.height += 10
        tagBounds.origin.x = 0
        tagBounds.origin.y = 0
        
        frame = tagBounds
        minimumTextFieldSize = CGSize(width: 25, height: 14)
        minimumTextFieldSizeWhileEditing = CGSize(width: 54, height: 14)
        minimumTextFieldSize = CGSize(width: 25, height: 14)
        
        normalizedArrowOffset = CGPoint(x:0, y: 0.02)
        self.isOpaque = false
        contentView.frame = contentView.frame.offsetBy(dx: -tagInsets.width, dy: 10-tagInsets.height)
        beginObservations()
        
    }
    
    deinit {
        stopObservations()
    }
    
    func loadContentView(){
        contentView = newContentView()
        addSubview(contentView)
    }
    
    func newContentView()-> UIView{
        let textField = UITextField(frame: CGRect(x:0, y:0, width: 0, height: 0))
        textField.font = textFont
        textField.backgroundColor = UIColor.clear
        textField.textColor = UIColor.white
        textField.textAlignment = .center
        textField.text = "Tap to tag"
        tagTextfield = textField
        _ = newcancelButton()
        return textField
    }
    
    func newcancelButton()-> UIView{
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 18, height: 18))
        button.setBackgroundImage(UIImage(named:"f_posting_btn_tagging_cancel"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        button.addTarget(self, action: #selector(self.removeTagView(_:)), for: .touchUpInside)
        cancelButton = button
        tagTextfield.rightView = button
        return button
    }
    func removeTag(_ tagView: TagView){
        removeTagView(tagView)
    }
    @objc func removeTagView(_ sender: Any) {
        if delegate == nil{
            return
        }
        delegate.removeTagView(self)
    }
    func loadGestureRecognizers(){
        
        if self.tagId != nil && self.tagId.count > 0 && singleTapGesture == nil{
            let singleTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(didRecognizerSingleTap(_:)))
            singleTapGesture.numberOfTapsRequired = 1
            addGestureRecognizer(singleTapGesture)
        }
        isUserInteractionEnabled = true
    }
    
    @objc func didRecognizerSingleTap(_ gesture: UITapGestureRecognizer){
        if delegate == nil || tagUser.id == nil{
            return
        }
        delegate.tagIsUpdated(self, gesture: gesture)
        
    }
    
    func edittingTagMode(_ gesture: UITapGestureRecognizer){
        if isCancelling == true{
            let translation = gesture.location(in: self)
            if translation.x > self.frame.size.width - 18 {
                if tagId != nil{
                    removeTag(self)
                }else{
                    removeTagView(self)
                }
                return
            }
        }
        isCancelling = !isCancelling
    }
    
    func beginObservations(){
        NotificationCenter.default.addObserver(self, selector: #selector(tagTextFieldDidChangeWithNotification(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }
    
    func stopObservations(){
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func tagTextFieldDidChangeWithNotification(_ notification: Notification){
        if let textField = notification.object as? UITextField{
            if textField == tagTextfield{
                self.resizeTextField()
            }
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        tagTextfield.isEnabled = false
        if tagTextfield.canBecomeFirstResponder{
            resizeTextField()
            tagTextfield.becomeFirstResponder()
            return true
        }
        return false
    }
    
    override func resignFirstResponder() -> Bool {
        tagTextfield.isEnabled = false
        return tagTextfield.resignFirstResponder()
    }
    
    func resizeTextField(){
        var newTagSize = CGSize.zero
        if tagTextfield.text != nil && tagTextfield.text != ""{
            newTagSize = (tagTextfield.text! as NSString).size(withAttributes: [kCTFontAttributeName as NSAttributedStringKey : textFont])
        }else if tagTextfield.placeholder != nil && tagTextfield.placeholder != ""{
            newTagSize = minimumTextFieldSize
        }
        if tagTextfield.isFirstResponder == true{
            //normal padding left & right
            newTagSize.width += 3
        }
        if isCancelling {
            //padding with cancel button on right
            newTagSize.width += 30
        }
        var newTextFieldFrame = tagTextfield.frame
        let minimumSize = tagTextfield.isFirstResponder ? minimumTextFieldSizeWhileEditing : minimumTextFieldSize

        newTextFieldFrame.size.width = max(newTagSize.width, minimumSize!.width)
        newTextFieldFrame.size.height = max(newTagSize.height, minimumSize!.height)
        
        tagTextfield.frame = newTextFieldFrame
        let tagInsets = CGSize(width: -7, height: -6)
        var tagBounds = tagTextfield.bounds.insetBy(dx: tagInsets.width, dy: tagInsets.height)
        tagBounds.origin.x = 0
        tagBounds.origin.y = 0
        tagBounds.size.height += 10.0
        let originalCenter = center
        frame = tagBounds
        center = originalCenter
        
        setNeedsDisplay()
    }
    //draw tag view
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        
        let fullRect = rect.insetBy(dx: 1, dy: 1)
        let containerRect = CGRect(x: fullRect.origin.x, y: fullRect.origin.y - arrowHeight, width: fullRect.size.width, height: fullRect.size.height - arrowHeight)
        
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let tagPath = CGMutablePath()
        
        
        
        //bottom right corner
        tagPath.move(to: CGPoint(x: containerRect.maxX - radius + overlapSize, y: containerRect.maxY))
        //draw the arrow
        tagPath.addLine(to: CGPoint(x: containerRect.midX - arrowWidth + overlapSize, y: containerRect.maxY))
        tagPath.addLine(to: CGPoint(x: containerRect.midX + overlapSize, y: fullRect.maxY))
        tagPath.addLine(to: CGPoint(x: containerRect.midX + arrowWidth + overlapSize, y: containerRect.maxY))

        
        let left  = CGFloat(Double.pi)
        let top    = CGFloat(1.5*Double.pi)
        let bottom  = CGFloat(Double.pi/2)
        let right = CGFloat(0.0)
        
        
        //bottom left corner
        tagPath.addArc(center:  CGPoint(x: containerRect.minX + radius, y: containerRect.maxY - radius), radius: radius, startAngle: bottom, endAngle: left, clockwise: false)
        
        //top left corner
        tagPath.addArc(center:  CGPoint(x: containerRect.minX + radius, y: containerRect.minY + topRadius), radius: radius, startAngle: left, endAngle: top, clockwise: false)
        
        //top right corner
        tagPath.addArc(center:  CGPoint(x: containerRect.maxX - radius, y: containerRect.minY + topRadius), radius: radius, startAngle: top, endAngle: right, clockwise: false)
        
        //bottom right corner
        tagPath.addArc(center:  CGPoint(x: containerRect.maxX - radius, y: containerRect.maxY - radius), radius: radius, startAngle: right, endAngle: bottom, clockwise: false)
        

        tagPath.closeSubpath()
        
        context.addPath(tagPath)
        
        context.setFillColor(UIColor(white: 0, alpha: 0.7).cgColor)
        
        context.fillPath()
        
        
        //draw stroke
        context.addPath(tagPath)
        context.setStrokeColor(UIColor.clear.cgColor)
        context.setLineWidth(1)
        context.setLineJoin(.round)
        context.strokePath()
        center.x = center.x - overlapSize
    }
    
    func repositionInRect(_ rect: CGRect){
        layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        var popoverPoint = CGPoint(x: rect.origin.x, y: rect.origin.y)
        popoverPoint.x += rect.size.width * (self.normalizedArrowPoint.x + self.normalizedArrowOffset.x)
        popoverPoint.y += rect.size.height * (self.normalizedArrowPoint.y + self.normalizedArrowOffset.y)

        center = popoverPoint
        let rightX = frame.origin.x + frame.size.width
        let leftXClip = max(rect.origin.x -  frame.origin.x, 0)
        let rightXClip = min((rect.origin.x + rect.size.width) - rightX, 0)

        var newFrame = frame
        newFrame.origin.x += leftXClip
        newFrame.origin.y += rightXClip - arrowHeight

        frame = newFrame
    }
    
    func convertToLocation()->TagLocation{
        let center = self.center
        let height = self.frame.size.height
        return TagLocation.init(point: CGPoint(x: center.x*ratio, y: (center.y + height)*ratio))
    }
    
    func presentPopoverFromPoint(_ point: CGPoint, inView: UIView, permittedArrowDirections: UIPopoverArrowDirection, animated: Bool){
        inView.addSubview(self)
        
        let difference = CGPoint(x: 0, y: 0.5)
        layer.anchorPoint = CGPoint(x: 0.5-difference.x, y: 0.5-difference.y)
        
        self.center = CGPoint(x: point.x, y: point.y - arrowHeight)
        let tagMaximumX = self.frame.maxX
        let tagMinimumX = self.frame.minX
        let tagMaximumY = self.frame.maxY
        let tagMinimumY = self.frame.minY

        let tagBoundary = self.frame.insetBy(dx: -5, dy: 5)
        let boundsMinimumX = tagBoundary.minX
        let boundsMaximumX = tagBoundary.maxX
        let boundsMinimumY = tagBoundary.minY
        let boundsMaximumY = tagBoundary.maxY

        let xOffset = (min(0, tagMinimumX - boundsMinimumX) + max(0, tagMaximumX - boundsMaximumX))/1.0
        let yOffset = (min(0, tagMinimumY - boundsMinimumY) + max(0, tagMaximumY - boundsMaximumY))/1.0

        let newCenter = CGPoint(x: point.x - xOffset, y: point.y - 8 * arrowHeight - yOffset)
        self.center = newCenter
    }

    func setupUser(_ user: TaggableUser){
        tagUser = user
        tagTextfield.text = user.fullName
        tagTextfield.isEnabled = false
        resizeTextField()
    }
}

extension TagView: UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textAlignment = .left
        resizeTextField()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.textAlignment = .center
        resizeTextField()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        _ = self.resignFirstResponder()
        return true
    }
}

extension TagView{
    //check overlap with other tags in image
    func checkOverlapWith(_ tag: TagView){
        if tag.tagUser.id == nil || tag.isSuperviewOverlapped == true{
            return
        }
        if self.frame.intersects(tag.frame) {
            var overlapSize = (self.frame.width + tag.frame.width)/2 - (self.center.x - tag.center.x)
            if tag.center.x < self.center.x{
                if tag.moveLeft(overlapSize){
                    tag.checkOverlapWithSuperView()
                }
            }else{
                overlapSize = (self.frame.width + tag.frame.width)/2 - (tag.center.x - self.center.x )
                if tag.moveRight(-overlapSize){
                    tag.checkOverlapWithSuperView()
                }
            }
            overlapTag.append(tag.tagUser.id)
        }
    }
    
    //move tagview to left but keep bottom arrow
    func moveLeft(_ size: CGFloat)-> Bool{
        overlapSize = min(size, frame.size.width/2 - minimumArrowX)
        setNeedsDisplay()
        return size > frame.size.width/2 - minimumArrowX
    }
    //move tagview to right but keep bottom arrow
    func moveRight(_ size: CGFloat)-> Bool{
        overlapSize = max(size, minimumArrowX - frame.size.width/2)
        setNeedsDisplay()
        return size > minimumArrowX - frame.size.width/2
    }
    
    //check overlap with superview
    func checkOverlapWithSuperView(){
        
        if self.center.x + self.frame.width / 2 > superview!.frame.size.width{ //tag is out of superview from right
            isSuperviewOverlapped = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                _ = self.moveLeft(self.center.x + self.frame.width / 2 - self.superview!.frame.size.width)
            }
        }else if self.center.x - self.frame.width / 2 < 0{ //tag is out of superview from left
            isSuperviewOverlapped = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                _ = self.moveRight(self.center.x - self.frame.width / 2)
            }
        }else{
            isSuperviewOverlapped = false
        }
    }
    //reset overlap
    func reset(){
        overlapSize = -overlapSize
        setNeedsDisplay()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.overlapSize = 0
            self.setNeedsDisplay()
        }
    }
}
extension String {
    func substring(to: Int) -> String {
        if self.count < to{
            return self
        }
        return String(prefix(to-3)) + "..."
    }
}
