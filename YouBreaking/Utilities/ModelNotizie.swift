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

class ModelNotizie {
    
    var session : Alamofire.SessionManager {
        return login.session
    }
    
    var login : LoginUtils
    
    init(){
        
        login = LoginUtils()
        
    }
    
    func getNews(handler :  @escaping ( (_ model : [JSON]) -> Void ) ) {
        
        session.request("http://192.168.1.11:3000/api/news", method: .get).responseJSON{
            response in
            if let data = response.data {
                let json = JSON(data).dictionaryValue
                if json["error"]?.bool == false , let data = json["data"] {
                    handler(data.arrayValue)
                }else{
                    handler([JSON]())
                }
            }
        }
        
    }
    
    func postNews(parameters : [String : Any], handler :  @escaping ( (_ model : JSON?) -> Void ) ) {
        
        session.request("http://192.168.1.11:3000/api/news", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{
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
    
    func vote(voto : Voto, notizia : String, handler :  @escaping ( (_ model : JSON?) -> Void )){
        
        let parameters = [
            "notizia_id" : notizia,
            "voto" : voto.rawValue
        ]
        
        session.request("http://192.168.1.11:3000/api/vote", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{
            response in
            if let data = response.data {
                let json = JSON(data).dictionaryValue
                if json["error"]?.bool == false {
                    handler(JSON(data))
                }else{
                    handler(nil)
                }
            }
        }
    }
    
    func getNewsToVote(handler :  @escaping ( (_ model : [JSON]) -> Void ) ) {
        
        session.request("http://192.168.1.11:3000/api/vote", method: .get).responseJSON{
            response in
            if let data = response.data {
                let json = JSON(data).dictionaryValue
                if json["error"]?.bool == false , let data = json["data"] {
                    handler(data.arrayValue)
                }else{
                    handler([JSON]())
                }
            }
        }
        
    }
    
    
}


enum Voto: String{
    case UP = "UP"
    case DOWN = "DOWN"
    case NO = "NO"
}
