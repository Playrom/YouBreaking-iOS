//
//  SingleNews.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 09/02/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit
import SwiftyJSON
import Lightbox

class SingleNews: UITableViewController  {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    var data : JSON?
    var coms = ModelNotizie()
    
    func reload() {
        titleLabel.text = data?["title"].string
        titleLabel.textColor = Colors.red
        
        self.title = data?["title"].string
        
        if let nameEvento = data?["evento"]["nome"].string{
            eventLabel.text = nameEvento
        }else{
            eventLabel.isHidden = true
        }
        
        bodyLabel.text = data?["text"].string
        bodyLabel.textAlignment = .justified
        bodyLabel.setNeedsLayout()
        bodyLabel.setNeedsDisplay()
        bodyLabel.layoutSubviews()
                
        scoreLabel.text = data?["score"].intValue.description
        
        var comps = [String : String]()
        
        if let aggiuntivi = data?["aggiuntivi"].array{
            _ = aggiuntivi.map{
                if let temp =  $0.dictionary , let tipo = temp["tipo"]?.string{
                    comps[tipo] = temp["valore"]!.stringValue
                }
            }
            print(aggiuntivi)
            print(comps)
            
            if comps["PHOTO"] != nil{
                
                coms.getPhoto(photo: comps["PHOTO"]!){
                    image in
                    self.imageView.image = image
                    self.imageView.setNeedsLayout()
                    self.imageView.layoutSubviews()
                    //self.tableView.reloadRows(at: [IndexPath.init(row: 0, section: 0)] , with: .none )
                    self.tableView.reloadSections(IndexSet.init(integer: 0) , with: .none)
                    self.imageView.setNeedsLayout()
                    self.imageView.layoutSubviews()
                    self.tableView.reloadData()
                    
                }
            }
            
            /*var posto = [comps["LOCATION_LOCALITY"],comps["LOCATION_COUNTRY"]]
             
             locationButton.setTitle(
             [
             comps["LOCATION_NAME"],
             posto.flatMap{$0}.joined(separator: ", ")
             
             ].flatMap{$0}.joined(separator: " - "),
             for : UIControlState.normal
             )
             
             if ( locationButton.currentTitle == nil || locationButton.currentTitle == ""){
             locationButton.isHidden = true
             }else{
             locationButton.isHidden = false
             }*/
            
        }

        
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsSelection = false;
        reload()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SingleNews.displayImage))
        tapGesture.numberOfTapsRequired = 1
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func displayImage(){
        // Create an array of images.
        if let image = self.imageView.image{
            let testo = data?["title"].string != nil ? data!["title"].string! : ""
            
            let images = [
                LightboxImage(
                    image: image,
                    text: testo
                )
            ]
            
            // Create an instance of LightboxController.
            let controller = LightboxController(images: images)
            
            
            // Use dynamic background.
            controller.dynamicBackground = true
            
            // Present your controller.
            present(controller, animated: true, completion: nil)
        }
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
        return 2
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.separatorInset = .zero
        // Configure the cell...
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        cell.layoutSubviews()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let image = self.imageView.image , indexPath.row == 0{
            let aspect = (image.size.width / image.size.height)
            return  ( self.view.size.width / aspect )
        }else if ( indexPath.row == 0 ){
            return 0
        }
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LightboxController{
    open override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
}
