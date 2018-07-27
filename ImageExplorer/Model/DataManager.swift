//
//  DataManager.swift
//  ImageExplorer
//
//  Created by Vadim Shoshin on 14.06.2018.
//  Copyright © 2018 Vadim Shoshin. All rights reserved.
//

import Foundation
import SDWebImage

final class DataManager {
    static let instance = DataManager()
    private let networkManager = NetworkManager.instance
    
    private init() { self.loadFavourites() }
    
    var favourites: [Post] = []
    
    var recents: [Post] = [] {
        didSet {
            NotificationCenter.default.post(name: .RecentsUpdated, object: nil)
        }
    }
    
    func loadFavourites() {
        if !CoreDataManager.instance.isFavoritesEmpty {
            CoreDataManager.instance.fetchFavorites {[unowned self] fetchedFavorites in
                self.favourites = fetchedFavorites
            }
        }
    }
    
    func fetchRecentPhotos() {
        networkManager.fetchRecentPhotos { [weak self] result in
            switch result {
            case .success(let jsonValue):
                guard let jsonArray = jsonValue.array else {print("Error at transition into array"); return }
                var fetchedPosts: [Post] = []
                for object in jsonArray {
                    guard let post = Post(json: object) else { continue }
                    fetchedPosts.append(post)
                }
                self?.recents = fetchedPosts
                
            case .fail(let error):
                NotificationCenter.default.post(name: .RequestFailed, object: nil)
                print(error)
            }
        }
    }
    
    func performSearch(for category: String, completion: @escaping (Result<[Post], Error>) -> Void) {
        networkManager.searchPhotos(by: category) { result in
            switch result {
            case .success(let jsonValue):
                guard let jsonArray = jsonValue["results"].array else {print("Error at transition into array"); return }
                var fetchedPosts: [Post] = []
                for object in jsonArray {
                    guard let post = Post(json: object) else { continue }
                    fetchedPosts.append(post)
                }
                completion(.success(fetchedPosts))
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
                               height: 1080,
                               width: 1920)
            
            #warning ("real values up here")
            
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
        guard let deletingIndex = favourites.index(of: post) else {
            print("No such post at favourites")
            return
        }
        favourites.remove(at: deletingIndex)
        CoreDataManager.instance.deletePostFromFavorites(post)
    }
    
    func downloadImage(with url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        networkManager.downloadImage(with: url, completion: completion)
    }
}
