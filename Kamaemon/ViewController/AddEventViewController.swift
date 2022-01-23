//
//  AddEventViewController.swift
//  Kamaemon
//
//  Created by Jun Hong on 23/1/22.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth


class AddEventViewController : UIViewController{
    
    @IBOutlet weak var address: UITextField!
    
    @IBOutlet weak var hours: UITextField!
    
    @IBOutlet weak var date: UIDatePicker!
    
    @IBOutlet weak var category: UITextField!
    
    @IBOutlet weak var des: UITextField!
    
    @IBOutlet weak var name: UITextField!
    var ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref.child("openEvents")
        
        
        
    }
    
    
    @IBAction func createEvent(_ sender: Any) {
        
        let event = Event(desc: des.text!, hours: Int(hours.text!)!, location: address.text!, uID: Auth.auth().currentUser!.uid, vID: "", name: name.text!, stat: "Open", cat: category.text!, date: date.date)
        //String(describing: date.date)
        
        if #available(iOS 15.0, *) {
            let key = ref.childByAutoId().key
            print(key)
            ref.child("openEvents").child((key as String?)!).setValue([ "eventID" : (key as String?)!,  "eventCat" : event.Category, "eventDate" : event.EventDate.ISO8601Format(), "eventDesc" : event.Desc, "eventHrs" : event.Hours, "eventLocation" : event.Location, "eventName" : event.Name, "eventStatus" : event.Status, "userID" : event.UserID, "volunteerID" : event.VolunteerID])
        } else {
            //let key = ref.childByAutoId().key
            ref.child("openEvents").childByAutoId().setValue(["eventCat" : event.Category, "eventDate" : String(describing: event.EventDate), "eventDesc" : event.Desc, "eventHrs" : event.Hours, "eventLocation" : event.Location, "eventName" : event.Name, "eventStatus" : event.Status, "userID" : event.UserID, "volunteerID" : event.VolunteerID])
        }
        
        
        
        name.text = ""
        des.text = ""
        category.text = ""
        date.date = Date()
        hours.text = ""
        address.text = ""
        
        
    }
    
    
    
    
    
}
