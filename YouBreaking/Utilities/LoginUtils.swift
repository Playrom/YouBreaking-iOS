//
//  LoginUtils.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 31/01/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import Alamofire
import SwiftyJSON
import JWTDecode

class LoginUtils {
    
    var session : Alamofire.SessionManager
    
    init(){
        var defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = defaultHeaders
        
        session = Alamofire.SessionManager(configuration: configuration)
        let tk = self.token
        self.token = tk

    }
    
    var token : String? {
        get{
            return UserDefaults.standard.string(forKey: "token")
        }
        set{
            if let temp = newValue{
                UserDefaults.standard.set(temp, forKey: "token")
            }else{
                UserDefaults.standard.removeObject(forKey: "token")
            }
            
            var defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
            
            if let token = newValue {
                defaultHeaders["Authorization"] = "JWT " + token
            }
            
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = defaultHeaders
            
            session = Alamofire.SessionManager(configuration: configuration)
            
        }
    }
    
    
    func loginWithFacebookToken(handler : @escaping ( () -> Void ) ) {
        
        if let fbToken = FBSDKAccessToken.current()?.tokenString {
            
            // Comparo la data di scadenza del token per vedere se è maggiore dell'istante attuale
            if(FBSDKAccessToken.current().expirationDate.compare(Date()) == ComparisonResult.orderedDescending){
                print(session)
                //Richiedo al server un nuovo token dell'applicazione utilizzando il token di facebook
                session.request("http://192.168.1.11:3000/auth/facebook/token?access_token=" + fbToken, method : .get).responseData { response in
                    print(response.description)
                    if let data = response.data{
                        
                        let dict = JSON(data: data).dictionaryValue
                        let tempToken = dict["token"]?.stringValue
                        do{
                            // Decodifico il token JWT
                            let jwt = try decode(jwt: tempToken!)
                            self.token = jwt.string
                            print("Logged In")
                            handler()
                        }catch{
                            print("Error")
                            handler()
                        }
                    }
                    
                }
            }else{
                print("Token Scaduto, Riloggarsi");
                handler()
            }
        }else{
            handler()
        }
        
    }
    
    func logout() {
        print("Logged Out")
        if let token = token {
            session.request("http://192.168.1.11:3000/api/auth/logout", method: .get).response{
                _ in
            }
        }
        token = nil
        
    }
    
    func checkStatus(){
        if let token = self.token{
            
            print(token)
            
            session.request("http://192.168.1.11:3000/api/auth/check", method: .get).responseJSON{
                response in
                if response.response?.statusCode == 401{
                    print("NON AUTORIZZATO")
                    
                    if let data = response.data{
                        
                        let dict = JSON(data: data).dictionaryValue
                        let message = dict["message"]?.stringValue
                        if(message == "ExpiredToken"){
                            print("TOKEN SCADUTO")
                            self.token = nil
                            FBSDKLoginManager().logOut()
                        }}
                    
                }else{
                    print(response)
                }
            }
            
        }else{
            print("Token Non Presente")
        }
    }
    
    
}
