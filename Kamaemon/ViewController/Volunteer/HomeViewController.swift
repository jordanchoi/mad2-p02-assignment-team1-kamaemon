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
    @IBOutlet weak var highestScorerHrs: UILabel!
    @IBOutlet weak var highestScorerName: UILabel!
    @IBOutlet var profilePic: UIImageView!
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
//        getHighestScorer()
        //getTop3()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getUserDets()
//        getHighestScorer()
        //getTop3()
    }
    
    func getUserDets(){
        var currentuser = Auth.auth().currentUser
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        print(Auth.auth().currentUser!.uid)
        ref.child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { snapshot in
          // Get user value
          let value = snapshot.value as? NSDictionary
            let displayName = value?["Name"] as? String ?? "Error"
            self.user.text = "Hello, " + displayName +  "👋"
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
        
        let dateFormatter = ISO8601DateFormatter()
                ref.child("Jobs").observe(.value) { snap in
                    let jobs = snap.value as? [String: AnyObject]
                    var completedhours = 0
                    var upcominghours = 0
                    var todayhours = 0
                    if(jobs != nil){
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
                    
                    
    }
        
         //set the textts
    }
    
    func getHighestScorer(){
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        ref.child("volunteers").observeSingleEvent(of: .value, with: { [self] snap in
            let volunteer = snap.value as? [String: AnyObject]
            print("HOW MANY VOLUNTEERS \(volunteer!.count)")
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
