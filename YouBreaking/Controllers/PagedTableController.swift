//
//  ListaNotizieController.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 02/02/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation

class PagedTableController: BreakingTableViewController , ListTableViewProtocol{
    
    // MARK: - Protocol Attributes
    let coms = ModelNotizie()
    var model = [JSON]()
    var reloading = true
    
    // MARK: - Class Attributes
    var sortOrder : SortOrder = SortOrder.Hot
    var location : ( String, String )?
    var heights = [Int : CGFloat]()
    
    // MARK: - UIKit Elements
    var mask : UIView?
    var loadingView : UIView?
    var loadingSpin = UIActivityIndicatorView()
    var noContentLabel = UILabel()
    
    // MARK: - UIKit Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let locationManager = CLLocationManager()
        
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        if let _ = coms.login.id{
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        let latitude = locationManager.location?.coordinate.latitude.description;
        let longitude = locationManager.location?.coordinate.longitude.description;
        if let latitude = latitude , let longitude = longitude {
            self.location = (latitude, longitude)
        }

        
        self.tableView.layoutMargins = .zero
        self.tableView.separatorStyle = .none
        
        if let nav = self.navigationController, let tab = self.tabBarController{
            
            let topHeight = nav.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height
            let totalHeight = self.tableView.bounds.height - topHeight - tab.tabBar.frame.height
            
            self.loadingView = UIView(frame : CGRect(x: 0, y: topHeight, width: self.tableView.bounds.width, height: totalHeight ) )
        }

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Ordina", style: .plain, target: self, action: Selector.init(("filtra")))
        self.refreshControl?.addTarget(self, action: Selector.init("refresh:"), for: UIControlEvents.valueChanged)
        
        let nc = NotificationCenter.default // Note that default is now a property, not a method call
        nc.addObserver(
            forName:Notification.Name(rawValue:"reloadNews"),
            object:nil,
            queue:nil){
                notification in

                if self.description != notification.userInfo?["sender"] as? String{
                    self.heights.removeAll()
                    self.reload()
                }
                
        }
        
        reload()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let nc = NotificationCenter.default
        nc.removeObserver(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.loadingView?.removeFromSuperview()
    }
    
    func refresh(_ refreshControl: UIRefreshControl) {
        // Do your job, when done:
        reload()
        refreshControl.endRefreshing()
    }
    
    // MARK: - Protocol Methods
    
    
    func reload(){
        self.tableView.contentOffset = CGPoint(x: 0, y: 0)
        if let vi = loadingView{
            noContentLabel.removeFromSuperview()
            vi.backgroundColor = Colors.lightGray
            loadingSpin = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            loadingSpin.center = CGPoint(x: vi.width/2 , y:  vi.height / 2)
            vi.addSubview(loadingSpin)
            loadingSpin.startAnimating()
            self.loadingView = vi
            self.navigationController?.view.addSubview(self.loadingView!)
        }
    }
    
    func endReload(){
        self.loadingSpin.stopAnimating()
        self.loadingView?.removeFromSuperview()
    }
    
    func endReloadNoContent(){
        self.loadingSpin.stopAnimating()
        self.loadingSpin.removeFromSuperview()
        
        if let vi = loadingView{
            noContentLabel.text = "Nessuna Notizia"
            noContentLabel.sizeToFit()
            noContentLabel.center = CGPoint(x: vi.width/2 , y:  vi.height / 2)
            vi.addSubview(noContentLabel)
        }
    }
    
    func advance(){
        
    }
    
    func filtra(){
        let alert = UIAlertController(title: "Ordina le Notizie", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(title: "Hot", style: .default, isEnabled: true){
            action in
            self.sortOrder = .Hot
            self.heights.removeAll()
            self.reload()
        }
        
        alert.addAction(title: "Recenti", style: .default, isEnabled: true){
            action in
            self.sortOrder = .Recent
            self.heights.removeAll()
            self.reload()
        }
        
        alert.addAction(title: "Punteggio", style: .default, isEnabled: true){
            action in
            self.sortOrder = .Score
            self.heights.removeAll()
            self.reload()
        }
        
        alert.addAction(title: "Eventi Vicini", style: .default, isEnabled: true){
            action in
            
            let locationManager = CLLocationManager()
            locationManager.requestWhenInUseAuthorization()
            
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
            
            let latitude = locationManager.location?.coordinate.latitude.description;
            let longitude = locationManager.location?.coordinate.longitude.description;
            if let latitude = latitude , let longitude = longitude {
                self.sortOrder = .Location
                self.location = (latitude, longitude)
            }
            self.heights.removeAll()
            self.reload()
        }
        
        alert.addAction(title: "Annulla", style : .cancel , isEnabled : true){
            action in
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var arr : [UITableViewRowAction]? = nil
        var level = self.coms.login.user?["level"] as? String
        
        if let level = level , level == "MOD" || level == "ADMIN"{
            arr = [UITableViewRowAction]()
            arr?.append(UITableViewRowAction(style: .destructive, title: "Cancella" ){
                action,indexPath in
                if let id = self.model.optionalSubscript(safe: indexPath.row)?["id"].string{
                    self.coms.deleteNews(id: id){
                        ok in
                        if(ok){
                            self.model.remove(at: indexPath.row)
                            self.tableView.beginUpdates()
                            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.top )
                            self.tableView.endUpdates()
                            NotificationCenter.default.post(Notification(name: Notification.Name("reloadNews"), object: nil, userInfo: ["sender" : self.description]))
                        }
                    }
                }
            })
            return arr
        }else{
            return [UITableViewRowAction]()
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        self.heights[indexPath.row] = cell.frame.height
        
        if(indexPath.row == ( self.model.count - 10) ){
            self.reloading = true
            DispatchQueue.global(qos: .background).async {
                self.advance()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = self.heights[indexPath.row]{
            return height
        }
        return UITableViewAutomaticDimension
    }
    
}

// MARK: - News Controller Delegate Extension

extension PagedTableController : NewsControllerDelegate{
    func removeMask() {
        if let nvc = self.navigationController, let modalMask = nvc.view.viewWithTag(999){
            UIView.animate(withDuration: 0.3, animations: {
                self.mask?.alpha = 0
            }, completion: {
                _ in
                self.mask?.removeFromSuperview()
            })
        }
    }
}
