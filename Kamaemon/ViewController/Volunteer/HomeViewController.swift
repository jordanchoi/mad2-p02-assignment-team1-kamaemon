//
//  HomeViewController.swift
//  Kamaemon
//
//  Created by Jun Hong on 16/1/22.
//

import Foundation
import UIKit
import FirebaseAuth
import Firebase
class HomeViewController : UIViewController{
    
    // UI elements
    @IBOutlet weak var user: UILabel!
    @IBOutlet weak var highestScorerHrs: UILabel!
    @IBOutlet weak var highestScorerName: UILabel!
    @IBOutlet var profilePic: UIImageView!
    @IBOutlet weak var upcomingHours: UILabel!
    @IBOutlet weak var completedHours: UILabel!
    @IBOutlet weak var todayHours: UILabel!
    
    // go to volunteer's page
    @IBAction func goToVolunteerPage(_ sender: Any) {
        tabBarController?.selectedIndex = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserDets()
        getHighestScorer()
        getTop3()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getUserDets()
        getHighestScorer()
        getTop3()
    }
    
    func getUserDets(){
        // instantiate user variable
        let currentuser = Auth.auth().currentUser
        
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        
        ref.child("users").child(currentuser!.uid).observeSingleEvent(of: .value, with: { snapshot in
            
          // Get and display user info
          let value = snapshot.value as? NSDictionary
            
            // name
            let displayName = value?["Name"] as? String ?? "Error"
            self.user.text = "Hello, " + displayName
            
            // profile picture
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
          print(error.localizedDescription)
        }
        
        // date formatter
        let dateFormatter = ISO8601DateFormatter()
        
        ref.child("Jobs").observe(.value) { snap in
            let jobs = snap.value as? [String: AnyObject]
            
            // set as 0 for dashboard
            var completed = 0
            var upcoming = 0
            var today = 0
            
            // if there are jobs
            if(jobs != nil){
                for i in jobs!.keys{
                    if(jobs![i]!["volunteerID"] as! String == currentuser!.uid){
                        if(jobs![i]!["eventStatus"] as! String == "Completed"){
                            completed = completed + 1
                        }
                        else if (Calendar.current.compare((dateFormatter.date(from: jobs![i]!["eventDate"] as! String)! as Date), to: Date(), toGranularity: .day) == .orderedDescending && jobs![i]!["eventStatus"] as! String == "Accepted"){
                            upcoming = upcoming + 1
                        }
                        else if (Calendar.current.compare((dateFormatter.date(from: jobs![i]!["eventDate"] as! String)! as Date), to: Date(), toGranularity: .day) == .orderedSame && jobs![i]!["eventStatus"] as! String == "Accepted" ){
                            today = today + 1
                        }
                    }
                }
                
                // display - ignore hours i.e change to task count instead of hours
                self.upcomingHours.text = String(upcoming)
                self.todayHours.text = String(today)
                self.completedHours.text = String(completed)
            }
        }
    }
    
    // get highest scorer for leaderboard
    // must have at least 1 user in db that hour > 0
    func getHighestScorer(){
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        ref.child("volunteers").observeSingleEvent(of: .value, with: { [self] snap in
            let volunteer = snap.value as? [String: AnyObject]
            var highestScorer:String = ""
            var highestHrs:Int = 0
            var hr:Int = 0
            for i in volunteer!.keys{
                hr = Int((volunteer![i]!["Hours"] as! NSString).floatValue)
                if(hr  > highestHrs){
                    highestHrs = hr as! Int
                    highestScorer = i
                }
            }
            
            highestScorerHrs.text = "\(highestHrs)"
            ref.child("users").child("\(highestScorer)").observeSingleEvent(of: .value, with: { snapshot in
                let value = snapshot.value as? NSDictionary
                let uname = value?["Name"] as! String
                highestScorerName.text = "Congratulations " + uname + "!"
            })
        }) { error in
          print(error.localizedDescription)
        }
    }
    
    // get top 3 user details
    func getTop3(){
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        ref.child("volunteers").observeSingleEvent(of: .value, with: { [self] snap in
            let jobs = snap.value as? [String: AnyObject]
            var all: [String:Int] = [:]
            for u in jobs!.keys{
                let hour = Int((jobs![u]!["Hours"] as! NSString).floatValue)
                all.updateValue(hour, forKey: u)
            }
            let sorted = all.sorted { (first, second) -> Bool in
                return first.value > second.value
            }
            let highestScorerID = [sorted[0].key, sorted[1].key, sorted[2].key]
            let highestHrs = [sorted[0].value, sorted[1].value, sorted[2].value]
            var highestScorer:[String] = []
            
            for id in highestScorerID{
                var uname:String = ""
                ref.child("users").child(id).observeSingleEvent(of: .value, with: { snapshot in
                    let value = snapshot.value as? NSDictionary
                        uname = value?["Name"] as! String
                    print(id)
                    print(uname)
                    if(!appDelegate.highestScorer.contains(uname)){
                        appDelegate.highestScorer.append(uname)
                    }
                })
                
                
            }
            appDelegate.highestHrs = highestHrs
        }) { error in
          print(error.localizedDescription)
        }
    }
}
