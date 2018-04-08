//
//  APIResponse.swift
//  DTS-iOS
//
//  Created by Viktor on 03/11/2016.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation

import SwiftyJSON

extension API{
    
    func handleResponse(parameters : JSON?) -> AnyObject? {
        switch self {
        case .ProductAPI(let value):
            switch value {
            case .RecentProduct(_):
                return "" as AnyObject?
                //return Product.parseArrayinToModal(withAttributes: parameters?.dictionaryValue["Products"]?.arrayValue)
            case .GetSubscriptionPacks(_):
                return "" as AnyObject?
                //return SubscriptionPack.parseArrayinToModal(withAttributes: parameters?.arrayValue)
            }
        default:
            return "" as AnyObject?
        }
    }
}
enum APIValidation : String{
    case None
    case Success = "1"
    case ServerIssue = "500"
    case Failed = "0"
    case TokenInvalid = "401"
}


enum APIResponse {
    case Success(AnyObject?)
    case Failure(String?)
}
