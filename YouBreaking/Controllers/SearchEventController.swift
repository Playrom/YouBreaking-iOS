//
//  SearchEventController.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 06/02/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit
import SwiftyJSON

class SearchEventController: BreakingTableViewController , UISearchResultsUpdating {
    
    // MARK: - UIKit Elements
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Class Elements
    var model = [JSON]()
    var coms = ModelNotizie()
    
    // MARK: - UIKit Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Seleziona Evento"
        
        self.reload(additionalQuery: [String : String]())
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController.searchBar
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        
        return cell
    }
    
    
    // MARK: - Class Methods
    func reload(additionalQuery: [String : String]){
        coms.getEvents(additionalQuery: additionalQuery){
            model in
            self.model = model
            self.tableView.reloadData()
        }
    }
    
    // MARK: - UISearchResults Delegate
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
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
