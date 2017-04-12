//
//  NewsUsersTableViewController.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 16/03/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit
import SwiftyJSON
import PromiseKit

class NewsUsersTableViewController: UITableViewController{
    
    // MARK: - IBOutlets
    @IBOutlet weak var avatarAuthor: UIImageView!
    @IBOutlet weak var labelAuthor: UILabel!
    @IBOutlet weak var scrollViewPositive: UIScrollView!
    @IBOutlet weak var scrollViewNegative: UIScrollView!
    
    // Mark: - UIKit Elements
    let spinAuthor = UIActivityIndicatorView()
    var loadingView : UIView?
    var loadingSpin = UIActivityIndicatorView()
    
    // MARK: - Class Elements
    var news : JSON?
    var upVotes = [JSON]()
    var downVotes = [JSON]()
    fileprivate var avatars = [String:UIImage](){
        didSet{
            self.endReload()
        }
    }
    let coms = ModelNotizie()
    
    // MARK: - UIKit Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preload()
    }
    
    // MARK: - Class Methods
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

        self.endReload()
        
    }
    
    func endReload(){
        self.loadingView?.removeFromSuperview()
        self.loadingSpin.stopAnimating()
    }
    
    func preload(){
        
        self.loadingView = UIView(frame : self.parent!.view.frame)
        self.loadingView?.backgroundColor = Colors.white
        self.loadingSpin.activityIndicatorViewStyle = .gray
        self.loadingSpin.center = CGPoint(x: self.parent!.view.width/2 , y:  self.parent!.view.height / 2)
        self.loadingView?.addSubview(self.loadingSpin)
        self.parent?.view.addSubview(self.loadingView!)
        self.loadingSpin.startAnimating()
        
        var promises = [Promise<Void>]()
        
        if let author = news?["user"]{
            
            if let picture = author["picture"].string{
                let item = coms.getImage(url: picture).then{
                    image -> Void in
                    self.avatars[author["id"].stringValue] = image.af_imageRoundedIntoCircle()
                }
                promises.append(item)
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
        
        for (_,vote) in upVotes.enumerated(){
            
            if let picture = vote["user"]["picture"].string{
                let item = coms.getImage(url: picture).then{
                    image -> Void in
                    self.avatars[vote["user"]["id"].stringValue] = image.af_imageRoundedIntoCircle()
                }
                promises.append(item)
            }
            
        }
        
        for (_,vote) in downVotes.enumerated(){
            
            if let picture = vote["user"]["picture"].string{
                let item = coms.getImage(url: picture).then{
                    image -> Void in
                    self.avatars[vote["user"]["id"].stringValue] = image.af_imageRoundedIntoCircle()
                }
                promises.append(item)
            }
            
        }
        
        _ = when(fulfilled: promises).then{ _ -> () in
            print(self.avatars.description)
            self.reload()
        }
        

    }
    
    // MARK: - Table view source data
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0){
            let vc = UIStoryboard(name: "Single", bundle: Bundle.main).instantiateViewController(withIdentifier: "Author Controller") as! AuthorViewController
            vc.authorId = news?["user"]["id"].string
            vc.preload()
            if let nav = self.parent?.parent?.navigationController {
                nav.pushViewController(vc, animated: true)
            }
        }
    }

}
