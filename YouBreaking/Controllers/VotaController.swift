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
    @IBOutlet weak var yes: UIView!
    @IBOutlet weak var no: UIView!
    
    var coms = ModelNotizie()
    var model = [JSON]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        koloda.delegate = self
        koloda.dataSource = self

        
        let nc = NotificationCenter.default // Note that default is now a property, not a method call
        nc.addObserver(forName:Notification.Name(rawValue:"reloadNews"),
                       object:nil, queue:nil){
                        noti in
                        if noti.userInfo?["sender"] as? String  == "votecontroller"{
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
                    nc.post(Notification(name:  Notification.Name("reloadNews"), object: nil, userInfo: ["sender" : "votecontroller"] ))
                    print("SWIPE LEFT")
                }
                break
            case .right , .bottomRight, .topRight:
                coms.vote(voto: .UP, notizia: id){
                    json in
                    let nc = NotificationCenter.default
                    nc.post(Notification(name:  Notification.Name("reloadNews"), object: nil, userInfo: ["sender" : "votecontroller"] ))
                    print("SWIPE RIGHT")
                }
                break
            default:
                print("Non Incluso")
            }
        }
    }
    
}

class YesCircleView : UIView{
    
    override init(frame:CGRect){
        super.init(frame:frame)
        self.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {return}
        
        context.setFillColor(UIColor.clear.cgColor)
        context.addEllipse(in: rect)
        context.setStrokeColor(UIColor.green.cgColor)
        context.strokePath()
        context.fillPath()
        
        
    }
}
