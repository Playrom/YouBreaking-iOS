//
//  SearchEventController.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 06/02/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit
import SwiftyJSON

class SearchEventController: UITableViewController , UISearchResultsUpdating {
    
    @available(iOS 8.0, *)
    public func updateSearchResults(for searchController: UISearchController) {
        if let q = self.searchController.searchBar.text{
            if(q==""){
                self.reload(additionalQuery: [String:String]())
            }else{
                self.reload(additionalQuery: ["q" : q])
            }
        }
    }
    
    var model = [JSON]()
    var coms = ModelNotizie()

    
    let searchController = UISearchController(searchResultsController: nil)
    
    func reload(additionalQuery: [String : String]){
        coms.getEvents(additionalQuery: additionalQuery){
            model in
            self.model = model
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Seleziona Evento"
        
        self.reload(additionalQuery: [String : String]())
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController.searchBar
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchController.searchBar.text != nil && searchController.searchBar.text! != "" ? model.count + 1 : model.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "evento", for: indexPath)
        
        if let textSearch = searchController.searchBar.text , textSearch != ""{
            
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Aggiungi Evento : " + textSearch
                break
            default:
                if let evento = self.model.optionalSubscript(safe: indexPath.row - 1){
                    cell.textLabel?.text = evento["name"].string
                }
                break
            }
            
            
        }else{
            if let evento = self.model.optionalSubscript(safe: indexPath.row){
                cell.textLabel?.text = evento["name"].string
            }
        }
        
        

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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier , identifier == "Event Selected", let dvc = segue.destination as? ScriviNotiziaController{
            let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell)
            if let row = indexPath?.row{
                if let textSearch = searchController.searchBar.text , textSearch != ""{
                    
                    if row == 0{
                        // CREA NUOVO EVENTO
                        coms.postEvent(parameters: ["name" : textSearch]){
                            response in
                            dvc.event = response
                            dvc.tableView.reloadData()
                        }
                    }else{
                        // MANDA ID DEL PATH - 1
                        dvc.event = self.model.optionalSubscript(safe: row - 1)
                        dvc.tableView.reloadData()
                    }
                    
                }else{
                    // MANDA ID DEL PATH
                    dvc.event = self.model.optionalSubscript(safe: row)
                    dvc.tableView.reloadData()
                }
            }
        }
    }
    

}
