//
//  NewsPagesController.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 28/02/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON

class NewsPagesController: UIPageViewController {
    
    // MARK: - Class Elements
    var controllers = [UIViewController]()
    var titles = [String]()
    var heightDelegate : HeightDelegate?
    var menu : UISegmentedControl?
    var data : JSON?
    var nextIndex = 0
    var currentIndex = 0
    let coms = ModelNotizie()
    
    // MARK: - UIKit Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        
        self.view.backgroundColor = Colors.lightGray
        
        let first = UIStoryboard(name: "Single", bundle: Bundle.main).instantiateViewController(withIdentifier: "News Text Page") as! NewsTextTableViewController
        first.delegate = self.heightDelegate
        first.text = data?["text"].string
        controllers.append(first)
        titles.append("Notizia")
        
        var comps = [String : String]()
        
        if let aggiuntivi = data?["aggiuntivi"].array{
            _ = aggiuntivi.map{
                if let temp =  $0.dictionary , let tipo = temp["tipo"]?.string{
                    comps[tipo] = temp["valore"]!.stringValue
                }
            }
            
            if data?["evento"]["id"].string != nil || (comps["LOCATION_LATITUDE"] != nil && comps["LOCATION_LONGITUDE"] != nil) || comps["LINK"] != nil  {

                let second = UIStoryboard(name: "Single", bundle: Bundle.main).instantiateViewController(withIdentifier: "News Info Controller") as! NewsInfoViewController
                second.news = data
                controllers.append(second)
                titles.append("Info")
            }
            
        }
        
        
        let third = UIStoryboard(name: "Single", bundle: Bundle.main).instantiateViewController(withIdentifier: "News Users Table") as! NewsUsersTableViewController
        controllers.append(third)
        titles.append("Utenti")
        
        var query = ["fields" : "voti"]
        
        if let idNews = data?["id"].string {
            
            coms.getSingleNews(id: idNews , query : query){
                model in
                third.news = model
                third.preload()
            }
            
        }
        
        self.setViewControllers([first], direction: .forward, animated: false, completion: nil)
        
        menu?.segmentTitles = titles
        menu?.selectedSegmentIndex = 0
        
        menu?.addTarget(self, action:  #selector( NewsPagesController.menuValueChanged(menu:) ), for: .valueChanged)
    }
    
    // MARK: - Class Methods
    func menuValueChanged(menu : UISegmentedControl){
        self.changeController(index: menu.selectedSegmentIndex)
    }
    
    func changeController(index : Int){
        if let vc = self.controllers.optionalSubscript(safe: index){
            
            if(index > currentIndex){
                self.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
            }else{
                self.setViewControllers([vc], direction: .reverse, animated: true, completion: nil)
            }
            
            self.currentIndex = index
            
            self.viewControllerAnimation(controller: vc)
            
        }
    }
    
    func viewControllerAnimation(controller : UIViewController){
        if let vc = controller as? NewsTextTableViewController{
            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: UInt64.init(9*100) )){
                self.heightDelegate?.heightChanged(height: vc.tableView.contentOffset.y, animated : true, completition : nil)
            }
        }else if let vc = controller as? NewsInfoViewController{
            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: UInt64.init(9*100) )){
                self.heightDelegate?.heightChanged(height: nil, animated : true, completition : nil)
            }
            
        }else{
            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: UInt64.init(9*100) )){
                self.heightDelegate?.heightChanged(height: 0, animated : true, completition : nil)
            }
        }
    }

}

// MARK: - Page View Controller Delegate Extension
extension NewsPagesController : UIPageViewControllerDelegate{
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, finished, let vc = self.controllers.optionalSubscript(safe: nextIndex){
            self.currentIndex = nextIndex
            self.menu?.selectedSegmentIndex = currentIndex
            self.viewControllerAnimation(controller : vc)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let vc = pendingViewControllers.first{
            if let index = controllers.index(of: vc){
                self.nextIndex = index
            }
        }
    }
}

// MARK: - Page View Controller Data Source Extension
extension NewsPagesController : UIPageViewControllerDataSource{
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let indexController = controllers.index(of: viewController){
            if(indexController > 0){
                return controllers[indexController - 1]
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let indexController = controllers.index(of: viewController){
            if(indexController < (controllers.count - 1) ){
                return controllers[indexController + 1]
            }
        }
        return nil
    }
    
}
