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
    @IBAction func viewFullMap(_ sender: Any) {
          self.getDirections(loc1: coord1, loc2: coord2)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.goToMap.setTitle("", for: .normal)
        event = appDelegate.selectedEvent!
        locationManager.delegate = locationDelegate
        locationDelegate.locationCallBack = { location in
            self.latestLocation = location
            
            /**Current Location**/
            let annotation = MKPointAnnotation()
            let annotation2 = MKPointAnnotation()
            self.coord1 = location.coordinate
            annotation.coordinate = location.coordinate
            annotation.title = "I'm Here"
            
            /**Ngee Ann**/
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString("535 Clementi Road Singapore 599489", completionHandler: {p,e in
                self.coord2 = (p![0].location)!.coordinate
                annotation2.coordinate = (p![0].location)!.coordinate
                annotation2.title = "Ngee Ann Polytechnic"
                annotation2.subtitle = "School of ICT"
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
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        
        if(nameCancel != nil){
            nameCancel.text = event?.Name
            timeCancel.text = dateFormatter.string(from: event!.EventDate)
            descCancel.text = event?.Desc
//            userName.text = event?.UserID
//            location.text = event?.Location
//            hours.text = event?.Hours as String!
        }
        else{
            ref.child("users").child(event!.UserID).observeSingleEvent(of: .value, with: { snapshot in
                let value = snapshot.value as? NSDictionary
                uname = value?["Name"] as! String
                self.userName.text = "By: " + uname
            })
            name.text = event?.Name
            time.text = dateFormatter.string(from: event!.EventDate)
            desc.text = event?.Desc
            
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
        
        // Update volunteer ID of event to current user's ID
        guard let key = ref.child("Jobs").child(String(event!.ID)).key else { return }
        let event = ["eventCat" : event?.Category,
                     "eventDate" : dateFormatter.string(from:event!.EventDate ),
                     "eventDesc" : event?.Desc,
                     "eventHrs" : event?.Hours,
                     "eventID" : event?.ID,
                     "eventLocation" : event?.Location,
                     "eventName" : event?.Name,
                     "eventStatus" : "Cancelled",
                     "userID" : event?.UserID,
                     "volunteerID" : ""] as [String : Any] as [String : Any]
        let childUpdates = ["/openEvents/\(key)": event]
        ref.updateChildValues(childUpdates)
        appDelegate.PopulateList(UID: Auth.auth().currentUser!.uid)
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func accept(_ sender: Any) {
        // DB
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        
        ref.child("Jobs").child(String(event!.ID)).child("eventStatus").setValue("Accepted")
        ref.child("Jobs").child(String(event!.ID)).child("volunteerID").setValue(Auth.auth().currentUser!.uid)
        appDelegate.PopulateList(UID: Auth.auth().currentUser!.uid)
        _ = navigationController?.popViewController(animated: true)
    }
}
