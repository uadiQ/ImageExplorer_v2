//
//  PostMO+CoreDataProperties.swift
//  ImageExplorer
//
//  Created by Vadim Shoshin on 15.06.2018.
//  Copyright © 2018 Vadim Shoshin. All rights reserved.
//
//

import Foundation
import CoreData


extension PostMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PostMO> {
        return NSFetchRequest<PostMO>(entityName: "PostMO")
    }

    @NSManaged public var id: String?
    @NSManaged public var fullImageUrl: String?
    @NSManaged public var regularImageUrl: String?
    @NSManaged public var fullName: String?
    @NSManaged public var username: String?
    @NSManaged public var htmlLink: String?
    @NSManaged public var fullPhotoImage: NSData?

}
