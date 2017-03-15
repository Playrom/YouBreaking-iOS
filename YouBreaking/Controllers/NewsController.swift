//
//  NewsController.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 28/02/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit
import SwiftyJSON
import Lightbox

class NewsController: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var menu: UISegmentedControl!
    @IBOutlet weak var crossView: UIImageView!
    
    @IBOutlet weak var arrowUp: UIImageView!
    @IBOutlet weak var arrowDown: UIImageView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var currentVote : Voto = Voto.NO
    
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
    let blurEffectView = UIVisualEffectView()
    
    var finalHeight : CGFloat = 130
    var initialHeight : CGFloat = 250

    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    var baseImageHeight : CGFloat? = nil
    
    var data : JSON?
    var coms = ModelNotizie()
    
    var delegate : ( NewsControllerDelegate & SingleNewsModalDelegate )?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.baseImageHeight = imageViewHeightConstraint.constant
        reload()
        
        self.containerView.backgroundColor = Colors.darkGray
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(NewsController.displayImage))
        tapGesture.numberOfTapsRequired = 1
        headerView.isUserInteractionEnabled = true
        headerView.addGestureRecognizer(tapGesture)
        
        blurEffectView.frame = self.imageView.bounds
        self.imageView.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        
        crossView.image = crossView.image!.withRenderingMode(.alwaysTemplate)
        crossView.tintColor = Colors.white
        let tapDismiss = UITapGestureRecognizer(target: self, action: #selector(NewsController.dismissTap))
        tapDismiss.numberOfTapsRequired = 1
        crossView.addGestureRecognizer(tapDismiss)
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func reload() {
        
        titleLabel.text = data?["title"].string
        
        var comps = [String : String]()
        
        if let aggiuntivi = data?["aggiuntivi"].array{
            _ = aggiuntivi.map{
                if let temp =  $0.dictionary , let tipo = temp["tipo"]?.string{
                    comps[tipo] = temp["valore"]!.stringValue
                }
            }
            
            
            if comps["PHOTO"] != nil{
                
                coms.getPhoto(photo: comps["PHOTO"]!){
                    image in
                    self.imageView.image = image
                    
                    self.imageView.setNeedsLayout()
                    self.imageView.layoutSubviews()
                    
                }
            }else{
                self.initialHeight = finalHeight
                self.imageViewHeightConstraint.constant = finalHeight
                self.maskView.backgroundColor = UIColor.clear
                self.headerView.backgroundColor = Colors.red
            }
        }
        
        self.scoreLabel.text = data?["score"].int?.description
        
        if let vote = data?["voto_utente"].dictionary{
            if let v = vote["voto"]?.stringValue , v.contains("UP"){
                self.setVoteImages(voto: .UP)
            }
            
            if let v = vote["voto"]?.stringValue , v.contains("DOWN"){
                self.setVoteImages(voto: .DOWN)
            }
        }else{
            self.setVoteImages(voto: .NO)
        }
        
        let tapUp = UITapGestureRecognizer(target: self, action: #selector(NewsController.voteUp))
        tapUp.numberOfTapsRequired = 1
        arrowUp.isUserInteractionEnabled = true
        arrowUp.addGestureRecognizer(tapUp)
        
        let tapDown = UITapGestureRecognizer(target: self, action: #selector(NewsController.voteDown))
        tapDown.numberOfTapsRequired = 1
        arrowDown.isUserInteractionEnabled = true
        arrowDown.addGestureRecognizer(tapDown)
        
        
    }
    
    func setVoteImages(voto : Voto){
        switch voto {
        case .UP:
            arrowUp.image = Images.imageOfArrowUpFill
            arrowDown.image = Images.imageOfArrowDown
            break
        case .DOWN:
            arrowUp.image = Images.imageOfArrowUp
            arrowDown.image = Images.imageOfArrowDownFill
            break
        case .NO:
            arrowUp.image = Images.imageOfArrowUp
            arrowDown.image = Images.imageOfArrowDown
            break
        }
        
        arrowUp.image = arrowUp.image!.withRenderingMode(.alwaysTemplate)
        arrowUp.tintColor = UIApplication.shared.delegate?.window??.tintColor
        
        arrowDown.image = arrowDown.image!.withRenderingMode(.alwaysTemplate)
        arrowDown.tintColor = UIApplication.shared.delegate?.window??.tintColor
        
        self.currentVote = voto
        
    }

    
    func voteUp(){
        if let data = data{
            
            if (self.currentVote == Voto.UP) {
                setVoteImages(voto: .NO)
                self.vote(voto: .NO )
            }else{
                setVoteImages(voto: .UP)
                self.vote(voto: .UP )
            }
            
            
            
        }
    }
    
    func voteDown(){
        if let data = data{
            
            if (self.currentVote == Voto.DOWN) {
                setVoteImages(voto: .NO)
                self.vote(voto: .NO )
            }else{
                setVoteImages(voto: .DOWN)
                self.vote(voto: .DOWN )
            }
        }
        
    }
    
    internal func vote(voto: Voto) {
        self.delegate?.vote(voto: voto, sender: self)
    }
    
    func dismissTap(){
        self.delegate?.removeMask()
        self.dismiss(animated: true, completion: nil)
    }
    
    func displayImage(){
        // Create an array of images.
        if let image = self.imageView.image{
            let testo = data?["title"].string != nil ? data!["title"].string! : ""
            
            let images = [
                LightboxImage(
                    image: image,
                    text: testo
                )
            ]
            
            // Create an instance of LightboxController.
            let controller = LightboxController(images: images)
            
            
            // Use dynamic background.
            controller.dynamicBackground = true
            
            // Present your controller.
            present(controller, animated: true, completion: nil)
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "Embed Page Controller", let dvc = segue.destination as? NewsPagesController{
            dvc.heightDelegate = self
            dvc.data = self.data
            dvc.menu = self.menu
        }
        
    }
    
    var originalPosition: CGPoint?
    var originalSize : CGSize?
    var currentPositionTouched: CGPoint?

    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    @IBAction func panGestureAction(_ panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: view)
        
        if panGesture.state == .began {
            originalPosition = view.frame.origin
            originalSize = view.size
            
            currentPositionTouched = panGesture.location(in: view)
        } else if panGesture.state == .changed {
            let padding = translation.y / 10
            
            var point = CGPoint()
            
            if(translation.y > 0){
                point = CGPoint(
                    x: padding ,
                    y: translation.y
                )
            }
            
            if(point.y > 0){
                view.frame.origin = point
                view.frame.size.width =  originalSize!.width - ( 2 * padding)
                
                view.alpha = ( originalSize!.height - ( translation.y / 2 ) ) / originalSize!.height
                
            }
        } else if panGesture.state == .ended {
            let velocity = panGesture.velocity(in: view)
            
            if velocity.y >= 1500 {
                UIView.animate(withDuration: 0.2
                    , animations: {
                        self.view.frame.origin = CGPoint(
                            x: self.view.frame.origin.x,
                            y: self.view.frame.size.height
                        )
                }, completion: { (isCompleted) in
                    if isCompleted {
                        self.delegate?.removeMask()
                        self.dismiss(animated: false, completion: nil)
                    }
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.view.frame.origin = self.originalPosition!
                    self.view.size = self.originalSize!
                    self.view.alpha = 1
                })
            }
        }
    }

}

extension LightboxController{
    open override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
}

extension NewsController : HeightDelegate{
    func heightChanged(height : CGFloat?, animated : Bool , completition handler : ( (Void) -> () )? ){
        
        var newConstant : CGFloat? = nil
        
        if(self.imageView.image != nil){
        
            if let forced = baseImageHeight, let height = height{
                let reduced = height
                let final = forced - reduced/3
                
                if(final > finalHeight){
                    newConstant = final
                }else{
                    newConstant = finalHeight
                }
            }else{
                newConstant = finalHeight
            }
            
            if let ct = newConstant{
                
                let originalHeight = self.imageViewHeightConstraint.constant

                self.imageViewHeightConstraint.constant = ct
                
                if !UIAccessibilityIsReduceTransparencyEnabled(), let height = height, height > 0 {
                    
                    if(ct > initialHeight - 20){
                        UIView.animate(withDuration: 0.3 , animations: {
                            self.blurEffectView.effect = nil
                            self.blurEffectView.cornerRadius = 2
                        })
                    }else if(ct > finalHeight + 50){
                        UIView.animate(withDuration: 0.3 , animations: {
                            self.blurEffectView.effect = self.blurEffect
                            self.blurEffectView.cornerRadius = 5
                        })
                    }else if(ct > finalHeight - 1){
                        UIView.animate(withDuration: 0.3 , animations: {
                            self.blurEffectView.effect = self.blurEffect
                            self.blurEffectView.cornerRadius = 10
                        })
                    }
                    

                    
                }
                
                
                
                
                if(animated){
                    UIView.animate(withDuration: 0.5, animations: {
                        self.view.layoutIfNeeded()
                    }, completion: {
                        _ in
                        if let handler = handler {
                            handler()
                        }
                    })
                }
            }
                
        }
    }
    
}

protocol NewsControllerDelegate{
    func removeMask()
}
