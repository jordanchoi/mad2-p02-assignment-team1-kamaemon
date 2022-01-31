//
//  SharedPrefsController.swift
//  Kamaemon
//
//  Created by mad2 on 31/1/22.
//

import Foundation
import CoreData
import UIKit
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
    func IsUserLoggedIn()->Bool{
        var login = false
        var prefs:[NSManagedObject] = []
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SharedPreference")
        do{
            prefs = try context.fetch(fetchRequest)
            for p in prefs{
                login = p.value(forKeyPath: "hasLoggedIn") as! Bool
            }
        }catch let error as NSError{
            fatalError("unresolved error \(error), \(error.userInfo)")
        }
        return login
    }
}
