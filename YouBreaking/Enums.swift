//
//  Enums.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 17/03/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import Foundation

enum NotificationLocation : String{
    case Gps = "Gps"
    case Place = "Place"
    case None = "None"
}

enum SortOrder : String{
    case Score = "score"
    case Location = "location"
    case Recent = "recent"
    case Hot = "hot"
}

enum Voto: String{
    case UP = "UP"
    case DOWN = "DOWN"
    case NO = "NO"
}
