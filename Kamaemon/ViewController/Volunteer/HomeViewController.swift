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
    }
}
