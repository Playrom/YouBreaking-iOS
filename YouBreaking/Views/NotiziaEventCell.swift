//
//  NotiziaEventCell.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 06/02/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit

class NotiziaEventCell: NotiziaCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.topicButton.isHidden = true
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
