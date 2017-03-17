//
//  NavigationRed.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 15/02/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit


class NavigationRed : UINavigationController{
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .lightContent
    }
        
    override func viewDidLoad() {
        self.navigationBar.tintColor = Colors.white
        self.navigationBar.isTranslucent = false
        self.navigationBar.barTintColor = Colors.red
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : Colors.white]
                
        let backImage = Images.imageOfBack.withRenderingMode(.alwaysTemplate)
        self.navigationBar.backIndicatorImage = backImage
        self.navigationBar.backIndicatorTransitionMaskImage = backImage
        self.navigationItem.backBarButtonItem?.title = ""
        
    }
    
    
}
