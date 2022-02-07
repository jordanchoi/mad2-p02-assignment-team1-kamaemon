//
//  AddEventViewController.swift
//  Kamaemon
//
//  Created by Jun Hong on 23/1/22.
//  Modified and Improved by Jordan on 2/2/22

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import DropDown
import CoreLocation
import MapKit
import CircleBar

class AddEventViewController : UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var dateMeet: UIButton!
    @IBOutlet weak var hoursSelect: UIView!
    @IBOutlet weak var hours: UILabel!
    @IBOutlet weak var date: UIDatePicker!
    @IBOutlet weak var categorySelect: UIView!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var des: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var eventLocMK: MKMapView!
    @IBOutlet weak var searchAddrBtn: UIButton!
    @IBOutlet weak var errorMsgLbl: UILabel!
    
    var ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
    let catDropDown = DropDown()
    let hrsDropDown = DropDown()
    var cat = ""
    var hrs = ""
    
    // MapKit
    let regionRadius:CLLocationDistance = 1000
    var previousAnnotation = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref.child("Jobs")
        
        date.frame = .init(x: 45, y: 50, width: 325, height: date.bounds.size.height)
        catDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.category.text = catDropDown.dataSource[index]
            category.textColor = UIColor { tc in
                switch tc.userInterfaceStyle {
                case .dark:
                    return UIColor.white
                default:
                    return UIColor.black
                }
            }
            cat = catDropDown.dataSource[index]
        }
        
        hrsDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.hours.text = hrsDropDown.dataSource[index]
            hours.textColor = UIColor { tc in
                switch tc.userInterfaceStyle {
                case .dark:
                    return UIColor.white
                default:
                    return UIColor.black
                }
            }
            hrs = hrsDropDown.dataSource[index]
        }
        
        category.text = "Category"
        catDropDown.anchorView = categorySelect
        catDropDown.dataSource = ["Errands", "Technology","Company","Health","Cleaning","Others"]
        catDropDown.bottomOffset = CGPoint(x: 0, y:(catDropDown.anchorView?.plainView.bounds.height)!)
        catDropDown.direction = .bottom
        
        hours.text = "Estimated Duration (Hrs)"
        hrsDropDown.anchorView = hoursSelect
        hrsDropDown.dataSource = ["1","2","3","4","5","6"]
        hrsDropDown.bottomOffset = CGPoint(x: 0, y:(hrsDropDown.anchorView?.plainView.bounds.height)!)
        hrsDropDown.direction = .bottom

        des.sizeToFit()
        des.adjustsFontSizeToFitWidth = true
        des.minimumFontSize = 10
        
        address.delegate = self
        des.delegate = self
        name.delegate = self
        
        address.setLeftPaddingPoints(10)
        des.setLeftPaddingPoints(10)
        name.setLeftPaddingPoints(10)
        
        
        // min and max date available
        let calendar = Calendar(identifier: .gregorian)
        var dateComps = DateComponents()
        dateComps.day = 1
        let minDate = calendar.date(byAdding: dateComps, to: Date())
        dateComps.day = 60
        let maxDate = calendar.date(byAdding: dateComps, to: Date())
        // set min date to at least tomorrow
        date.minimumDate = minDate
        // set max date to 2 months in advanced
        date.maximumDate = maxDate
    
        
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
        // validation
        if (name.text == "" || category.text == "Category" || hours.text == "Estimated Duration (Hrs)" || des.text == "" || address.text == "") {
            print("There are empty fields.")
            // show error message
            errorMsgLbl.text = "All fields must be filled in."
            errorMsgLbl.isHidden = false
            
        } else {
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
            
            // reset text fields
            name.text = ""
            des.text = ""
            category.text = "Category"
            date.date = Date()
            hours.text = "Estimated Durations (Hrs)"
            address.text = ""
            
            // change tabView
            tabBarController?.selectedIndex = 0
        }
        
        
    }
    
    // MapKit Methods
    // Focus on location
    func focusLocationOnMap(location: CLLocation) {
        let coordinateReg = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        eventLocMK.setRegion(coordinateReg, animated: true)
    }
    
    //to add
    @IBAction func navigateBtnDidPressed(_ sender: Any) {
        
    }
    
    @IBAction func searchLocationBtnDidPressed(_ sender: Any) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(self.address?.text ?? "", completionHandler: {p, e in
            if (p != nil) {
                let lat = String(format: "Lat: %3.12f", p![0].location!.coordinate.latitude)
                let long = String(format: "Lat: %3.12f", p![0].location!.coordinate.longitude)
                print("\(lat), \(long)")
                let setLocAnnotation = MKPointAnnotation()
                self.eventLocMK.removeAnnotation(self.previousAnnotation)
                self.eventLocMK.addAnnotation(setLocAnnotation)
                self.previousAnnotation = setLocAnnotation
                setLocAnnotation.coordinate = p![0].location!.coordinate

                self.focusLocationOnMap(location: p![0].location!)
                
                // reverse geocode
                geoCoder.reverseGeocodeLocation(p![0].location!) { (placemarks, error) in
                    if let error = error {
                        print("Something went wrong retrieving the Geocode location.")
                    } else {
                        if let placemarks = placemarks, let placemark = placemarks.first {
                            self.address!.text = placemark.name
                        } else {
                            print("Location not found.")
                        }
                    }
                }
            }
            else {
                let alertView = UIAlertController(title: "Address not found.", message: "The address is not found, please re-enter a valid address.", preferredStyle: UIAlertController.Style.alert)
                alertView.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: { _ in
                    alertView.dismiss(animated: true, completion: nil)
                }))
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        // disable navigation bar
        navigationController?.hidesBarsOnSwipe = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
