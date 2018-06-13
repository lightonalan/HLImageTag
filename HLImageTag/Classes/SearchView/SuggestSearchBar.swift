//
//  SuggestSearchBar.swift
//  HLImageTag
//
//  Created by Nguyen Xuan Hieu on 6/13/18.
//  Copyright © 2018 Nguyen Xuan Hieu. All rights reserved.
//

import UIKit

class SuggestSearchBar: UIView {

    
    @IBOutlet var containView: UIView!
    @IBOutlet weak var textField: UITextField!
    var customConstraints:[NSLayoutConstraint]?
    
    // MARK: - FUNCTION
    /// コードから初期化はここから
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        xibSetup()
        commonInit()
    }
    
    /// Storyboard/xib から初期化はここから
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        xibSetup()
        commonInit()
    }
    
    func commonInit() {
        
    }
    @IBAction func onCancelPressed(_ sender: Any) {
        textField.text = ""
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 検索バーの枠線と角丸の設定
        textField.clearButtonMode = .always
//        containView.roundCorner(containView.frame.height/2, color: UIColor(red: CGFloat(220) / 255.0, green: CGFloat(220) / 255.0, blue: CGFloat(220) / 255.0, alpha: 1.0))
    }
    
    override var intrinsicContentSize: CGSize {
        return UILayoutFittingExpandedSize
    }
    /// xibからの初期化
    func xibSetup() {
        
        customConstraints = [NSLayoutConstraint]()
        Bundle.main.loadNibNamed(String(describing: self.className ) , owner: self, options: nil)
        addSubview(containView)
        containView.frame = self.bounds
        containView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        
        // Constraintsの更新
        setNeedsUpdateConstraints()
    }
    
    var className: String {
        return String(describing: type(of: self)).components(separatedBy: ".").last!
    }
    
    func roundCorner(_ radian:CGFloat, color:UIColor, borderWidth:CGFloat = 0.5) {
        self.layer.cornerRadius = radian
        self.layer.masksToBounds = true
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = borderWidth
    }
}
