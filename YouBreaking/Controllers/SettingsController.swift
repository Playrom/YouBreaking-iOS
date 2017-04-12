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

class SettingsController: BreakingTableViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var nameBorder: UIView!
    @IBOutlet weak var emailBorder: UIView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    // MARK: - Class Elements
    var editingData : Bool = false
    var data : JSON?
    var coms = ModelNotizie()
    var selectedRow : Int?
    var locationType = NotificationLocation.None
    
    // MARK: - MapKit Elements
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    var place : MKPlacemark?
    
    // MARK: - UIKit Elements
    var activityIndicator = UIActivityIndicatorView()
    
    // MARK: - UIKit Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.image.contentMode   = .scaleAspectFill
        self.image.clipsToBounds = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        reload()
        coms.getProfile{
            json in
            self.data = json
            self.reload()
        }
    }
    
    // MARK: - IBActions
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
    
    @IBAction func unwindToSettings(segue: UIStoryboardSegue) {
        
    }
    
    // MARK: - Class Methods
    
    func reload(){
        nameField.textColor = .gray
        emailField.textColor = .gray
        
        nameField.text = data?["name"].string
        emailField.text = data?["email"].string
        
        activityIndicator.center = image.center
        activityIndicator.startAnimating()
        
        if let imageUrl = data?["picture"].string{

            coms.getImage(url: imageUrl)
            .then{
                image -> Void in
                self.image.image = image.af_imageRoundedIntoCircle()
                self.activityIndicator.stopAnimating()
            }
        }
        
        if let location = data?["location"]{
            
            if let type = location["type"].string{
                
                let temp = NotificationLocation(rawValue: type)
                
                self.locationType = temp != nil ? temp! : .None
                                
                if(self.locationType == .Gps){
                    self.locationManager.requestAlwaysAuthorization()
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
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 2:
            if(locationType == .None){
                return 1
            }
            return 3
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 2 && indexPath.row > 0){
            let cell = self.tableView(tableView, cellForRowAt: indexPath)
            
            if let row = selectedRow{
                self.tableView(tableView, cellForRowAt: IndexPath(row: row, section: 2 ) ).accessoryType = .none
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
        }else if(indexPath.section == 3 && indexPath.row == 0){
            // Logout
            coms.login.logout {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if(indexPath.section == 2 && indexPath.row == 0){
            if let location = self.place{
                cell.textLabel?.text = "Localizzazione : " + location.name! + " , " + location.contextString!
            }else{
                cell.textLabel?.text = "Localizzazione : Non Attivata"
            }
        }
        
        if(indexPath.section == 2 && indexPath.row > 0){
            if let row = selectedRow, row == indexPath.row{
                cell.accessoryType = .checkmark
            }
        }

        return cell
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier , identifier == "Select Location", let dvc = segue.destination as? SelectLocationSettingsController {
            dvc.delegate = self
            dvc.location = self.place
            dvc.selectionType = self.locationType
        }
    }
    
}

// MARK: - Selection Location Settings Delegate Extension
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

// MARK: - CLLocation Manager Delegate Delegate Extension
extension SettingsController : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        
        if let location = locations.first {

            geocoder.reverseGeocodeLocation(location){
                place, error in
                if let place = place?.first{
                    self.place = MKPlacemark(placemark: place)
                    if let pl = self.place, let name = pl.name, let country = pl.country{
                        let parameters : [String : Any] = [
                            "latitude" : pl.coordinate.latitude,
                            "longitude" : pl.coordinate.longitude,
                            "name" : name,
                            "country" : country,
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
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case CLAuthorizationStatus.authorizedAlways:
            self.locationManager.startUpdatingLocation()
        default:
            return
        }
    }
}
