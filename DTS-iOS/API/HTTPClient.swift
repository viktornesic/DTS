//
//  HTTPClient.swift
//  DTS-iOS
//
//  Created by Viktor on 03/11/2016.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation

import Alamofire

typealias HttpClientSuccess = (AnyObject?) -> ()
typealias HttpClientFailure = (NSError) -> ()

class HTTPClient {
    
    func postRequest(withApi api : API  , success : HttpClientSuccess , failure : HttpClientFailure )  {
        
        let params = api.parameters
        let fullPath = api.url()
        let method = api.method
        
        Alamofire.request(method, fullPath, parameters: params, encoding: ParameterEncoding.JSON, headers: nil).responseJSON(completionHandler: { (Response) -> Void in
            switch(Response.result) {
            case .Success(let data):
                success(data as AnyObject?)
            case .Failure(let error):
                failure(error as NSError)
            }
            
        })
    }
    
}
