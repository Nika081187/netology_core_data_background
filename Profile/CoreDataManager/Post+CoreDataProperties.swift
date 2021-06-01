//
//  Post+CoreDataProperties.swift
//  Navigation
//
//  Created by v.milchakova on 27.05.2021.
//  Copyright © 2021 Artem Novichkov. All rights reserved.
//
//

import Foundation
import CoreData


extension Post {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Post> {
        return NSFetchRequest<Post>(entityName: "Post")
    }

    @NSManaged public var author: String?
    @NSManaged public var title: String?
    @NSManaged public var image: Data?
    @NSManaged public var likes: Int64
    @NSManaged public var views: Int64

}
