//
//  SingleNewsModalDelegate.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 15/03/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import Foundation
import SwiftyJSON
import MapKit

protocol SingleNewsModalDelegate {
    func vote(voto : Voto , sender : NewsController)
}

protocol DataNewsDelegate{
    var data : JSON? { get set }
}

protocol HeightDelegate{
    func heightChanged(height : CGFloat?, animated : Bool , completition handler : ( (Void) -> () )? )
    func dismissGestureControll(panGesture: UIPanGestureRecognizer)
}

protocol SelectLocation {
    func selectLocation( location : MKPlacemark)
}

protocol NotiziaCellDelegate{
    func vote(voto : Voto, sender : NotiziaCell)
    func performSegueToEvent(eventId : String, sender : NotiziaCell)
    func performSegueToSingle(id : String, sender : NotiziaCell)
}

protocol LocationSearchTableDelegate{
    func selectPlacemark(placemark:MKPlacemark)
}


protocol SelectLocationSettingsControllerDelegate {
    func updateLocation(place : MKPlacemark?)
    func updateSelectionType( type : NotificationLocation)
}

protocol NewsControllerDelegate{
    func removeMask()
}
