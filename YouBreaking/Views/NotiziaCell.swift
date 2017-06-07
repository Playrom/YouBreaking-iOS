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
    @IBOutlet weak var topicButton: UIButton!
    @IBOutlet weak var testo: UILabel!
    
    @IBOutlet weak var mainImageView: UIView!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
        
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var position: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    
    // MARK: - Class Elements
    var model : JSON?
    var liked : Bool = false {
        didSet{
            self.likeButton.isSelected = self.liked
        }
    }
    var coms = ModelNotizie()
    var delegate : NotiziaCellDelegate?

    // MARK: - UIKit Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        mainImageView.isHidden = true
        divider.isHidden = false
        author.text = nil
        position.text = nil
        // Initialization code
        
        likeButton.setImage(UIImage(named: "heart")?.withRenderingMode(.alwaysTemplate) , for: .selected)
        self.liked = false
        
    }
    
    override func prepareForReuse() {
        topicButton.isHidden = false
        
        mainImageView.isHidden = true
        divider.isHidden = false
        mainImage.image = nil
        
        testoTitolo.text = ""
        testo.text = ""
        
        author.text = nil
        position.text = nil
        
        self.liked = false
    }
    
    override func layoutSubviews() {
        mainImageView.backgroundColor = Colors.lightGray
        
        if let model = model{
            
            if let liked = model["userLike"].dictionary, liked.count > 0{
                self.liked = true
            }
            
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
                    self.divider.isHidden = true
                    self.activityIndicator.startAnimating()
                                        
                    coms.getPhoto(photo: comps["PHOTO"]!){
                        image in
                        self.mainImage.image = image
                        self.activityIndicator.stopAnimating()
                    }
                }
                                
            }
            
        
//            let tapDown = UITapGestureRecognizer(target: self, action: #selector(NotiziaCell.voteDown))
//            tapDown.numberOfTapsRequired = 1
//            imageDown.isUserInteractionEnabled = true
//            imageDown.addGestureRecognizer(tapDown)
            
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if let id = self.model?["id"].string , selected == true{
            self.delegate?.performSegueToSingle(id: id, sender: self)
        }
    }
    
    @IBAction func tapLike(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.liked = sender.isSelected
        if(self.liked){
            self.delegate?.like(sender : self)
        }else{
            self.delegate?.unlike(sender : self)
        }
        
    }
    // MARK: - Class Methods
//    func setVoteImages(voto : Voto){
//        switch voto {
//            case .UP:
//                imageUp.image = Images.imageOfArrowUpFill
//                imageDown.image = Images.imageOfArrowDown
//                break
//            case .DOWN:
//                imageUp.image = Images.imageOfArrowUp
//                imageDown.image = Images.imageOfArrowDownFill
//                break
//            case .NO:
//                imageUp.image = Images.imageOfArrowUp
//                imageDown.image = Images.imageOfArrowDown
//                break
//        }
//        
//        self.currentVote = voto
//        
//    }
//    
//    func voteUp(){
//        if let model = model{
//            
//            if (self.currentVote == Voto.UP) {
//                setVoteImages(voto: .NO)
//                self.delegate?.vote(voto: .NO , sender: self)
//            }else{
//                setVoteImages(voto: .UP)
//                self.delegate?.vote(voto: .UP , sender: self)
//            }
//            
//            
//            
//        }
//    }
//    
//    func voteDown(){
//        if let model = model{
//            
//            if (self.currentVote == Voto.DOWN) {
//                setVoteImages(voto: .NO)
//                self.delegate?.vote(voto: .NO , sender: self)
//            }else{
//                setVoteImages(voto: .DOWN)
//                self.delegate?.vote(voto: .DOWN , sender: self)
//            }
//        }
//    }
    
    // MARK: - IBActions
    @IBAction func pressEvent(_ sender: UIButton) {
//        if let eventId = self.model?["evento"]["id"].string{
//            self.delegate?.performSegueToEvent(eventId: eventId, sender: self)
//        }
    }
    
    @IBAction func pressShare(_ sender: UIButton) {
        // grab an item we want to share
        let url = model?["news_url"].url
        let items : [Any] = [url]
        
        // build an activity view controller
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.parentViewController?.present(activityController, animated: true, completion: nil)
    }
}

// MARK: - Extension 

