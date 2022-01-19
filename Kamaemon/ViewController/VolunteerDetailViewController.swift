//
//  VolunteerDetailViewController.swift
//  Kamaemon
//
//  Created by mad2 on 19/1/22.
//

import Foundation
import UIKit
import Firebase

class VolunteerDetailViewController: UIViewController{
    let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
    var volunteerList : [[Event]] = []
    var event: Event?
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var desc: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        event = appDelegate.selectedEvent!
        name.text = event?.UserID
        location.text = event?.Location
        desc.text = event?.Desc
    }
    
    @IBAction func accept(_ sender: Any) {
        // DB
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        
        // Update volunteer ID of event to current user's ID
        guard let key = ref.child("openEvents").child(String(event!.ID)).key else { return }
        let event = ["eventID": event?.ID,
                     "eventDesc": event?.Desc,
                     "eventHrs": event?.Hours,
                     "eventLocation": event?.Location,
                     "userID": event?.UserID,
                     "volunteerID":Auth.auth().currentUser!.uid ] as [String : Any] as [String : Any]
        let childUpdates = ["/openEvents/\(key)": event]
        ref.updateChildValues(childUpdates)
    }
}
