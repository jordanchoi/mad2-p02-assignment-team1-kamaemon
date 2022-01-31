//
//  UserHomeViewController.swift
//  Kamaemon
//
//  Created by Jun Hong on 23/1/22.
//  Resumed and Modified by Jordan on 24/1/22

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
    
    //
    var userEventsList:[Event] = []
    // Database Reference for Firebase
    var ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
    var user:User = User()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // disable navigation bar
        navigationController?.hidesBarsOnSwipe = true
        
        // Load custom tableview cell
        let nib = UINib(nibName: "UserEventsTableViewCell", bundle: nil)
        eventTableView.register(nib, forCellReuseIdentifier: "UserEventsTableViewCell")
        eventTableView.reloadData()
        eventTableView.delegate = self
        eventTableView.dataSource = self

        // Retrieve current user information
        ref.child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value) { DataSnapshot in
            let value = DataSnapshot.value as? [String: AnyObject]
            
            print(value)
            let formatter4 = DateFormatter()
            formatter4.dateFormat = "d MMM yyyy"
            print(formatter4.date(from: value!["DOB"] as! String) ?? "Unknown date")
            print(value!["DOB"] as! String)
            self.user = User(userUID: value!["userUID"] as! String, userType: value!["UserType"] as! String, name: value!["Name"] as! String, gender: value!["Gender"] as! String, phonenumber: value!["PhoneNumber"] as! String, birthdate: formatter4.date(from: value!["DOB"] as! String) ?? Date(), pfpurl: value!["PFPURL"] as! String, isnewuser: value!["isNewUser"] as! Int)
            self.name.text = "Hi " + self.user.n
        }
        
        // Retrieve all events started by user
        let eventRef = ref.child("Jobs").queryOrdered(byChild: "userID").queryEqual(toValue: Auth.auth().currentUser?.uid as? String).observe(.value) { snapshot in
            print(Auth.auth().currentUser?.uid)
            let formatter4Get = DateFormatter()
            formatter4Get.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            
            for jobs in snapshot.children.allObjects as! [DataSnapshot] {
                let value = jobs.value as? [String: AnyObject]
                print(value)
                if (value != nil) {
                    let dateStr = value!["eventDate"] as! String
                    let eventDate:Date? = formatter4Get.date(from: dateStr)
                 //error
                    let dateFormatter = ISO8601DateFormatter()
                    let job = Event(desc: value!["eventDesc"] as! String, hours: Int(value!["eventHrs"] as! Int32), location: value!["eventLocation"] as! String, uID: value!["userID"] as! String, vID: value!["volunteerID"] as! String, vName: "", name: value!["eventName"] as! String, stat: value!["eventStatus"] as! String, cat: value!["eventCat"] as! String, date: dateFormatter.date(from: value!["eventDate"] as! String)! as Date)
                    
                    var volunteerName:String = ""
                    if (value!["volunteerID"] as! String != "")
                    {
                        // Retrieve volunteer information
                        self.ref.child("users").child(value!["volunteerID"] as! String).observeSingleEvent(of: .value) { DataSnapshot in
                            let value = DataSnapshot.value as? [String: AnyObject]
                            print(value)
                            if (value != nil)
                            {
                                let formatter4 = DateFormatter()
                                formatter4.dateFormat = "d MMM yyyy"
                                var volunteer:User = User(userUID: value!["userUID"] as! String, userType: value!["UserType"] as! String, name: value!["Name"] as! String, gender: value!["Gender"] as! String, phonenumber: value!["PhoneNumber"] as! String, birthdate: formatter4.date(from: value!["DOB"] as! String) ?? Date(), pfpurl: value!["PFPURL"] as! String, isnewuser: value!["isNewUser"] as! Int)
                                job.volunteer = volunteer
                                // job.VolunteerName = value!["Name"] as! String
                            }
                        }
                    }
                    self.userEventsList.append(job)
                    self.eventTableView.reloadData()
                }
            }
    
            // Dashboard numbers
            if (self.userEventsList.count == 0) {
                self.totalNumEvents.text = "0"
            } else {
                var ongoing:Int = 0
                var completed:Int = 0
                
                for e in self.userEventsList {
                    if (e.Status == "Completed") {
                        completed += 1
                    } else if (e.EventDate >= Date() && (e.Status == "Accepted" || e.Status == "Ongoing")) {
                        ongoing += 1
                    }
                }
                
                self.totalNumEvents.text = String(self.userEventsList.count)
                self.totalNumCompletedEventsLbl.text = String(completed)
                self.totalNumUpcomingsLbl.text = String(ongoing)
            }
            
            // perform sorting? -- pushed to back if time permits
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        // disable navigation bar
        navigationController?.hidesBarsOnSwipe = true
    }
    
    // TableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UserEventsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "UserEventsTableViewCell", for: indexPath) as! UserEventsTableViewCell
        
        cell.selectionStyle = .none
        
        let formatter4Display = DateFormatter()
        formatter4Display.dateFormat = "dd MMM yyyy HH:mm"
        let event = userEventsList[indexPath.row]
    
        // Cell items - Status
        cell.eventStatusLbl.text = event.Status
        if (event.Status == "Open") {
            cell.statusViewBar.backgroundColor = .green
            cell.eventStatusLbl.backgroundColor = .green
            cell.eventRemarksLbl.text = "Finding a volunteer.."
        } else if (event.Status == "Accepted") {
            cell.statusViewBar.backgroundColor = .orange
            cell.eventStatusLbl.backgroundColor = .orange
            cell.eventRemarksLbl.text = "Your request has been accepted by \(event.volunteer.n)"
        } else if (event.Status == "Cancelled") {
            cell.statusViewBar.backgroundColor = .red
            cell.eventStatusLbl.backgroundColor = .red
            cell.eventRemarksLbl.text = "You had cancelled this request."
        } else if (event.Status == "Ongoing") {
            cell.statusViewBar.backgroundColor = .blue
            cell.eventStatusLbl.backgroundColor = .blue
            cell.eventRemarksLbl.text = "Your request is ongoing"
        } else if (event.Status == "Completed") {
            cell.statusViewBar.backgroundColor = .purple
            cell.eventStatusLbl.backgroundColor = .purple
            cell.eventRemarksLbl.text = "Your request has been completed by \(event.volunteer.n)"
        }
        else {
            cell.statusViewBar.backgroundColor = .black
            cell.eventStatusLbl.backgroundColor = .black
            cell.eventStatusLbl.textColor = .white
            cell.eventRemarksLbl.text = ""
            
        }
        
        // Cell items - Status
        cell.eventNameLbl.text = event.Name
        cell.eventLocationLbl.text = event.Location
        cell.eventDateLbl.text = formatter4Display.string(from: event.EventDate)
        cell.eventDescLbl.text = event.Desc

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userEventsList.count
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        appDelegate.selectedEventDetails = userEventsList[indexPath.row]
//        let destinationVC = UserViewEventDetailsViewController()
//        destinationVC.eventObject = selectedEvent
        self.performSegue(withIdentifier: "detailsSegue", sender: self)
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
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
