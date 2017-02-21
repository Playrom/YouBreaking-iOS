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
import UserNotifications

class LoginUtils {
    
    static let sharedInstance = LoginUtils()
    
    var session : Alamofire.SessionManager
    
    private init() {
        let defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = defaultHeaders
        
        session = Alamofire.SessionManager(configuration: configuration)
        let tk = self.token
        self.token = tk
        
    } //This prevents others from using the default '()' initializer for this class.
    
    var user : [String : Any]?{
        if let token = token {
            do{
                // Decodifico il token JWT
                let jwt = try decode(jwt: token)
                return jwt.body
            }catch{
                return nil
            }
        }
        return nil
    }
    
    var headers : [String : String]{
        if let token = token{
            
            return [
                "Authorization": "JWT " + token ,
                "Accept": "application/json"
            ]
        }
        
        return [String:String]()
    }
    
    var id : String?{
        if let id = user?["id"] as? String{
            return id
        }
        return nil
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
            
        }
    }
    
    var baseUrl : String{
        if let mode = Bundle.main.object(forInfoDictionaryKey: "mode") as? String{
            switch mode {
            case "development":
                return Bundle.main.object(forInfoDictionaryKey: "url_development") as! String
            default:
                return Bundle.main.object(forInfoDictionaryKey: "url_production") as! String
            }
        }
        return Bundle.main.object(forInfoDictionaryKey: "url_development") as! String
    }
    
    
    func loginWithFacebookToken(handler : @escaping ( () -> Void ) ) {
        print(baseUrl)
        
        if let fbToken = FBSDKAccessToken.current()?.tokenString {
            
            // Comparo la data di scadenza del token per vedere se è maggiore dell'istante attuale
            if(FBSDKAccessToken.current().expirationDate.compare(Date()) == ComparisonResult.orderedDescending){
                print(session)
                //Richiedo al server un nuovo token dell'applicazione utilizzando il token di facebook
                session.request( baseUrl + "/auth/facebook/token?access_token=" + fbToken, method : .get).responseData { response in
                    if let data = response.data{
                        
                        let dict = JSON(data: data).dictionaryValue
                        if let tempToken = dict["token"]?.string{
                            do{
                                // Decodifico il token JWT
                                let jwt = try decode(jwt: tempToken)
                                self.token = jwt.string
                                print("Logged In")
                                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]){
                                    (granted,error) in
                                    if(granted){
                                        print("GRANTED")
                                        UIApplication.shared.registerForRemoteNotifications()
                                    }else{
                                        print("UNAUTHORIZED")
                                    }
                                }
                                
                                handler()
                            }catch{
                                let alert = UIAlertController(title: "Server Non Disponibile", message: "Riprova più tardi", preferredStyle: UIAlertControllerStyle.alert )
                                UIApplication.shared.delegate?.window??.rootViewController?.present(alert, animated: true, completion: nil)

                                handler()
                            }
                        }else{
                            let alert = UIAlertController(title: "Server Non Disponibile", message: "Riprova più tardi", preferredStyle: UIAlertControllerStyle.alert )
                            UIApplication.shared.delegate?.window??.rootViewController?.present(alert, animated: true, completion: nil)
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
    
    func logout(handler : @escaping ( () -> Void )) {
        print("Logged Out")
        if  token != nil {
            session.request(baseUrl + "/api/auth/logout", method: .post).responseJSON{
                response in
                self.token = nil
                FBSDKLoginManager().logOut()
                handler()
            }
        }
        
    }
    
    func checkStatus(){
        if let token = self.token{
            
            print(token)
            
            session.request(baseUrl + "/api/auth/check", method: .get).responseJSON{
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
    
    func getProfile(handler :  @escaping ( (_ model : JSON?) -> Void ) ) {
        
        session.request( baseUrl + "/api/profile", method: .get).responseJSON{
            response in
            if let data = response.data {
                let json = JSON(data).dictionaryValue
                if json["error"]?.bool == false , let data = json["data"] {
                    handler(data)
                }else{
                    handler(nil)
                }
            }
        }
        
    }
    
    func updateProfile(parameters : [String : Any], handler :  @escaping ( (_ : Bool) -> Void ) ) {
        
        if let id = self.id{
            
            session.request( baseUrl + "/api/profile/" + id, method: .put, parameters: parameters, encoding: JSONEncoding.default).responseJSON{
                response in
                if let data = response.data {
                    let json = JSON(data).dictionaryValue
                    if json["error"]?.bool == false  {
                        handler(true)
                    }else{
                        handler(false)
                    }
                }
            }
        }
    }
    
    func getImage(url : String , handler :  @escaping ( (_ : Data?) -> Void ) ) {
        
        session.request( url , method: .get).responseImage{
            response in
            handler(response.data)
        }
        
    }
    
    func updateUserLocation(parameters : [String : Any], handler :  @escaping ( (_ model : JSON?) -> Void ) ) {
        
        session.request( baseUrl + "/api/profile/location", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{
            response in
            if let data = response.data {
                let json = JSON(data).dictionaryValue
                if json["error"]?.bool == false , let data = json["data"] {
                    handler(data)
                }else{
                    handler(nil)
                }
            }
        }
        
    }
    
    func updateUserLocationDistance(parameters : [String : Any], handler :  @escaping ( (_ model : JSON?) -> Void ) ) {
        
        session.request( baseUrl + "/api/profile/location/distance", method: .put, parameters: parameters, encoding: JSONEncoding.default).responseJSON{
            response in
            if let data = response.data {
                let json = JSON(data).dictionaryValue
                if json["error"]?.bool == false , let data = json["data"] {
                    handler(data)
                }else{
                    handler(nil)
                }
            }
        }
        
    }
    
    func deleteUserLocation(handler :  @escaping ( (_ model : Bool) -> Void ) ) {
        
        session.request( baseUrl + "/api/profile/location", method: .delete).responseJSON{
            response in
            if let data = response.data {
                let json = JSON(data).dictionaryValue
                if json["error"]?.bool == false  {
                    handler(true)
                }else{
                    handler(false)
                }
            }
        }
        
    }
    
    
    
    
}
