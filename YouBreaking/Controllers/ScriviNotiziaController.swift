//
//  ScriviNotiziaController.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 02/02/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit
import LocationPickerViewController
import GooglePlaces
import SwiftyJSON

class ScriviNotiziaController: UITableViewController {
    
    var coms = ModelNotizie()
    
    var location : GMSPlace?
    var event : JSON?
    
    @IBOutlet weak var titolo: UITextField!
    @IBOutlet weak var testo: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        
        var parameters: [String : Any] = [
            "title": titolo.text != nil ? titolo.text! : "",
            "text" : testo.text
        ]
        
        if let eventId = event?["id"].string{
            parameters["eventId"] = eventId
        }
        
        var aggiuntivi = [[String:Any]]()
        
        if let location = location {
            if let locality = location.addressComponents?.dictionary["locality"]{
                aggiuntivi.append([
                    "tipo" : "LOCATION_LOCALITY",
                    "valore" : locality
                ])
            }
            
            if let locality = location.addressComponents?.dictionary["country"]{
                aggiuntivi.append([
                    "tipo" : "LOCATION_COUNTRY",
                    "valore" : locality
                ])
            }
            
            aggiuntivi.append([
                "tipo" : "LOCATION_ID",
                "valore" : location.placeID
            ])
            
            aggiuntivi.append([
                "tipo" : "LOCATION_NAME",
                "valore" : location.name
            ])
            
            aggiuntivi.append([
                "tipo" : "LOCATION_LATITUDE",
                "valore" : location.coordinate.latitude.description
            ])
            
            aggiuntivi.append([
                "tipo" : "LOCATION_LONGITUDE",
                "valore" : location.coordinate.longitude.description
            ])
            
        }
        
        parameters["aggiuntivi"] = aggiuntivi
                
        coms.postNews(parameters: parameters){
            json in
            let nc = NotificationCenter.default
            nc.post(Notification(name: Notification.Name("reloadNews")))
            self.dismiss(animated: true, completion: nil)
        }
        
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 2:
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            
            if let location = location{
                cell.textLabel?.text = location.name
                
                cell.detailTextLabel?.text = [
                    location.addressComponents?.dictionary["locality"],
                    location.addressComponents?.dictionary["country"]
                    ].flatMap{$0}.joined(separator: ", ")
                
            }
            return cell
        case 3:
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            
            if let event = event{
                cell.textLabel?.text = event["name"].string
            }
            return cell
        default:
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    
    }
    

        // Configure the cell...    }
    

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
        
        if segue.identifier == "Pick Location" {
            if let locationPicker = segue.destination as? GMSAutocompleteViewController{
                locationPicker.delegate = self
            }
        }
    }
    
    @IBAction func unwindToCreationVc(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindToCreationVcSelectedEvent(segue: UIStoryboardSegue) {
        
    }
    

}


extension ScriviNotiziaController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        self.location = place
        self.tableView.reloadData()
        viewController.performSegue(withIdentifier: "return to creation", sender: viewController)
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

extension Collection where Iterator.Element == GMSAddressComponent {
    var dictionary : [String:String] {
        let elements = self.map{
            val in
            return (val.type , val.name)
        }
        
        var dict = [String:String]()
        
        for (key, value) in elements {
            dict[key] = value
        }
        
        return dict
    }
}
