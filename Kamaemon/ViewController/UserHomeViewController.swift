//
//  UserHomeViewController.swift
//  Kamaemon
//
//  Created by Jun Hong on 23/1/22.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class UserHomeViewController : UIViewController{
    
    @IBOutlet weak var name: UILabel!
    
    var ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref.child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value) { DataSnapshot in
            let value = DataSnapshot.value as? [String: AnyObject]
            
            print(value)
            let formatter4 = DateFormatter()
            formatter4.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            print(formatter4.date(from: value!["DOB"] as! String) ?? "Unknown date")
            print(value!["DOB"] as! String)
            //print(dateFormatter.date(from: value!["DOB"] as! String))
            //print(
            let u = User(userUID: value!["userUID"] as! String, userType: value!["UserType"] as! String, name: value!["Name"] as! String, gender: value!["Gender"] as! String, phonenumber: value!["PhoneNumber"] as! String, birthdate: formatter4.date(from: value!["DOB"] as! String) ?? Date(), pfpurl: value!["PFPURL"] as! String, isnewuser: value!["isNewUser"] as! Int)
            
            
            self.name.text = "Hi " + u.n
        }
        
        
    }
    
    
    
    
    
}
