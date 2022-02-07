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
import CoreLocation
import UIKit
import MapKit
import nanopb

class VolunteerDetailViewController: UIViewController, MKMapViewDelegate{
    // date formatter
    let dateFormatter = DateFormatter()
    
    // app delegate
    let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
    
    // initialise variables
    var volunteerList : [[Event]] = []
    var event: Event?
    var coord1:CLLocationCoordinate2D!
    var coord2:CLLocationCoordinate2D!
    let locationDelegate = LocationDelegate()
    var latestLocation: CLLocation? = nil
    
    // UI elements
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var hours: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var goToMap: UIButton!
    @IBOutlet weak var descCancel: UILabel!
    @IBOutlet weak var timeCancel: UILabel!
    @IBOutlet weak var nameCancel: UILabel!
    @IBOutlet weak var userNameCancel: UILabel!
    @IBOutlet weak var hoursCancel: UILabel!
    @IBOutlet weak var locationCancel: UILabel!
    @IBOutlet weak var completeEvent: UIButton!
    
    // how to go to the destination
    @IBAction func viewFullMap(_ sender: Any) {
        
        // show that destination can't be found
        if (coord2 == nil){
            showAlert()
        }
        
        // get direction
        else{
            self.getDirections(loc1: coord1, loc2: coord2)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set title
        navigationItem.title = "Event Details"
        
        // set the texts for both views
        event = appDelegate.selectedEvent!
        setTexts(event: event)
        
        // map view
        initMap()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // set title
        navigationItem.title = "Event Details"
        
        // set the texts for both views
        event = appDelegate.selectedEvent!
        setTexts(event: event)
        
        // map view
        initMap()
    }
    
    func setTexts(event:Event?){
        // date formatter to display
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        // date formatter to get value from database
        let dateFormatter2 = ISO8601DateFormatter()
        
        // initialise variables
        var id = ""
        var selectedname = ""
        var dob = Date()
        var gender = ""
        var pfpurl = ""
        var phonenum = ""
        var utype = ""
        var isnewuser = 100
        var user:User?
        
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        let userDB = ref.child("users").child(String(event!.UserID))
        
        userDB.observeSingleEvent(of: .value, with: { snapshot in
            // Get user
            let value = snapshot.value as? NSDictionary
            id = value!["userUID"] as! String
            selectedname = value!["Name"] as! String
            dob = (dateFormatter2.date(from: value!["DOB"] as! String) ?? Date()) as Date
            gender = value!["Gender"] as! String
            pfpurl = value!["PFPURL"] as! String
            phonenum = value!["PhoneNumber"] as! String
            utype = value!["UserType"] as! String
            isnewuser = value!["isNewUser"] as! Int
            
            // create user object
            user  = User(userUID: id, userType: utype, name: selectedname, gender: gender, phonenumber: phonenum , birthdate: dob , pfpurl: pfpurl , isnewuser: isnewuser)
            self.appDelegate.selectedUser = user
        }) { error in
            return
        }
        
        // cancel page set all texts
        var uname = ""
        if(nameCancel != nil){
            ref.child("users").child(event!.UserID).observeSingleEvent(of: .value, with: { snapshot in
                let value = snapshot.value as? NSDictionary
                uname = value?["Name"] as! String
                self.userNameCancel.text = "By: " + uname
            })
            nameCancel.text = event?.Name
            timeCancel.text = dateFormatter.string(from: event!.EventDate)
            descCancel.text = " " + event!.Desc
            locationCancel.text = event?.Location
            hoursCancel.text = "\(event!.Hours) Hours"
        }
        
        // accept page set all texts
        else{
            ref.child("users").child(event!.UserID).observeSingleEvent(of: .value, with: { snapshot in
                let value = snapshot.value as? NSDictionary
                uname = value?["Name"] as! String
                self.userName.text = "By: " + uname
            })
            name.text = event?.Name
            time.text = dateFormatter.string(from: event!.EventDate)
            desc.text = " " + event!.Desc
            self.desc.adjustsFontSizeToFitWidth = true
            self.desc.minimumScaleFactor = 0.5
            location.text = event?.Location
            hours.text = "\(event!.Hours) Hours"
            self.userName.adjustsFontSizeToFitWidth = true
            self.userName.minimumScaleFactor = 0.5
            self.name.adjustsFontSizeToFitWidth = true
            self.name.minimumScaleFactor = 0.5
            self.location.adjustsFontSizeToFitWidth = true
            self.location.minimumScaleFactor = 0.5
        }
        
        //set button inenabled when not date
        if (completeEvent != nil) {
            if(Calendar.current.compare( event!.EventDate, to: Date(), toGranularity: .day) == .orderedDescending){
                completeEvent.isEnabled = false
                completeEvent.isUserInteractionEnabled = false
            }
        }
    }
    
    // set location manager
    let locationManager: CLLocationManager = {
        $0.requestAlwaysAuthorization()
        $0.desiredAccuracy = kCLLocationAccuracyBest
        $0.startUpdatingLocation()
        return $0
    }(CLLocationManager())
    
    func initMap(){
        // delegate
        locationManager.delegate = locationDelegate
        
        // initialise annotations
        let annotation = MKPointAnnotation()
        let annotation2 = MKPointAnnotation()
        
        // initialise route
        var route = MKRoute()
        
        locationDelegate.locationCallBack = { [self] location in
            // remove annotationa and overlays
            self.map.removeAnnotations(map.annotations)
            self.map.removeOverlays(self.map.overlays)
            
            // volunteer's latest location
            self.latestLocation = location
            
            // current location
            self.coord1 = location.coordinate
            annotation.coordinate = location.coordinate
            annotation.title = "I'm Here"
            
            // geocoding user's address / meet point
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(event!.Location, completionHandler: { [self]p,e in
                
                // don't continue if faled to fetch data
                guard e == nil else {
                    return
                }
                
                // user's meet up location
                self.coord2 = (p![0].location)!.coordinate
                annotation2.coordinate = (p![0].location)!.coordinate
                annotation2.title = event?.Location
                
                // plot line between two spots
                let sourcePlaceMark = MKPlacemark(coordinate: self.coord1)
                let destPlaceMark = MKPlacemark(coordinate: self.coord2!)
                let directionRequest = MKDirections.Request()
                directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
                directionRequest.destination = MKMapItem(placemark: destPlaceMark)
                directionRequest.transportType = .walking
                let directions = MKDirections(request: directionRequest)
                
                directions.calculate { (response, error) in
                    // if error getting overlay
                    guard let directionResponse = response else {
                        if error != nil{
                            showAlert()
                        }
                        return
                    }
                    
                    // plot the line
                    route = directionResponse.routes[0]
                    self.map.addOverlay(route.polyline)
                    let rect = route.polyline.boundingMapRect
                    self.map.setRegion(MKCoordinateRegion(rect), animated: true)
                }
            
                // delegate
                self.map.delegate = self
            })
        
            // add annotations set to map
            self.map.addAnnotation(annotation)
            self.map.addAnnotation(annotation2)
        }
    }
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        initMap()
    }
    
    // get directions for full map - how to get there
    func getDirections(loc1: CLLocationCoordinate2D, loc2: CLLocationCoordinate2D) {
       let source = MKMapItem(placemark: MKPlacemark(coordinate: loc1))
       source.name = "Your Location"
       let destination = MKMapItem(placemark: MKPlacemark(coordinate: loc2))
       destination.name = "Destination"
       MKMapItem.openMaps(with: [source, destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    // render overlay
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        return renderer
    }
    
    // on cancel event
    @IBAction func cancel(_ sender: Any) {
        showAlertConfirmCancel()
    }
    
    // show alert to confirm cancel event
    func showAlertConfirmCancel(){
        // create the alert
        let alert = UIAlertController(title: "Cancel Event", message: "Are you sure you want to cancel going to this event?", preferredStyle: UIAlertController.Style.alert)

        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Back", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Proceed Cancelling", style: UIAlertAction.Style.destructive, handler: { [self] action in
            updateToCancel()
        }))

        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    // update to firebase
    func updateToCancel(){
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        
        // Update status and volunteer ID of event to ""
        guard let key = ref.child("Jobs").child(String(event!.ID)).key else { return }
        ref.child("Jobs").child(String(event!.ID)).child("eventStatus").setValue("Cancelled")
        ref.child("Jobs").child(String(event!.ID)).child("volunteerID").setValue("")
        appDelegate.PopulateList(UID: Auth.auth().currentUser!.uid)
        self.navigationController?.popViewController(animated: true)
    }
    
    // on press call
    @IBAction func call(_ sender: Any) {
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        ref.child("users").child(appDelegate.selectedEvent!.UserID).observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            let number = value?["PhoneNumber"] as! String
            let callURL:NSURL = URL(string: "TEL://\(number)")! as NSURL
            UIApplication.shared.open(callURL as URL, options: [:], completionHandler: nil)
        })
    }
    
    // on press accept
    @IBAction func accept(_ sender: Any) {
        showAlertConfirmAccept()
    }
    
    // show alert to confirm accept event
    func showAlertConfirmAccept(){
        // create the alert
        let alert = UIAlertController(title: "Accept Event", message: "Are you sure you want to accept this event?", preferredStyle: UIAlertController.Style.alert)

        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Yes, I am", style: UIAlertAction.Style.default, handler: { [self] action in
            updateToAccept()
        }))
        alert.addAction(UIAlertAction(title: "Back", style: UIAlertAction.Style.cancel, handler: nil))

        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    // update to firebase
    func updateToAccept(){
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        
        // Update status and volunteer ID of event to current user's ID
        guard let key = ref.child("Jobs").child(String(event!.ID)).key else { return }
        ref.child("Jobs").child(String(event!.ID)).child("eventStatus").setValue("Accepted")
        ref.child("Jobs").child(String(event!.ID)).child("volunteerID").setValue(Auth.auth().currentUser!.uid)
        appDelegate.PopulateList(UID: Auth.auth().currentUser!.uid)
        self.navigationController?.popViewController(animated: true)
    }
    
    // on press open chat
    @IBAction func openChat(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let chat = storyboard.instantiateViewController(withIdentifier: "Chat")
        self.navigationController?.pushViewController(chat, animated: true)
    }
    
    // show error alert cannot find location
    func showAlert(){
        // create the alert
        let alert = UIAlertController(title: "Cannot Find Location", message: "We are unable to find the location stated by the user.", preferredStyle: UIAlertController.Style.alert)

        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Noted", style: UIAlertAction.Style.cancel, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    // on press complete
    @IBAction func eventComplete(_ sender: Any) {
        showAlertConfirmComplete()
    }
    
    //update to firebase
    func updateToComplete(){
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        
        // Update status
        guard let key = ref.child("Jobs").child(String(event!.ID)).key else { return }
        ref.child("Jobs").child(String(event!.ID)).child("eventStatus").setValue("Completed")
        self.navigationController?.popViewController(animated: true)
    }
    
    // show alert to confirm complete event
    func showAlertConfirmComplete(){
        // create the alert
        let alert = UIAlertController(title: "Complete Event", message: "Can you confirm the event is complete?", preferredStyle: UIAlertController.Style.alert)

        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Yes, I am", style: UIAlertAction.Style.default, handler: { [self] action in
            updateToComplete()
        }))
        alert.addAction(UIAlertAction(title: "Back", style: UIAlertAction.Style.cancel, handler: nil))

        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
}
