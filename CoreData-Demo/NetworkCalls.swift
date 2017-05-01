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
                    let result = json.arrayValue
                    
                    let ids = result.map {
                        $0["id"].string ?? ""
                    }
                    
                    let context = appDelegate.managedObjectContext
                    for item in result {
                        
                        let temp_id = item["id"].int ?? 0
                        let id = "\(temp_id)"
                        
                        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
                        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
                        fetchRequest.resultType = NSFetchRequestResultType.countResultType
                        do {
                            let count = try context?.fetch(fetchRequest) as! [Int]
                            self.syncRecords(id: id, item: item, context: context!, count: count[0])
                        } catch {
                            print("Can't fetch the result.")
                        }
                    }
                    completion(["errorcode": 200])
                }
        }
    }
    
    func syncPerson(json: JSON) {
        // 3. Id variable
        var ids = [String]()
        
        // Insert the rocord
        func insertRecord(item: JSON, context: NSManagedObjectContext) {
            let entity = NSEntityDescription.entity(forEntityName: "Person", in: context)
            let person = NSManagedObject(entity: entity!, insertInto: context) as! Person
            
            person.id = "\(item["id"].int ?? 0)"
            person.email = item["email"].string ?? ""
            person.name = item["name"].string ?? ""
            person.username = item["username"].string ?? ""
            person.phone = item["phone"].string ?? ""
            
            ids.append("\(item["id"].int ?? 0)")
            
            do {
                try context.save()
                print("Inserted the object with id: \(person.id!)")
            } catch {
                print(error.localizedDescription)
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
                
                ids.append(id)
                
                do {
                    try context.save()
                    print("Updated the object with id \(id)")
                } catch {
                    print("Failed to update the object with id \(id)")
                }
                
            } catch {
                print("Failed to fetch the object with id: \(id)")
            }
        }
        
        // delete the records
        func deleteRecord() {
            
        }
        
        // 1. Get hold of the context
        let context = appDelegate.managedObjectContext!
        
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
                } else {
                    // update
                }
            } catch {
                print("Can't fetch the result.")
            }
        }
    }
    
    func syncRecords(id: String, item: JSON, context: NSManagedObjectContext, count: Int) {
        // Insert the record
        func insertRecord(item: JSON, context: NSManagedObjectContext) {
            let entity = NSEntityDescription.entity(forEntityName: "Person", in: context)
            let person = NSManagedObject(entity: entity!, insertInto: context) as! Person
            
            person.id = "\(item["id"].int ?? 0)"
            person.email = item["email"].string ?? ""
            person.name = item["name"].string ?? ""
            person.username = item["username"].string ?? ""
            person.phone = item["phone"].string ?? ""
            
            do {
                try context.save()
                print("Inserted the object with id: \(person.id!)")
            } catch {
                print(error.localizedDescription)
            }
        }
        
        // Update the record
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
                
                do {
                    try context.save()
                    print("Updated the object with id \(id)")
                } catch {
                    print("Failed to update the object with id \(id)")
                }
                
            } catch {
                print("Failed to fetch the object with id: \(id)")
            }
        }
        
        if count == 0 {
            insertRecord(item: item, context: context)
        } else {
            updateRecord(id: id, item: item, context: context)
        }
    }
}















