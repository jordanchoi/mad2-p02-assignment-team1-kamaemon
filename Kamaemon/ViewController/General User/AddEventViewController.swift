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
import DropDown

class AddEventViewController : UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var address: UITextField!
    
    @IBOutlet weak var dateMeet: UIButton!
    @IBOutlet weak var hoursSelect: UIView!
    
    @IBOutlet weak var hours: UILabel!
    
    @IBOutlet weak var date: UIDatePicker!
    
    @IBOutlet weak var categorySelect: UIView!
    
    @IBOutlet weak var category: UILabel!
    
    @IBOutlet weak var des: UITextField!
    
    @IBOutlet weak var name: UITextField!
    var ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
    let catDropDown = DropDown()
    let hrsDropDown = DropDown()
    var cat = ""
    var hrs = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        ref.child("Jobs")
        
        date.frame = .init(x: 45, y: 50, width: 325, height: date.bounds.size.height)
        catDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.category.text = catDropDown.dataSource[index]
            category.textColor = UIColor.black
            cat = catDropDown.dataSource[index]
        }
        
        hrsDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.hours.text = hrsDropDown.dataSource[index]
            hours.textColor = UIColor.black
            hrs = catDropDown.dataSource[index]
        }
        
        category.text = "Category"
        catDropDown.anchorView = categorySelect
        catDropDown.dataSource = ["Errands", "Technology","Company","Health"]
        catDropDown.bottomOffset = CGPoint(x: 0, y:(catDropDown.anchorView?.plainView.bounds.height)!)
        catDropDown.direction = .bottom
        
        hours.text = "Hours"
        hrsDropDown.anchorView = hoursSelect
        hrsDropDown.dataSource = ["1","2","3"]
        hrsDropDown.bottomOffset = CGPoint(x: 0, y:(hrsDropDown.anchorView?.plainView.bounds.height)!)
        hrsDropDown.direction = .bottom

        address.delegate = self
        des.delegate = self
        name.delegate = self
        
        address.setLeftPaddingPoints(10)
        des.setLeftPaddingPoints(10)
        name.setLeftPaddingPoints(10)
        
        // Dismiss keyboard on click background
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
    }
    
    // Background press
    @objc func handleTap() {
        categorySelect.resignFirstResponder()
        hoursSelect.resignFirstResponder()
        address.resignFirstResponder()
        des.resignFirstResponder()
        name.resignFirstResponder()
    }
    
    // Return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func clickCategory(_ sender: Any) {
        hrsDropDown.hide()
        catDropDown.show()
    }
    
    @IBAction func clickHours(_ sender: Any) {
        catDropDown.hide()
        hrsDropDown.show()
    }
    @IBAction func createEvent(_ sender: Any) {
        
        let event = Event(desc: des.text!, hours: Int(hours.text!)!, location: address.text!, uID: Auth.auth().currentUser!.uid, vID: "", name: name.text!, stat: "Open", cat: category.text!, date: date.date)
        //String(describing: date.date)
        
        if #available(iOS 15.0, *) {
            let key = ref.childByAutoId().key
            print(key)
            ref.child("Jobs").child((key as String?)!).setValue([ "eventID" : (key as String?)!,  "eventCat" : event.Category, "eventDate" : event.EventDate.ISO8601Format(), "eventDesc" : event.Desc, "eventHrs" : event.Hours, "eventLocation" : event.Location, "eventName" : event.Name, "eventStatus" : event.Status, "userID" : event.UserID, "volunteerID" : event.VolunteerID])
        } else {
            //let key = ref.childByAutoId().key
            ref.child("Jobs").childByAutoId().setValue(["eventCat" : event.Category, "eventDate" : String(describing: event.EventDate), "eventDesc" : event.Desc, "eventHrs" : event.Hours, "eventLocation" : event.Location, "eventName" : event.Name, "eventStatus" : event.Status, "userID" : event.UserID, "volunteerID" : event.VolunteerID])
        }
        
        
        
        name.text = ""
        des.text = ""
        category.text = ""
        date.date = Date()
        hours.text = ""
        address.text = ""
        
        
    }
    
}
