//
//  SelectPhotoCell.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 20/02/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit

class SelectPhotoCell: UITableViewCell {
    
    @IBOutlet weak var fullImageView: UIImageView!
    var url : [URL]?
    @IBOutlet weak var overlay: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true;

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
            fullImageView.frame = self.frame
            fullImageView.contentMode = .scaleAspectFill
            self.clipsToBounds = true;
            fullImageView.clipsToBounds = true
            overlay.backgroundColor = Colors.red
            overlay.alpha = 0.4
    }
    
}
