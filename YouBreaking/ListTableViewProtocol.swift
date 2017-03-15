//
//  ListTableViewProtocol.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 14/03/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol ListTableViewProtocol  {
    
    var reloading : Bool { get set }
    var coms : ModelNotizie { get }
    var model : [JSON] {get set }
    
    func advance()
    func reload()
    func endReload()
    func filtra()
}
