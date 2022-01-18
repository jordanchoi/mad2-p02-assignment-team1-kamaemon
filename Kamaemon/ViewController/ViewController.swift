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
    let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
    
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
                 let storyboard = UIStoryboard(name: "Main", bundle: nil)
                 let home = storyboard.instantiateViewController(withIdentifier: "home") as! UIViewController
                 home.modalPresentationStyle = .fullScreen
                 self.present(home, animated: true, completion: nil)
             }
        }
        PopulateList()
    }
    public func PopulateList() {
        // DB
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        
        
        ref.child("openEvents").observeSingleEvent(of: .value , with: { snapshot in
            for event in snapshot.children{
                let events = snapshot.childSnapshot(forPath: (event as AnyObject).key)
                for eventDetails in events.children{
                    let details = events.childSnapshot(forPath: (eventDetails as AnyObject).key)
                    if(details.key == "volunteerID"){
                        // Populate list of volunteer activities that are open
                        if(details.value as! String == ""){
                            print("getting data...")
                            let event = (events.value! as AnyObject)
                            let id = event["eventID"]!!
                            let desc = event["eventDesc"]!!
                            let hrs = event["eventHrs"]!!
                            let loc = event["eventLocation"]!!
                            let user = event["userID"]!!
                            let volunteer = event["volunteerID"]!!
                            self.appDelegate.openEventList.append(
                                Event(id: id as! Int, desc: desc as! String, hours: hrs as! Int, location: loc as! String, uID: user as! String, vID: volunteer as! String)
                            )
                        }
                        
                        // Populate list of volunteer activities that user have selected and have not done
                        if(details.value as! String == Auth.auth().currentUser!.uid){
                            print("getting data...")
                            let event = (events.value! as AnyObject)
                            let id = event["eventID"]!!
                            let desc = event["eventDesc"]!!
                            let hrs = event["eventHrs"]!!
                            let loc = event["eventLocation"]!!
                            let user = event["userID"]!!
                            let volunteer = event["volunteerID"]!!
                            self.appDelegate.joinedEventList.append(
                                Event(id: id as! Int, desc: desc as! String, hours: hrs as! Int, location: loc as! String, uID: user as! String, vID: volunteer as! String)
                            )
                        }
                    }
                    self.appDelegate.volunteerList[1] = self.appDelegate.joinedEventList
                    self.appDelegate.volunteerList[0] = self.appDelegate.openEventList
                }
            }
        })
        {
            error in
                print(error.localizedDescription)
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
    
    
    @IBAction func here(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let home = storyboard.instantiateViewController(withIdentifier: "register") as! UIViewController
        home.modalPresentationStyle = .fullScreen
        self.present(home, animated: true, completion: nil)
    }
}

