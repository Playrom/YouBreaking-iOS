//
//  SingleContentViewController.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 11/06/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit
import Hero
import SwiftyJSON

class SingleContentViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var blurredEffectView: UIVisualEffectView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var textBackgroundView: UIView!
    @IBOutlet weak var spinnerLoadingView: UIActivityIndicatorView!
    @IBOutlet weak var containerView: UIView!

    
    @IBOutlet weak var contentScollViewToHeaderImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentScrollViewToTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerImageHeightConstraint: NSLayoutConstraint!
    
    var pageController : SinglePagesViewController?
    
    var imageForHeader : UIImage?
    var coms = ModelNotizie()
    var data : JSON?
    var headerImageHeightOriginal : CGFloat = 130
    let minimumHeaderImageHeight : CGFloat = 64
    var scrollViewOffset = CGPoint(x: 0, y: 0)
    var effect : UIBlurEffect?
    
    var scrollViewInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    // MARK: - UIKit Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //headerImage.heroModifiers = [.duration(4)]

        self.headerImageHeightOriginal = self.headerImageHeightConstraint.constant
        self.headerImage.image = imageForHeader
        
        effect = blurredEffectView.effect as? UIBlurEffect
        self.blurredEffectView.effect = nil
        
        self.textBackgroundView.backgroundColor = Colors.lightBlack
        self.textBackgroundView.alpha = 0.7
        
        if(self.imageForHeader == nil){
            self.headerImageHeightConstraint.constant = 0
//            self.automaticallyAdjustsScrollViewInsets = true
            
            self.contentScollViewToHeaderImageConstraint.isActive = false
            self.contentScrollViewToTopMarginConstraint.isActive = true
            
            var topInset : CGFloat = 20;
            
            if let nav = self.navigationController {
                topInset = topInset + nav.navigationBar.bounds.size.height;
            }
            
            scrollViewInsets = UIEdgeInsetsMake(topInset, 0, 0, 0);

        }
        
        if let id = self.data?["id"].string{
            coms.getSingleNews(id: id, query: [String:String]()){
                json in
                if let content = json{
                    self.propagate(content)
                }
                self.spinnerLoadingView.stopAnimating()
                UIView.animate(withDuration: 0.4){
                    self.loadingView.removeFromSuperview()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(self.imageForHeader != nil){
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.isTranslucent = true
        }else{

        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

//        if(self.imageForHeader != nil){
//            if let pageOne = pageController?.viewControllers?.first as? SingleTextViewController{
//                pageOne.contentScrollView.contentOffset = scrollViewOffset;
//            }
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func propagate(_ json : JSON){
        self.updatePagesController()
        self.pageController?.data = json
        self.pageController?.reload()
    }
    
    func updatePagesController(){
        if(self.imageForHeader == nil){
            pageController?.scrollInsets = scrollViewInsets
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? SinglePagesViewController{
            self.pageController = dvc
            updatePagesController()
        }
    }

    @IBAction func dismissGesture(_ sender: UIPanGestureRecognizer) {
        self.dismissGestureControll(panGesture: sender)
    }
    @IBAction func close(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func dismissGestureControll(panGesture: UIPanGestureRecognizer) {
        
        if( panGesture.velocity(in: view).y > 1000 ){
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - Extensions

extension SingleContentViewController : UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if(scrollView.contentOffset.y < -120){
            self.dismiss(animated: true, completion: nil)
        }
        
        if(imageForHeader != nil){
        
            let maxScroll = scrollView.contentSize.height - scrollView.frame.size.height;
            
            
            print(scrollView.contentOffset)
            if(scrollView.contentOffset.y < 0){
                
                scrollViewOffset = scrollView.contentOffset
                self.headerImageHeightConstraint.constant = self.headerImageHeightOriginal - scrollView.contentOffset.y

            }else if(scrollView.contentOffset.y > 5 && scrollView.contentOffset.y < maxScroll){
                scrollViewOffset = scrollView.contentOffset
                if(self.headerImageHeightOriginal - scrollView.contentOffset.y / 3 > self.minimumHeaderImageHeight){
                    self.headerImageHeightConstraint.constant = self.headerImageHeightOriginal - scrollView.contentOffset.y / 3
                }else{
                    self.headerImageHeightConstraint.constant = self.minimumHeaderImageHeight
                }
                
                if(scrollView.contentOffset.y > 30){
                    UIView.animate(withDuration: 0.8){
                        self.blurredEffectView.effect = self.effect
                    }
                }else{
                    UIView.animate(withDuration: 0.2){
                        self.blurredEffectView.effect = nil
                    }
                }
                
                
            }
        }
        
    }
}
