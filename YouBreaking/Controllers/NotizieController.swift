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

class NotizieController: PagedTableController {
    

    // MARK: - UIKit Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib.init(nibName: "NotiziaCell", bundle: Bundle.main), forCellReuseIdentifier: "notizia")
    }
    
    // MARK: - Protocol Methods
    
    override func reload(){
        super.reload()
    }
    
    override func advance(){
        super.advance()
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notizia", for: indexPath) as! NotiziaCell
        
        if let contenuto = model.optionalSubscript(safe: indexPath.row){
            cell.model = contenuto
            cell.delegate = self
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
    
    // MARK: - Segues
    
    func performSegueToEvent(eventId: String , sender : NotiziaCell) {
        performSegue(withIdentifier: "Select Event", sender: sender)
    }
    
    func performSegueToSingle(id: String, sender: NotiziaCell) {
        performSegue(withIdentifier: "Select News", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier {
            switch identifier {
            case "Select Event":
                if let dvc = segue.destination as? EventPageController,  let cell = sender as? NotiziaCell{
                    let index = self.tableView.indexPath(for: cell)
                    if let row = index?.row , let eventId = self.model.optionalSubscript(safe: row)?["evento"]["id"].string{
                        dvc.eventId = eventId
                    }
                }
                
                
                break
            case "Select News":
                if let dvc = segue.destination as? NewsController, let indexPath = self.tableView.indexPath(for: sender as! NotiziaCell){
                    dvc.data = self.model.optionalSubscript(safe: indexPath.row)
                    dvc.delegate = self
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }
                if let nvc = self.navigationController{
                    mask = UIView(frame : nvc.view.frame)
                    mask!.backgroundColor = Colors.darkGray
                    mask!.alpha = 0.3
                    mask!.tag = 999
                    nvc.view.addSubview(mask!)
                }
            default:
                break
            }
        }
    }
    
    
}


// MARK: - Notizia Cell Delegate Extension

extension NotizieController : NotiziaCellDelegate{
    
    internal func vote(voto: Voto, sender : NotiziaCell) {
        if let row = self.tableView.indexPath(for: sender)?.row{
            if let newsId = model[row].dictionaryValue["id"]?.stringValue{
                coms.vote(voto: voto, notizia: newsId){
                    response in
                    
                    if(response?["data"]["voto"].string == Voto.NO.rawValue){
                        var dict = self.model[row].dictionaryObject
                        dict?.removeValue(forKey: "voto_utente")
                        self.model[row].dictionaryObject = dict
                        self.model[row]["score"].int = response?["data"]["score"].int
                    }else{
                        self.model[row]["voto_utente"] = JSON.init(dictionaryLiteral: ("voto" , response!["data"]["voto"].stringValue ) )
                        self.model[row]["score"].int = response?["data"]["score"].int
                    }
                    
                    
                    let nc = NotificationCenter.default
                    nc.post(Notification(name: Notification.Name("reloadNews"), object: nil, userInfo: ["sender" : self.description]))
                    
                    self.tableView.reloadRows(at: [ IndexPath(row: row, section: 0) ], with: .none)
                    
                }
            }
            
        }
        
        
    }
}

extension NotizieController : SingleNewsModalDelegate{
    internal func vote(voto: Voto, sender : NewsController){
        if var data = sender.data , let newsId = data["id"].string{
            
            coms.vote(voto: voto, notizia: newsId){
                response in
                                
                if(response?["data"]["voto"].string == Voto.NO.rawValue){
                    var dict = data.dictionaryObject
                    dict?.removeValue(forKey: "voto_utente")
                    data = JSON.init(dict)
                    data["score"].int = response?["data"]["score"].int
                }else{
                    data["voto_utente"] = JSON.init(dictionaryLiteral: ("voto" , response!["data"]["voto"].stringValue ) )
                    data["score"].int = response?["data"]["score"].int
                }
                
                sender.data = data
                sender.reload()
                
                var row : Int?
                
                for (index,json) in self.model.enumerated(){
                    
                    if(json["id"].string == data["id"].string){
                        
                        if(response?["data"]["voto"].string == Voto.NO.rawValue){
                            var dict = json.dictionaryObject
                            dict?.removeValue(forKey: "voto_utente")
                            self.model[index] = JSON.init(dict)
                            data["score"].int = response?["data"]["score"].int
                        }else{
                            self.model[index]["voto_utente"] = JSON.init(dictionaryLiteral: ("voto" , response!["data"]["voto"].stringValue ) )
                            self.model[index]["score"].int = response?["data"]["score"].int
                        }
                        
                        self.tableView.reloadRows(at: [ IndexPath(row: index, section: 0) ], with: .none)
                    }
                }
                
                
                let nc = NotificationCenter.default
                nc.post(Notification(name: Notification.Name("reloadNews"), object: nil, userInfo: ["sender" : self.description]))
                
            }
        }
    }
}
