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
    
    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var usernumber: UILabel!
    
    @IBOutlet weak var profilePic: UIImageView!
    
    @IBOutlet weak var qualificationTable: UITableView!
    
    @IBOutlet weak var hours: UILabel!
    var Qualifications : [String] = []
    var user = User()
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserDets()
        
    }
  
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getUserDets()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return self.Qualifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.qualificationTable.dequeueReusableCell(withIdentifier: "qualification", for: indexPath)
        
        let userhelp = self.Qualifications[indexPath.row]
        print(userhelp)
        cell.textLabel!.text = "\(String(userhelp))"
        //cell.detailTextLabel!.text = "\(String(userhelp.UID))"
        
        return cell
    }
    
    
    @IBAction func manageQualifications(_ sender: Any) {
    }
    
    func getCurrentUser(UID : String) {
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        ref.child("users").child(UID).observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            let Name = value?["Name"] as? String ?? "Error"
            let UserCat = value?["userCategory"] as? String ?? "Error"
            print(value)
            print(UID)
            print(Name)
            print(UserCat)
            self.user.UID = UID
            self.user.n = Name
            self.user.UserType = UserCat
        }) { error in
          print(error.localizedDescription)
        }
        
        
    }
    
    func getUserDets(){
        let currentuser = Auth.auth().currentUser
        self.qualificationTable.register(UITableViewCell.self, forCellReuseIdentifier: "qualification")
        //getCurrentUser(UID: currentuser!.uid)
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        ref.child("users").child(currentuser!.uid).observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            let Name = value?["Name"] as? String ?? "Error"
            let UserCat = value?["PhoneNumber"] as? String ?? "Error"
            self.username.text = Name
            self.usernumber.text = UserCat
            if let url = URL(string: value!["PFPURL"] as! String){
                if let data = try? Data(contentsOf: url) {
                                if let image = UIImage(data: data){
                                    DispatchQueue.main.async {
//                                        self.profilePic = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                                        self.profilePic.layer.cornerRadius = (self.profilePic.frame.size.width ) / 2
                                        self.profilePic.clipsToBounds = true
                                        self.profilePic.image = image
                                    }
                                }
                            }
            }
        }) { error in
          print(error.localizedDescription)
        }
        
        ref.child("volunteers").child(Auth.auth().currentUser!.uid).observe(.value) { data in
            let da = data.value as? NSDictionary
            print(da)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let uQualification = da?["Qualifications"]
            if uQualification is String{
                appDelegate.qualificationsList = []
            }
            if uQualification is [String] {
                let q = uQualification as! [String]
                if (q[0] is NSNull) {
                    ref.child("volunteers").child(Auth.auth().currentUser!.uid).child("Qualifications").child("0").removeValue()
                }
                appDelegate.qualificationsList = q
            }
            ref.child("Jobs").observe(.value) { snap in
                            let jobs = snap.value as? [String: AnyObject]
                            var hours = 0
                            for i in jobs!.keys{
                                if(jobs![i]!["volunteerID"] as! String == currentuser!.uid && jobs![i]!["eventStatus"] as! String == "Completed"){
                                    let jobhours =  jobs![i]!["eventHrs"] as! Int
                                    hours =  hours + jobhours
                                }
                            }
                            self.hours.text = String(hours)
                            //if(jobs?["volunteer"])
                            ref.child("volunteers").child(currentuser!.uid).child("Hours").setValue(hours)
                        }
            self.Qualifications = appDelegate.qualificationsList
            //self.hours.text = (da?["Hours"] as? String)!
            //SelectionQualificationViewController().Qualifications =
            DispatchQueue.global(qos: .background).async {
                DispatchQueue.main.async {
                    self.qualificationTable.reloadData()
                }
            }
        }
    }
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
