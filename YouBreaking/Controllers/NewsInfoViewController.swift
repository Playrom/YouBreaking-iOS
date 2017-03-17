//
//  NewsInfoViewController.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 16/03/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON

class NewsInfoViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var eventButton: UIButton!
    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var map: MKMapView!
    
    // MARK: - MapKit Elements
    let geocoder = CLGeocoder()
    
    // MARK: - Class Elements
    var news : JSON?
    
    // MARK: - UIKit Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reload()
        
    }
    
    // MARK: - Class Methods
    func reload(){
        var comps = [String : String]()
        
        if let aggiuntivi = news?["aggiuntivi"].array{
            _ = aggiuntivi.map{
                if let temp =  $0.dictionary , let tipo = temp["tipo"]?.string{
                    comps[tipo] = temp["valore"]!.stringValue
                }
            }
            
            if let latitudeString =  comps["LOCATION_LATITUDE"] , let longitudeString = comps["LOCATION_LONGITUDE"], let latitude = Double(latitudeString) , let longitude = Double(longitudeString){
                
                map.isScrollEnabled = false
                map.isZoomEnabled = false
                map.region = MKCoordinateRegionMake(CLLocationCoordinate2D(latitude: latitude , longitude: longitude )  , MKCoordinateSpanMake(0.05, 0.05) )
                
                
                
                map.removeAnnotations(map.annotations)
                
                geocoder.reverseGeocodeLocation(CLLocation(latitude: latitude , longitude: longitude)){
                    place, error in
                    if let place = place?.first , let location = place.location{
                        
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = location.coordinate
                        annotation.title = comps["LOCATION_NAME"]
                        annotation.subtitle = place.contextString
                        self.map.addAnnotation(annotation)
                        
                        let span = MKCoordinateSpanMake(0.05, 0.05)
                        let region = MKCoordinateRegionMake(location.coordinate, span)
                        self.map.setRegion(region, animated: true)
                    }
                    
                }
            }else{
                map.isHidden = true
            }
            
            if let eventName = news?["evento"]["name"].string{
                eventButton.setTitle(eventName, for: .normal)
            }else{
                eventButton.titleForDisabled = "Nessun Evento"
                eventButton.isEnabled = false
            }
            
            if let link = comps["LINK"]{
                linkButton.setTitle(link , for: .normal)
            }else{
                linkButton.titleForDisabled = "Nessun Link"
                linkButton.isEnabled = false
            }
            
            
        }
    }

    
    // MARK: - IBActions
    @IBAction func selectEvent(_ sender: UIButton) {
        if let nav = self.parent?.parent?.navigationController {
            let eventPage = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Event Page Controller") as! EventPageController
            
            eventPage.eventId = news?["evento"]["id"].string
            nav.pushViewController(eventPage, animated: true)

        }
    }
    
}
