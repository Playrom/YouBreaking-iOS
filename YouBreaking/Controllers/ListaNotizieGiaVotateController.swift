//
//  ListaNotizieGiaVotateController.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 13/02/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit

class ListaNotizieGiaVotateController: NotizieController {
    
    // MARK: - Protocol Methods
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
            if(model.count > 0){
                self.endReload()
            }else{
                self.endReloadNoContent()
            }
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
            DispatchQueue.main.async {
                self.reloading = false
                
                self.model.append(contentsOf: model)
                
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source
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
                            self.tableView.beginUpdates()
                            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.top )
                            self.tableView.endUpdates()
                            NotificationCenter.default.post(Notification(name: Notification.Name("reloadNews"), object: nil, userInfo: ["sender" : self.description]))
                        }
                    }
                }
            })
            return actions
        }else{
            return actions
        }
    }

}
