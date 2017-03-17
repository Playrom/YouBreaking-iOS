//
//  Extensions.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 14/03/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit
import CoreLocation

extension Collection where Indices.Iterator.Element == Index {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    func optionalSubscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension String {
    var date : Date? {
        let formatter = DateFormatter()
        
        // Format 1
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let parsedDate =  formatter.date(from: self) {
            return parsedDate
        }
        
        // Format 2
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:SSSZ"
        if let parsedDate = formatter.date(from: self) {
            return parsedDate
        }
        
        // Couldn't parsed with any format. Just get the date
        let splitedDate = self.components(separatedBy: "T")
        if splitedDate.count > 0 {
            formatter.dateFormat = "yyyy-MM-dd"
            if let parsedDate = formatter.date(from: self) {
                return parsedDate
            }
        }
        
        // Nothing worked!
        return nil
    }
}

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage!)!)
    }
    
    func base64String() -> String?{
        return UIImagePNGRepresentation(self)?.base64EncodedString()
        
    }
}

extension CLPlacemark{
    var contextString : String?{
        guard let locality = self.locality else{return nil}
        guard let country = self.country else{return nil}
        
        return locality + " - " + country
    }
}


extension UIImageView {
    
    func imageFromURL(url : URL) {
        
        do{
            let data = try Data.init(contentsOf: url)
            self.image = UIImage(data: data)
        }catch{
            print("URL VUOTO")
            self.image = nil
        }
        
    }
}
