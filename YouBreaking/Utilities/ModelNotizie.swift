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
import AlamofireImage

import SwiftyJSON
import JWTDecode

class ModelNotizie {
    
    var session : Alamofire.SessionManager {
        return login.session
    }
    
    var login : LoginUtils{
        return LoginUtils.sharedInstance
    }
    
    var page : Int = 1
    var nextPage : Int = 2
    var pageSize : Int = 5
    var totalItems : Int = 1
    var totalPages : Int = 1
    
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
    
    func sendNotificationToken(_ deviceToken : Data, handler :  @escaping ( (_ model : Bool) -> Void )){
        
        let token = String(data: deviceToken.base64EncodedData(), encoding: .utf8)?.trimmingCharacters(in: CharacterSet.whitespaces).trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
        if let token = token{
            let parameters = [ "devicetoken" : token ]
            
            session.request(baseUrl + "/api/register/ios", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{
                response in
                print(response.request)
                print(response.error)
                handler(true)
            }
        }
        
    }
    
    func getNews(handler :  @escaping ( ( _ model : [JSON], _ pagination : [String : JSON]?) -> Void ) ) {
        
        if(self.page > self.totalPages){
            self.page = self.totalPages
            return
        }
        
        session.request( baseUrl + "/api/news?live=true&page=\(page)&pageSize=\(pageSize)", method: .get).responseJSON{
            response in
            if let data = response.data {
                let json = JSON(data).dictionaryValue
                if json["error"]?.bool == false , let data = json["data"], let pagination = json["pagination"] {
                    
                    handler(data.arrayValue,pagination.dictionaryValue)

                    self.page = pagination["page"].int!
                    self.pageSize = pagination["pageSize"].int!
                    self.totalPages = pagination["pages"].int!
                    self.totalItems = pagination["total"].int!
                }else{
                    handler([JSON](), nil)
                }
            }
        }
        
    }
    
    func getNewsNotLive(handler :  @escaping ( (_ model : [JSON]) -> Void ) ) {
        
        session.request( baseUrl + "/api/news?live=false&page=\(page)&pageSize=\(pageSize)", method: .get).responseJSON{
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
                
        if let id = login.id{
        
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


enum Voto: String{
    case UP = "UP"
    case DOWN = "DOWN"
    case NO = "NO"
}
