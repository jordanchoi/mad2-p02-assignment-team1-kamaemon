//
//  RegisterPageViewController.swift
//  Kamaemon
//
//  Created by Jun Hong on 17/1/22.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
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
        
    
//        do {
//            try Auth.auth().signOut()
//        } catch let error {
//            print("(error)")
//        }
        Auth.auth().createUser(withEmail: EmailAddress.text!, password: Password.text!) { authResult, error in
            print("success")
            print(authResult?.user.uid)
            let u = User(userUID: (authResult?.user.uid)!, userCategory: self.cat.currentTitle!, name: self.Name.text!)
            var ref: DatabaseReference!
            ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
            ref.child("users").child((authResult?.user.uid)!).setValue(["userUID" :(authResult?.user.uid)!, "userCategory" : u.Category, "Name" : u.n])
        }
        
    
    
        
    }

    
    
}
    
    
    
