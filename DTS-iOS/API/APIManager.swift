//
//  APIManager.swift
//  DTS-iOS
//
//  Created by Viktor on 03/11/2016.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation

import SwiftyJSON


typealias APICompletion = (APIResponse) -> ()




class APIManager: NSObject {
    
    static let sharedInstance = APIManager()
    private lazy var httpClient : HTTPClient = HTTPClient()
    func opertationWithRequest ( withApi api : API , completion : (APIResponse) -> () )  {
        httpClient.postRequest(withApi: api, success: { (data) in
            guard let response = data else {
                completion(APIResponse.Failure(""))
                return
            }
            let json = JSON(response)
            completion(.Success(api.handleResponse(json)))
            
        }) { (error) in
            print(error)
        }
    }
}
