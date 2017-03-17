//
//  LocationSearchTable.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 22/02/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchTable: BreakingTableViewController {
    
    // MARK: - Class Elements
    var locations = [MKMapItem]()
    var mapView: MKMapView?
    var delegate : LocationSearchTableDelegate?

    // MARK: - UIKit Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "location", for: indexPath)
        
        let location = locations[indexPath.row].placemark
        cell.textLabel?.text = location.name
        cell.detailTextLabel?.text = location.contextString
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = locations[indexPath.row]
        self.delegate?.selectPlacemark(placemark: location.placemark)
        self.performSegue(withIdentifier: "Select Location", sender: self)
    }
}

// MARK: - UISearcResultsUpdating
extension LocationSearchTable : UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController){
        guard let mapView = mapView, let searchBarText = searchController.searchBar.text else { return }
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start{
            response, error in
            guard let response = response else {
                return
            }
            self.locations = response.mapItems
            self.tableView.reloadData()
        }
    }
}
