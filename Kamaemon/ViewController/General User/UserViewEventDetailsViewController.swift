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

class UserViewEventDetailsViewController : UIViewController {
    
    // Event View Items in Storyboard
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // disable navigation bar
        navigationController?.hidesBarsOnSwipe = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        // disable navigation bar
        navigationController?.hidesBarsOnSwipe = false
    }
    
    @IBAction func eventActionDidPressed(_ sender: Any) {
    }
    @IBAction func msgVolunteerDidPressed(_ sender: Any) {
    }
    @IBAction func callVolunteerDidPressed(_ sender: Any) {
    }
    
}
