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
}

class TagView: UIView {
    var tagUser: TaggableUser!
    var contentView: UIView!
    var tagTextfield: UITextField!
    var cancelButton: UIButton!
    var textFont: UIFont! = UIFont.systemFont(ofSize: 12)
    var delegate: HLTagViewDelegate!
    
    fileprivate var minimumTextFieldSize: CGSize!
    fileprivate var minimumTextFieldSizeWhileEditing: CGSize!
    fileprivate var maximumTextLength: Int! = 20
    var normalizedArrowPoint: CGPoint! = CGPoint.zero
    var normalizedArrowOffset: CGPoint! = CGPoint.zero
    
    let radius:CGFloat = 10.0
    let topRadius:CGFloat = 14.0
    let arrowHeight:CGFloat = 5.0
    let arrowWidth:CGFloat = 10.0
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
        textField.autocorrectionType = .no
        textField.textAlignment = .center
        textField.keyboardAppearance = .alert
        textField.delegate = self
        textField.isEnabled = false
        textField.text = "タグを付ける"
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
    @objc func removeTagView(_ sender: Any) {
        delegate.removeTagView(self)
    }
    func loadGestureRecognizers(){
        let singleTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(didRecognizerSingleTap(_:)))
        singleTapGesture.numberOfTapsRequired = 1
        addGestureRecognizer(singleTapGesture)
    }
    
    @objc func didRecognizerSingleTap(_ gesture: UITapGestureRecognizer){
        if isCancelling == true{
            let translation = gesture.location(in: self)
            if translation.x > (tagTextfield.text! as NSString).size(withAttributes: [NSAttributedStringKey.font : textFont]).width {
                removeTagView(self)
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
        tagTextfield.isEnabled = false
        return false
    }
    
    override func resignFirstResponder() -> Bool {
        tagTextfield.isEnabled = false
        return tagTextfield.resignFirstResponder()
    }
    
    func resizeTextField(){
        var newTagSize = CGSize.zero
        if tagTextfield.text != nil && tagTextfield.text != ""{
            newTagSize = (tagTextfield.text! as NSString).size(withAttributes: [NSAttributedStringKey.font : textFont])
        }else if tagTextfield.placeholder != nil && tagTextfield.placeholder != ""{
            newTagSize = minimumTextFieldSize
        }
        if tagTextfield.isFirstResponder == true{
            newTagSize.width += 3
        }
        if isCancelling {
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
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        
        let fullRect = rect.insetBy(dx: 1, dy: 1)
        let containerRect = CGRect(x: fullRect.origin.x, y: fullRect.origin.y - arrowHeight, width: fullRect.size.width, height: fullRect.size.height - arrowHeight)
        
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let tagPath = CGMutablePath()
        
        
        
        //bottom right corner
        tagPath.move(to: CGPoint(x: containerRect.maxX - radius, y: containerRect.maxY))
        //draw the arrow
        tagPath.addLine(to: CGPoint(x: containerRect.midX - arrowWidth, y: containerRect.maxY))
        tagPath.addLine(to: CGPoint(x: containerRect.midX, y: fullRect.maxY))
        tagPath.addLine(to: CGPoint(x: containerRect.midX + arrowWidth, y: containerRect.maxY))

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
        
        context.setFillColor(UIColor(white: 0.11, alpha: 0.75).cgColor)
        
        context.fillPath()
        
        
        //draw stroke
        context.addPath(tagPath)
        context.setStrokeColor(UIColor.clear.cgColor)
        context.setLineWidth(1)
        context.setLineJoin(.round)
        context.strokePath()
        
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
        let width = self.frame.size.width
        let height = self.frame.size.height
        return TagLocation.init(point: CGPoint(x: center.x - width / 2, y: center.y - height / 2))
    }
    
    func presentPopoverFromPoint(_ point: CGPoint, inView: UIView, permittedArrowDirections: UIPopoverArrowDirection, animated: Bool){
        inView.addSubview(self)
        print("location: \(point)")
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
        var result = false
        if textField == tagTextfield{
            let newLength = textField.text!.count + string.count - range.length
            if maximumTextLength == nil || newLength <= maximumTextLength{
                result = true
            }
        }
        return result
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
