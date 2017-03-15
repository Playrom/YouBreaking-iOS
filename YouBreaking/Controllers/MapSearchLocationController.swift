//
//  MapSearchLocationController.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 22/02/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapSearchLocationController: UIViewController {
    
    let locationManager = CLLocationManager()

    @IBOutlet weak var mapView: MKMapView!
    
    var searchController : UISearchController?
    
    var placemark : MKPlacemark?
    
    var delegate : SelectLocation?
    fileprivate var updatedLocation : CLLocation?
    fileprivate var geocoder = CLGeocoder()

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        mapView.delegate = self
        
        let locationSearchTable = UIStoryboard.init(name: "LocationPicker", bundle: Bundle.main).instantiateViewController(withIdentifier: "Location Search Table") as! LocationSearchTable
        locationSearchTable.mapView = self.mapView
        locationSearchTable.delegate = self

        searchController = UISearchController(searchResultsController: locationSearchTable)
        searchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = searchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        
        mapView.addSubview(searchBar)
        
        searchController?.hidesNavigationBarDuringPresentation = true
        searchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Seleziona", style: .done, target: self, action: Selector("selezionaLocation") )
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToMapView(segue: UIStoryboardSegue) {
        
    }
    
    func selezionaLocation(){
        if let placemark = placemark{
            self.delegate?.selectLocation(location: placemark)
            self.navigationController?.popViewController(animated: true)
        }else{
            // SELEZIONA POSIZIONE ATTUALE
            if let location = updatedLocation{
                geocoder.reverseGeocodeLocation(location){
                    place, error in
                    if let place = place?.first{
                        self.placemark = MKPlacemark(placemark: place)
                        
                        self.delegate?.selectLocation(location: self.placemark!)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
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

extension MapSearchLocationController : CLLocationManagerDelegate{
    
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
            self.updatedLocation = location
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error)")
    }
}

extension MapSearchLocationController : MKMapViewDelegate{
    
}

extension MapSearchLocationController : UISearchControllerDelegate{
    
}

extension MapSearchLocationController : LocationSearchTableDelegate{
    func selectPlacemark(placemark:MKPlacemark){

        self.placemark = placemark

        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        annotation.subtitle = placemark.contextString
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}

protocol SelectLocation {
    func selectLocation( location : MKPlacemark)
}
