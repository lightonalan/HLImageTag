//
//  ViewController.swift
//  HLImageTag
//
//  Created by Nguyen Xuan Hieu on 6/12/18.
//  Copyright © 2018 Nguyen Xuan Hieu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tagImage: UIImage_Tag!
    var isTagShow = true
    var realImageSize: CGSize!
    override func viewDidLoad() {
        super.viewDidLoad()
        tagImage.delegate = self
        tagImage.realImage = tagImage.image!
        realImageSize = tagImage.realImage.size
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: UIImage_TagDelegate{
    func onShowHideTags() {
        tagImage.removeAllTagView()
        if isTagShow == false{
            let ratio = realImageSize.width/view.frame.size.width
            self.tagImage.insertAllTagView(false, ratio: ratio)
            isTagShow = true
        }else{
            isTagShow = false
        }
    }
    func didStartTagAtPoint(_ point: CGPoint) {
        let searchVC = HLSearchViewController(nibName: "HLSearchViewController", bundle: nil)
        searchVC.delegate = self
        searchVC.location = TagLocation(point:point)
        present(searchVC, animated: true, completion: nil)
    }
    func gotoUserInfo(_ userId: String) {
        
    }
    func setupTag() {
        
    }
    func removeTag(_ tag: Tag) {
        
    }
}

extension ViewController: HLSearchViewControllerDelegate{
    func selecctedTagUser(_ tag: Tag) {
        tagImage.addTagUser(tag, ratio: 1)
    }
}
