//
//  ViewController.swift
//  Kamaemon
//
//  Created by Jordan Choi on 14/1/22.
//

import UIKit
import Firebase
import FirebaseAuth

class ViewController: UIViewController, UITextFieldDelegate{
    
    // core data
    let prefs = SharedPrefsController()
    
    // app delegate
    let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
    
    // firebase db reference
    var ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
    
    // UI elements
    @IBOutlet weak var EmailAddress: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var newUser: UILabel!
    @IBOutlet weak var errorlabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set padding of text fields
        EmailAddress.setLeftPaddingPoints(10)
        Password.setLeftPaddingPoints(10)
        
        // clear button
        EmailAddress.clearButtonMode = .whileEditing
        Password.clearButtonMode = .whileEditing
        
        // dismiss keyboard on return
        EmailAddress.delegate = self
        Password.delegate = self
        
        // dismiss keyboard on click background
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
    }

    // on click login
    @IBAction func LogIn(_ sender: Any) {
        Auth.auth().signIn(withEmail: EmailAddress!.text!, password: Password!.text!) { [self] (authResult, error) in
            
            // if error
            if let error = error as NSError? {
               switch AuthErrorCode(rawValue: error.code) {
                   
               // if error is wrong password, display to user
               case .wrongPassword:
                   self.errorlabel.text = "Invalid Password"
                   self.Password.layer.borderColor = UIColor.red.cgColor
                   self.Password.layer.borderWidth = 1.0
                   
               // if error is invalid email, display to user
               case .invalidEmail:
                   self.errorlabel.text = "Invalid Email"
                   self.EmailAddress.layer.borderColor = UIColor.red.cgColor
                   self.EmailAddress.layer.borderWidth = 1.0
                   
               // return
               default:
                   return
               }
                
            // if success
             } else {
                 // update app delegate for verification volunteer
                 appDelegate.verifyUser = User()
                 appDelegate.verifyUser?.UID = (authResult?.user.uid)!
                 
                 self.ref.child("users").child((authResult?.user.uid)!).observeSingleEvent(of: .value) { snapshot in
                     
                     // get user type to determine which page to go
                     let value = snapshot.value as? NSDictionary
                     let usertype = value!["UserType"] as! String
                     let isVerified = value!["isNewUser"] as! Int
                     
                     // go to volunteer home page
                     if (usertype == "Volunteer"){
                         if(Int(isVerified) == 1){
                             self.appDelegate.PopulateList(UID: Auth.auth().currentUser!.uid)
                             let storyboard = UIStoryboard(name: "Main", bundle: nil)
                             let home = storyboard.instantiateViewController(withIdentifier: "home")
                             home.modalPresentationStyle = .fullScreen
                             self.present(home, animated: true, completion: nil)
                             // modify core data that a user is logged in and who
                             prefs.modifyLogin(isloggedIn: true,userID: Auth.auth().currentUser!.uid)
                         }
                         else{
                             self.appDelegate.PopulateList(UID: Auth.auth().currentUser!.uid)
                             let storyboard = UIStoryboard(name: "Main", bundle: nil)
                             let home = storyboard.instantiateViewController(withIdentifier: "verify")
                             home.modalPresentationStyle = .popover
                             self.present(home, animated: true, completion: nil)
                         }
                     }
                     
                     // go to user home page
                     else{
                         let storyboard = UIStoryboard(name: "User", bundle: nil)
                         let home = storyboard.instantiateViewController(withIdentifier: "UserHome")
                         home.modalPresentationStyle = .fullScreen
                         self.present(home, animated: true, completion: nil)
                     }
                 }
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
    
    // go to register page
    @IBAction func here(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let home = storyboard.instantiateViewController(withIdentifier: "register") as! UIViewController
        home.modalPresentationStyle = .fullScreen
        self.present(home, animated: true, completion: nil)
    }
}

