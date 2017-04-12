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
import Haneke
import PromiseKit

class ModelNotizie {
    
    var session : Alamofire.SessionManager {
        return login.session
    }
    
    var login : LoginUtils{
        return LoginUtils.sharedInstance
    }
    
    var headers: HTTPHeaders {
        return login.headers
    }
    
    let cache = Shared.dataCache
    
    var page : Int = 1
    var nextPage : Int = 2
    var pageSize : Int = 15
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
    
    func getNewsWithQuery(query : [String:String], handler :  @escaping ( ( _ model : [JSON], _ pagination : [String : JSON]?) -> Void ) ) {
        
        if(self.page > self.totalPages){
            self.page = self.totalPages
            return
        }
        
        var url = baseUrl + "/api/news?page=\(page)&pageSize=\(pageSize)"
        
        if(query.count > 0){
            for(key,value) in query{
                url = url + "&\(key)=\(value)"
            }
        }
        
        print(url)
        
        
        session.request( url, method: .get,  headers: self.headers).responseJSON{
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
    
    func getSingleNews(id : String , query : [String:String], handler :  @escaping ( ( _ model : JSON?) -> Void ) ) {
        
        
        var url = baseUrl + "/api/news/" + id
        
        if(query.count > 0){
            url = url + "?"
            for(key,value) in query{
                url = url + "&\(key)=\(value)"
            }
        }
        
        print(url)
        
        
        session.request( url, method: .get,  headers: self.headers).responseJSON{
            response in
            if let data = response.data {
                let json = JSON(data).dictionaryValue
                if json["error"]?.bool == false , let data = json["data"]{
                    
                    handler(data)
                    
                }else{
                    handler(nil)
                }
            }
        }
        
    }
    
    func postNews(parameters : [String : Any], handler :  @escaping ( (_ model : JSON?) -> Void ) ) {
        
        self.login.isLogged {
            self.session.request( self.baseUrl + "/api/news", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: self.headers).responseJSON{
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
    
    func vote(voto : Voto, notizia : String, handler :  @escaping ( (_ model : JSON?) -> Void )){
        self.login.isLogged {
            let parameters = [
                "notizia_id" : notizia,
                "voto" : voto.rawValue
            ]
            
            self.session.request( self.baseUrl + "/api/vote", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: self.headers).responseJSON{
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
    }
    
    func getNewsToVote(handler :  @escaping ( (_ model : [JSON]) -> Void ) ) {
        self.login.isLogged {
            self.session.request( self.baseUrl + "/api/vote", method: .get, headers: self.headers).responseJSON{
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
    
    func deleteNews(id : String , handler :  @escaping ( ( _ response : Bool ) -> Void ) ) {
        self.login.isLogged {
            self.session.request( self.baseUrl + "/api/news/\(id)", method: .delete, headers: self.headers).responseJSON{
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
    
    func promoteNews(id : String , handler :  @escaping ( ( _ response : Bool ) -> Void ) ) {
        self.login.isLogged {
            self.session.request( self.baseUrl + "/api/news/promote/\(id)", method: .put, headers: self.headers).responseJSON{
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
    
    
    
    func getEvent(eventId : String , handler :  @escaping ( (_ model : JSON?) -> Void ) ) {
        
        var url =  baseUrl + "/api/events/" + eventId
        
        session.request(url, method: .get, headers: self.headers).responseJSON{
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
        
        session.request(url, method: .get, headers: self.headers).responseJSON{
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
        self.login.isLogged {
            self.session.request( self.baseUrl + "/api/events", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: self.headers).responseJSON{
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
    
    
    func getUser(id : String , query : [String:String], handler :  @escaping ( ( _ model : JSON?) -> Void ) ) {
        
        
        var url = baseUrl + "/api/users/" + id
        
        if(query.count > 0){
            url = url + "?"
            for(key,value) in query{
                url = url + "&\(key)=\(value)"
            }
        }
        
        print(url)
        
        session.request( url, method: .get,  headers: self.headers).responseJSON{
            response in
            if let data = response.data {
                let json = JSON(data).dictionaryValue
                if json["error"]?.bool == false , let data = json["data"]{
                    
                    handler(data)
                    
                }else{
                    handler(nil)
                }
            }
        }
        
    }
    
    func getProfile(handler :  @escaping ( (_ model : JSON?) -> Void ) ) {
        if let _ = login.id {
            self.session.request( self.baseUrl + "/api/profile", method: .get, headers: self.headers).responseJSON{
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
    
    func updateProfile(parameters : [String : Any], handler :  @escaping ( (_ : Bool) -> Void ) ) {
                
        if let id = login.id{
            self.login.isLogged {
                self.session.request( self.baseUrl + "/api/profile/" + id, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: self.headers).responseJSON{
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
    }
    
    func getImage(url : String) -> Promise<UIImage> {
        return Promise { fulfill, reject in
            session.request( url , method: .get, headers: self.headers).responseImage{
                response in
                switch response.result {
                    case .success(let image):
                        fulfill(image)
                    case .failure(let error):
                        reject(error)
                }
            }

        }
    }
    
    func updateUserLocation(parameters : [String : Any], handler :  @escaping ( (_ model : JSON?) -> Void ) ) {
        if let _ = login.id {
            self.session.request( self.baseUrl + "/api/profile/location", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: self.headers).responseJSON{
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
    
    func updateUserLocationDistance(parameters : [String : Any], handler :  @escaping ( (_ model : JSON?) -> Void ) ) {
        if let _ = login.id {
            self.login.session.request( self.baseUrl + "/api/profile/location/distance", method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: self.headers).responseJSON{
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
    
    func deleteUserLocation(handler :  @escaping ( (_ model : Bool) -> Void ) ) {
        self.login.isLogged {
            self.session.request( self.baseUrl + "/api/profile/location", method: .delete, headers: self.headers).responseJSON{
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
    
    
    func getPhoto(photo : String, handler :  @escaping ( (_ image : UIImage?) -> Void ) ) {
        
        DispatchQueue.global(qos: .background).async {
            
            // Eventually...
            
            self.cache.fetch(key: photo).onSuccess { data in
                DispatchQueue.main.async {
                    handler(UIImage(data: data))
                }
            }.onFailure{
                fail in
                self.session.request(self.baseUrl + "/photos/\(photo)").responseImage{
                    response in
                    if let data = response.data{
                        self.cache.set(value: data, key: photo)
                        
                        DispatchQueue.main.async {
                            
                            let image = UIImage(data: data)
                            handler(image)
                            
                        }
                    }
                }
            }
            
        }
        
        
    }


    
}


