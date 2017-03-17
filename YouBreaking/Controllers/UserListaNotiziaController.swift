//
//  ListaNotizieController.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 02/02/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit
import SwiftyJSON

class UserListaNotizieController: NotizieController{
    
    // MARK: - Class Attributes
    var id : String?
    
    // MARK: - UIKit Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar on the this view controller
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = Colors.white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let nc = NotificationCenter.default
        nc.removeObserver(self)
    }
    
    // MARK: - Protocol Methods
    override func reload(){
        super.reload()
        
        if let id = id{
            
            if(coms.page == 1){
                
            }else{
                coms.pageSize = coms.page * coms.pageSize
                coms.page = 1
            }
            
            var query = ["sort" : self.sortOrder.rawValue, "live" : "true", "author" : id]
            
            if let location = location{
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
        
        if let id = id{
        
            coms.page = coms.page + 1
            
            var query = ["sort" : self.sortOrder.rawValue, "live" : "true", "author" : id]
            
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
    
    
}
