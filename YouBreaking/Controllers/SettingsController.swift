//
//  SettingsController.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 08/02/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit
import SwiftyJSON
import MapKit
import CoreLocation

class SettingsController: UITableViewController {
    
    var place : MKPlacemark?
    
    var editingData : Bool = false
        
    var data : JSON?
    
    var coms = ModelNotizie()
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    
    var selectedRow : Int?
    var locationType = NotificationLocation.None
    
    @IBAction func editAction(_ sender: UIBarButtonItem) {
        if(editingData){
            
            nameField.textColor = .gray
            emailField.textColor = .gray
            
            nameBorder.isHidden = true
            emailBorder.isHidden = true
            
            editingData = false
            
            var params = [ String :Any ]()
            
            if let text = nameField.text{
                params["name"] = text
            }
            
            if let text = emailField.text{
                params["email"] = text
            }
            
            coms.updateProfile(parameters: params){
                _ in
            }
            
            let newButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(SettingsController.editAction(_:)))
            self.navigationItem.rightBarButtonItem = newButton
            
        }else{
            
            nameBorder.isHidden = false
            emailBorder.isHidden = false
            
            
            nameField.textColor = .black
            emailField.textColor = .black
            
            nameField.isEnabled = true
            emailField.isEnabled = true

            editingData = true
            
            let newButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(SettingsController.editAction(_:)))
            self.navigationItem.rightBarButtonItem = newButton
        }
    }
    
    func reload(){
        nameField.textColor = .gray
        emailField.textColor = .gray
        
        nameField.text = data?["name"].string
        emailField.text = data?["email"].string
        
        activityIndicator.center = image.center
        activityIndicator.startAnimating()
        
        if let imageUrl = data?["picture"].string{

            coms.getImage(url: imageUrl){
                responseData in
                if let responseData = responseData{
                    let img = UIImage(data: responseData)
                    if let img = img{
                        self.image.image = img.af_imageRoundedIntoCircle()
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        }
        
        if let location = data?["location"]{
            
            if let type = location["type"].string{
                
                let temp = NotificationLocation(rawValue: type)
                
                self.locationType = temp != nil ? temp! : .None
                                
                if(self.locationType == .Gps){
                    self.locationManager.startUpdatingLocation()
                }
                
                if(self.locationType == .Place){
                    let latitude = Double(location["latitude"].stringValue)
                    let longitude = Double(location["longitude"].stringValue)
                    
                    
                    if let latitude = latitude , let longitude = longitude{
                        let location = CLLocation(latitude: latitude, longitude: longitude)
                        geocoder.reverseGeocodeLocation(location){
                            place, error in

                            if let place = place?.first{
                                self.place = MKPlacemark(placemark: place)
                                self.tableView.reloadData()
                            }
                            
                        }
                    }
                }
                
                // OTTENERE VALORI
                
                selectedRow = 1
                
                if let distance = location["distance"].int{
                    switch distance{
                    case 10 :
                        selectedRow = 1
                        break
                    case 100 :
                        selectedRow = 2
                        break
                    default :
                        selectedRow = 1
                        break
                    }
                    
                }
            }
            
        }
        
        self.tableView.reloadData()

    }
    
    var activityIndicator = UIActivityIndicatorView()
    
    @IBOutlet weak var nameBorder: UIView!
    @IBOutlet weak var emailBorder: UIView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.image.contentMode   = .scaleAspectFill
        self.image.clipsToBounds = true
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        reload()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 1:
            if(locationType == .None){
                return 1
            }
            return 3
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 1 && indexPath.row > 0){
            let cell = self.tableView(tableView, cellForRowAt: indexPath)
            
            if let row = selectedRow{
                self.tableView(tableView, cellForRowAt: IndexPath(row: row, section: 1 ) ).accessoryType = .none
            }
            
            selectedRow = indexPath.row
            cell.accessoryType = .checkmark
            
            var params = [String : Any]()
            
            switch indexPath.row {
            case 1:
                params["distance"] = 10
                break
            case 2:
                params["distance"] = 100
                break
            default:
                break
            }
            
            coms.updateUserLocationDistance(parameters: params){
                result in
            }
        }else if(indexPath.section == 2 && indexPath.row == 0){
            // Logout
            coms.login.logout {
                if let window = UIApplication.shared.delegate?.window{
                    let rootController = UIStoryboard(name: "Landing", bundle: Bundle.main).instantiateViewController(withIdentifier: "Login Landing Page")
                    window?.rootViewController = rootController
                }
            }
        }else if(indexPath.section == 3){
            LoginUtils.sharedInstance.checkStatus()
        }
    }
    
    @IBAction func unwindToSettings(segue: UIStoryboardSegue) {
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if(indexPath.section == 1 && indexPath.row == 0){
            if let location = self.place{
                cell.textLabel?.text = "Localizzazione : " + location.name! + " , " + location.contextString!
            }else{
                cell.textLabel?.text = "Localizzazione : Non Attivata"
            }
        }
        
        if(indexPath.section == 1 && indexPath.row > 0){
            if let row = selectedRow, row == indexPath.row{
                cell.accessoryType = .checkmark
            }
        }

        // Configure the cell...

        return cell
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
        
        if let identifier = segue.identifier , identifier == "Select Location", let dvc = segue.destination as? SelectLocationSettingsController {
            dvc.delegate = self
            dvc.location = self.place
            dvc.selectionType = self.locationType
        }
    }
    

}

extension SettingsController : SelectLocationSettingsControllerDelegate{
    
    
    internal func updateSelectionType(type: NotificationLocation) {
        self.locationType = type
        self.tableView.reloadData()
    }
    
    internal func updateLocation(place: MKPlacemark?) {
        self.place = place
        self.tableView.reloadData()
    }

}

extension SettingsController : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        
        if let location = locations.first {

            geocoder.reverseGeocodeLocation(location){
                place, error in
                if let place = place?.first{
                    self.place = MKPlacemark(placemark: place)
                    
                    let parameters : [String : Any] = [
                        "latitude" : self.place!.coordinate.latitude,
                        "longitude" : self.place!.coordinate.longitude,
                        "name" : self.place!.name!,
                        "country" : self.place!.country!,
                        "type" : "Gps"
                    ]
                    
                    self.coms.updateUserLocation(parameters: parameters){
                        response in
                        self.reload()
                    }
                    
                }
                
            }
        }
    }
}
