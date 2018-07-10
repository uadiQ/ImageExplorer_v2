//
//  CoreDataManager.swift
//  ImageExplorer
//
//  Created by Vadim Shoshin on 14.06.2018.
//  Copyright © 2018 Vadim Shoshin. All rights reserved.
//

import UIKit
import CoreData

final class CoreDataManager {
    static let instance = CoreDataManager()
    private init() {}
    

    var isFavoritesEmpty: Bool {
        let request: NSFetchRequest = PostMO.fetchRequest()
        guard let postsCount = try? persistentContainer.viewContext.count(for: request) else { return false }
        return !(postsCount > 0)
    }
    
    func fetchFavorites(completionHandler: @escaping ([Post]) -> Void) {
        persistentContainer.performBackgroundTask { bgContext in
            let request: NSFetchRequest = PostMO.fetchRequest()
            let fetchedResult = (try? bgContext.fetch(request)) ?? []
            let result = fetchedResult.map {
                $0.convertedPlainObject()
            }
            completionHandler(result)
        }
    }
    
    func addPostToFavorites(_ post: Post) {
        persistentContainer.performBackgroundTask { bgContext in
            let postMO = PostMO(context: bgContext)
            postMO.setup(from: post)
            try? bgContext.save()
        }
    }
    
    func refreshFavorites(_ favorites: [Post]) {
        deleteAllData()
        persistentContainer.performBackgroundTask { bgContext in
            favorites.forEach {
                let postMO = PostMO(context: bgContext)
                postMO.setup(from: $0)
            }
            try? bgContext.save()
        }
    }
    
    func deleteAllData() {
        persistentContainer.performBackgroundTask { bgContext in
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: PostMO.fetchRequest())
            _ = try? bgContext.execute(deleteRequest)
            try? bgContext.save()
        }
    }
    
    func deletePostFromFavorites(_ post: Post) {
        let deletionId = post.id
        persistentContainer.performBackgroundTask { bgContext in
            
            let request: NSFetchRequest<PostMO> = PostMO.fetchRequest()
            let idPredicate = NSPredicate(format: "id = %@", deletionId)
            
            request.predicate = idPredicate
            if let result = try? bgContext.fetch(request) {
                print(result)
                for object in result {
                    bgContext.delete(object)
                }
            }
            try? bgContext.save()
        }
    }
  
    // MARK: - Core Data stack
    private lazy var persistentContainer: NSPersistentContainer = {
        
        
        let container = NSPersistentContainer(name: "ImageExplorer")
        
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    private func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
