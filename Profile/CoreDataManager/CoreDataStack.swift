//
//  CoreDataStack.swift
//  Navigation
//
//  Created by v.milchakova on 27.05.2021.
//  Copyright © 2021 Artem Novichkov. All rights reserved.
//

import Foundation
import CoreData

final class CoreDataStack {
    
    private let modelName: String
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    lazy var persistentStoreContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError()
            }
        }
        return container
    }()
    
    func getContext() -> NSManagedObjectContext {
        persistentStoreContainer.newBackgroundContext()
    }
    
    func save() {
        let context = getContext()
        
        context.performAndWait {
            if context.hasChanges {
                do {
                    try context.save()
                    context.reset()
                } catch {
                    context.rollback()
                }
            }
        }

    }
    
    func create<T: NSManagedObject> (from entity: T.Type, title: String) -> T? {
        
        let context = persistentStoreContainer.viewContext
        
        if !isExist(title: title, context: context) {
            return NSEntityDescription.insertNewObject(forEntityName: String(describing: entity), into: context) as? T
        }
        return nil
    }
    
    func delete(object: NSManagedObject) {
        let context = persistentStoreContainer.viewContext
        context.delete(object)
        save()
    }
    
    func fetchData<T: NSManagedObject>(for entity: T.Type, predicate: NSPredicate?) -> [Post] {
        let taskContext = persistentStoreContainer.viewContext
        
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        taskContext.undoManager = nil

        let entityName = String(describing: T.self)
        let request = NSFetchRequest<T>(entityName: entityName)
        request.predicate = predicate

        do {
            let posts = try taskContext.fetch(request) as! [Post]
            return posts
        } catch {
            fatalError()
        }
    }
    
    private func isExist(title: String, context: NSManagedObjectContext) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Post")
        fetchRequest.predicate = NSPredicate(format: "title = %s", argumentArray: [title])

        let res = try? context.fetch(fetchRequest)
        guard let result = res else {
            return false
        }
        return result.count > 0 ? true : false
    }
}
