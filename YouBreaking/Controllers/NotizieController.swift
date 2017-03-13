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

enum SortOrder : String{
    case Score = "score"
    case Location = "location"
    case Recent = "recent"
    case Hot = "hot"
}

class NotizieController: UITableViewController , NotiziaCellDelegate{
    
    internal func vote(voto: Voto, sender : NotiziaCell) {
        if let row = self.tableView.indexPath(for: sender)?.row{
            if let newsId = model[row].dictionaryValue["id"]?.stringValue{
                coms.vote(voto: voto, notizia: newsId){
                    response in
                    
                    let nc = NotificationCenter.default
                    nc.post(Notification(name: Notification.Name("reloadNews")))
                }
            }
            
        }
        
        
    }
    
    let coms = ModelNotizie()
    var model = [JSON]()
    
    var reloading = true
    
    var sortOrder : SortOrder = SortOrder.Hot
    
    var location : ( String, String )?
    var mask : UIView?

    var loadingView : UIView?
    var loadingSpin = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView = UIView(frame : self.view.frame)
        reload()
        
        self.tableView.layoutMargins = .zero
        
        let nc = NotificationCenter.default // Note that default is now a property, not a method call
        nc.addObserver(forName:Notification.Name(rawValue:"reloadNews"),
                       object:nil, queue:nil){
                        notification in
                        if self.description != notification.userInfo?["sender"] as? String{
                            self.reload()
                        }
                        
        }
        
        self.tableView.register(UINib.init(nibName: "NotiziaCell", bundle: Bundle.main), forCellReuseIdentifier: "notizia")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Ordina", style: .plain, target: self, action: Selector.init(("filtra")))
        self.refreshControl?.addTarget(self, action: Selector.init("refresh:"), for: UIControlEvents.valueChanged)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let nc = NotificationCenter.default
        nc.removeObserver(self)
    }
    
    func refresh(_ refreshControl: UIRefreshControl) {
        // Do your job, when done:
        reload()
        refreshControl.endRefreshing()
    }
    
    func endReload(){
        self.loadingSpin.startAnimating()
        self.loadingView?.removeFromSuperview()
    }
    
    func reload(){
        if let vi = loadingView{
            print(vi.frame)
            vi.backgroundColor = Colors.lightGray
            loadingSpin = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            loadingSpin.center = vi.center
            vi.addSubview(loadingSpin)
            loadingSpin.stopAnimating()
            self.loadingView = vi
            self.view.addSubview(self.loadingView!)
        }
    }
    
    func advance(){
        
    }
    
    func filtra(){
        let alert = UIAlertController(title: "Ordina le Notizie", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(title: "Hot", style: .default, isEnabled: true){
            action in
            self.sortOrder = .Hot
            self.reload()
        }
        
        alert.addAction(title: "Recenti", style: .default, isEnabled: true){
            action in
            self.sortOrder = .Recent
            self.reload()
        }
        
        alert.addAction(title: "Punteggio", style: .default, isEnabled: true){
            action in
            self.sortOrder = .Score
            self.reload()
        }
        
        alert.addAction(title: "Eventi Vicini", style: .default, isEnabled: true){
            action in
            
            let locationManager = CLLocationManager()
            locationManager.requestAlwaysAuthorization()
            
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
            
            let latitude = locationManager.location?.coordinate.latitude.description;
            let longitude = locationManager.location?.coordinate.longitude.description;
            if let latitude = latitude , let longitude = longitude {
                self.sortOrder = .Location
                self.location = (latitude, longitude)
            }
            self.reload()
        }
        
        alert.addAction(title: "Annulla", style : .cancel , isEnabled : true){
            action in
        }
        
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notizia", for: indexPath) as! NotiziaCell
        
        if let contenuto = model.optionalSubscript(safe: indexPath.row){
            cell.model = contenuto
            cell.delegate = self
        }
        
        if(indexPath.row % 2 == 0){
            cell.backgroundColor = Colors.white
        }else{
            cell.backgroundColor = Colors.lightGray
        }
                
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        cell.layoutSubviews()
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

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
        return UITableViewAutomaticDimension
    }
    
    func performSegueToEvent(eventId: String , sender : NotiziaCell) {
        performSegue(withIdentifier: "Select Event", sender: sender)
    }
    
    func performSegueToSingle(id: String, sender: NotiziaCell) {
        performSegue(withIdentifier: "Select News", sender: sender)
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let identifier = segue.identifier {
            switch identifier {
            case "Select Event":
                if let dvc = segue.destination as? EventPageController,  let cell = sender as? NotiziaCell{
                    let index = self.tableView.indexPath(for: cell)
                    if let row = index?.row , let eventId = self.model.optionalSubscript(safe: row)?["evento"]["id"].string{
                        dvc.eventId = eventId
                    }
                }
                
                
                break
            case "Select News":
                if let dvc = segue.destination as? NewsController, let indexPath = self.tableView.indexPath(for: sender as! NotiziaCell){
                    dvc.data = self.model.optionalSubscript(safe: indexPath.row)
                    dvc.delegate = self
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }
                if let nvc = self.navigationController{
                    mask = UIView(frame : nvc.view.frame)
                    mask!.backgroundColor = Colors.darkGray
                    mask!.alpha = 0.3
                    mask!.tag = 999
                    nvc.view.addSubview(mask!)
                }
            default:
                break
            }
        }
    }
    
    
}

extension NotizieController : NewsControllerDelegate{
    func removeMask() {
        if let nvc = self.navigationController, let modalMask = nvc.view.viewWithTag(999){
            UIView.animate(withDuration: 0.3){
                modalMask.removeFromSuperview()
            }
        }
    }
}

extension Collection where Indices.Iterator.Element == Index {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    func optionalSubscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
