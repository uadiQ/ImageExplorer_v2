//
//  PostMO+CoreDataClass.swift
//  ImageExplorer
//
//  Created by Vadim Shoshin on 15.06.2018.
//  Copyright © 2018 Vadim Shoshin. All rights reserved.
//
//

import UIKit
import CoreData


public class PostMO: NSManagedObject {
    func convertedPlainObject() -> Post {
        let user = User(name: self.fullName ?? "", username: self.username ?? "")
        let urls = Urls(full: self.fullImageUrl ?? "", regular: self.regularImageUrl ?? "")
        let links = Links(html: self.htmlLink ?? "")
        
        var plainPost = Post(id: self.id ?? "", urls: urls, links: links, user: user)
        plainPost.addImage(from: self.fullPhotoImage)
        return plainPost
    }
    
    func setup(from post: Post) {
        id = post.id
        fullImageUrl = post.urls.full
        regularImageUrl = post.urls.regular
        fullName = post.user.name
        username = post.user.username
        htmlLink = post.links.html
        if let image = post.fullPhotoImage {
            guard let imageData = UIImagePNGRepresentation(image) else { return }
            self.fullPhotoImage = NSData(data: imageData)
        }
    }
}
