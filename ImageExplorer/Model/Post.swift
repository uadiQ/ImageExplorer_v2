//
//  Post.swift
//  ImageExplorer
//
//  Created by Vadim Shoshin on 14.06.2018.
//  Copyright © 2018 Vadim Shoshin. All rights reserved.
//

import UIKit
import SwiftyJSON

struct Urls {
    let full: String
    let regular: String
}

struct User {
    let name: String
    let username: String
}

struct Links {
    let html: String
}

struct Post {
    let id: String
    let user: User
    let width: Int
    let height: Int
    
    var fullPhotoImage: UIImage?
    
    let urls: Urls
    let links: Links
    var ratio: CGFloat {
        return (CGFloat(width) / CGFloat(height))
    }
    
    init(id: String, urls: Urls, links: Links, user: User, height: Int, width: Int) {
        self.id = id
        self.urls = urls
        self.links = links
        self.user = user
        self.height = height
        self.width = width
    }
    
    init?(json: JSON) {
        guard let id = json["id"].string,
        let html = json["links"]["html"].string,
            let full = json["urls"]["full"].string,
            let regular = json["urls"]["regular"].string,
            let username = json["user"]["username"].string,
            let name = json["user"]["name"].string,
            let width = json["width"].int,
            let height = json["height"].int else {
                print("Didn't parse all needed data")
                return nil
        }
        
        let links = Links(html: html)
        let user = User(name: name, username: username)
        let urls = Urls(full: full, regular: regular)
        
        self.id = id
        self.links = links
        self.urls = urls
        self.user = user
        self.width = width
        self.height = height
    }
    
    mutating func addImage(from data: NSData?) {
        guard let imageData = data else { return }
        let imageToSet = UIImage(data: imageData as Data)
        self.fullPhotoImage = imageToSet
    }
    
    mutating func savePostImage(by url: URL) {
        guard let dataImage = try? Data(contentsOf: url) else { return }
        self.fullPhotoImage = UIImage(data: dataImage)
    }
}

extension Post: Equatable {
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id
    }
}
