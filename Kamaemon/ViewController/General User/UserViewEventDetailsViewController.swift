//
//  UserViewEventDetailsViewController.swift
//  Kamaemon
//
//  Created by Jordan Choi on 31/1/22.
//

import Foundation
import UIKit
import CoreLocation
import MapKit
import Lottie
import Firebase
import FirebaseAuth

class UserViewEventDetailsViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {

    // Event View Items in Storyboard
    @IBOutlet weak var eventStatusBarView: UIView!
    @IBOutlet weak var eventLocationMKView: MKMapView!
    @IBOutlet weak var eventNameLbl: UILabel!
    @IBOutlet weak var eventCatLbl: UILabel!
    @IBOutlet weak var eventLocLbl: UILabel!
    @IBOutlet weak var eventDateLbl: UILabel!
    @IBOutlet weak var eventStatusLbl: UILabel!
    @IBOutlet weak var estDurationLbl: UILabel!
    @IBOutlet weak var eventDescLbl: UILabel!
    @IBOutlet weak var eventActionBtn: UIButton!
    
    // Volunteer View Items in Storyboard
    @IBOutlet weak var volunteerPFPIV: UIImageView!
    @IBOutlet weak var volunteerNameLbl: UILabel!
    @IBOutlet weak var volunteerGenderIV: UIImageView!
    @IBOutlet weak var volunteerSkillTableView: UITableView!
    @IBOutlet weak var volunteerSkillTitleLbl: UILabel!
    @IBOutlet weak var noVolunteersLbl: UILabel!
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var msgBtn: UIButton!
    
    //
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var volunteerSkills:[String] = []
    let ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
    var eventObject:Event?
    
    // MapKit properties
    let regionRadius:CLLocationDistance = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Navigation Bar Configuration - Disable Hide from source.
        navigationController?.hidesBarsOnSwipe = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        // Load custom TableViewCell for Volunteer Skills TableView
        let nib = UINib(nibName: "VolunteerSkillsTableViewCell", bundle: nil)
        volunteerSkillTableView.register(nib, forCellReuseIdentifier: "skillsCell")
        volunteerSkillTableView.delegate = self
        volunteerSkillTableView.dataSource = self
        volunteerSkillTableView.reloadData()
        
        // Error handling - in case somehow user get to this scene without selecting an event.
        if (appDelegate.selectedEventDetails != nil) {
            // Event Object selected by User, passed through App Delegate
            self.eventObject = appDelegate.selectedEventDetails!
            
            // Date Format method to display date in desired format
            let formatter4Display = DateFormatter()
            formatter4Display.dateFormat = "dd MMM yyyy HH:mm"
            
            // Mapkit Configurations
            getEventLocation()
            
            // Event Details
            eventNameLbl.text = eventObject!.Name
            eventCatLbl.text = eventObject!.Category
            eventLocLbl.text = eventObject!.Location
            eventDateLbl.text = formatter4Display.string(from: eventObject!.EventDate)
            eventStatusLbl.text = eventObject!.Status
            estDurationLbl.text = "This request will take approximately \(eventObject!.Hours) hours"
            eventDescLbl.text = eventObject!.Desc
            
            if (eventObject!.Status == "Ongoing") {
                eventActionBtn.setTitle("Mark as Completed", for: .normal)
                // color for the status
                eventStatusBarView.backgroundColor = .blue
            } else if (eventObject!.Status == "Accepted" || eventObject!.Status == "Open") {
                eventActionBtn.setTitle("Cancel Request", for: .normal)
                if (eventObject!.Status == "Accepted") {
                    eventStatusBarView.backgroundColor = .orange
                } else {
                    eventStatusBarView.backgroundColor = .green
                    hideVolunteerInformation()
                }
                
            } else if (eventObject!.Status == "Cancelled" || eventObject!.Status == "Completed") {
                eventActionBtn.isEnabled = false
                callBtn.isEnabled = false
                msgBtn.isEnabled = false
                if (eventObject!.Status == "Cancelled") {
                    eventStatusBarView.backgroundColor = .red
                    hideVolunteerInformation()
                } else {
                    eventStatusBarView.backgroundColor = .purple

                }
            }else if(eventObject!.Status == "Cancelled By User"){
                eventActionBtn.isEnabled = false
                callBtn.isEnabled = false
                msgBtn.isEnabled = false
            }else
            {
                eventActionBtn.setTitle("Incorrect Status", for: .normal)
            }
            
            print(eventObject!.volunteer)
            
            // Volunteer
            if (eventObject!.volunteer != nil) {
                
                // load dp from firebase
                if let url = URL(string: eventObject!.volunteer?.profilepicurl as! String){
                    if let data = try? Data(contentsOf: url) {
                                    if let image = UIImage(data: data){
                                        DispatchQueue.main.async {
                                            self.volunteerPFPIV.layer.cornerRadius = (self.volunteerPFPIV.frame.size.width ) / 2
                                            self.volunteerPFPIV.clipsToBounds = true
                                            self.volunteerPFPIV.image = image
                                        }
                                    }
                                }
                }

                
                //volunteerPFPIV =
                volunteerNameLbl.text = eventObject!.volunteer!.n
                if (eventObject!.volunteer!.Gender == "Male") {
                    volunteerGenderIV.image = UIImage(named: "male")
                } else if (eventObject!.volunteer!.Gender == "Female") {
                    volunteerGenderIV.image = UIImage(named: "female")
                } else {
                    volunteerGenderIV.isHidden = true
                }

                // get skills
                ref.child("volunteers").child(eventObject!.volunteer!.UID).observeSingleEvent(of: .value) { DataSnapshot in
                    let value = DataSnapshot.value as? [String: AnyObject]
                    if (value != nil) {
                        // no qualification
                        if(value!["Qualifications"] is String){
                            return
                        }
                        // qualification list
                        else{
                            if (value!["Qualifications"] != nil) {
                                for skills in value!["Qualifications"]! as! NSArray {
                                    self.volunteerSkills.append(skills as! String)
                                }
                            }
                        }
                        self.volunteerSkillTableView.reloadData()
                    }
                }
            }
        } else
        {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        // disable navigation bar
        navigationController?.hidesBarsOnSwipe = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func eventActionDidPressed(_ sender: Any) {
        var alertTitle:String = "Confirm Cancellation"
        var alertMessage:String = "Are you sure you want to cancel the request? This action is irreversible and you may have to create a new request."
        
        let alertView = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
        
        // Event Statuses - Ongoing, Accepted, Canceled, Completed, Open, Expired?
        if (eventObject!.Status == "Ongoing") {
            alertTitle = "Confirm Completion"
            alertMessage = "Are you sure to mark this request as completed by the volunteer?"
            alertView.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { _ in
                alertView.dismiss(animated: true, completion: nil)
            }))
            alertView.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { _ in
                // mark as complete
                self.updateEventStatus(eID: self.eventObject!.ID, status: "Completed")
                self.eventObject!.Status = "Completed"
                self.eventStatusLbl.text = self.eventObject!.Status
                self.eventActionBtn.isEnabled = false
                self.eventStatusBarView.backgroundColor = .purple
            }))
        } else if (eventObject!.Status == "Accepted" || eventObject!.Status == "Open") {
            alertView.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: { _ in
                alertView.dismiss(animated: true, completion: nil)
            }))
            alertView.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { _ in
                // cancel request
                self.updateEventStatus(eID: self.eventObject!.ID, status: "Cancelled By User")
                self.eventObject!.Status = "Cancelled"
                self.eventStatusLbl.text = self.eventObject!.Status
                self.eventActionBtn.isEnabled = false
                self.eventStatusBarView.backgroundColor = .red
            }))
        } else {
            
        }
        
        alertView.title = alertTitle
        alertView.message = alertMessage
        self.present(alertView, animated: true, completion: nil)
        
    }
    @IBAction func msgVolunteerDidPressed(_ sender: Any) {
      //  if let editView = storyboard?.instantiateViewController(withIdentifier: "EditContactViewController") as? EditContactViewController {
  //          editView.selectedIndex = indexPath.row;
    //        self.navigationController?.pushViewController(editView, animated: true);
      //  }
        appDelegate.selectedUser = self.eventObject!.volunteer
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let msgVol = storyboard.instantiateViewController(withIdentifier: "Chat") as? MessageViewController {
            self.navigationController?.pushViewController(msgVol, animated: true)
        }
        
    }
    @IBAction func callVolunteerDidPressed(_ sender: Any) {
        let callURL:NSURL = URL(string: "TEL://\(self.eventObject!.volunteer!.PhoneNumber)")! as NSURL
        UIApplication.shared.open(callURL as URL, options: [:], completionHandler: nil)
    }
    
    func hideVolunteerInformation() {
        volunteerPFPIV.isHidden = true
        volunteerNameLbl.isHidden = true
        volunteerGenderIV.isHidden = true
        volunteerSkillTitleLbl.isHidden = true
        volunteerSkillTableView.isHidden = true
        callBtn.isHidden = true
        msgBtn.isHidden = true
        noVolunteersLbl.isHidden = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return volunteerSkills.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: VolunteerSkillsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "skillsCell", for: indexPath) as! VolunteerSkillsTableViewCell
        
        cell.selectionStyle = .none
        
        cell.skillsLbl.text = volunteerSkills[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // MapKit Methods
    // Focus on location
    func focusLocationOnMap(location: CLLocation) {
        let coordinateReg = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        eventLocationMKView.setRegion(coordinateReg, animated: true)
    }
    
    func getEventLocation() {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(eventObject!.Location, completionHandler: {p,e in
            if (p != nil) {
                let lat = String(format: "Lat: %3.12f", p![0].location!.coordinate.latitude)
                let long = String(format: "Lat: %3.12f", p![0].location!.coordinate.longitude)
                print("\(lat), \(long)")
                let eventLocAnnotation = MKPointAnnotation()
                eventLocAnnotation.coordinate = p![0].location!.coordinate
                eventLocAnnotation.title = self.eventObject!.Location
                self.eventLocationMKView.addAnnotation(eventLocAnnotation)
                self.focusLocationOnMap(location: p![0].location!)
            }
        })
    }
    
    func updateEventStatus(eID:String,status:String) {
        let updatedValues = ["eventStatus": status]
        ref.child("Jobs").child(eID).updateChildValues(updatedValues)
    }
    
    
}
