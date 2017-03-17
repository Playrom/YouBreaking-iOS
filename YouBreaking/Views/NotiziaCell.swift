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
    
    @IBOutlet weak var testoTitolo: UILabel!
    @IBOutlet weak var topicButton: UIButton!
    @IBOutlet weak var testo: UILabel!
    @IBOutlet weak var imageUp: UIImageView!
    @IBOutlet weak var imageDown: UIImageView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var mainImageView: UIView!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
        
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var position: UILabel!
    
    var model : JSON?
    var coms = ModelNotizie()
    
    var delegate : NotiziaCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainImageView.isHidden = true
        divider.isHidden = false
        author.text = nil
        position.text = nil
        // Initialization code
        
    }
    
    var currentVote = Voto.NO
    
    override func prepareForReuse() {
        topicButton.isHidden = false
        currentVote = Voto.NO
        
        mainImageView.isHidden = true
        divider.isHidden = false
        mainImage.image = nil
        
        testoTitolo.text = ""
        testo.text = ""
        scoreLabel.text = "0"
        
        author.text = nil
        position.text = nil
    }
    
    override func layoutSubviews() {
        
        mainImageView.backgroundColor = Colors.lightGray
        
        if let model = model{
            
            if let text = model["text"].string{
            
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
            
            testoTitolo.textColor = Colors.red
            testoTitolo.text = model["title"].string
            testoTitolo.sizeToFit()
            
            scoreLabel.text = model["score"].intValue.description
            scoreLabel.textColor = Colors.red
            
            
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
                    self.divider.isHidden = true
                    self.activityIndicator.startAnimating()
                                        
                    coms.getPhoto(photo: comps["PHOTO"]!){
                        image in
                        self.mainImage.image = image
                        self.activityIndicator.stopAnimating()
                    }
                }
                                
            }
            
            
            if let vote = model["voto_utente"].dictionary{
                if let v = vote["voto"]?.stringValue , v.contains("UP"){
                    self.currentVote = .UP
                    self.setVoteImages(voto: .UP)
                }
                
                if let v = vote["voto"]?.stringValue , v.contains("DOWN"){
                    self.currentVote = .DOWN
                    self.setVoteImages(voto: .DOWN)
                }
            }else{
                self.setVoteImages(voto: .NO)
            }
            
            let tapUp = UITapGestureRecognizer(target: self, action: #selector(NotiziaCell.voteUp))
            tapUp.numberOfTapsRequired = 1
            imageUp.isUserInteractionEnabled = true
            imageUp.addGestureRecognizer(tapUp)
            
            let tapDown = UITapGestureRecognizer(target: self, action: #selector(NotiziaCell.voteDown))
            tapDown.numberOfTapsRequired = 1
            imageDown.isUserInteractionEnabled = true
            imageDown.addGestureRecognizer(tapDown)
            
            //author.text = model["user"]["name"].string
            
            if let date = model["created_at"].string?.date{
                author.text = date.timeAgoSinceNow
            }
            
            if let distance = model["distance"].double{
                let formatter = NumberFormatter()
                formatter.maximumFractionDigits = 2
                let distanceString = formatter.string(from: NSNumber(floatLiteral: distance ) )
                if let str = distanceString{
                    position.text = "Distante " + str + "km"
                }else{
                    position.text = ""
                }
            }
            
        }
    }
    
    func setVoteImages(voto : Voto){
        switch voto {
            case .UP:
                imageUp.image = Images.imageOfArrowUpFill
                imageDown.image = Images.imageOfArrowDown
                break
            case .DOWN:
                imageUp.image = Images.imageOfArrowUp
                imageDown.image = Images.imageOfArrowDownFill
                break
            case .NO:
                imageUp.image = Images.imageOfArrowUp
                imageDown.image = Images.imageOfArrowDown
                break
        }
        
        self.currentVote = voto
        
    }
    
    func voteUp(){
        if let model = model{
            
            if (self.currentVote == Voto.UP) {
                setVoteImages(voto: .NO)
                self.delegate?.vote(voto: .NO , sender: self)
            }else{
                setVoteImages(voto: .UP)
                self.delegate?.vote(voto: .UP , sender: self)
            }
            
            
            
        }
    }
    
    func voteDown(){
        if let model = model{
            
            if (self.currentVote == Voto.DOWN) {
                setVoteImages(voto: .NO)
                self.delegate?.vote(voto: .NO , sender: self)
            }else{
                setVoteImages(voto: .DOWN)
                self.delegate?.vote(voto: .DOWN , sender: self)
            }
        }
    }
    
    
    @IBAction func pressEvent(_ sender: UIButton) {
//        if let eventId = self.model?["evento"]["id"].string{
//            self.delegate?.performSegueToEvent(eventId: eventId, sender: self)
//        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if let id = self.model?["id"].string , selected == true{
            self.delegate?.performSegueToSingle(id: id, sender: self)
        }
    }
    
    
}

protocol NotiziaCellDelegate{
    func vote(voto : Voto, sender : NotiziaCell)
    func performSegueToEvent(eventId : String, sender : NotiziaCell)
    func performSegueToSingle(id : String, sender : NotiziaCell)
}
