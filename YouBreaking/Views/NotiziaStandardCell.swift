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

class NotiziaStandardCell: NotiziaCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var likeButton: UIButton!
    
    // MARK: - Class Elements
    var liked : Bool = false {
        didSet{
            self.likeButton.isSelected = self.liked
        }
    }

    // MARK: - UIKit Methods
    override func awakeFromNib() {
        super.awakeFromNib()
//        mainImageView.isHidden = true
//        divider.isHidden = false
//        author.text = nil
//        position.text = nil
        // Initialization code
        self.liked = false
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        topicButton.isHidden = false
        self.liked = false
//        mainImageView.isHidden = true
//        divider.isHidden = false
//        mainImage.image = nil
        
        
//        author.text = nil
//        position.text = nil
        
    }
    
    override func layoutSubviews() {
//        mainImageView.backgroundColor = Colors.lightGray
        super.layoutSubviews()
        if let model = model{
            
            if let liked = model["userLike"].dictionary, liked.count > 0{
                self.liked = true
            }

            
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
    @IBAction func tapLike(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.liked = sender.isSelected
        if(self.liked){
            self.delegate?.like(sender : self)
        }else{
            self.delegate?.unlike(sender : self)
        }
        
    }
    
    @IBAction func pressShare(_ sender: UIButton) {
        // grab an item we want to share
        let url = model?["url"].url
        let items : [Any] = [url]
        
        // build an activity view controller
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.parentViewController?.present(activityController, animated: true, completion: nil)
    }
}

// MARK: - Extension 

