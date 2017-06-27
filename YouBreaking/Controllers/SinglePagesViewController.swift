//
//  SinglePagesViewController.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 27/06/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit
import SwiftyJSON

class SinglePagesViewController: UIPageViewController {
    
    // MARK: - Class Elements
    var controllers = [UIViewController]()
    var data : JSON?
    var nextIndex = 0
    var currentIndex = 0
    var scrollInsets : UIEdgeInsets?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        self.reload()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reload(){
        var newControllers = [UIViewController]()
        if let textViewController = UIStoryboard(name: "Content", bundle: Bundle.main).instantiateViewController(withIdentifier: "Single Text View Controller") as? SingleTextViewController{
            textViewController.data = data
            if let insets = scrollInsets{
                textViewController.insets = insets
            }
            textViewController.delegate = self.parent as? SingleContentViewController
            newControllers.append(textViewController)
        }

        self.setViewControllers([newControllers.first!], direction: .forward, animated: false, completion: nil)
        self.controllers = newControllers
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


// MARK: - Page View Controller Delegate Extension
extension SinglePagesViewController : UIPageViewControllerDelegate{
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, finished, let vc = self.controllers.optionalSubscript(safe: nextIndex){
            self.currentIndex = nextIndex
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
extension SinglePagesViewController : UIPageViewControllerDataSource{
    
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
