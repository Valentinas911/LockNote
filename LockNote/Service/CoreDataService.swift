//
//  CoreDataService.swift
//  LockNote
//
//  Created by Valentinas Mirosnicenko on 5/17/18.
//  Copyright © 2018 Valentinas Mirosnicenko. All rights reserved.
//

import Foundation
import CoreData

class CoreDataService {
    
    static let instance = CoreDataService()
    
    public var context: NSManagedObjectContext?
    
    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "LockNote")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private init() {
        context = persistentContainer.viewContext
    }
    
    func saveContext () {
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
    
    func unlockNote(note: Note) {
        note.isLocked = false
        saveContext()
    }
    
}
