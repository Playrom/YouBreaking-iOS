//
//  UserPublishedNotiziaCell.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 14/03/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit
import SwiftyJSON

class UserPublishedNotiziaCell: UITableViewCell {

    // MARK: - Class Attributes
    var model : JSON?
    
    // MARK: - IBOutlets
    @IBOutlet weak var titolo: UILabel!
    @IBOutlet weak var stato: UILabel!
    @IBOutlet weak var score: UILabel!

    // MARK: - UKit Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        titolo.text = ""
        stato.text = ""
        score.text = ""
    }
    
    override func layoutSubviews() {
        
        if let model = model{
            
            titolo.text = model["title"].string
            
            if let live = model["live"].int{
                switch live {
                case 0:
                    stato.text = "In Votazione"
                    stato.textColor = Colors.red
                    break
                default:
                    stato.text = "Pubblicato"
                    stato.textColor = Colors.green
                    break
                }
            }
            
            score.text = model["score"].intValue.description
            
        }
    }



}
