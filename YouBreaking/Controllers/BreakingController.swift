//
//  BreakingController.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 17/03/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit

class BreakingViewController : UIViewController{
    
    var statusBarStyle : UIStatusBarStyle = .lightContent {
        didSet{
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}

class BreakingTableViewController : UITableViewController{
    var statusBarStyle : UIStatusBarStyle = .lightContent {
        didSet{
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
