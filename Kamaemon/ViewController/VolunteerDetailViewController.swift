//
//  VolunteerDetailViewController.swift
//  Kamaemon
//
//  Created by mad2 on 19/1/22.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class VolunteerDetailViewController: UIViewController{
    let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
    var volunteerList : [[Event]] = []
    var event: Event?
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var desc: UILabel!
    
    @IBOutlet weak var descCancel: UILabel!
    @IBOutlet weak var locationCancel: UILabel!
    @IBOutlet weak var nameCancel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        event = appDelegate.selectedEvent!
        nameCancel.text = event?.UserID
        locationCancel.text = event?.Location
        descCancel.text = event?.Desc
    }
    
    @IBAction func cancel(_ sender: Any) {
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
                     "volunteerID": ""] as [String : Any] as [String : Any]
        let childUpdates = ["/openEvents/\(key)": event]
        ref.updateChildValues(childUpdates)
        //appDelegate.PopulateList()
        appDelegate.PopulateList(UID: Auth.auth().currentUser!.uid)
        _ = navigationController?.popViewController(animated: true)
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
        //appDelegate.PopulateList()
        appDelegate.PopulateList(UID: Auth.auth().currentUser!.uid)
        _ = navigationController?.popViewController(animated: true)
    }
}
