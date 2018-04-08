//
//  APIRoutes.swift
//  DTS-iOS
//
//  Created by Viktor on 03/11/2016.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

typealias OptionalDictionary = [String : String]?
typealias OptionalSwiftJSONParameters = [String : JSON]?


infix operator => {associativity left precedence 160}
infix operator =| {associativity left precedence 160}
infix operator =/ {associativity left precedence 160}

func =>(key : String, json : OptionalSwiftJSONParameters) -> String?{
    return json?[key]?.stringValue
}

func =/(key : String, json : OptionalSwiftJSONParameters) -> Int?{
    return json?[key]?.int
}

func =|(key : String, json : OptionalSwiftJSONParameters) -> [JSON]?{
    return json?[key]?.arrayValue
}



prefix operator ¿ {}
prefix func ¿(value : String?) -> String {
    return value.unwrap()
}


protocol Router {
    var route : String { get }
    var baseURL : String { get }
    var parameters : OptionalDictionary { get }
    var method : Alamofire.Method { get }
}



enum API {
    
    static func mapKeysAndValues(keys : [String]?,values : [String]?) -> [String : String]?{
        guard let tempValues = values,let tempKeys = keys else { return nil}
        var params = [String : String]()
        for (key,value) in zip(tempKeys,tempValues) {
            params[key] = ¿value
        }
        return params
    }
    
    
    enum PropertyEnum {
        case NearByProperties(page: String?, token: String?, showOwnedOnly: String?, showActiveOnly: String?, latitude: String?, longitude: String?)
        
    }
    
    
    case PropertyAPI(value: PropertyEnum)
    //case ProductAPI(value : ProductEnum)
}


extension API : Router{
    
    var route : String {
        switch self {
        case .PropertyAPI(let value):
            switch value {
            case .NearByProperties(_):
                return APIPaths.GetProperty
            default:
                return ""
            }
        default:
            return ""
        }
    }
    
    
    var baseURL : String {  return APIConstants.BasePath }
    
    var parameters : OptionalDictionary {
        return formatParameters()
    }
    
    func url() -> String {return baseURL + route}

    var method : Alamofire.Method {  return  .GET}
    var postMethod: Alamofire.Method { return .POST }
    
}



extension API {
    
    func formatParameters() -> OptionalDictionary {
        switch self {
        case .PropertyAPI(let value):
            switch value {
            case .NearByProperties(let page, let token, let showOwnedOnly, let showActiveOnly, let latitude, let longitude):
                return API.mapKeysAndValues(APIParameterConstants.Property.GetProperties, values: [¿page, ¿token, ¿showOwnedOnly, ¿showActiveOnly, ¿latitude, ¿longitude])
            }
        default:
            return [:]
        }
    }
    
}
