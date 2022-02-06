//
//  ProfilePageViewController.swift
//  Kamaemon
//
//  Created by Jun Hong on 21/1/22.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import nanopb

class ProfilePageViewController : UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    // UI elements
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var usernumber: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var qualificationTable: UITableView!
    @IBOutlet weak var hours: UILabel!
    
    // initialise variables
    var Qualifications : [String] = []
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.qualificationTable.register(UITableViewCell.self, forCellReuseIdentifier: "qualification")
        getUserDets()
    }
  
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getUserDets()
    }
    
    // qualifications table
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.Qualifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.qualificationTable.dequeueReusableCell(withIdentifier: "qualification", for: indexPath)
        let userhelp = self.Qualifications[indexPath.row]
        cell.textLabel!.text = "\(indexPath.row + 1)" + ". " + "\(String(userhelp))"
        
        return cell
    }
    
    // get current user details from db
    func getCurrentUser(UID : String) {
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        ref.child("users").child(UID).observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            let Name = value?["Name"] as? String ?? "Error"
            let UserCat = value?["userCategory"] as? String ?? "Error"
            self.user.UID = UID
            self.user.n = Name
            self.user.UserType = UserCat
        }) { error in
          return
        }
    }
    
    // display user details in view
    func getUserDets(){
        let currentuser = Auth.auth().currentUser
        
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        
        // get user details from user table
        ref.child("users").child(currentuser!.uid).observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            
            // get data
            let Name = value?["Name"] as? String ?? "Error"
            let UserCat = value?["PhoneNumber"] as? String ?? "Error"
            
            // show data
            self.username.text = Name
            self.usernumber.text = UserCat
            if let url = URL(string: value!["PFPURL"] as! String){
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data){
                        DispatchQueue.main.async {
                            self.profilePic.layer.cornerRadius = (self.profilePic.frame.size.width ) / 2
                            self.profilePic.clipsToBounds = true
                            self.profilePic.image = image
                        }
                    }
                }
            }
        }) { error in
          return
        }
        
        // get qualifications from volunteer table
        ref.child("volunteers").child(currentuser!.uid).observe(.value) { data in
            let da = data.value as? NSDictionary
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let uQualification = da?["Qualifications"]
            
            // if no qualifications
            if uQualification is String{
                appDelegate.qualificationsList = []
            }
            
            // if there's at least 1 qualifications
            if uQualification is [String] {
                let q = uQualification as! [String]
                if (q[0] is NSNull) {
                    ref.child("volunteers").child(Auth.auth().currentUser!.uid).child("Qualifications").child("0").removeValue()
                }
                appDelegate.qualificationsList = q
            }
            self.Qualifications = appDelegate.qualificationsList
            DispatchQueue.global(qos: .background).async {
                DispatchQueue.main.async {
                    self.qualificationTable.reloadData()
                }
            }
        }
        
        // check how many hours completed
        ref.child("Jobs").observe(.value) { snap in
            let jobs = snap.value as? [String: AnyObject]
            var hours = 0
            if (jobs != nil) {
                for i in jobs!.keys{
                    if(jobs![i]!["volunteerID"] as! String == currentuser!.uid && jobs![i]!["eventStatus"] as! String == "Completed"){
                        let jobhours =  jobs![i]!["eventHrs"] as! Int
                        hours =  hours + jobhours
                    }
                }
                self.hours.text = String(hours)
                ref.child("volunteers").child(currentuser!.uid).child("Hours").setValue("\(hours)")
            }
        }
    }
    
    // on press logout, go to login page
    @IBAction func logOut(_ sender: Any) {
        let prefs = SharedPrefsController()
        prefs.deleteRow()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vp = storyboard.instantiateViewController(withIdentifier: "ViewController")
        let navController = UINavigationController(rootViewController: vp)
        navController.modalPresentationStyle = .fullScreen
        navController.modalTransitionStyle = .crossDissolve
        self.present(navController, animated: true, completion: nil)
    }
}
