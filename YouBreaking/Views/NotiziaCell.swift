//
//  NotiziaCell.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 02/02/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit
import SwiftyJSON
import DateToolsSwift

class NotiziaCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var testoTitolo: UILabel!
    @IBOutlet weak var testo: UILabel!
    
    
    // MARK: - Class Elements
    var model : JSON?
    var coms = ModelNotizie()
    var delegate : NotiziaCellDelegate?
    
    // MARK: - UIKit Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        //        mainImageView.isHidden = true
        //        divider.isHidden = false
        //        author.text = nil
        //        position.text = nil
        // Initialization code
        testoTitolo.text = ""
        testoTitolo.textColor = Colors.red
        testo.text = ""
        testo.textColor = Colors.black
        
        
    }
    
    override func prepareForReuse() {
        //        topicButton.isHidden = false
        //
        //        mainImageView.isHidden = true
        //        divider.isHidden = false
        //        mainImage.image = nil
        
        testoTitolo.text = ""
        testoTitolo.textColor = Colors.red
        testo.text = ""
        testo.textColor = Colors.black
        
        //        author.text = nil
        //        position.text = nil
        
    }
    
    override func layoutSubviews() {
        //        mainImageView.backgroundColor = Colors.lightGray
        
        if let model = model{
            
                        
            if let text = model["description"].string{
                
                if(text.characters.count > 500){
                    var temp = text.substring(to: text.index(text.startIndex, offsetBy: 500) )
                    let endString = NSAttributedString(string: "\nFai un Tap per continuare a leggere", attributes: [NSForegroundColorAttributeName : Colors.red])
                    let attributed = NSAttributedString(string: temp+"[...]")
                    var mutable = NSMutableAttributedString(attributedString: attributed)
                    mutable.append(endString)
                    self.testo.attributedText = mutable
                }else{
                    
                    testo.text = text
                    testo.textAlignment = .justified
                }
            }
            self.testo.sizeToFit()
            
            testoTitolo.text = model["title"].string
            testoTitolo.sizeToFit()
            
            
            if let eventName = model["evento"]["name"].string {
                //                topicButton.setTitle(eventName, for: .normal)
            }else{
                //                topicButton.isHidden = true
            }
            
            if let featured_photo_url = model["featured_photo"]["large"].string{
                //                self.mainImageView.isHidden = false
                //                self.divider.isHidden = true
                //                self.activityIndicator.startAnimating()
                
                coms.getImage(url: featured_photo_url)
                    .then{
                        image -> Void in
                        
                        //                    self.mainImage.image = image
                        //                    self.activityIndicator.stopAnimating()
                }
            }
            
            var comps = [String : String]()
            
            if let aggiuntivi = model["aggiuntivi"].array{
                _ = aggiuntivi.map{
                    if let temp =  $0.dictionary , let tipo = temp["tipo"]?.string{
                        comps[tipo] = temp["valore"]!.stringValue
                    }
                }
                
            }
            
            
            //            let tapDown = UITapGestureRecognizer(target: self, action: #selector(NotiziaCell.voteDown))
            //            tapDown.numberOfTapsRequired = 1
            //            imageDown.isUserInteractionEnabled = true
            //            imageDown.addGestureRecognizer(tapDown)
            
            //author.text = model["user"]["name"].string
            
            if let date = model["created_at"].string?.date{
                //                author.text = date.timeAgoSinceNow
            }
            
            if let distance = model["distance"].double{
                let formatter = NumberFormatter()
                formatter.maximumFractionDigits = 2
                let distanceString = formatter.string(from: NSNumber(floatLiteral: distance ) )
                if let str = distanceString{
                    //                    position.text = "Distante " + str + "km"
                }else{
                    //                    position.text = ""
                }
            }
            
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if let id = self.model?["id"].string , selected == true{
            self.delegate?.performSegueToSingle(id: id, sender: self)
        }
    }
    
    
    
    
    
}

// MARK: - Extension 

