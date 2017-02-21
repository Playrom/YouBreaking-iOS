//
//  NotiziaCell.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 02/02/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit
import SwiftyJSON

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
    
    @IBOutlet weak var distanceView: UIView!
    
    var model : JSON?
    var coms = ModelNotizie()
    
    var delegate : NotiziaCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainImageView.isHidden = true
        distanceView.isHidden = false
        // Initialization code
        
    }
    
    var currentVote = Voto.NO
    
    override func prepareForReuse() {
        topicButton.isHidden = false
        currentVote = Voto.NO
        mainImageView.isHidden = true
        distanceView.isHidden = false
    }
    
    override func layoutSubviews() {
        
        mainImageView.backgroundColor = Colors.lightGray
        
        if let model = model{
            testo.text = model["text"].string
            testo.textAlignment = .justified
            testoTitolo.textColor = Colors.red
            testoTitolo.text = model["title"].string
            
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
                    self.distanceView.isHidden = true
                    self.activityIndicator.startAnimating()
                                        
                    coms.getPhoto(photo: comps["PHOTO"]!){
                        image in
                        self.mainImage.image = image
                        self.activityIndicator.stopAnimating()
                    }
                }
                
                /*var posto = [comps["LOCATION_LOCALITY"],comps["LOCATION_COUNTRY"]]
                
                locationButton.setTitle(
                    [
                        comps["LOCATION_NAME"],
                        posto.flatMap{$0}.joined(separator: ", ")
                        
                    ].flatMap{$0}.joined(separator: " - "),
                    for : UIControlState.normal
                )
                
                if ( locationButton.currentTitle == nil || locationButton.currentTitle == ""){
                    locationButton.isHidden = true
                }else{
                    locationButton.isHidden = false
                }*/
                
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
        
        imageUp.image = imageUp.image!.withRenderingMode(.alwaysTemplate)
        imageUp.tintColor = self.tintColor
        
        imageDown.image = imageDown.image!.withRenderingMode(.alwaysTemplate)
        imageDown.tintColor = self.tintColor
        
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
        if let eventId = self.model?["evento"]["id"].string{
            self.delegate?.performSegueToEvent(eventId: eventId, sender: self)
        }
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
