//
//  APIConstants.swift
//  DTS-iOS
//
//  Created by Viktor on 03/11/2016.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation

internal struct APIConstants {
    /////dev/////
//    static let BasePath = "https://api.dev-ditchthe.space"
    /////staging/////
//    static let BasePath = "https://api.qa-ditchthe.space"
    /////Live/////
    static let BasePath = "https://api.ditchthe.space"
}


internal struct APIPaths {
    static let GetProperty = "api/getproperty"
    
}


internal struct FormatParameterKeys{
    static let Page = "page"
    static let Token = "token"
    static let ShowOwnedOnly = "show_owned_only"
    static let ShowActiveOnly = "show_active_only"
    static let Latitude = "latitude"
    static let Longitude = "longitude"
    
    /*static let UserId = "userId"
    static let PageIndex = "page"
    static let PageSize = "pageSize"*/
}

internal struct OtherConstants {
    static let token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjIwLCJpc3MiOiJodHRwOlwvXC9hZG1pbmR0cy5sb2NhbGhvc3QuY29tXC9vbGRhcGlcL2F1dGhlbnRpY2F0ZSIsImlhdCI6MTQ2MzkzMzg4NSwiZXhwIjoxNTU3MjQ1ODg1LCJuYmYiOjE0NjM5MzM4ODUsImp0aSI6IjJkOGY4YWE3YzU5MWRmYmVkOTAxODE2ZmRiYmU3ZWFkIn0.uPteNq6R9e35rBFuy6UmjNOXL0VJoaehk_OPqHWtFh"
}

internal struct APIParameterConstants {
    struct Property {
        static let GetProperties = [FormatParameterKeys.Page, FormatParameterKeys.Token, FormatParameterKeys.ShowOwnedOnly, FormatParameterKeys.ShowActiveOnly, FormatParameterKeys.Latitude, FormatParameterKeys.Longitude]
    }
    /*struct Product {
        static let RecentSold = [FormatParameterKeys.UserId,FormatParameterKeys.PageIndex,FormatParameterKeys.PageSize]
        static let SubscriptionPacks = [FormatParameterKeys.UserId]
        
    }*/
}
