//
//  VolunteerListViewController.swift
//  Kamaemon
//
//  Created by mad2 on 18/1/22.
//
import FirebaseAuth
import Firebase
import Foundation
import UIKit

class VolunteerListViewController : UIViewController, UITableViewDataSource, UITableViewDelegate{
    // appdelegate
    let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
    
    // initialise variables
    var volunteerList : [[Event]] = []
    var currentTableView:Int!
    
    // refresh control
    let refreshControl = UIRefreshControl()
    
    // UI elements
    @IBOutlet weak var tableView: UITableView!
    
    // switch the segmented control
    @IBAction func switchTableViewAction(_ sender: UISegmentedControl) {
        currentTableView = sender.selectedSegmentIndex
        tableView.reloadData()
    }
    
    // refresh data
    @objc func refresh(_ sender: AnyObject) {
        appDelegate.PopulateList(UID: Auth.auth().currentUser!.uid)
        volunteerList = appDelegate.volunteerList
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    override func viewDidLoad() {
        // register cell
        self.tableView.register(UINib(nibName: "EventTableViewCell", bundle: .main), forCellReuseIdentifier: "eventCell")
        
        // add refresh
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        // load data
        appDelegate.PopulateList(UID: Auth.auth().currentUser!.uid)
        volunteerList = appDelegate.volunteerList
        
        // set current selected index as 0
        currentTableView = 0
        
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // add refresh
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        // load data
        appDelegate.PopulateList(UID: Auth.auth().currentUser!.uid)
        volunteerList = appDelegate.volunteerList
        
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        
        let cell: EventTableViewCell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as! EventTableViewCell
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        
        // get event details based on current selected view and row
        let event = volunteerList[currentTableView][indexPath.row]
        cell.category.text = event.Category
        cell.location.text = event.Location
        cell.hours.text = String(event.Hours) + " hours"
        cell.date.text = dateFormatter.string(from: event.EventDate)
        cell.name.text = event.Name
        ref.child("users").child(event.UserID).observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            let uname = value?["Name"] as! String
            cell.userName.text = "By: " + uname
        })
        cell.selectionStyle = .none
        cell.name.adjustsFontSizeToFitWidth = true
        cell.name.minimumScaleFactor = 0.5
        cell.location.adjustsFontSizeToFitWidth = true
        cell.location.minimumScaleFactor = 0.5
        cell.userName.adjustsFontSizeToFitWidth = true
        cell.userName.minimumScaleFactor = 0.5
        // display different images for each category
        if(event.Category == "Health"){
            cell.img.image = UIImage(named: "health")
        }
        else if(event.Category == "Technology"){
            cell.img.image = UIImage(named: "tech")
        }
        else if(event.Category == "Company"){
            cell.img.image = UIImage(named: "company")
        }
        else if(event.Category == "Errands"){
            cell.img.image = UIImage(named: "errands")
        }
        else if(event.Category == "Cleaning"){
            cell.img.image = UIImage(named: "cleaning")
        }
        else if(event.Category == "Others"){
            cell.img.image = UIImage(named: "others")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return volunteerList[currentTableView].count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        appDelegate.selectedEvent = volunteerList[currentTableView][indexPath.row]
        
        // go to accept view if user is in explore page
        if(currentTableView == 0){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let accept = storyboard.instantiateViewController(withIdentifier: "Accept")
            self.navigationController?.pushViewController(accept, animated: true)
        }
        
        // go to cancel view if user in 'my event' page
        else if(currentTableView == 1){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let cancel = storyboard.instantiateViewController(withIdentifier: "Cancel")
            self.navigationController?.pushViewController(cancel, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
