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
    
    init(){
        
        login = LoginUtils()
        
    }
    
    func getNews(handler :  @escaping ( (_ model : [JSON]) -> Void ) ) {
        
        session.request( baseUrl + "/api/news", method: .get).responseJSON{
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
        
        session.request( baseUrl + "/api/news", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{
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
        
        session.request( baseUrl + "/api/vote", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{
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
        
        session.request( baseUrl + "/api/vote", method: .get).responseJSON{
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
    
    func getEvent(eventId : String , additionalQuery : [String : String], handler :  @escaping ( (_ model : JSON?) -> Void ) ) {
        
        var url =  baseUrl + "/api/events/" + eventId
        if ( additionalQuery.count > 0){
            url = url + "?"
            for ( key , value ) in additionalQuery{
                url = url + key + "=" + value + "&"
            }
        }
        
        session.request(url, method: .get).responseJSON{
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
    
    
    func getEvents( additionalQuery : [String : String], handler :  @escaping ( (_ model : [JSON]) -> Void ) ) {
        
        var url =  baseUrl + "/api/events/"
        if ( additionalQuery.count > 0){
            url = url + "?"
            for ( key , value ) in additionalQuery{
                url = url + key + "=" + value + "&"
            }
        }
        
        session.request(url, method: .get).responseJSON{
            response in
            if let data = response.data {
                let json = JSON(data).dictionaryValue
                if json["error"]?.bool == false , let data = json["data"]?.arrayValue {
                    handler(data)
                }else{
                    handler([JSON]())
                }
            }
        }
        
    }
    
    func postEvent(parameters : [String : Any], handler :  @escaping ( (_ model : JSON?) -> Void ) ) {
        
        session.request( baseUrl + "/api/events", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{
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
    
}


enum Voto: String{
    case UP = "UP"
    case DOWN = "DOWN"
    case NO = "NO"
}
