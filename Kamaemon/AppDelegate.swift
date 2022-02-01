//
//  AppDelegate.swift
//  Kamaemon
//
//  Created by Jordan Choi on 14/1/22.
//

import UIKit
import CoreData
import Firebase
import FirebaseAuth
import IQKeyboardManager
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var volunteerList : [[Event]] = [[],[]]
    var qualificationsList : [String] = []
    var doneEventList : [Event] = []
    var selectedEvent:Event?
    var selectedUser:User?
    var verifyUser:User?
    var verifyEmail:String?
    var verifyPassword:String?
    var window: UIWindow?
    var selectedEventDetails:Event?
    var userprofilevolunteerList : [User] = []
    var userprofilevolunteerUIDList : [String] = []
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared().isEnabled = true
        FirebaseApp.configure()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Kamaemon")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    public func PopulateList(UID:String) {
        var openEventList : [Event] = []
        var joinedEventList : [Event] = []
        var doneEventList : [Event] = []
        
        // DB
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        
        
        ref.child("Jobs").observeSingleEvent(of: .value , with: { snapshot in
            for event in snapshot.children{
                let events = snapshot.childSnapshot(forPath: (event as AnyObject).key)
                for eventDetails in events.children{
                    let details = events.childSnapshot(forPath: (eventDetails as AnyObject).key)
                    if(details.key == "volunteerID"){
                        // Populate list of volunteer activities that are open
                        if(details.value as! String == ""){
                            print("getting data...")
                            let event = (events.value! as AnyObject)
                            let id = event["eventID"]!!
                            let desc = event["eventDesc"]!!
                            let hrs = event["eventHrs"]!!
                            let loc = event["eventLocation"]!!
                            let user = event["userID"]!!
                            let volunteer = event["volunteerID"]!!
                            let name = event["eventName"]!!
                            let status = event["eventStatus"]!!
                            let category = event["eventCat"]!!
                            let date = event["eventDate"]!!
                        
                            let dateFormatter = ISO8601DateFormatter()
                            openEventList.append(
                                Event(id: id as! String, desc: desc as! String, hours: hrs as! Int, location: loc as! String, uID: user as! String, vID: volunteer as! String, name: name as! String, stat: status as! String, cat: category as! String, date: dateFormatter.date(from: date as! String)! as Date
                                     )
                            )
                        }
                        
                        // Populate list of volunteer activities that user have selected and have not done
                        if(details.value as! String == UID){
                            let event = (events.value! as AnyObject)
                            let id = event["eventID"]!!
                            let desc = event["eventDesc"]!!
                            let hrs = event["eventHrs"]!!
                            let loc = event["eventLocation"]!!
                            let user = event["userID"]!!
                            let volunteer = event["volunteerID"]!!
                            let name = event["eventName"]!!
                            let status = event["eventStatus"]!!
                            let category = event["eventCat"]!!
                            let date = event["eventDate"]!!
                            let dateFormatter = ISO8601DateFormatter()
                            if(event["eventStatus"]!! as! String != "Completed"){
                                joinedEventList.append(
                                    Event(id: id as! String, desc: desc as! String, hours: hrs as! Int, location: loc as! String, uID: user as! String, vID: volunteer as! String, name: name as! String, stat: status as! String, cat: category as! String, date: dateFormatter.date(from: date as! String)! as Date
                                         )
                                )
                            }
                            else{
                                doneEventList.append(
                                    Event(id: id as! String, desc: desc as! String, hours: hrs as! Int, location: loc as! String, uID: user as! String, vID: volunteer as! String, name: name as! String, stat: status as! String, cat: category as! String, date: dateFormatter.date(from: date as! String)! as Date
                                         )
                                )
                            }
                            
                        }
                    }
                    self.volunteerList[1] = joinedEventList
                    self.volunteerList[0] = openEventList
                    self.doneEventList = doneEventList
                }
            }
        })
        {
            error in
                print(error.localizedDescription)
        }
    }
}

