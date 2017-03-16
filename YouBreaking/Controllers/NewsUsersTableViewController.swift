//
//  NewsUsersCollectionViewController.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 16/03/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit
import SwiftyJSON

class NewsUsersTableViewController: UITableViewController{
    
    // MARK: - Utility Classes
    let coms = ModelNotizie()
    
    // MARK: - IBOutlets

    @IBOutlet weak var avatarAuthor: UIImageView!
    @IBOutlet weak var labelAuthor: UILabel!
    @IBOutlet weak var scrollViewPositive: UIScrollView!
    @IBOutlet weak var scrollViewNegative: UIScrollView!
    
    
    // Mark: - IBOutlets Extensions
    
    let spinAuthor = UIActivityIndicatorView()
    
    // MARK: - Class attributes
    
    var news : JSON?
    var upVotes = [JSON]()
    var downVotes = [JSON]()
    fileprivate var avatars = [String:UIImage]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reload()
    }
    
    func reload(){
        
        if let author = news?["user"]{
            self.labelAuthor.text = author["name"].string
            if let id = author["id"].string{
                self.avatarAuthor.image = avatars[id]
            }
        }
        
        // POSITIVE SCROLL VIEW
        
        var avatarHeight = scrollViewPositive.height
        
        for (index,vote) in upVotes.enumerated(){
            
            let padding = CGFloat(index) * 4

            if let id = vote["user"]["id"].string{
                let img = UIImageView(frame: CGRect(x: ( CGFloat(index) * avatarHeight + padding), y: CGFloat(0), width: avatarHeight, height: avatarHeight))
                img.image = avatars[id]
                scrollViewPositive.addSubview(img)
                
                let divider = UIView(frame: CGRect(x: CGFloat(index + 1) * avatarHeight, y: 0, width: 4, height: avatarHeight ) )
                scrollViewPositive.addSubview(divider)
                
            }
        }
        
        scrollViewPositive.contentSize = CGSize(width: ( scrollViewPositive.height + CGFloat(4) ) * CGFloat(upVotes.count), height: scrollViewPositive.height)
        
        // NEGATIVE SCROLL VIEW
        
        avatarHeight = scrollViewNegative.height
        
        for (index,vote) in downVotes.enumerated(){
            
            let padding = CGFloat(index) * 4
            
            if let id = vote["user"]["id"].string{
                let img = UIImageView(frame: CGRect(x: ( CGFloat(index) * avatarHeight + padding), y: CGFloat(0), width: avatarHeight, height: avatarHeight))
                img.image = avatars[id]
                scrollViewNegative.addSubview(img)
                
                let divider = UIView(frame: CGRect(x: CGFloat(index + 1) * avatarHeight, y: 0, width: 4, height: avatarHeight ) )
                scrollViewNegative.addSubview(divider)
                
            }
        }
        
        scrollViewNegative.contentSize = CGSize(width: ( scrollViewNegative.height + CGFloat(4) ) * CGFloat(downVotes.count), height: scrollViewNegative.height)

        
        
    }
    
    func preload(){
        
        if let author = news?["user"]{
            
            if let picture = author["picture"].string{
                coms.getImage(url: picture){
                    data in
                    
                    if let data = data{
                        if let img = UIImage(data: data){
                            self.avatars[author["id"].stringValue] = img.af_imageRoundedIntoCircle()
                        }
                    }
                }
            }
        }
        
        if let votes = news?["voti"].array{
            for var vote in votes{
                if let stringa = vote["voto"].string , stringa.contains("UP"){
                    upVotes.append(vote)
                }else if let stringa = vote["voto"].string , stringa.contains("DOWN"){
                    downVotes.append(vote)
                }
            }
        }
        
        for (index,vote) in upVotes.enumerated(){
            
            if let picture = vote["user"]["picture"].string{
                coms.getImage(url: picture){
                    data in
                    
                    if let data = data{
                        if let img = UIImage(data: data){
                            self.avatars[vote["user"]["id"].stringValue] = img.af_imageRoundedIntoCircle()
                        }
                    }
                }
            }
            
        }
        
        for (index,vote) in downVotes.enumerated(){
            
            if let picture = vote["user"]["picture"].string{
                coms.getImage(url: picture){
                    data in
                    
                    if let data = data{
                        if let img = UIImage(data: data){
                            self.avatars[vote["user"]["id"].stringValue] = img.af_imageRoundedIntoCircle()
                        }
                    }
                }
            }
            
        }
        

    }
    
    // MARK: - Table view source data
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }


}
