//
//  ViewController.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 30/01/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Alamofire
import SafariServices
import SwiftyJSON
import JWTDecode

class ViewController: UIViewController , FBSDKLoginButtonDelegate{

    @IBOutlet weak var loginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.readPermissions = ["public_profile","email"]
        loginButton.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "red-background")?.draw(in: self.view.bounds)
        
        if let image: UIImage = UIGraphicsGetImageFromCurrentImageContext(){
            UIGraphicsEndImageContext()
            self.view.backgroundColor = UIColor(patternImage: image)
        }else{
            UIGraphicsEndImageContext()
            debugPrint("Image not available")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        LoginUtils().loginWithFacebookToken{
            self.performSegue(withIdentifier: "Login Completato", sender: self)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        LoginUtils().logout()
    }

    @IBAction func connessione(_ sender: UIButton) {
        LoginUtils().checkStatus()
    }
}

