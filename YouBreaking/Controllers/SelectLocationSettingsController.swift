//
//  SelectLocationSettingsController.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 08/02/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit
import GooglePlaces
import CoreLocation

enum NotificationLocation : String{
    case Gps = "GPS"
    case Place = "Place"
    case None = "None"
}

class SelectLocationSettingsController: UITableViewController, CLLocationManagerDelegate {
    
    var coms = ModelNotizie()
    var location : GMSPlace?
    private let locationManager = CLLocationManager()
    var delegate : SelectLocationSettingsControllerDelegate?
    private let googleclient = GMSPlacesClient()
    
    var selectionType = NotificationLocation.None{
        didSet{
            switch selectionType {
            case .None:
                self.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0 ) ).accessoryType = .checkmark
                self.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0 ) ).accessoryType = .none
                self.tableView(tableView, cellForRowAt: IndexPath(row: 2, section: 0 ) ).accessoryType = .disclosureIndicator
                coms.deleteUserLocation{
                    response in
                    print(response)
                    self.delegate?.updateLocation(place: nil)
                    self.delegate?.updateSelectionType(type: .None)
                }
                break
            case .Gps:
                self.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0 ) ).accessoryType = .none
                self.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0 ) ).accessoryType = .checkmark
                self.tableView(tableView, cellForRowAt: IndexPath(row: 2, section: 0 ) ).accessoryType = .disclosureIndicator
                
                
                self.googleclient.currentPlace{
                    (placeLikelihoodList, error)  in
                    if let error = error {
                        print("Pick Place error: \(error.localizedDescription)")
                        return
                    }
                    
                    if let placeLike = placeLikelihoodList?.likelihoods.optionalSubscript(safe: 0){
                        self.location = placeLike.place

                        let parameters : [String : Any] = [
                            "latitude" : self.location!.coordinate.latitude,
                            "longitude" : self.location!.coordinate.longitude,
                            "place_id" : self.location!.placeID,
                            "country" : self.location!.addressComponents!.dictionary["country"] as Any,
                            "type" : "Place"
                        ]
                        
                        self.coms.updateUserLocation(parameters: parameters){
                            response in
                            self.delegate?.updateLocation(place: self.location!)
                            self.delegate?.updateSelectionType(type: .Gps)
                        }
                        
                    }
                }
                
                break
                
            case .Place:
                self.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0 ) ).accessoryType = .none
                self.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0 ) ).accessoryType = .none
                self.tableView(tableView, cellForRowAt: IndexPath(row: 2, section: 0 ) ).accessoryType = .checkmark
                
                let parameters : [String : Any] = [
                    "latitude" : location!.coordinate.latitude,
                    "longitude" : location!.coordinate.longitude,
                    "place_id" : location!.placeID,
                    "country" : location!.addressComponents!.dictionary["country"] as Any,
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
                
                cell.detailTextLabel?.text = [
                    location.addressComponents?.dictionary["locality"],
                    location.addressComponents?.dictionary["country"]
                    ].flatMap{$0}.joined(separator: ", ")
                
            }
            return cell

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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "Pick Location" {
            if let locationPicker = segue.destination as? GMSAutocompleteViewController{
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
        print(status)
    }

}


extension SelectLocationSettingsController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        self.location = place
        self.selectionType = .Place
        
        
        
        
        self.tableView.reloadData()
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

protocol SelectLocationSettingsControllerDelegate {
    func updateLocation(place : GMSPlace?)
    func updateSelectionType( type : NotificationLocation)
}
