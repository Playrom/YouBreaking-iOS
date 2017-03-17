//
//  SelectLocationSettingsController.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 08/02/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class SelectLocationSettingsController: BreakingTableViewController{
    
    // MARK: - MapKit Elements
    var location : MKPlacemark?
    fileprivate let locationManager = CLLocationManager()
    fileprivate let geocoder = CLGeocoder()
    
    // MARK: - Class Elements
    var coms = ModelNotizie()
    var delegate : SelectLocationSettingsControllerDelegate?
    
    var selectionType = NotificationLocation.None{
        didSet{
            switch selectionType {
            case .None:
                self.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0 ) ).accessoryType = .checkmark
                self.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0 ) ).accessoryType = .none
                self.tableView(tableView, cellForRowAt: IndexPath(row: 2, section: 0 ) ).accessoryType = .disclosureIndicator
                coms.deleteUserLocation{
                    response in
                    self.delegate?.updateLocation(place: nil)
                    self.delegate?.updateSelectionType(type: .None)
                }
                break
            case .Gps:
                self.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0 ) ).accessoryType = .none
                self.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0 ) ).accessoryType = .checkmark
                self.tableView(tableView, cellForRowAt: IndexPath(row: 2, section: 0 ) ).accessoryType = .disclosureIndicator
                self.locationManager.requestAlwaysAuthorization()
                
                break
                
            case .Place:
                self.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0 ) ).accessoryType = .none
                self.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0 ) ).accessoryType = .none
                self.tableView(tableView, cellForRowAt: IndexPath(row: 2, section: 0 ) ).accessoryType = .checkmark
                
                let parameters : [String : Any] = [
                    "latitude" : location!.coordinate.latitude,
                    "longitude" : location!.coordinate.longitude,
                    "name" : location!.name!,
                    "country" : location!.country!,
                    "type" : "Place"
                ]
                
                coms.updateUserLocation(parameters: parameters){
                    response in
                    self.delegate?.updateLocation(place: self.location!)
                    self.delegate?.updateSelectionType(type: .Place)
                }
                break
            }
        }
    }
    
    // MARK: - UIKit Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if(indexPath.row == 2){
            if let location = location{
                cell.textLabel?.text = location.name
                cell.detailTextLabel?.text = location.contextString
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = self.tableView(tableView, cellForRowAt: indexPath)
        
        switch indexPath.row {
        case 0:
            selectionType = .None
            break
        case 1:
            selectionType = .Gps
            break
        case 2:
            break
        default:
            selectionType = .None
        }
        
    }

    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Pick Location" {
            if let locationPicker = segue.destination as? MapSearchLocationController{
                locationPicker.delegate = self
            }
        }
    }
}

extension SelectLocationSettingsController : CLLocationManagerDelegate{

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case CLAuthorizationStatus.authorizedAlways,CLAuthorizationStatus.authorizedWhenInUse:
                self.locationManager.startUpdatingLocation()
            default:
                return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        if let location = locations.first {
            geocoder.reverseGeocodeLocation(location){
                place, error in
                if let place = place?.first{
                    var pla = MKPlacemark(placemark: place)
                    
                    let parameters : [String : Any] = [
                        "latitude" : pla.coordinate.latitude,
                        "longitude" : pla.coordinate.longitude,
                        "name" : pla.name!,
                        "country" : pla.country!,
                        "type" : "Gps"
                    ]
                    
                    self.location = pla
                    
                    self.coms.updateUserLocation(parameters: parameters){
                        response in
                        self.delegate?.updateLocation(place: self.location)
                        self.delegate?.updateSelectionType(type: .Gps)
                    }
                    
                }
                
            }
        }
    }

}

// MARK: - Select Location Delegate Extension
extension SelectLocationSettingsController : SelectLocation{
    func selectLocation(location: MKPlacemark) {
        self.location = location
        self.selectionType = .Place
        self.tableView.reloadData()
    }
}
