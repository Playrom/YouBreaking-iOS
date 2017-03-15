//
//  Extensions.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 14/03/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    func optionalSubscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
