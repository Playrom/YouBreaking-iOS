//
//  ListaNotizieGiaVotateController.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 13/02/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit

class ListaNotizieGiaVotateController: NotizieController {
    
    override func reload(){
        
        super.reload()
        
        if(coms.page == 1){
            
        }else{
            coms.pageSize = coms.page * coms.pageSize
            coms.page = 1
        }
        
        var query = ["sort" : self.sortOrder.rawValue, "live" : "false"]
        
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
        
    }
    
    override func advance(){
        
        coms.page = coms.page + 1
        
        var query = ["sort" : self.sortOrder.rawValue, "live" : "false"]
        
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
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        var actions = super.tableView(tableView, editActionsForRowAt: indexPath)
        
        var level = self.coms.login.user?["level"] as? String
        
        if let level = level , level == "MOD" || level == "ADMIN"{
            actions?.append(UITableViewRowAction(style: .normal, title: "Promuovi" ){
                action,indexPath in
                if let id = self.model.optionalSubscript(safe: indexPath.row)?["id"].string{
                    self.coms.promoteNews(id: id){
                        ok in
                        if(ok){
                            self.model.remove(at: indexPath.row)
                            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.top )
                            self.tableView.reloadData()
                            NotificationCenter.default.post(Notification(name: Notification.Name.init("reloadNews")))
                        }
                    }
                }
            })
            return actions
        }else{
            return actions
        }
    }



    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
