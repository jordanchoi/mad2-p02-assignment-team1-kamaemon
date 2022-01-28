//
//  UserEventsTableViewController.swift
//  Kamaemon
//
//  Created by Jun Hong on 23/1/22.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth


class UserEventsTableViewController : UITableViewController{
    
    var eventsList : [Event] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
    
        ref.child("Jobs").observeSingleEvent(of: .value) { datasnapshot in
            let value = datasnapshot.value as? [String: AnyObject]
            print(value)
            for i in value!.keys{
                if (value![i]!["userID"] as! String == Auth.auth().currentUser!.uid){
                    let dateFormatter = ISO8601DateFormatter()
                    self.eventsList.append(
                        Event(id: value![i]!["eventID"] as! String, desc: value![i]!["eventDesc"] as! String, hours: value![i]!["eventHrs"] as! Int, location: value![i]!["eventLocation"] as! String, uID: value![i]!["userID"] as! String, vID: value![i]!["volunteerID"] as! String, name: value![i]!["eventName"] as! String, stat: value![i]!["eventStatus"] as! String, cat: value![i]!["eventCat"] as! String, date: dateFormatter.date(from: value![i]!["eventDate"] as! String)! as Date
                             )
                    )
                }
            }
            DispatchQueue.global(qos: .background).async {
                    DispatchQueue.main.async {
                    self.tableView.reloadData()
                    
                }
            }
        }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
    
        return self.eventsList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "event", for: indexPath)
        
        let event = self.eventsList[indexPath.row]
        cell.textLabel!.text = "\(event.Name)"
        //cell.detailTextLabel!.text = "\(String(userhelp.UID))"
    
        return cell
    }
    
}
