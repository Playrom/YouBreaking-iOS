//
//  ListaNotizieController.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 02/02/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit
import SwiftyJSON

class ListaNotizieController: NotizieController{

    // MARK: - IBOutlets
    @IBOutlet weak var iconaSettings: UIBarButtonItem!
    
    // MARK: - Class Attributes
    var profile : JSON?
    
    // MARK: - UIKit Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        iconaSettings.image = iconaSettings.image!.withRenderingMode(.alwaysTemplate)
        iconaSettings.tintColor = Colors.white
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let nc = NotificationCenter.default
        nc.removeObserver(self)
    }
    
    // MARK: - Protocol Methods
    override func reload(){
        super.reload()
        
        if(coms.page == 1){
            
        }else{
            coms.pageSize = coms.page * coms.pageSize
            coms.page = 1
        }
        
        var query = ["sort" : self.sortOrder.rawValue, "live" : "true"]
        
        if let location = location{
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
        
        coms.getProfile{
            json in
            self.profile = json
        }
        
    }
    
    override func advance(){
        
        coms.page = coms.page + 1
        
        var query = ["sort" : self.sortOrder.rawValue, "live" : "true"]
        
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

    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        if let identifier = segue.identifier {
            switch identifier {
            case "Present Settings":
                if let dvc = segue.destination as? SettingsController{
                    dvc.data = profile
                }
                break
            default:
                break
            }
        }
    }
    

}
