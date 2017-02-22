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

enum NotificationLocation : String{
    case Gps = "Gps"
    case Place = "Place"
    case None = "None"
}

class SelectLocationSettingsController: UITableViewController, CLLocationManagerDelegate {
    
    var coms = ModelNotizie()
    var location : MKPlacemark?
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
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
                
                self.locationManager.startUpdatingLocation()
                
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

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        

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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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

        // Configure the cell...

        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "Pick Location" {
            if let locationPicker = segue.destination as? MapSearchLocationController{
                locationPicker.delegate = self
            }
        }
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
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        if let location = locations.first {
            geocoder.reverseGeocodeLocation(location){
                place, error in
                if let place = place?.first{
                    self.location = MKPlacemark(placemark: place)
                    
                    let parameters : [String : Any] = [
                        "latitude" : self.location!.coordinate.latitude,
                        "longitude" : self.location!.coordinate.longitude,
                        "name" : self.location!.name!,
                        "country" : self.location!.country!,
                        "type" : "Gps"
                    ]
                    
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

extension SelectLocationSettingsController : SelectLocation{
    func selectLocation(location: MKPlacemark) {
        self.location = location
        self.selectionType = .Place
        self.tableView.reloadData()
    }
}

protocol SelectLocationSettingsControllerDelegate {
    func updateLocation(place : MKPlacemark?)
    func updateSelectionType( type : NotificationLocation)
}
