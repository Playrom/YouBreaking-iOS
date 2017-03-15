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
    @IBOutlet weak var no: UIImageView!
    @IBOutlet weak var yes: UIImageView!
    
    var coms = ModelNotizie()
    var model = [JSON]()
    
    var mask : UIView?

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

        // Do any additional setup after loading the view.
    }
    
    func tapYes(){
        self.koloda.swipe(.right)
    }
    
    func tapNo(){
        self.koloda.swipe(.left)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let nc = NotificationCenter.default
        nc.removeObserver(self)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tapCard(_ gesture : UITapGestureRecognizer){

        if let tapModel = (gesture.view as? VoteCard)?.model{
            let vc = UIStoryboard.init(name: "Single", bundle: Bundle.main).instantiateViewController(withIdentifier: "Single News Controller") as! NewsController
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

extension VotaController : NewsControllerDelegate, SingleNewsModalDelegate{
    func removeMask() {
        if let nvc = self.tabBarController, let modalMask = nvc.view.viewWithTag(999){
            UIView.animate(withDuration: 0.3){
                modalMask.removeFromSuperview()
            }
        }
    }
    
    func vote(voto: Voto, sender: NewsController) {
        
    }
    
}

extension VotaController: KolodaViewDelegate {
    func kolodaDidRunOutOfCards(koloda: KolodaView) {

    }
    
    func koloda(koloda: KolodaView, didSelectCardAt index: Int) {

    }
    
    
}

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
