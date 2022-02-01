//
//  SharedPrefsController.swift
//  Kamaemon
//
//  Created by mad2 on 31/1/22.
//

import Foundation
import CoreData
import UIKit
import Firebase
class SharedPrefsController {
    let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
    
    func modifyLogin(isloggedIn : Bool, userID : String){
        let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "SharedPreference", in: context)!
        let preferences = NSManagedObject(entity: entity, insertInto: context)
        preferences.setValue(isloggedIn, forKeyPath: "hasLoggedIn")
        preferences.setValue(userID, forKeyPath: "userID")
        do{
            try context.save()
        }catch let error as NSError{
            fatalError("unresolved error \(error), \(error.userInfo)")
        }
    }
    func getLoginUID()->String{
        var id = ""
        var prefs:[NSManagedObject] = []
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SharedPreference")
        do{
            prefs = try context.fetch(fetchRequest)
            print(String(prefs.count))
                for p in prefs{
                    id = p.value(forKeyPath: "userID") as! String
                }
        }catch let error as NSError{
            fatalError("unresolved error \(error), \(error.userInfo)")
        }
        return id
    }
    func deleteRow(){
        var contact:[NSManagedObject] = []
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SharedPreference")
        do{
            contact = try context.fetch(fetchRequest)
            for c in contact{
                context.delete(c)
            }
            try context.save()
        }catch let error as NSError{
            fatalError("unresolved error \(error), \(error.userInfo)")
        }
    }
    func modifyNewUser(isNew:Bool){
        let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "NewUser", in: context)!
        let preferences = NSManagedObject(entity: entity, insertInto: context)
        preferences.setValue(isNew, forKeyPath: "isNew")
        do{
            try context.save()
        }catch let error as NSError{
            fatalError("unresolved error \(error), \(error.userInfo)")
        }
    }
    func IsNew()->Bool{
        var new = true
        var prefs:[NSManagedObject] = []
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NewUser")
        do{
            prefs = try context.fetch(fetchRequest)
            for p in prefs{
                new = p.value(forKeyPath: "isNew") as! Bool
            }
        }catch let error as NSError{
            fatalError("unresolved error \(error), \(error.userInfo)")
        }
        return new
    }
}
