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
import DropDown

class RegisterPageViewController : UIViewController , UITextFieldDelegate{
    
    // UI elements
    @IBOutlet weak var Name: UITextField!
    @IBOutlet weak var EmailAddress: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var cfmPassword: UITextField!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var vwDropdown: UIView!
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var phonenumber: UITextField!
    
    // initialise dropdown (user type)
    let dropDown = DropDown()
    
    // store category of user
    var cat:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialise user category dropdown
        lblTitle.text = "Select User Category"
        dropDown.anchorView = vwDropdown
        dropDown.dataSource = ["Volunteer", "Public User"]
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.topOffset = CGPoint(x: 0, y:-(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.direction = .bottom
        
        // real time change when user selects data
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.lblTitle.text = dropDown.dataSource[index]
            lblTitle.textColor = UIColor.black
            cat = dropDown.dataSource[index]
        }
        
        // Paddings
        Name.setLeftPaddingPoints(10)
        EmailAddress.setLeftPaddingPoints(10)
        phonenumber.setLeftPaddingPoints(10)
        Password.setLeftPaddingPoints(10)
        cfmPassword.setLeftPaddingPoints(10)
        
        // Dismiss keyboard on return
        EmailAddress.delegate = self
        phonenumber.delegate = self
        Password.delegate = self
        Name.delegate = self
        cfmPassword.delegate = self
        
        // Dismiss keyboard on click background
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
    }

    // Show options of user type dropdown
    @IBAction func showOptions(_ sender: Any) {
        dropDown.show()
    }
    
    // Background press
    @objc func handleTap() {
        EmailAddress.resignFirstResponder()
        Password.resignFirstResponder()
        Name.resignFirstResponder()
    }
    
    // validate phone number
    func validate(value: String) -> Bool {
        let PHONE_REGEX = "[6|8|9]\\d{7}|\\+65[6|8|9]\\d{7}|\\+65\\s[6|8|9]\\d{7}"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result = phoneTest.evaluate(with: value)
        return result
    }
    
    // validate email
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Return to original state
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.EmailAddress.layer.borderWidth = 0
        self.Password.layer.borderWidth = 0
        self.Name.layer.borderWidth = 0
        self.phonenumber.layer.borderWidth = 0
        self.cfmPassword.layer.borderWidth = 0
        self.vwDropdown.layer.borderWidth = 0
        self.errorLbl.text = ""
    }
    
    // on click create account
    @IBAction func createAccount(_ sender: Any) {
        // validations
        var notValid = 0
        
        if(Password.text!.count < 8){
            errorLbl.text = "Password must be at least 8 characters"
            self.Password.layer.borderColor = UIColor.red.cgColor
            self.Password.layer.borderWidth = 1.0
            notValid  += 1
        }
        
        if(!isValidEmail(EmailAddress.text!)){
            errorLbl.text = "Please enter a valid email"
            self.EmailAddress.layer.borderColor = UIColor.red.cgColor
            self.EmailAddress.layer.borderWidth = 1.0
            notValid  += 1
        }
        
        if(EmailAddress.text == ""){
            errorLbl.text = "Please enter an email address"
            self.EmailAddress.layer.borderColor = UIColor.red.cgColor
            self.EmailAddress.layer.borderWidth = 1.0
            notValid  += 1
        }
        
        if(self.Name.text == ""){
            errorLbl.text = "Please enter a name"
            self.Name.layer.borderColor = UIColor.red.cgColor
            self.Name.layer.borderWidth = 1.0
            notValid  += 1
        }
        
        if(phonenumber.text == ""){
            errorLbl.text = "Please enter a mobile number"
            self.phonenumber.layer.borderColor = UIColor.red.cgColor
            self.phonenumber.layer.borderWidth = 1.0
            notValid  += 1
        }
        
        if(!validate(value: phonenumber.text!)){
            errorLbl.text = "Please enter a valid mobile number"
            self.phonenumber.layer.borderColor = UIColor.red.cgColor
            self.phonenumber.layer.borderWidth = 1.0
            notValid  += 1
        }
        
        if(cfmPassword.text! == ""){
            errorLbl.text = "Please confirm your password"
            self.cfmPassword.layer.borderColor = UIColor.red.cgColor
            self.cfmPassword.layer.borderWidth = 1.0
            notValid  += 1
        }
        
        if(Password.text != cfmPassword.text){
            errorLbl.text = "Ensure that the two password match"
            self.cfmPassword.layer.borderColor = UIColor.red.cgColor
            self.cfmPassword.layer.borderWidth = 1.0
            self.Password.layer.borderColor = UIColor.red.cgColor
            self.Password.layer.borderWidth = 1.0
            notValid  += 1
        }
        
        if(cat == ""){
            self.vwDropdown.layer.borderColor = UIColor.red.cgColor
            self.vwDropdown.layer.borderWidth = 1.0
            errorLbl.text = "Please select a user type"
            notValid  += 1
        }
        
        // if pass valid test
        if(notValid == 0){
            
            // create user object
            let newUser = User(userUID: "", userType: self.cat, name: self.Name.text!, gender: "", phonenumber: self.phonenumber.text!, birthdate: Date(), pfpurl: "", isnewuser: 0)
            
                // volunteer
                if (self.lblTitle.text == "Volunteer"){
                    
                    // add user email and password in db
                    Auth.auth().createUser(withEmail: EmailAddress.text!, password: Password.text!) { (authResult, error) in
                        
                        // repeated account error
                        if let error = error as? NSError {
                            self.errorLbl.text = "Please enter a different email"
                            self.EmailAddress.layer.borderColor = UIColor.red.cgColor
                            self.EmailAddress.layer.borderWidth = 1.0
                        }
                        
                        // success
                        else  {
                            
                            // create user object in firebase
                            var ref: DatabaseReference!
                            ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
                            if #available(iOS 15.0, *) {
                                ref.child("users").child((authResult?.user.uid)!).setValue(["userUID" :(authResult?.user.uid)!, "UserType" : newUser.UserType, "Name" : newUser.n, "Gender" : newUser.Gender, "PhoneNumber" : newUser.PhoneNumber, "DOB" :  newUser.BirthDate.ISO8601Format(), "PFPURL" : newUser.profilepicurl, "isNewUser" : newUser.isNewUser])
                            } else {
                                return
                            }
                            
                            // create volunteer object in firebase with default hrs and qualification
                            ref.child("volunteers").child((authResult?.user.uid)!).setValue(["Hours" : "0", "Qualifications" : ""])
                            
                            // update app delegate
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            newUser.UID = (authResult?.user.uid)!
                            appDelegate.verifyUser = newUser
                            appDelegate.verifyEmail =  self.EmailAddress.text!
                            appDelegate.verifyPassword = self.Password.text!
                            
                            // go to identity verification
                            self.performSegue(withIdentifier:"toIdentityVerificationSegue", sender: nil)
                        }
                    }
                }
            
                // general user
                if (self.lblTitle.text == "Public User"){
                    
                    // add user email and passsword in db
                    Auth.auth().createUser(withEmail: EmailAddress.text!, password: Password.text!) { (authResult, error) in
                        
                        // repeated account error
                        if let error = error as? NSError {
                            self.errorLbl.text = "Please enter a different email"
                            self.EmailAddress.layer.borderColor = UIColor.red.cgColor
                            self.EmailAddress.layer.borderWidth = 1.0
                        }
                        
                        // success
                        else  {
                            // update core data that user and logged in
                            let prefs = SharedPrefsController()
                            prefs.modifyLogin(isloggedIn: true,userID: Auth.auth().currentUser!.uid)
                            
                            // create user object in firebase
                            var ref: DatabaseReference!
                            ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
                            if #available(iOS 15.0, *) {
                                ref.child("users").child((authResult?.user.uid)!).setValue(["userUID" :(authResult?.user.uid)!, "UserType" : newUser.UserType, "Name" : newUser.n, "Gender" : newUser.Gender, "PhoneNumber" : newUser.PhoneNumber, "DOB" : String(newUser.BirthDate.ISO8601Format()), "PFPURL" : newUser.profilepicurl, "isNewUser" : newUser.isNewUser])
                                
                                // go to user home page
                                let storyboard = UIStoryboard(name: "User", bundle: nil)
                                let controller = storyboard.instantiateViewController(identifier: "UserHome")
                                controller.modalPresentationStyle = .fullScreen
                                self.present(controller, animated: true, completion: nil)
                            } else {
                                return
                            }
                        }
                    }
                }
        }
    }
}
