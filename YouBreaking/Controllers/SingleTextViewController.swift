//
//  SingleTextViewController.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 27/06/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit
import SwiftyJSON

class SingleTextViewController: UIViewController {
    
    
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var bodyTextView: UITextView!
    
    var delegate : SingleContentViewController?
    var data : JSON?
    var insets : UIEdgeInsets?
    
    // MARK: - UIKit Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //headerImage.heroModifiers = [.duration(4)]
        
        self.contentScrollView.delegate = delegate
        self.reload()
        
    }
    
    func reload(){
        
        if let insets = insets{
            self.contentScrollView.contentInset = insets
            self.contentScrollView.scrollIndicatorInsets = insets
        }
        
        self.titleTextView.text = self.data?["title"].stringValue
        self.bodyTextView.text = self.data?["text"].stringValue
    }
    
}

// MARK: - Extensions
