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
    let urls: Urls
    let links: Links
    let user: User
    
    var fullPhotoImage: UIImage?
    
    init(id: String, urls: Urls, links: Links, user: User) {
        self.id = id
        self.urls = urls
        self.links = links
        self.user = user
    }
    
    init?(json: JSON) {
        guard let id = json["id"].string,
        let html = json["links"]["html"].string,
            let full = json["urls"]["full"].string,
            let regular = json["urls"]["regular"].string,
            let username = json["user"]["username"].string,
            let name = json["user"]["name"].string else {
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
    }
    
    mutating func addImage(from data: NSData?) {
        guard let imageData = data else { return }
        let imageToSet = UIImage(data: imageData as Data)
        self.fullPhotoImage = imageToSet
    }
    
    mutating func saveMealImage(by url: URL) {
        guard let dataImage = try? Data(contentsOf: url) else { return }
        self.fullPhotoImage = UIImage(data: dataImage)
    }
}

extension Post: Equatable {
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id
    }
}

