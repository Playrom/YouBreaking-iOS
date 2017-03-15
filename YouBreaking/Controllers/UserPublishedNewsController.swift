//
//  ListaNotizieController.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 02/02/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation

class UserPublishedNewsController: PagedTableController{
    
    // MARK: - UIKit Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Protocol Methods
    
    
    override func reload(){
        super.reload()
        
        if(coms.page == 1){
            
        }else{
            coms.pageSize = coms.page * coms.pageSize
            coms.page = 1
        }
        
        if let id = coms.login.user?["id"] as? String{
            
            var query = ["sort" : self.sortOrder.rawValue, "author" : id]
            
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
        }
  
        
    }
    
    override func advance(){
        
        coms.page = coms.page + 1
        
        if let id = coms.login.user?["id"] as? String{
        
            var query = ["sort" : self.sortOrder.rawValue, "author" : id]
            
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
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notizia", for: indexPath) as! UserPublishedNotiziaCell
        
        if let contenuto = model.optionalSubscript(safe: indexPath.row){
            cell.model = contenuto
        }
        
        if(indexPath.row % 2 == 0){
            cell.backgroundColor = Colors.white
        }else{
            cell.backgroundColor = Colors.lightGray
        }
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        cell.layoutSubviews()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var arr : [UITableViewRowAction]? = nil
        
        if let _ = coms.login.user?["id"] as? String{
            arr = [UITableViewRowAction]()
            arr?.append(UITableViewRowAction(style: .destructive, title: "Cancella" ){
                action,indexPath in
                if let id = self.model.optionalSubscript(safe: indexPath.row)?["id"].string{
                    self.coms.deleteNews(id: id){
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
            return arr
        }else{
            return [UITableViewRowAction]()
        }
    }
    
    // MARK: - Segues
    
}
