//
//  VoteCard.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 03/02/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit
import SwiftyJSON

class VoteCard: UIView {
    
    var model : JSON?

    @IBOutlet weak var title: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func setNeedsLayout() {
        if let model = model?.dictionary{
            
            title.text = (model["title"]?.string) != nil ? model["title"]!.stringValue : ""
            
        }
    }
}
