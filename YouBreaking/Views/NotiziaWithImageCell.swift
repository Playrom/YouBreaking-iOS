//
//  NotiziaWithImageCell.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 08/06/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit

class NotiziaWithImageCell: NotiziaCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var textBackgroundView: UIView!
    
    // MARK: - UIKit Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        //        mainImageView.isHidden = true
        //        divider.isHidden = false
        //        author.text = nil
        //        position.text = nil
        // Initialization code
        
        self.mainImage.image = nil
        self.coverView.backgroundColor = Colors.white
        self.textBackgroundView.backgroundColor = .clear
        self.testoTitolo.textColor = Colors.white
        self.testo.textColor = Colors.white
    }
    
    override func prepareForReuse() {
        //        topicButton.isHidden = false
        //        mainImageView.isHidden = true
        //        divider.isHidden = false
        //        mainImage.image = nil
        self.mainImage.image = nil
        self.coverView.backgroundColor = Colors.white
        self.textBackgroundView.backgroundColor = .clear
        self.testoTitolo.textColor = Colors.white
        self.testo.textColor = Colors.white
        
    }
    
    override func layoutSubviews() {
        //        mainImageView.backgroundColor = Colors.lightGray
        super.layoutSubviews()
        
        if let model = model{
            
            if let featured_photo_url = model["featured_photo"]["thumb"].string{
                self.activityIndicator.startAnimating()
                
                coms.getImage(url: featured_photo_url)
                    .then{
                        image -> Void in
                        
                        self.mainImage.image = image
                        self.activityIndicator.stopAnimating()
                        self.coverView.backgroundColor = .clear
                        self.textBackgroundView.backgroundColor = Colors.lightBlack
                        self.textBackgroundView.alpha = 0.7
                }
            }
            
        }
    }
    
}
