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
        
    @IBOutlet weak var Name: UITextField!
    @IBOutlet weak var EmailAddress: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var vwDropdown: UIView!
    @IBOutlet weak var errorLbl: UILabel!
    let dropDown = DropDown()
    
    var cat:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialising user category dropdown
        lblTitle.text = "Select User Category"
        dropDown.anchorView = vwDropdown
        dropDown.dataSource = ["Volunteer", "General"]
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.topOffset = CGPoint(x: 0, y:-(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.direction = .bottom
        
        // Real time change when user selects data
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.lblTitle.text = dropDown.dataSource[index]
            lblTitle.textColor = UIColor.black
            cat = dropDown.dataSource[index]
        }
        
        // Paddings
        Name.setLeftPaddingPoints(10)
        EmailAddress.setLeftPaddingPoints(10)
        Password.setLeftPaddingPoints(10)
        
        // Dismiss keyboard on return
        EmailAddress.delegate = self
        Password.delegate = self
        Name.delegate = self
        
        // Dismiss keyboard on click background
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
    }

    // Show options
    @IBAction func showOptions(_ sender: Any) {
        dropDown.show()
    }
    
    // Background press
    @objc func handleTap() {
        EmailAddress.resignFirstResponder()
        Password.resignFirstResponder()
        Name.resignFirstResponder()
    }
    
    // Client side validation
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.Password.layer.borderColor = UIColor.red.cgColor
        self.EmailAddress.layer.borderColor = UIColor.red.cgColor
        self.Name.layer.borderColor = UIColor.red.cgColor
        self.Password.layer.borderWidth = 1.0
        self.EmailAddress.layer.borderWidth = 1.0
        self.Name.layer.borderWidth = 1.0
        
        if(Password.text!.count >= 6){
            self.Password.layer.borderWidth = 0
        }
        
        if(EmailAddress.text != "" && isValidEmail(EmailAddress.text!)){
            self.EmailAddress.layer.borderWidth = 0
        }
        
        if(self.Name.text != ""){
            self.Name.layer.borderWidth = 0
        }
        
        return true
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // Return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func createAccount(_ sender: Any) {
//        do {
//            try Auth.auth().signOut()
//        } catch let error {
//            print("(error)")
//        }
        Auth.auth().createUser(withEmail: EmailAddress.text!, password: Password.text!) { (authResult, error) in
            if let error = error as? NSError {
                self.errorLbl.text = "Something went wrong. Please try again."
            }
            else  {
                print("success")
                print(authResult?.user.uid)
                let u = User(userUID: (authResult?.user.uid)!, userCategory: self.cat, name: self.Name.text!)
                var ref: DatabaseReference!
                ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
                ref.child("users").child((authResult?.user.uid)!).setValue(["userUID" :(authResult?.user.uid)!, "userCategory" : u.Category, "Name" : u.n])
            }
        }
    }
}
    
    
    
