//
//  ViewController.swift
//  Kamaemon
//
//  Created by Jordan Choi on 14/1/22.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    
    @IBOutlet weak var EmailAddress: UITextField!
    
    @IBOutlet weak var Password: UITextField!
    
    @IBOutlet weak var newUser: UILabel!
    @IBOutlet weak var errorlabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        Auth.auth().createUser(withEmail: "honglec162003@gmail.com", password: "123456789") { authResult, error in
//
//            print("success")
//        }
        
        //let tap = UITapGestureRecognizer(target: self, action: Selector())
        
    }

    @IBAction func LogIn(_ sender: Any) {
        
        Auth.auth().signIn(withEmail: EmailAddress!.text!, password: Password!.text!) { (authResult, error) in
            if let error = error as? NSError {
               switch AuthErrorCode(rawValue: error.code) {
               case .wrongPassword:
                   self.errorlabel.text = "Wrong Password"
               case .invalidEmail:
                   self.errorlabel.text = "Invalid Email"
                 // Error: Indicates the email address is malformed.
               default:
                   print("Error: \(error.localizedDescription)")
               }
             } else {
               print("User signs in successfully")
               let userInfo = Auth.auth().currentUser
               let email = userInfo?.email
               let storyboard = UIStoryboard(name: "Main", bundle: nil)
               let home = storyboard.instantiateViewController(withIdentifier: "home") as! UIViewController
                 home.modalPresentationStyle = .fullScreen
                 self.present(home, animated: true, completion: nil)
                
             }
            
            
            
        }
    }
    
    
   
    
}

