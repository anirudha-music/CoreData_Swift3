//
//  ViewController.swift
//  CoreData-Demo
//
//  Created by Anirudha on 30/04/17.
//  Copyright © 2017 Anirudha Mahale. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    struct Person_Model {
        let id: String
        let name: String
        let username: String
        let phoneNumber: String
        let email: String
        
        init(id: String, name: String, username: String, phoneNumber: String, email: String) {
            self.id = id
            self.name = name
            self.username = username
            self.phoneNumber = phoneNumber
            self.email = email
        }
    }
    
    var data = [Person_Model]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.printRecords()
        NetworkCalls.instance.getJson { (response) in
            if response["errorcode"] as! Int == 200 {
                self.printRecords()
            }
        }
    }
    
    @IBAction func deleteRec(_ sender: Any) {
        deleteRecord()
    }
    
    func fetchRequest() {
        let fetchRequest1 = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: appDelegate.managedObjectContext)
        fetchRequest1.entity = entity
        do {
            let result = try appDelegate.managedObjectContext.fetch(fetchRequest1)
            print("Count: ", result.count)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchRequestFromTemplate() {
        let model = appDelegate.coreDataStack.context.persistentStoreCoordinator?.managedObjectModel
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = (model?.fetchRequestFromTemplate(withName: "PersonId", substitutionVariables:  ["username": "Bret"]))!
        do {
            let result = try appDelegate.managedObjectContext.fetch(fetchRequest)
            print("Count: ", result.count)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteRecord() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
        let id = "3"
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        let context = appDelegate.managedObjectContext
        
        if let result = try? context?.fetch(fetchRequest) {
            for object in result! {
                context?.delete(object as! NSManagedObject)
                print("Deleted the record with id 3")
            }
        }
        
        if (context?.hasChanges)! {
            do {
                try context?.save()
                self.printRecords()
            } catch {
                print("Failed to delete the object.")
            }
        }
    }
    
    func printRecords() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
        let context = appDelegate.managedObjectContext
        
        func parseModel(result: [Any]?) {
            if let results = result as? [Person] {
                for item in results {
                    print("id: ", item.id ?? "")
                    print("name: ", item.name ?? "")
                    print("username:", item.username ?? "")
                    print("phone: ", item.phone ?? "")
                    print("email: ", item.email ?? "")
                }
            }
        }
        
        do {
            let result = try context?.fetch(fetchRequest)
            parseModel(result: result)
        } catch {
            print(error.localizedDescription)
        }
    }
    
}














