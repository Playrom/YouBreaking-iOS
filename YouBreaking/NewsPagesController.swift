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
    
    var controllers = [UIViewController]()
    var titles = [String]()
    var heightDelegate : HeightDelegate?
    var menu : UISegmentedControl?
    var data : JSON?
    var nextIndex = 0
    var currentIndex = 0
    let geocoder = CLGeocoder()
    
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
        
        
        self.setViewControllers([first], direction: .forward, animated: false, completion: nil)
        
        var comps = [String : String]()
        
        if let aggiuntivi = data?["aggiuntivi"].array{
            _ = aggiuntivi.map{
                if let temp =  $0.dictionary , let tipo = temp["tipo"]?.string{
                    comps[tipo] = temp["valore"]!.stringValue
                }
            }
            
            if let latitudeString =  comps["LOCATION_LATITUDE"] , let longitudeString = comps["LOCATION_LONGITUDE"], let latitude = Double(latitudeString) , let longitude = Double(longitudeString){
                
                let second = UIViewController()
                let map = MKMapView(frame: second.view.frame)
                map.isScrollEnabled = false
                map.isZoomEnabled = false
                map.region = MKCoordinateRegionMake(CLLocationCoordinate2D(latitude: latitude , longitude: longitude )  , MKCoordinateSpanMake(0.05, 0.05) )
                
                
                
                map.removeAnnotations(map.annotations)
                
                geocoder.reverseGeocodeLocation(CLLocation(latitude: latitude , longitude: longitude)){
                    place, error in
                    if let place = place?.first , let location = place.location{
                        
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = location.coordinate
                        annotation.title = comps["LOCATION_NAME"]
                        annotation.subtitle = place.contextString
                        map.addAnnotation(annotation)
                        
                        let span = MKCoordinateSpanMake(0.05, 0.05)
                        let region = MKCoordinateRegionMake(location.coordinate, span)
                        map.setRegion(region, animated: true)
                    }
                    
                }
                
                
                
                
                second.view.addSubview(map)
                controllers.append(second)
                
                titles.append("Mappa")
            }
        }
        
        menu?.segmentTitles = titles
        menu?.selectedSegmentIndex = 0
        
        menu?.addTarget(self, action:  #selector( NewsPagesController.menuValueChanged(menu:) ), for: .valueChanged)

        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func menuValueChanged(menu : UISegmentedControl){
        self.changeController(index: menu.selectedSegmentIndex)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
        }else{
            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: UInt64.init(9*100) )){
                self.heightDelegate?.heightChanged(height: nil, animated : true, completition : nil)
            }
        }
    }

}

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

protocol HeightDelegate{
    func heightChanged(height : CGFloat?, animated : Bool , completition handler : ( (Void) -> () )? )
}

