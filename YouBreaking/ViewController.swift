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

class LandingViewController: BreakingViewController , FBSDKLoginButtonDelegate{

    @IBOutlet weak var loginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.readPermissions = ["public_profile","email"]
        loginButton.delegate = self
        
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        LoginUtils.sharedInstance.loginWithFacebookToken{
            self.performSegue(withIdentifier: "Login Completato", sender: self)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        LoginUtils.sharedInstance.logout{
            
        }
    }
}

