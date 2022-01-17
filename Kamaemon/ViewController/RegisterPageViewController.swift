//
//  RegisterPageViewController.swift
//  Kamaemon
//
//  Created by Jun Hong on 17/1/22.
//

import Foundation
import UIKit
import Firebase

class RegisterPageViewController : UIViewController {
        
    @IBOutlet weak var Name: UITextField!
    
    @IBOutlet weak var EmailAddress: UITextField!
    
    @IBOutlet weak var Password: UITextField!
    
    @IBOutlet weak var cat: UIButton!
    
    @IBOutlet weak var userCategory: UIMenu!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.\
    
        
        
        
        

        
        
        
        
    }
    
    
    @IBAction func createAccount(_ sender: Any) {
        
        Auth.auth().createUser(withEmail: EmailAddress.text!, password: Password.text!) { authResult, error in
            print("success")
        }
        let u = User(userUID: Auth.auth().currentUser!.uid, userCategory: cat.currentTitle!, name: Name.text!)
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        ref.child("users").child(Auth.auth().currentUser!.uid).setValue(["userUID" : u.UID, "userCategory" : u.Category, "Name" : u.n])
    }
    
    
}
