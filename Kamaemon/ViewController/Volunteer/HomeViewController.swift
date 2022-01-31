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
    
    @IBOutlet weak var user: UILabel!
    
    @IBOutlet weak var upcomingHours: UILabel!
    
    @IBOutlet weak var completedHours: UILabel!
    @IBOutlet weak var todayHours: UILabel!
    @IBAction func goToVolunteerPage(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vp = storyboard.instantiateViewController(withIdentifier: "VolunteerPage")
        let navController = UINavigationController(rootViewController: vp)
        self.present(navController, animated: true, completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        getUserDets()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getUserDets()
    }
    func getUserDets(){
        var currentuser = Auth.auth().currentUser
        // Do any additional setup after loading the view.\
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        print(Auth.auth().currentUser!.uid)
        ref.child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { snapshot in
          // Get user value
          let value = snapshot.value as? NSDictionary
            let displayName = value?["Name"] as? String ?? "Error"
            self.user.text = "Hello, " + displayName +  "👋"
        }) { error in
          print(error.localizedDescription)
        }
        
        let dateFormatter = ISO8601DateFormatter()
                ref.child("Jobs").observe(.value) { snap in
                    let jobs = snap.value as? [String: AnyObject]
                    var completedhours = 0
                    var upcominghours = 0
                    var todayhours = 0
                    for i in jobs!.keys{
                        if(jobs![i]!["volunteerID"] as! String == currentuser!.uid){
                            if(jobs![i]!["eventStatus"] as! String == "Completed"){
                                let jobhours =  jobs![i]!["eventHrs"] as! Int
                                completedhours =  completedhours + jobhours
                            }
                            else if (Calendar.current.compare((dateFormatter.date(from: jobs![i]!["eventDate"] as! String)! as Date), to: Date(), toGranularity: .day) == .orderedDescending && jobs![i]!["eventStatus"] as! String == "Accepted"){
                                let upHours = jobs![i]!["eventHrs"] as! Int
                                upcominghours = upcominghours + upHours     //dateFormatter.date(from: jobs![i]!["eventDate"] as! String)! as Date Date().ISO8601Format()

                            }
                            else if (Calendar.current.compare((dateFormatter.date(from: jobs![i]!["eventDate"] as! String)! as Date), to: Date(), toGranularity: .day) == .orderedSame && jobs![i]!["eventStatus"] as! String == "Accepted" ){
                                let today = jobs![i]!["eventHrs"] as! Int
                                todayhours = todayhours + today
                              
                                //dateFormatter.date(from: jobs![i]!["eventDate"] as! String)! as Date Date().ISO8601Format()
                        }
                        }

                    }
                    self.upcomingHours.text = String(upcominghours)
                    self.todayHours.text = String(todayhours)
                    self.completedHours.text = String(completedhours)
                    
    }
        
         //set the textts
    }
}
