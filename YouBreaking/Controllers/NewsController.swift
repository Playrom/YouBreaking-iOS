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
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var menu: UISegmentedControl!
    
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
    let blurEffectView = UIVisualEffectView()

    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    var baseImageHeight : CGFloat? = nil
    
    var data : JSON?
    var coms = ModelNotizie()
    
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
            }
        }
        
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.baseImageHeight = imageViewHeightConstraint.constant
        reload()
        
        self.containerView.backgroundColor = Colors.darkGray
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(NewsController.displayImage))
        tapGesture.numberOfTapsRequired = 1
        headerView.isUserInteractionEnabled = true
        headerView.addGestureRecognizer(tapGesture)
        
        print(self.transitioningDelegate)

        blurEffectView.frame = self.imageView.bounds
        self.imageView.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
    
    @IBAction func dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var originalPosition: CGPoint?
    var currentPositionTouched: CGPoint?

    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    @IBAction func panGestureAction(_ panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: view)
        
        if panGesture.state == .began {
            originalPosition = view.center
            currentPositionTouched = panGesture.location(in: view)
        } else if panGesture.state == .changed {
            let point = CGPoint(
                x: view.frame.origin.x ,
                y: translation.y
            )
            
            if(point.y > 0){
                view.frame.origin = point
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
                        self.dismiss(animated: false, completion: nil)
                    }
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.view.center = self.originalPosition!
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
        
        if let forced = baseImageHeight, let height = height{
            //print("Forced: \(forced)")
            let reduced = height 
            //print("Reduced: \(reduced)")
            let final = forced - reduced/3
            //print("Final: \(final)")
            
            if(final > 100){
                newConstant = final
            }else{
                newConstant = 100
            }
        }else{
            newConstant = 100
        }
        
        if let ct = newConstant{
            
            let originalHeight = self.imageViewHeightConstraint.constant

            self.imageViewHeightConstraint.constant = ct
            
            if !UIAccessibilityIsReduceTransparencyEnabled(), let height = height, height > 0 {
                
                if(ct > 230){
                    UIView.animate(withDuration: 0.3 , animations: {
                        self.blurEffectView.effect = nil
                        self.blurEffectView.cornerRadius = 2
                    })
                }else if(ct>150){
                    UIView.animate(withDuration: 0.3 , animations: {
                        self.blurEffectView.effect = self.blurEffect
                        self.blurEffectView.cornerRadius = 5
                    })
                }else if(ct>99){
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
