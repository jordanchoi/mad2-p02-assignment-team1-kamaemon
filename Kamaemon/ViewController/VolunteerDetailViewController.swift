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
    
    let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
    var volunteerList : [[Event]] = []
    var event: Event?
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var desc: UILabel!
    
    @IBOutlet weak var descCancel: UILabel!
    @IBOutlet weak var locationCancel: UILabel!
    @IBOutlet weak var nameCancel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        event = appDelegate.selectedEvent!
        locationManager.delegate = locationDelegate
        locationDelegate.locationCallBack = { location in
            self.latestLocation = location
//            self.centerMapOnLocation(location: location)
            
            /**Current Location**/
            let annotation = MKPointAnnotation()
            let annotation2 = MKPointAnnotation()
            var  coord1 = location.coordinate
            var coord2:CLLocationCoordinate2D?
            annotation.coordinate = location.coordinate
            annotation.title = "I'm Here"
            
            /**Ngee Ann**/
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString("535 Clementi Road Singapore 599489", completionHandler: {p,e in
                coord2 = (p![0].location)!.coordinate
                annotation2.coordinate = (p![0].location)!.coordinate
                annotation2.title = "Ngee Ann Polytechnic"
                annotation2.subtitle = "School of ICT"
//                self.getDirections(loc1: coord1, loc2: coord2)
                let sourcePlaceMark = MKPlacemark(coordinate: coord1)
                let destPlaceMark = MKPlacemark(coordinate: coord2!)
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
        if(nameCancel != nil){
            nameCancel.text = event?.UserID
            locationCancel.text = event?.Location
            descCancel.text = event?.Desc
        }
        else{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            name.text = event?.UserID
            time.text = dateFormatter.string(from: event!.EventDate)
            desc.text = event?.Desc
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
