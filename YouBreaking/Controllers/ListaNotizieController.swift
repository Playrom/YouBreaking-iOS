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
            self.model.append(contentsOf: model)
            self.reloading = false
            self.tableView.reloadData()
        }
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
