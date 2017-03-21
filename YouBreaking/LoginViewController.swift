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

class LoginViewController: BreakingViewController , FBSDKLoginButtonDelegate{

    @IBOutlet weak var loginButton: FBSDKLoginButton!
    @IBOutlet weak var cross: UIImageView!
    
    var completition : ( () -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.readPermissions = ["public_profile","email"]
        loginButton.delegate = self
        cross.image = cross.image?.withRenderingMode(.alwaysTemplate)
        cross.tintColor = Colors.white
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissLogin))
        tapGesture.numberOfTapsRequired = 1
        cross.isUserInteractionEnabled = true
        cross.addGestureRecognizer(tapGesture)
        
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        LoginUtils.sharedInstance.loginWithFacebookToken{
            if let completition = self.completition{
                self.dismiss(animated: true) {
                    _ in
                    completition()

                }
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        LoginUtils.sharedInstance.logout{
            
        }
    }
    
    func dismissLogin(){
        self.dismiss(animated: true, completion: nil)
    }
}

