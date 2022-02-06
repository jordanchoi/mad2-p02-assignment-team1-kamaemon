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
import CircleBar

class UserHomeViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Storyboard views
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var totalNumUpcomingsLbl: UILabel!
    @IBOutlet weak var totalNumCompletedEventsLbl: UILabel!
    @IBOutlet weak var totalNumEvents: UILabel!
    @IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var profilepic: UIImageView!
    
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
            if let url = URL(string: value!["PFPURL"] as! String){
                if let data = try? Data(contentsOf: url) {
                                if let image = UIImage(data: data){
                                    DispatchQueue.main.async {
//                                        self.profilePic = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                                        self.profilepic.layer.cornerRadius = (self.profilepic.frame.size.width ) / 2
                                        self.profilepic.clipsToBounds = true
                                        self.profilepic.image = image
                                    }
                                }
                            }
            }
        }
        
        // Retrieve all events started by user
        let eventRef = ref.child("Jobs").queryOrdered(byChild: "userID").queryEqual(toValue: Auth.auth().currentUser?.uid as? String).observe(DataEventType.value, with: { snapshot in
            print(Auth.auth().currentUser?.uid)
            let formatter4Get = DateFormatter()
            formatter4Get.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            // resets list
            self.userEventsList = []
            for jobs in snapshot.children.allObjects as! [DataSnapshot] {
                let value = jobs.value as? [String: AnyObject]
                print(value)
                if (value != nil) {
                    let dateStr = value!["eventDate"] as! String
                    let eventDate:Date? = formatter4Get.date(from: dateStr)
                    
                    let job = Event(id: value!["eventID"] as! String, desc: value!["eventDesc"] as! String, hours: Int(value!["eventHrs"] as! Int32), location: value!["eventLocation"] as! String, uID: value!["userID"] as! String, vID: value!["volunteerID"] as! String, vName: "", name: value!["eventName"] as! String, stat: value!["eventStatus"] as! String, cat: value!["eventCat"] as! String, date: eventDate! ?? Date())
                    
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
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        // disable navigation bar
        navigationController?.hidesBarsOnSwipe = true
        eventTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // TableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UserEventsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "UserEventsTableViewCell", for: indexPath) as! UserEventsTableViewCell
        
        cell.selectionStyle = .none
        
        let formatter4Display = DateFormatter()
        formatter4Display.dateFormat = "dd MMM yyyy HH:mm"
        let event = userEventsList[indexPath.row]
        
        // Update Statuses first
        let now:Date = Date()
        if (event.Status == "Open" && event.EventDate <= now) {
            event.Status = "Cancelled"
            updateEventStatus(eID: event.ID, status: "Cancelled")
        }
    
        // Cell items - Status
        cell.eventStatusLbl.text = event.Status
        if (event.Status == "Open") {
            cell.statusViewBar.backgroundColor = .green
            cell.eventStatusLbl.backgroundColor = .green
            cell.eventRemarksLbl.text = "Finding a volunteer.."
        } else if (event.Status == "Accepted") {
            cell.statusViewBar.backgroundColor = .orange
            cell.eventStatusLbl.backgroundColor = .orange
            cell.eventRemarksLbl.text = "Your request has been accepted by \(event.volunteer?.n ?? "")"
        } else if (event.Status == "Cancelled") {
            cell.statusViewBar.backgroundColor = .red
            cell.eventStatusLbl.backgroundColor = .red
            cell.eventRemarksLbl.text = "Volunteer had cancelled your request."
        } else if (event.Status == "Ongoing") {
            cell.statusViewBar.backgroundColor = .blue
            cell.eventStatusLbl.backgroundColor = .blue
            cell.eventRemarksLbl.text = "\(event.volunteer?.n ?? "") is proceeding with your request."
        } else if (event.Status == "Completed") {
            cell.statusViewBar.backgroundColor = .purple
            cell.eventStatusLbl.backgroundColor = .purple
            cell.eventStatusLbl.textColor = .white
            cell.eventRemarksLbl.text = "Your request has been completed by \(event.volunteer?.n ?? "")"
        } else if (event.Status == "Cancelled By User") {
            cell.statusViewBar.backgroundColor = .black
            cell.eventStatusLbl.backgroundColor = .black
            cell.eventStatusLbl.textColor = .white
            cell.eventRemarksLbl.text = "You had cancelled this request."
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
        self.performSegue(withIdentifier: "detailsSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func requestBtnDidPressed(_ sender: Any) {
        tabBarController?.selectedIndex = 1
    }
    
    func updateEventStatus(eID:String,status:String) {
        let updatedValues = ["eventStatus": status]
        ref.child("Jobs").child(eID).updateChildValues(updatedValues)
    }
    
}
