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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.\
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
//        ref.child("users").child(Auth.auth().currentUser!.uid).child("Name").observeSingleEvent(of: .value) { snapshot in
//            guard let value1 = snapshot.value as? String else{
//                return
//            }
//            displayName = value1
//
//        }
            //.value(forKeyPath: "Name") as! String?
        print(Auth.auth().currentUser!.uid)
        ref.child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { snapshot in
          // Get user value
          let value = snapshot.value as? NSDictionary
            let displayName = value?["Name"] as? String ?? "Error"
            self.user.text = "Hello, " + displayName +  "👋"
          //let user = User(username: username)

          // ...
        }) { error in
          print(error.localizedDescription)
        }
        
        
        


        
    }
    
    
}
