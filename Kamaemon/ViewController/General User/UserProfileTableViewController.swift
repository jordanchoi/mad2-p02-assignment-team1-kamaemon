//
//  UserProfileTableViewController.swift
//  Kamaemon
//
//  Created by Jordan Choi on 28/1/22.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class UserProfileTableViewController : UIViewController{
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var userPhoneNo: UILabel!
    
    
    //@IBOutlet weak var pastVolunteers: UITableView!
  
    var volunteers : [User] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var volunteer : User = User()
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.pastVolunteers.register(UITableViewCell.self, forCellReuseIdentifier: "volunteer")
//        self.pastVolunteers.delegate = self
//        self.pastVolunteers.dataSource = self
        getCurrentUser(UID: Auth.auth().currentUser!.uid)
       // getVolunteer(UID: Auth.auth().currentUser!.uid)
        print("hre herer"  + String(appDelegate.userprofilevolunteerUIDList.count))
        //print("hre herer"  + String(userprofilevolunteerUIDList.count))
//        DispatchQueue.global(qos: .background).async {
//            DispatchQueue.main.async {
//                self.pastVolunteers.reloadData()
//                self.pastVolunteers.delegate = self
//                self.pastVolunteers.dataSource = self
//            }
//        }
//        self.pastVolunteers.delegate = self
//        self.pastVolunteers.dataSource = self
        //self.pastVolunteers.register(volunteercell.self, forCellReuseIdentifier: "volunteer"
       
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
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
//
//        return self.appDelegate.userprofilevolunteerList.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = self.pastVolunteers.dequeueReusableCell(withIdentifier: "volunteer", for: indexPath)
//        let userhelp = self.appDelegate.userprofilevolunteerUIDList[indexPath.row]
//        getObject(UID: userhelp, cell : cell)
//        //cell.textLabel!.text = "\(String(userhelp.n))"
//        //cell.detailTextLabel!.text = "\(String(123))"
//
//        return cell
//    }
    
    func getCurrentUser(UID : String) {
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        //ref.observe(.childAdded) { (snapshot) in
        ref.child("users").child(UID).observe( .value) { snapshot in
            let value = snapshot.value as? NSDictionary
            let Name = value?["Name"] as? String ?? "Error"
            let phoneNum = value?["PhoneNumber"] as? String ?? "Error"
            //print(value)
            //print(UID)
            //print(Name)
            self.userName.text = Name
            self.userPhoneNo.text = phoneNum
            
            if let url = URL(string: value!["PFPURL"] as! String){
                if let data = try? Data(contentsOf: url) {
                                if let image = UIImage(data: data){
                                    DispatchQueue.main.async {
//                                        self.profilePic = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                                        self.profileImage.layer.cornerRadius = (self.profileImage.frame.size.width ) / 2
                                        self.profileImage.clipsToBounds = true
                                        self.profileImage.image = image
                                    }
                                }
                            }
            }
            
        } withCancel: { error in
            print(error)
        }
        
        
    }
    
//    func getVolunteer(UID : String){
//
//        var ref: DatabaseReference!
//        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
//        ref.child("Jobs").observe(.value) { snap in
//            let value = snap.value as? [String: AnyObject]
//            //print(value)
//            for i in value!.keys{
//                let userID = value?[i]!["userID"] as? String ?? "Error"
//                let volunteerID = value?[i]!["volunteerID"] as? String ?? "Error"
//                let status = value?[i]!["eventStatus"] as? String ?? "Error"
//
//                if(userID == UID && status == "Completed"){
//                    if(!self.appDelegate.userprofilevolunteerUIDList.contains(volunteerID)){
//                        self.appDelegate.userprofilevolunteerUIDList.append(volunteerID)
//                   //     self.appDelegate.userprofilevolunteerList.append(self.getObject(UID: volunteerID))=
//                        print(userID)
//                      //  print(self.getObject(UID: volunteerID).n)
//                        DispatchQueue.global(qos: .background).async {
//                            DispatchQueue.main.async {
//                                self.pastVolunteers.reloadData()
//                            }
//                        }
//                        print("inside" + String(self.appDelegate.userprofilevolunteerUIDList.count))
//
//                    }
//                }
//            }
//
//        }
//
//        print("inside here" + String(self.appDelegate.userprofilevolunteerUIDList.count))
//        DispatchQueue.global(qos: .background).async {
//            DispatchQueue.main.async {
//                self.pastVolunteers.reloadData()
//            }
//        }
//
////        for uids in self.volunteersUID{
////            ref.child("users").child(uids).observe(.value) { (snap) in
////                let snapshot = snap.value as? [String: AnyObject]
////                let name = snapshot?["Name"] as? String ?? "Error"
////                let phone = snapshot?["PhoneNumber"] as? String ?? "Error"
////                print(name)
////                self.volunteers.append(User(userUID: uids, userType: "", name: name, gender: "", phonenumber: phone, birthdate: Date(), pfpurl: "", isnewuser: 0))
////
////            }
////        }
////        DispatchQueue.global(qos: .background).async {
////            DispatchQueue.main.async {
////                self.pastVolunteers.reloadData()
////            }
////        }
////
//    }
//
//    func getObject(UID: String, cell : UITableViewCell){
//
//        var ref: DatabaseReference!
//        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
//        ref.child("users").child(UID).observe(.value) { (snap) in
//            let snapshot = snap.value as? [String: AnyObject]
//            let name = snapshot?["Name"] as? String ?? "Error"
//            let phone = snapshot?["PhoneNumber"] as? String ?? "Error"
//            var u = User(userUID: UID, userType: "", name: name, gender: "", phonenumber: phone, birthdate: Date(), pfpurl: "", isnewuser: 0)
//           // print(userhelp.n)
//            cell.textLabel!.text = "\(String(u.n))"
//        }
//    }
//

}
