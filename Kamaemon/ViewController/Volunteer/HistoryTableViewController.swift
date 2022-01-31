//
//  HistoryTableViewController.swift
//  Kamaemon
//
//  Created by mad2 on 31/1/22.
//

import Foundation
import UIKit
import FirebaseAuth
import Firebase
class MyCell: UITableViewCell {
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var myimage: UIImageView!
    @IBOutlet weak var userName: UILabel!
}
class HistoryTableViewController : UITableViewController{
    let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
    var doneList:[Event] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.PopulateList(UID: Auth.auth().currentUser!.uid)
        doneList = appDelegate.doneEventList
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appDelegate.PopulateList(UID: Auth.auth().currentUser!.uid)
        doneList = appDelegate.doneEventList
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return doneList.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(doneList.count) Requests Completed"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "history", for: indexPath) as! MyCell
        // DB
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        ref.child("users").child(doneList[indexPath.row].UserID).observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            let uname = value?["Name"] as! String
            cell.userName.text = uname
        })
        if(doneList[indexPath.row].Category == "Health"){
            cell.myimage.image = UIImage(named: "health")
        }
        else if(doneList[indexPath.row].Category == "Technology"){
            cell.myimage.image = UIImage(named: "tech")
        }
        else if(doneList[indexPath.row].Category == "Company"){
            cell.myimage.image = UIImage(named: "company")
        }
        else if(doneList[indexPath.row].Category == "Errands"){
            cell.myimage.image = UIImage(named: "errands")
        }
        cell.userName.text = doneList[indexPath.row].UserID
        cell.eventDate.text = dateFormatter.string(from: doneList[indexPath.row].EventDate)
        cell.eventName.text = doneList[indexPath.row].Name
        
        return cell
    }
}
