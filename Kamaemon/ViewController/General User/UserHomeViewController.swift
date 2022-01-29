//
//  UserHomeViewController.swift
//  Kamaemon
//
//  Created by Jun Hong on 23/1/22.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class UserHomeViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Storyboard views
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var totalNumUpcomingsLbl: UILabel!
    @IBOutlet weak var totalNumCompletedEventsLbl: UILabel!
    @IBOutlet weak var totalNumEvents: UILabel!
    @IBOutlet weak var eventTableView: UITableView!
    
    var userEventsList:[Event] = []
    // Database Reference for Firebase
    var ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
    var user:User = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "UserEventsTableViewCell", bundle: nil)
        eventTableView.register(nib, forCellReuseIdentifier: "UserEventsTableViewCell")
        eventTableView.reloadData()
        eventTableView.delegate = self
        eventTableView.dataSource = self
        
        var testEvent:Event = Event(id: "ABCDEF", desc: "THIS IS A TEST EVENT FOR TABLEVIEW", hours: 6, location: "NGEE ANN POLYTECHNIC", uID: "JCSY11", vID: "", name: "TEST EVENT", stat: "Open", cat: "Technology", date: Date())
        userEventsList.append(testEvent)
        userEventsList.append(testEvent)
        userEventsList.append(testEvent)
        testEvent.Status = "Canceled"
        userEventsList.append(testEvent)

        // Retrieve current user information
        ref.child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value) { DataSnapshot in
            let value = DataSnapshot.value as? [String: AnyObject]
            
            print(value)
            let formatter4 = DateFormatter()
            formatter4.dateFormat = "dd-mmm-yyyy"
            print(formatter4.date(from: value!["DOB"] as! String) ?? "Unknown date")
            print(value!["DOB"] as! String)
            self.user = User(userUID: value!["userUID"] as! String, userType: value!["UserType"] as! String, name: value!["Name"] as! String, gender: value!["Gender"] as! String, phonenumber: value!["PhoneNumber"] as! String, birthdate: formatter4.date(from: value!["DOB"] as! String) ?? Date(), pfpurl: value!["PFPURL"] as! String, isnewuser: value!["isNewUser"] as! Int)
            self.name.text = "Hi " + self.user.n
        }
        
        // Retrieve all events started by user
        let eventRef = ref.child("Jobs").queryOrdered(byChild: "userID").queryEqual(toValue: Auth.auth().currentUser?.uid as? String).observe(.value) { snapshot in
            print(Auth.auth().currentUser?.uid)
            
            for jobs in snapshot.children.allObjects as! [DataSnapshot] {
                let value = jobs.value as? [String: AnyObject]
                print(value)
                if (value != nil) {
                    let job = Event(id: value!["eventID"] as! String, desc: value!["eventDesc"] as! String, hours: Int(value!["eventHrs"] as! Int32), location: value!["eventLocation"] as! String, uID: value!["userID"] as! String, vID: "", name: value!["eventName"] as! String, stat: value!["eventStatus"] as! String, cat: value!["eventCat"] as! String, date: DateFormatter().date(from: value!["eventDate"] as! String) ?? Date())
                    self.userEventsList.append(job)
                    self.eventTableView.reloadData()
                }
            }
    
            // Dashboard numbers
            if (self.userEventsList.count == 0) {
                self.totalNumEvents.text = "0"
            } else {
                self.totalNumEvents.text = String(self.userEventsList.count)
                self.totalNumCompletedEventsLbl.text = String(self.userEventsList.count)
                self.totalNumUpcomingsLbl.text = String(self.userEventsList.count)
            }
            
        }
    }
    
    // TableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UserEventsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "UserEventsTableViewCell", for: indexPath) as! UserEventsTableViewCell
        
        cell.selectionStyle = .none
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let event = userEventsList[indexPath.row]
        
        // Cell items - Status
        cell.eventStatusLbl.text = event.Status
        if (event.Status == "Open") {
            cell.statusViewBar.backgroundColor = .green
            cell.eventStatusHighlightView.backgroundColor = .green
        } else if (event.Status == "Accepted") {
            cell.statusViewBar.backgroundColor = .orange
            cell.eventStatusHighlightView.backgroundColor = .orange
        } else if (event.Status == "Canceled") {
            cell.statusViewBar.backgroundColor = .red
            cell.eventStatusHighlightView.backgroundColor = .red
        } else if (event.Status == "Ongoing") {
            cell.statusViewBar.backgroundColor = .blue
            cell.eventStatusHighlightView.backgroundColor = .blue
        } else {
            cell.statusViewBar.backgroundColor = .black
            cell.eventStatusHighlightView.backgroundColor = .black
        }
        
        // Cell items - Status
        cell.eventNameLbl.text = event.Name
        cell.eventLocationLbl.text = event.Location
        cell.eventDateLbl.text = dateFormatter.string(from: event.EventDate)
        cell.eventDescLbl.text = event.Desc
        
        // NEED TO EDIT THIS TO FIND VOLUNTEER NAME ACCEPTED BY
        cell.eventRemarksLbl.text = "ACCEPTED BY JORDAN CHOI"

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userEventsList.count
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
        appDelegate.selectedEvent = volunteerList[currentTableView][indexPath.row]
        if(currentTableView == 0){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let accept = storyboard.instantiateViewController(withIdentifier: "Accept")
            accept.modalPresentationStyle = .popover
            self.present(accept, animated: true, completion: nil)
        }
        else if(currentTableView == 1){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let cancel = storyboard.instantiateViewController(withIdentifier: "Cancel")
            cancel.modalPresentationStyle = .popover
            self.present(cancel, animated: true, completion: nil)
        }
        */
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
