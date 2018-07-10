//
//  NetworkManager.swift
//  ImageExplorer
//
//  Created by Vadim Shoshin on 14.06.2018.
//  Copyright © 2018 Vadim Shoshin. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

final class NetworkManager {
    static let instance = NetworkManager()
    
    private init() { }
    
    func fetchRecentPhotos(completionHandler: @escaping (Result<JSON>) -> Void) {
        Alamofire.request(Constants.Networking.photos, headers: Constants.Networking.headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let jsonResponse = JSON(value)
                completionHandler(.success(jsonResponse))
                
            case .failure(let error):
                print("failedRequest")
                completionHandler(.fail(error))
                
            }
        }
    }
    
}

