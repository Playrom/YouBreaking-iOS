//
//  ScriviNotiziaController.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 02/02/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit
import SwiftyJSON
import Photos
import MobileCoreServices
import ImagePicker
import MapKit
import Whisper

class ScriviNotiziaController: UITableViewController {
    
    var coms = ModelNotizie()
    
    var location : MKPlacemark?
    var event : JSON?
    
    var images = [[String : Any]]()
    var data = Data()
    
    var notificationSelect = "NONE"
    
    var navigationDelegate : UINavigationController?
    
    @IBOutlet weak var titolo: UITextField!
    @IBOutlet weak var testo: UITextView!
    @IBOutlet weak var linkField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib.init(nibName: "SelectPhotoCell", bundle: Bundle.main), forCellReuseIdentifier: "Photo Cell")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ScriviNotiziaController.dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tapGesture)
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func dismissKeyboard(){
        titolo.resignFirstResponder()
        testo.resignFirstResponder()
        linkField.resignFirstResponder()
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        
        var parameters: [String : Any] = [
            "title": titolo.text != nil ? titolo.text! : "",
            "text" : testo.text
        ]
        
        if let eventId = event?["id"].string{
            parameters["eventId"] = eventId
        }
        
        var aggiuntivi = [[String:Any]]()
        
        if let location = location {
            if let locality = location.locality{
                aggiuntivi.append([
                    "tipo" : "LOCATION_LOCALITY",
                    "valore" : locality
                ])
            }
            
            if let locality = location.country{
                aggiuntivi.append([
                    "tipo" : "LOCATION_COUNTRY",
                    "valore" : locality
                ])
            }
            
            /*aggiuntivi.append([
                "tipo" : "LOCATION_ID",
                "valore" : location.placeID
            ])*/
            
            if let name = location.name{
            
                aggiuntivi.append([
                    "tipo" : "LOCATION_NAME",
                    "valore" : location.name
                ])
            
            }
            
            aggiuntivi.append([
                "tipo" : "LOCATION_LATITUDE",
                "valore" : location.coordinate.latitude.description
            ])
            
            aggiuntivi.append([
                "tipo" : "LOCATION_LONGITUDE",
                "valore" : location.coordinate.longitude.description
            ])
            
        }
        
        if let link = self.linkField.text, link != ""{
            aggiuntivi.append([
                "tipo" : "LINK",
                "valore" : link
            ])
        }
        
        if (self.images.count > 0){
            
            let imageManager = PHImageManager.default()

            
            
            do{
                let base64 = try Data(contentsOf: images[0]["URL"] as! URL).base64EncodedString()
                aggiuntivi.append([
                "tipo" : "PHOTO",
                "valore" : base64
                ])
            }catch{
                print("Data Base64 Non Corretta")
            }
            
            
        }
        
        parameters["aggiuntivi"] = aggiuntivi
        parameters["notification"] = self.notificationSelect
//        
        if let nav = self.navigationDelegate{
            Whisper.show(whistle: Murmur(title: "Salvataggio in corso", backgroundColor: Colors.darkGray, titleColor: Colors.white, font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body), action: nil ) )
        }
        self.dismiss(animated: true, completion: nil)
        
        coms.postNews(parameters: parameters){
            json in
            let nc = NotificationCenter.default
            NotificationCenter.default.post(Notification(name: Notification.Name("reloadNews"), object: nil, userInfo: ["sender" : self.description]))
            
            if(json == nil){
                let alert = UIAlertController(title: "Salvataggio non riuscito", message: "La tua notizia non è stata salvata", defaultActionButtonTitle: "Ok", tintColor: nil)
                self.present(alert, animated: true, completion: nil)
            }
            
            if let nav = self.navigationDelegate{
                Whisper.hide()
                Whisper.show(whistle: Murmur(title: "Notizia Salvata", backgroundColor: UIColor.green, titleColor: Colors.white, font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body), action: nil ) )
                Whisper.hide(whistleAfter: 3)
            }
        }
        
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
            case 3,4,5,6,7:
                self.dismissKeyboard()
                break
            default:
                break
        }
        
        if(indexPath.section == 3){
            self.dismissKeyboard()
            
            let imagePickerController = ImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.imageLimit = 1
            present(imagePickerController, animated: true, completion: nil)
            
        }
        
        if(indexPath.section == 6){
            if let level = coms.login.user?["level"] as? String{
                switch level {
                    case "ADMIN","MOD","EDITOR":
                        for i in 0...2{
                            if let cell = self.tableView.cellForRow(at: IndexPath(row: i, section: 6 ) ){
                                if(indexPath.row == i){
                                    cell.accessoryType = .checkmark
                                }else{
                                    cell.accessoryType = .none
                                }
                            }
                        }
            
                        switch indexPath.row {
                            case 0:
                                self.notificationSelect = "NONE"
                                break
                            case 1:
                                self.notificationSelect = "GLOBAL"
                                break
                            case 2:
                                self.notificationSelect = "LOCAL"
                                break
                            default:
                                break
                        }
                    default:
                        let alert = UIAlertController(title: "Non sei autorizzato ad inviare notifiche")
                        self.present(alert, animated : true , completion : nil)
                        break
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 7
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(section == 6){ return 3 }
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 3:
            if(self.images.count > 0) , let cell = self.tableView.dequeueReusableCell(withIdentifier: "Photo Cell") as? SelectPhotoCell{
                
                cell.fullImageView?.imageFromURL(url: self.images[0]["URL"] as! URL)
                
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
                cell.layoutSubviews()

                return cell
            }else{
                let cell = super.tableView(tableView, cellForRowAt: indexPath)
                return cell
            }
        case 4:
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            
            if let location = location{
                cell.textLabel?.text = location.name
                cell.detailTextLabel?.text = location.contextString
                
            }
            return cell
        case 5:
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            
            if let event = event{
                cell.textLabel?.text = event["name"].string
            }
            return cell
        case 6:
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            
            if let level = coms.login.user?["level"] as? String{
                switch level {
                case "ADMIN","MOD","EDITOR":
                    cell.textLabel?.textColor = Colors.black
                    break
                default:
                    cell.textLabel?.textColor = Colors.darkGray
                    break
                }
            }
            
            return cell
            
        default:
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 3 && self.images.count > 0){
            return 180.0
        }else{
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 3 && self.images.count > 0){
            return 180.0
        }else{
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "Pick Location" {
            if let locationPicker = segue.destination as? MapSearchLocationController{
                locationPicker.delegate = self
            }
        }
    }
    
    @IBAction func unwindToCreationVc(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindToCreationVcSelectedEvent(segue: UIStoryboardSegue) {
        
    }
    

}

extension UIImageView {
    
    func imageFromURL(url : URL) {
        
        do{
            let data = try Data.init(contentsOf: url)
            self.image = UIImage(data: data)
        }catch{
            print("URL VUOTO")
            self.image = nil
        }
        
    }
}

extension UIImage {
    func base64String() -> String?{
        return UIImagePNGRepresentation(self)?.base64EncodedString()

    }
}

extension ScriviNotiziaController : ImagePickerDelegate{
    func wrapperDidPress(_ imagePicker: ImagePicker.ImagePickerController, images: [UIImage]){
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePicker.ImagePickerController, images: [UIImage]){
        
        let image = images[0]
        
        
        do{
            
            
            let jpegData = UIImageJPEGRepresentation(image,0.6);
            
            
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
            let localPath = URL(fileURLWithPath: documentDirectory.appendingPathComponent(".jpeg"))
            try jpegData?.write(to: localPath)
            
            let imageData = try Data(contentsOf: localPath )
            
            let imageWithData = UIImage(data: imageData)!
            
            self.images.append(["URL" : localPath ])
            
            self.tableView.reloadData()
            imagePicker.dismiss(animated: true, completion: nil)
            
            
        }catch{
            print("ERROR")
        }
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePicker.ImagePickerController){
        
    }
}

extension ScriviNotiziaController : SelectLocation{
    func selectLocation(location: MKPlacemark) {
        self.location = location
        self.tableView.reloadData()
    }
}
