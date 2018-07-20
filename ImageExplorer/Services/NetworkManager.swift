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

enum NetworkError: Error {
    case imageDownloadError
}

final class NetworkManager {
    static let instance = NetworkManager()
    
    private init() { }
    
    func fetchRecentPhotos(completionHandler: @escaping (Result<JSON, Error>) -> Void) {
        let parameters: Parameters = [ "per_page": 30 ]
        Alamofire.request(Constants.Networking.photos, method: .get, parameters: parameters, headers: Constants.Networking.headers).responseJSON { response in
            
            // Getting info for pagination
            
            if let link = response.response?.allHeaderFields["Link"] as? String {
                self.parsePaginationInfo(linkString: link)
            }
 
            
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
    
    func searchPhotos(by keyword: String, completionHandler: @escaping (Result<JSON, Error>) -> Void) {
        let parameters: Parameters = [ "per_page": 30, "query": keyword ]
        Alamofire.request(Constants.Networking.searchPhotos, method: .get, parameters: parameters, headers: Constants.Networking.headers).responseJSON { response in
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
    
    func downloadImage(with url: URL, completion:@escaping (Result<UIImage, Error>) -> Void) {
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: url),
                let image = UIImage(data: imageData) else {
                    completion(.fail(NetworkError.imageDownloadError))
                    return
            }
            completion(.success(image))
        }
    }
    
    private func parsePaginationInfo(linkString: String) {
        let links = linkString.split(separator: ",")
        let components = links.flatMap { $0.split(separator: ";") }
        if let lastComponent = components.last, lastComponent.hasSuffix("\"next\"") {
            let requiredIndex = components.index(of: lastComponent)! - 1
            var nextPage = components[requiredIndex]
            nextPage.removeFirst()
            nextPage.removeLast()
            print(nextPage)
        }
    }
    
}

