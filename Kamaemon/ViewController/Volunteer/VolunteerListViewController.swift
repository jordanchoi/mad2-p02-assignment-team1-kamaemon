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
    let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
    var testList : [String] = []
    var volunteerList : [[Event]] = []
    
    let refreshControl = UIRefreshControl()
    var currentTableView:Int!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func switchTableViewAction(_ sender: UISegmentedControl) {
        currentTableView = sender.selectedSegmentIndex
        tableView.reloadData()
    }
    
    @objc func refresh(_ sender: AnyObject) {
       // Code to refresh table view
        volunteerList = appDelegate.volunteerList
        print("refreshed")
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    override func viewDidLoad() {
        self.tableView.register(UINib(nibName: "EventTableViewCell", bundle: .main), forCellReuseIdentifier: "eventCell")
        currentTableView = 0
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        volunteerList = appDelegate.volunteerList
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        segmented.selectedSegmentIndex = 0;
        currentTableView = 0
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        volunteerList = appDelegate.volunteerList
        self.tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: EventTableViewCell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as! EventTableViewCell
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let event = volunteerList[currentTableView][indexPath.row]
        cell.desc.text = event.Desc
        cell.location.text = event.Location
        cell.hours.text = String(event.Hours) + " hours"
        cell.date.text = dateFormatter.string(from: event.EventDate)
        cell.name.text = event.Name
        cell.userName.text = event.UserID
        cell.selectionStyle = .none
        
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("current: "
              + String(volunteerList[currentTableView].count))
        return volunteerList[currentTableView].count
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
}
