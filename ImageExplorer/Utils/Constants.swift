//
//  Constants.swift
//  ImageExplorer
//
//  Created by Vadim Shoshin on 14.06.2018.
//  Copyright © 2018 Vadim Shoshin. All rights reserved.
//

import UIKit
import Alamofire

enum Constants {
    static let accessKey = "331cf76d030f45bdc36b3bf7de0dc0c789f7458076cc705648c8a9520681832e"
    static var authorizationHeaderValue: String {
        return "Client-ID " + Constants.accessKey
    }
    
    static let showDetails = "showDetails"
    
    enum Networking {
        
        static var baseWeb: URL {
            guard let baseURL = URL(string: "https://unsplash.com/") else { fatalError("Error at creating base URL") }
            return baseURL
        }
        static var baseAPI: URL {
            guard let baseURL = URL(string: "https://api.unsplash.com/") else { fatalError("Error at creating base URL") }
            return baseURL
        }
        
        static var photos: URL {
            return Networking.baseAPI.appendingPathComponent("photos")
        }
        
        static var headers: HTTPHeaders {
            let headers: HTTPHeaders = [
                "Authorization" : Constants.authorizationHeaderValue,
                "Content-Type" : "application/json",
                "Accept-Version" : "v1"
            ]
            return headers
        }
    }
}
