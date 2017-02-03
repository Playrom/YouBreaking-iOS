//
//  VotaController.swift
//  Pods
//
//  Created by Giorgio Romano on 03/02/2017.
//
//

import UIKit
import Koloda
import SwiftyJSON

class VotaController: UIViewController {
    
    @IBOutlet weak var koloda: KolodaView!
    
    var coms = ModelNotizie()
    var model = [JSON]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        koloda.delegate = self
        koloda.dataSource = self
        
        coms.getNewsToVote{
            model in
            self.model = model
            self.koloda.reloadData()
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension VotaController: KolodaViewDelegate {
    func kolodaDidRunOutOfCards(koloda: KolodaView) {
        print("SENZA CARTE")
    }
    
    func koloda(koloda: KolodaView, didSelectCardAt index: Int) {
        print("CARTA SELEZIONATA")
    }
    
    
}

extension VotaController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return self.model.count
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let view =  Bundle.main.loadNibNamed("VoteCard", owner: self, options: nil)?[0] as! VoteCard
        
        if let model = model.optionalSubscript(safe: index){
            view.model = model
        }
        
        return view
    }
    
    func koloda(koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return nil //Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)?[0] as? OverlayView
    }
    
    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: Int) -> [SwipeResultDirection] {
        return [.left , .bottomLeft , .topLeft, .right , .bottomRight, .topRight]
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        if let id =  model.optionalSubscript(safe: index)?.dictionary?["id"]?.string{
            switch direction {
            case .left , .bottomLeft , .topLeft:
                coms.vote(voto: .DOWN, notizia: id){
                    json in
                    let nc = NotificationCenter.default
                    nc.post(Notification(name: Notification.Name("Lista Notizie Modificata")))
                    print("SWIPE LEFT")
                }
                break
            case .right , .bottomRight, .topRight:
                coms.vote(voto: .UP, notizia: id){
                    json in
                    let nc = NotificationCenter.default
                    nc.post(Notification(name: Notification.Name("Lista Notizie Modificata")))
                    print("SWIPE RIGHT")
                }
                break
            default:
                print("Non Incluso")
            }
        }
    }
    
}
