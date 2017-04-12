//
//  AuthorViewController.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 28/02/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit
import SwiftyJSON
import Lightbox
import PromiseKit

class AuthorViewController: BreakingViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var avatarView: UIImageView!
    
    // MARK: - UIKit Elements
    var loadingView : UIView?
    var loadingSpin = UIActivityIndicatorView()
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .default
    }
    
    // MARK: - Class Elements
    var author : JSON?
    var authorId : String?
    var coms = ModelNotizie()
    
    // MARK: - UIKit Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        if let nav = self.navigationController{
            
            let totalHeight = self.view.bounds.height
            
            self.loadingView = UIView(frame : CGRect(x: 0, y: 0, width: self.view.bounds.width, height: totalHeight ) )
        }
        
        reload()
        
        self.containerView.backgroundColor = Colors.darkGray
        
        let crossImage = UIImage(named: "Cross")?.withRenderingMode(.alwaysTemplate)
        if let crossImage = crossImage{
            let imageView = UIImageView(image: crossImage)
            imageView.tintColor = Colors.white
            imageView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
            imageView.contentMode = .scaleAspectFit
            
            self.navigationController?.navigationBar.tintColor = Colors.red
 
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = Colors.red

        
    }
    
    // MARK: - Class Methods
    func preload() {
        if let id = authorId{
            let query = [String:String]()
            coms.getUser(id: id, query: query){
                response in
                self.author = response
            }
        }
    }
    
    func reload(){
        
        if let vi = loadingView{
            
            vi.backgroundColor = Colors.lightGray
            loadingSpin = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            loadingSpin.center = CGPoint(x: vi.width/2 , y:  vi.height / 2)
            vi.addSubview(loadingSpin)
            loadingSpin.startAnimating()
            self.loadingView = vi
            self.view.addSubview(self.loadingView!)
        }
        
        if let  _ = author?["name"].string{
            
            titleLabel.text = author?["name"].string
            
            if let picture = author?["picture"].string{
                coms.getImage(url: picture)
                .then{
                    image -> Void in
                    self.avatarView.image = image.af_imageRoundedIntoCircle()
                    self.avatarView.setNeedsLayout()
                    self.avatarView.layoutSubviews()
                    self.endReload()
                }
                .catch { error in
                }
            }
        }else{
            if let id = authorId{
                let query = [String:String]()
                coms.getUser(id: id, query: query){
                    response in
                    self.author = response
                    
                    self.titleLabel.text = self.author?["name"].string
                    
                    if let picture = self.author?["picture"].string{
                        self.coms.getImage(url: picture)
                        .then{
                            image -> Void in
                            self.avatarView.image = image.af_imageRoundedIntoCircle()
                            self.avatarView.setNeedsLayout()
                            self.avatarView.layoutSubviews()
                            self.endReload()
                                
                        }
                    }
                    
                }
            }
        }

    }
    

    func endReload(){
        self.loadingSpin.stopAnimating()
        self.loadingView?.removeFromSuperview()
    }



    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SelectAuthorSectionsTableViewController, segue.identifier == "Embed Table"{
            vc.authorId = authorId
        }
    }
}
