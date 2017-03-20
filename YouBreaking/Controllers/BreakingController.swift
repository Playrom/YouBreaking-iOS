//
//  BreakingController.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 17/03/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit

class BreakingViewController : UIViewController{
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}

class BreakingTableViewController : UITableViewController{
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
