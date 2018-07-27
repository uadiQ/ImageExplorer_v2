//
//  PostMO+CoreDataClass.swift
//  
//
//  Created by swstation on 7/27/18.
//
//
import UIKit
import CoreData


public class PostMO: NSManagedObject {
    func convertedPlainObject() -> Post {
        let user = User(name: self.fullName ?? "", username: self.username ?? "")
        let urls = Urls(full: self.fullImageUrl ?? "", regular: self.regularImageUrl ?? "")
        let links = Links(html: self.htmlLink ?? "")
        
        //#warning ("paste normal values here")
        
        var plainPost = Post(id: self.id ?? "", urls: urls, links: links, user: user, height: Int(self.height), width: Int(self.width))
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
        height = Int64(post.height)
        width = Int64(post.width)
        if let image = post.fullPhotoImage {
            guard let imageData = UIImagePNGRepresentation(image) else { return }
            self.fullPhotoImage = NSData(data: imageData)
        }
    }
}
