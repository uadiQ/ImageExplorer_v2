//
//  DataManager.swift
//  ImageExplorer
//
//  Created by Vadim Shoshin on 14.06.2018.
//  Copyright © 2018 Vadim Shoshin. All rights reserved.
//

import Foundation
import SDWebImage
import SwiftyJSON

protocol BrowseScreenRefreshing: class {
    func refreshCell(with postID: String)
}

final class DataManager {
    static let instance = DataManager()
    private let networkManager = NetworkManager.instance
    
    private init() { self.loadFavourites() }
    
    var favourites: [Post] = []
    
    weak var deletingDelegate: BrowseScreenRefreshing?
    
    var recents: [Post] = []
    
    func loadFavourites() {
        if !CoreDataManager.instance.isFavoritesEmpty {
            CoreDataManager.instance.fetchFavorites {[unowned self] fetchedFavorites in
                self.favourites = fetchedFavorites
            }
        }
    }
    
    func parseResponse(_ responseModel: ResponseModel, isFromSearch: Bool = false) -> ([Post], String)? {
        let jsons = isFromSearch ? responseModel.json["results"].array : responseModel.json.array
        guard let jsonArray = jsons else {
            print("Error at transition into array")
            return nil
        }
            var fetchedPosts: [Post] = []
            for object in jsonArray {
                guard let post = Post(json: object) else {
                    continue
                }
                fetchedPosts.append(post)
            }
            let response = (fetchedPosts, responseModel.paginationInfo)
            return response
        }
        
        func paginateRecents(with paginationURL: URL, completion: @escaping (String) -> Void) {
            networkManager.paginate(with: paginationURL) { [weak self] result in
                switch result {
                case .success(let responseModel):
                    guard let response = self?.parseResponse(responseModel) else {
                        print("Error at parsing data")
                        return
                    }
                    self?.recents.append(contentsOf: response.0)
                    completion(response.1)
                case .fail(let error):
                    NotificationCenter.default.post(name: .RequestFailed, object: nil)
                    print(error)
                }
            }
        }
        
        func paginateSearch(with paginationURL: URL, completion: @escaping (([Post],String)) -> Void) {
            networkManager.paginate(with: paginationURL) { [weak self] result in
                switch result {
                case .success(let responseModel):
                    guard let response = self?.parseResponse(responseModel, isFromSearch: true) else {
                        print("Error at parsing data")
                        return
                    }
                    completion(response)
                case .fail(let error):
                    NotificationCenter.default.post(name: .RequestFailed, object: nil)
                    print(error)
                }
            }
        }
        
        func fetchRecentPhotos(completion: @escaping (String) -> Void) {
            networkManager.fetchRecentPhotos { [weak self] result in
                switch result {
                case .success(let responseModel):
                    guard let response = self?.parseResponse(responseModel) else {
                        print("Error at parsing data")
                        return
                    }
                    self?.recents = response.0
                    completion(response.1)
                case .fail(let error):
                    NotificationCenter.default.post(name: .RequestFailed, object: nil)
                    print(error)
                }
            }
        }
        
        func performSearch(for category: String, completion: @escaping (Result<([Post], String), Error>) -> Void) {
            networkManager.searchPhotos(by: category) { [weak self] result in
                switch result {
                case .success(let responseModel):
                    guard let response = self?.parseResponse(responseModel, isFromSearch: true) else {
                        print("Error at parsing data")
                        return
                    }
                    completion(.success(response))
                case .fail(let error):
                    completion(.fail(error))
                    print(error)
                }
            }
        }
        
        func addToFavourites(post: Post) {
            DispatchQueue.global().async {
                var newPost = Post(id: post.id,
                                   urls: post.urls,
                                   links: post.links,
                                   user: post.user,
                                   height: post.height,
                                   width: post.width)
                
                // #warning ("real values up here")
                
                if let imageUrl = URL(string: newPost.urls.full) {
                    newPost.savePostImage(by: imageUrl)
                }
                self.favourites.append(newPost)
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .FavouritesChanged, object: nil)
                }
                CoreDataManager.instance.addPostToFavorites(newPost)
            }
        }
        
        func deleteFromFavourites(post: Post) {
            let id = post.id
            guard let deletingIndex = favourites.index(of: post) else {
                print("No such post at favourites")
                return
            }
            favourites.remove(at: deletingIndex)
            CoreDataManager.instance.deletePostFromFavorites(post)
            deletingDelegate?.refreshCell(with: id)
        }
        
        func downloadImage(with url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
            networkManager.downloadImage(with: url, completion: completion)
        }
}
