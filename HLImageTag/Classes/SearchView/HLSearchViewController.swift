//
//  HLSearchViewController.swift
//  HLImageTag
//
//  Created by Nguyen Xuan Hieu on 6/13/18.
//  Copyright © 2018 Nguyen Xuan Hieu. All rights reserved.
//

import UIKit
protocol HLSearchViewControllerDelegate {
    func selecctedTagUser(_ tag: Tag)
}
class HLSearchViewController: UIViewController {

    @IBOutlet weak var tabBar: UIView!
    @IBOutlet weak var tableView: UITableView!
    var delegate: HLSearchViewControllerDelegate!
    var location: TagLocation!
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        addShadowToBar()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func addShadowToBar() {
        let shadowView = UIView(frame: self.tabBar!.frame)
        shadowView.backgroundColor = UIColor.white
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowColor  = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.1 // your opacity
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 2) // your offset
        shadowView.layer.position.y = -shadowView.frame.height/2
        self.view.addSubview(shadowView)
    }
    
    func registerCell(){
        tableView.register(UINib(nibName: "HLSearchTableViewCell", bundle: nil), forCellReuseIdentifier: "HLSearchTableViewCell")
    }
}
extension HLSearchViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HLSearchTableViewCell", for: indexPath) as! HLSearchTableViewCell
        
        cell.lblFullName.text = "user \(indexPath.row + 1)"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tagUser = TaggableUser()
        tagUser.id = indexPath.row + 1
        tagUser.fullName = "user \(indexPath.row + 1)"
        tagUser.username = "user\(indexPath.row + 1)"
        let tag = Tag.init(user: tagUser, location: location)
        delegate.selecctedTagUser(tag)
        self.dismiss(animated: true, completion: nil)
    }
}
