//
//  SingleNewsModalDelegate.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 15/03/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import Foundation
import SwiftyJSON

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
