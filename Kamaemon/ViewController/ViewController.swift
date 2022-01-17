//
//  ViewController.swift
//  Kamaemon
//
//  Created by Jordan Choi on 14/1/22.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController, UITextFieldDelegate{
    @IBOutlet weak var EmailAddress: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var newUser: UILabel!
    @IBOutlet weak var errorlabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set padding of text fields
        EmailAddress.setLeftPaddingPoints(10)
        Password.setLeftPaddingPoints(10)
        
        // Clear button
        EmailAddress.clearButtonMode = .whileEditing
        Password.clearButtonMode = .whileEditing
        
        // Dismiss keyboard on return
        EmailAddress.delegate = self
        Password.delegate = self
        
        // Dismiss keyboard on click background
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)

//        Auth.auth().createUser(withEmail: "honglec162003@gmail.com", password: "123456789") { authResult, error in
//
//            print("success")
//        }
        
        
    }

    @IBAction func LogIn(_ sender: Any) {
        Auth.auth().signIn(withEmail: EmailAddress!.text!, password: Password!.text!) { (authResult, error) in
            if let error = error as? NSError {
               switch AuthErrorCode(rawValue: error.code) {
               case .wrongPassword:
                   self.errorlabel.text = "Invalid Password"
                   self.Password.layer.borderColor = UIColor.red.cgColor
                   self.Password.layer.borderWidth = 1.0
               case .invalidEmail:
                   self.errorlabel.text = "Invalid Email"
                   self.EmailAddress.layer.borderColor = UIColor.red.cgColor
                   self.EmailAddress.layer.borderWidth = 1.0
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
    
    // Background press
    @objc func handleTap() {
        EmailAddress.resignFirstResponder()
        Password.resignFirstResponder()
    }
    
    // Return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Return to original state
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.EmailAddress.layer.borderWidth = 0
        self.Password.layer.borderWidth = 0
        self.errorlabel.text = ""
        return true
    }
}

