//
//  NavigationRed.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 15/02/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit


class NavigationRed : UINavigationController{
    override var preferredStatusBarStyle : UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        self.navigationBar.tintColor = Colors.white
        self.navigationBar.isTranslucent = false
        self.navigationBar.barTintColor = Colors.red
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : Colors.white]
        
    }
}

