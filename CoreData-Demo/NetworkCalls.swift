//
//  NetworkCalls.swift
//  CoreData-Demo
//
//  Created by Anirudha on 30/04/17.
//  Copyright © 2017 Anirudha Mahale. All rights reserved.
//

import AlamofireSwiftyJSON
import Alamofire
import SwiftyJSON
import Foundation
import CoreData

class NetworkCalls: NSObject {
    
    private let url = "https://jsonplaceholder.typicode.com/users"
    
    static let instance = NetworkCalls()
    
    func getJson(completion: @escaping ([String: Int]) -> ()) {
        Alamofire.request(url)
            .responseSwiftyJSON { (response) in
                if let json = response.result.value {
                    syncPerson(json: json)
                }
                completion(["errorcode": 200])
        }
    }
}

func syncPerson(json: JSON) {
    // 3. Id variable
    var ids = [String]()
    
    // 1. Get hold of the context
    let context = appDelegate.managedObjectContext!
    
    func populateIds() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
        fetchRequest.propertiesToFetch = ["id"]
        fetchRequest.resultType = NSFetchRequestResultType.dictionaryResultType
        
        func parseDictonary(result: [Any]?) {
            if let results = result {
                for item in results {
                    if let dict = item as? [String: Any] {
                        let id = dict["id"] as? String ?? ""
                        ids.append(id)
                    }
                }
            }
        }
        
        do {
            let result = try context.fetch(fetchRequest)
            parseDictonary(result: result)
            //            parseModel(result: result)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    populateIds()
    // Insert the rocord
    func insertRecord(item: JSON, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: context)
        let person = NSManagedObject(entity: entity!, insertInto: context) as! Person
        
        person.id = "\(item["id"].int ?? 0)"
        person.email = item["email"].string ?? ""
        person.name = item["name"].string ?? ""
        person.username = item["username"].string ?? ""
        person.phone = item["phone"].string ?? ""
        
        if context.hasChanges {
            do {
                try context.save()
                print("Inserted the object with id: \(person.id!)")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    // update the record
    func updateRecord(id: String, item: JSON, context: NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        
        do {
            let result = try context.fetch(fetchRequest) as! [Person]
            let person_update = result.first
            
            person_update?.email = item["email"].string ?? ""
            person_update?.name = item["name"].string ?? ""
            person_update?.username = item["username"].string ?? ""
            person_update?.phone = item["phone"].string ?? ""
            
            for (index, value) in ids.enumerated() {
                if value == id {
                    ids.remove(at: index)
                    break
                }
            }
            
            if context.hasChanges {
                do {
                    try context.save()
                    print("Updated the object with id \(id)")
                } catch {
                    print("Failed to update the object with id \(id)")
                }
            }
        } catch {
            print("Failed to fetch the object with id: \(id)")
        }
    }
    
    // delete the records
    func deleteRecord() {
        func delete(id: String) {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
            fetchRequest.predicate = NSPredicate(format: "id = %@", id)
            let context = appDelegate.managedObjectContext
            
            if let result = try? context?.fetch(fetchRequest) {
                for object in result! {
                    context?.delete(object as! NSManagedObject)
                    print("Deleted the record with id: \(id)")
                }
            }
            
            if (context?.hasChanges)! {
                do {
                    try context?.save()
                    print("Deleted records with Ids: \(ids)")
                } catch {
                    print("Failed to delete the object.")
                }
            }
        }
        
        for id in ids {
            delete(id: id)
        }
    }
    
    // 2. parse the json
    let result = json.arrayValue
    
    for item in result {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
        fetchRequest.predicate = NSPredicate(format: "id = %@", "\(item["id"].int ?? 0)")
        fetchRequest.resultType = NSFetchRequestResultType.countResultType
        
        do {
            let count = try context.fetch(fetchRequest) as! [Int]
            if count[0] == 0 {
                // insert
                insertRecord(item: item, context: context)
            } else {
                // update
                updateRecord(id: "\(item["id"].int ?? 0)", item: item, context: context)
            }
        } catch {
            print("Can't fetch the result.")
        }
    }
    deleteRecord()
}
















