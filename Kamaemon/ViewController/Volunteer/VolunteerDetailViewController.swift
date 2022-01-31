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
    @IBOutlet weak var map: MKMapView!
    let dateFormatter = DateFormatter()
    
    let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
    var volunteerList : [[Event]] = []
    var event: Event?
    var coord1:CLLocationCoordinate2D!
    var coord2:CLLocationCoordinate2D!
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
    @IBAction func viewFullMap(_ sender: Any) {
        if (coord2 == nil){
            showAlert()
        }
        else{
            self.getDirections(loc1: coord1, loc2: coord2)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Event Details"
        event = appDelegate.selectedEvent!
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let dateFormatter2 = ISO8601DateFormatter()
//        dateFormatter.formatOptions =  [.withInternetDateTime, .withFractionalSeconds]
        // DB
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        let userDB = ref.child("users").child(String(event!.UserID))
        var id = ""
        var selectedname = ""
        var dob = Date()
        var gender = ""
        var pfpurl = ""
        var phonenum = ""
        var utype = ""
        var isnewuser = 100
        var user:User?
        userDB.observeSingleEvent(of: .value, with: { snapshot in
            // Get user value
            let value = snapshot.value as? NSDictionary
            id = value!["userUID"] as! String
            selectedname = value!["Name"] as! String
            dob = (dateFormatter2.date(from: value!["DOB"] as! String) ?? Date()) as Date
            gender = value!["Gender"] as! String
            pfpurl = value!["PFPURL"] as! String
            phonenum = value!["PhoneNumber"] as! String
            utype = value!["UserType"] as! String
            isnewuser = value!["isNewUser"] as! Int
            
            user  = User(userUID: id, userType: utype, name: selectedname, gender: gender, phonenumber: phonenum , birthdate: dob , pfpurl: pfpurl , isnewuser: isnewuser)
            appDelegate.selectedUser = user
          }) { error in
            print(error.localizedDescription)
          }
        
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.goToMap.setTitle("", for: .normal)
        
        locationManager.delegate = locationDelegate
        locationDelegate.locationCallBack = { [self] location in
            self.latestLocation = location
            
            /**Current Location**/
            let annotation = MKPointAnnotation()
            let annotation2 = MKPointAnnotation()
            self.coord1 = location.coordinate
            annotation.coordinate = location.coordinate
            annotation.title = "I'm Here"
            
            /**Ngee Ann**/
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(event!.Location, completionHandler: { [self]p,e in
                guard e == nil else {
                    showAlert()
                            return
                        }
                    self.coord2 = (p![0].location)!.coordinate
                    annotation2.coordinate = (p![0].location)!.coordinate
                    annotation2.title = event?.Location
                    let sourcePlaceMark = MKPlacemark(coordinate: self.coord1)
                    let destPlaceMark = MKPlacemark(coordinate: self.coord2!)
                    let directionRequest = MKDirections.Request()
                    directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
                    directionRequest.destination = MKMapItem(placemark: destPlaceMark)
                    directionRequest.transportType = .walking
                        
                    let directions = MKDirections(request: directionRequest)
                    directions.calculate { (response, error) in
                        guard let directionResponse = response else {
                            if let error = error{
                                print("we have error getting directions")
                            }
                            return
                        }
                        let route = directionResponse.routes[0]
                        self.map.addOverlay(route.polyline)
                        let rect = route.polyline.boundingMapRect
                        self.map.setRegion(MKCoordinateRegion(rect), animated: true)
                    }
                    self.map.delegate = self
                
                
            })
        
            self.map.addAnnotation(annotation)
            self.map.addAnnotation(annotation2)
        }
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
        else{
            ref.child("users").child(event!.UserID).observeSingleEvent(of: .value, with: { snapshot in
                let value = snapshot.value as? NSDictionary
                uname = value?["Name"] as! String
                self.userName.text = "By: " + uname
            })
            name.text = event?.Name
            time.text = dateFormatter.string(from: event!.EventDate)
            desc.text = " " + event!.Desc
            location.text = event?.Location
            hours.text = "\(event!.Hours) Hours"
        }
    }
    let locationDelegate = LocationDelegate()
    var latestLocation: CLLocation? = nil
    
    let locationManager: CLLocationManager = {
        $0.requestAlwaysAuthorization()
        $0.desiredAccuracy = kCLLocationAccuracyBest
        $0.startUpdatingLocation()
        return $0
    }(CLLocationManager())
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location:CLLocation){
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius
        )
        map.setRegion(coordinateRegion, animated: true)
    }
    func getDirections(loc1: CLLocationCoordinate2D, loc2: CLLocationCoordinate2D) {
       let source = MKMapItem(placemark: MKPlacemark(coordinate: loc1))
       source.name = "Your Location"
       let destination = MKMapItem(placemark: MKPlacemark(coordinate: loc2))
       destination.name = "Destination"
       MKMapItem.openMaps(with: [source, destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        return renderer
    }
    @IBAction func cancel(_ sender: Any) {
        // DB
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        
        // Update status and volunteer ID of event to ""
        
        // create the alert
        let alert = UIAlertController(title: "Cancel Event", message: "Are you sure you want to cancel going to this event?", preferredStyle: UIAlertController.Style.alert)

        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Back", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Proceed Cancelling", style: UIAlertAction.Style.destructive, handler: { [self] action in
            guard let key = ref.child("Jobs").child(String(event!.ID)).key else { return }
            ref.child("Jobs").child(String(event!.ID)).child("eventStatus").setValue("Cancelled")
            ref.child("Jobs").child(String(event!.ID)).child("volunteerID").setValue("")
            appDelegate.PopulateList(UID: Auth.auth().currentUser!.uid)
            self.navigationController?.popViewController(animated: true)
        }))

        // show the alert
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    @IBAction func accept(_ sender: Any) {
        // DB
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        
        // create the alert
        let alert = UIAlertController(title: "Accept Event", message: "Are you sure you want to accept this event?", preferredStyle: UIAlertController.Style.alert)

        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Yes, I am", style: UIAlertAction.Style.default, handler: { [self] action in
            // Update status and volunteer ID of event to current user's ID
            guard let key = ref.child("Jobs").child(String(event!.ID)).key else { return }
            ref.child("Jobs").child(String(event!.ID)).child("eventStatus").setValue("Accepted")
            ref.child("Jobs").child(String(event!.ID)).child("volunteerID").setValue(Auth.auth().currentUser!.uid)
            appDelegate.PopulateList(UID: Auth.auth().currentUser!.uid)
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Back", style: UIAlertAction.Style.cancel, handler: nil))

        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func openChat(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let chat = storyboard.instantiateViewController(withIdentifier: "Chat")
        self.navigationController?.pushViewController(chat, animated: true)
    }
    
    func showAlert(){
        // create the alert
        let alert = UIAlertController(title: "Cannot Find Location", message: "We are unable to find the location stated by the user.", preferredStyle: UIAlertController.Style.alert)

        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Noted", style: UIAlertAction.Style.cancel, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
}
