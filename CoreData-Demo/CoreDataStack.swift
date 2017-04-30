//
//  CoreDataStack.swift
//  CoreData-Demo
//
//  Created by Anirudha on 30/04/17.
//  Copyright © 2017 Anirudha Mahale. All rights reserved.
//

import CoreData

class CoreDataStack {
    
    // 1. variable holding model name
    let modelName = "Data"
    
    // 2. URL to application's Document Directory
    lazy var applicationDocumentDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1]
    }()
    
    // 3. Managed Object Model
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelUrl = Bundle.main.url(forResource: self.modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelUrl)!
    }()
    
    // 4. create persistant store coordinator
    private lazy var psc: NSPersistentStoreCoordinator = {
        let coordinator: NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url: URL = self.applicationDocumentDirectory.appendingPathComponent(self.modelName)
        
        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption : true]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            print("Error adding persistent store.")
        }
        return coordinator
    }()
    
    // 5. create context
    lazy var context: NSManagedObjectContext = {
        var managedObjectContext: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.psc
        return managedObjectContext
    }()
    
    // 6. public method to push the commited changes.
    func saveContext() {
        if context.hasChanges {
            do {
                _ = try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
