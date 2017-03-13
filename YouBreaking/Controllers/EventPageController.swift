//
//  EventPageController.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 06/02/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit
import SwiftyJSON

class EventPageController: NotizieController {
    
    var eventId : String?
    
    var event : JSON?
    
    override func reload(){
        if let eventId = eventId  {
            
            super.reload()
            
            if(coms.page == 1){
                
            }else{
                coms.pageSize = coms.page * coms.pageSize
                coms.page = 1
            }
            
            var query = ["event":eventId, "sort" : self.sortOrder.rawValue, "live" : "true"]
            
            if let location = location, self.sortOrder == .Location{
                query["latitude"] = location.0
                query["longitude"] = location.1
            }
            
            coms.getNewsWithQuery(query: query ){
                model,pagination in
                self.model = model
                self.reloading = false
                self.tableView.reloadData()
                self.endReload()
            }
            
            coms.getEvent(eventId: eventId){
                model in
                self.event = model
                self.title = model?["name"].string
                self.tableView.reloadData()
                
            }
            
        }

    }
    
    override func advance(){
        if let eventId = eventId  {
            coms.page = coms.page + 1
            
            var query = ["event":eventId, "sort" : self.sortOrder.rawValue, "live" : "true"]
            
            if let location = location, self.sortOrder == .Location{
                query["latitude"] = location.0
                query["longitude"] = location.1
            }
            
            coms.getNewsWithQuery(query: query ){
                model,pagination in
                DispatchQueue.main.async {
                    self.reloading = false
                    
                    self.model.append(contentsOf: model)
                    
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notizia", for: indexPath) as! NotiziaCell
        
        if let contenuto = model.optionalSubscript(safe: indexPath.row){
            cell.model = contenuto
            cell.delegate = self
            cell.topicButton.isHidden = true
        }
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        cell.layoutSubviews()
        
        // Configure the cell...
        
        return cell
    }
}
