//
//  SelectPhotoCell.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 20/02/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit

class SelectPhotoCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var fullImageView: UIImageView!
    @IBOutlet weak var overlay: UIView!
    
    // MARK: - Class Elements
    var url : [URL]?
    
    // MARK: - UIKit Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
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
