//
//  PostMO+CoreDataProperties.swift
//  
//
//  Created by swstation on 7/27/18.
//
//

import Foundation
import CoreData


extension PostMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PostMO> {
        return NSFetchRequest<PostMO>(entityName: "PostMO")
    }

    @NSManaged public var fullImageUrl: String?
    @NSManaged public var fullName: String?
    @NSManaged public var fullPhotoImage: NSData?
    @NSManaged public var htmlLink: String?
    @NSManaged public var id: String?
    @NSManaged public var regularImageUrl: String?
    @NSManaged public var username: String?
    @NSManaged public var height: Int64
    @NSManaged public var width: Int64

}
