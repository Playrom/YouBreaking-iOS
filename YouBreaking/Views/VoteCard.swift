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
    var coms = ModelNotizie()

    @IBOutlet weak var mainImageView: UIView!
    @IBOutlet weak var testoTitolo: UILabel!
    @IBOutlet weak var topicButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mainImage: UIImageView!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func layoutSubviews() {
        
        mainImageView.backgroundColor = Colors.lightGray
        mainImageView.isHidden = true
        
        if let model = model{
            
            testoTitolo.textColor = Colors.red
            testoTitolo.text = model["title"].string
            testoTitolo.sizeToFit()
            
            
            if let eventName = model["evento"]["name"].string {
                topicButton.setTitle(eventName, for: .normal)
            }else{
                topicButton.isHidden = true
            }
            
            var comps = [String : String]()
            
            if let aggiuntivi = model["aggiuntivi"].array{
                _ = aggiuntivi.map{
                    if let temp =  $0.dictionary , let tipo = temp["tipo"]?.string{
                        comps[tipo] = temp["valore"]!.stringValue
                    }
                }
                
                if comps["PHOTO"] != nil{
                    self.mainImageView.isHidden = false
                    //self.divider.isHidden = true
                    self.activityIndicator.startAnimating()
                    
                    coms.getPhoto(photo: comps["PHOTO"]!){
                        image in
                        self.mainImage.image = image
                        self.activityIndicator.stopAnimating()
                    }
                }
                
            }

        }
    }
}
