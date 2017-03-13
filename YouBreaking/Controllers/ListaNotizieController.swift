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


    @IBOutlet weak var iconaSettings: UIBarButtonItem!
    
    var profile : JSON?
    
    let tempView = UIView()
    let loader = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        iconaSettings.image = iconaSettings.image!.withRenderingMode(.alwaysTemplate)
        iconaSettings.tintColor = Colors.white
                
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let nc = NotificationCenter.default
        nc.removeObserver(self)
    }
    
    override func reload(){
        
        super.reload()
        
        print("RELOADED")
        
        if(coms.page == 1){
            
        }else{
            coms.pageSize = coms.page * coms.pageSize
            coms.page = 1
        }
        
        var query = ["sort" : self.sortOrder.rawValue, "live" : "true"]
        
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
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
