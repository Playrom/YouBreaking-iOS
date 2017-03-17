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
    
    // MARK: - IBOutlets
    @IBOutlet weak var mainImageView: UIView!
    @IBOutlet weak var testoTitolo: UILabel!
    @IBOutlet weak var topicButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mainImage: UIImageView!
    
    // MARK: - Class Elements
    var model : JSON?
    var coms = ModelNotizie()
    
    //MARK: - UIKit Methods
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
