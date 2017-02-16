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
            
            var query = ["event":eventId, "sort" : self.sortOrder.rawValue, "live" : "false"]
            
            if let location = location, self.sortOrder == .Location{
                query["latitude"] = location.0
                query["longitude"] = location.1
            }
            
            coms.getNewsWithQuery(query: query ){
                model,pagination in
                self.model = model
                self.reloading = false
                self.tableView.reloadData()
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
            
            var query = ["event":eventId, "sort" : self.sortOrder.rawValue, "live" : "false"]
            
            if let location = location, self.sortOrder == .Location{
                query["latitude"] = location.0
                query["longitude"] = location.1
            }
            
            coms.getNewsWithQuery(query: query ){
                model,pagination in
                self.model.append(contentsOf: model)
                self.reloading = false
                self.tableView.reloadData()
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notizia", for: indexPath) as! NotiziaEventCell
        
        if let contenuto = model.optionalSubscript(safe: indexPath.row){
            cell.model = contenuto
            cell.delegate = self
        }
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        cell.layoutSubviews()
        
        // Configure the cell...
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
