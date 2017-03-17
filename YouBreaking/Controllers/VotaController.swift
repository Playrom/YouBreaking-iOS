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

class VotaController: BreakingViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var koloda: KolodaView!
    @IBOutlet weak var no: UIImageView!
    @IBOutlet weak var yes: UIImageView!
    
    // MARK: - UIKit Elements
    var mask : UIView?
    
    // MARK: - Class Elements
    var coms = ModelNotizie()
    var model = [JSON]()
    
    // MARK: - UIKit Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        koloda.delegate = self
        koloda.dataSource = self

        yes.image = Images.imageOfYes.withRenderingMode(.alwaysTemplate)
        yes.tintColor = Colors.green
        
        no.image = Images.imageOfNo.withRenderingMode(.alwaysTemplate)
        no.tintColor = Colors.red

        
        let nc = NotificationCenter.default // Note that default is now a property, not a method call
        nc.addObserver(forName:Notification.Name(rawValue:"reloadNews"),
                       object:nil, queue:nil){
                        noti in
                        if noti.userInfo?["sender"] as? String  == self.description{
                            self.update()
                        }else{
                            self.reload()
                        }
                        
        }
        
        let tapyes = UITapGestureRecognizer()
        tapyes.numberOfTapsRequired = 1
        tapyes.addTarget(self, action: Selector.init("tapYes"))
        yes.addGestureRecognizer(tapyes)
        
        let tapno = UITapGestureRecognizer()
        tapno.numberOfTapsRequired = 1
        tapno.addTarget(self, action: Selector.init("tapNo"))
        no.addGestureRecognizer(tapno)
        
        self.reload()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let nc = NotificationCenter.default
        nc.removeObserver(self)
    }
    
    // MARK: - Class Elements
    func tapYes(){
        self.koloda.swipe(.right)
    }
    
    func tapNo(){
        self.koloda.swipe(.left)
    }
    
    func reload(){
        coms.getNewsToVote{
            model in
            self.model = model
            self.koloda.resetCurrentCardIndex()
        }
    }
    
    func update(){
//        coms.getNewsToVote{
//            model in
//            self.model = model
//            self.koloda.reloadData()
//        }
    }
    
    func tapCard(_ gesture : UITapGestureRecognizer){

        if let tapModel = (gesture.view as? VoteCard)?.model{
            
            let vc = UIStoryboard.init(name: "Single", bundle: Bundle.main).instantiateViewController(withIdentifier: "Single News Controller") as! NewsController
            vc.modalPresentationCapturesStatusBarAppearance = true
            vc.delegate = self
            vc.data = tapModel

            if let nvc = self.tabBarController{
                mask = UIView(frame : nvc.view.frame)
                mask!.backgroundColor = Colors.darkGray
                mask!.alpha = 0.3
                mask!.tag = 999
                nvc.view.addSubview(mask!)
            }
            
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }

}

// MARK: - News Controller Delegate Extension
extension VotaController : NewsControllerDelegate{
    func removeMask() {
        if let nvc = self.tabBarController, let modalMask = nvc.view.viewWithTag(999){
            UIView.animate(withDuration: 0.3){
                modalMask.removeFromSuperview()
            }
        }
    }
}

// MARK: - Single News Modal Delegate
extension VotaController : SingleNewsModalDelegate{
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
                                
                let nc = NotificationCenter.default
                nc.post(Notification(name: Notification.Name("reloadNews"), object: nil, userInfo: ["sender" : self.description]))
                
                self.reload()
                
            }
        }
    }
}

// MARK: - Koloda View Delegate Extension
extension VotaController: KolodaViewDelegate {
    func kolodaDidRunOutOfCards(koloda: KolodaView) {

    }
    
    func koloda(koloda: KolodaView, didSelectCardAt index: Int) {

    }
    
    
}

// MARK: - Koloda View Data Source Extension
extension VotaController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return self.model.count
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let view =  Bundle.main.loadNibNamed("VoteCard", owner: self, options: nil)?[0] as! VoteCard
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(VotaController.tapCard(_:)))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        
        if let model = model.optionalSubscript(safe: index){
            view.model = model
        }
        
        return view
    }
    
    func koloda(koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return nil
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
                    NotificationCenter.default.post(Notification(name: Notification.Name("reloadNews"), object: nil, userInfo: ["sender" : self.description]))
                }
                break
            case .right , .bottomRight, .topRight:
                coms.vote(voto: .UP, notizia: id){
                    json in
                    let nc = NotificationCenter.default
                    NotificationCenter.default.post(Notification(name: Notification.Name("reloadNews"), object: nil, userInfo: ["sender" : self.description]))
                }
                break
            default:
                break
            }
        }
    }
    
}
