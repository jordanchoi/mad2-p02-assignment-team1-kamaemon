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
    @IBOutlet weak var cfmPassword: UITextField!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var vwDropdown: UIView!
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var phonenumber: UITextField!
    
    let dropDown = DropDown()
    let genderDropDown = DropDown()
    
    var cat:String = ""
//    var gender:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialising user category dropdown
        lblTitle.text = "Select User Category"
        dropDown.anchorView = vwDropdown
        dropDown.dataSource = ["Volunteer", "Public User"]
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.topOffset = CGPoint(x: 0, y:-(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.direction = .bottom
        
        // Real time change when user selects data
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.lblTitle.text = dropDown.dataSource[index]
            lblTitle.textColor = UIColor.black
            cat = dropDown.dataSource[index]
        }
        
        // gender dropdown
        
        //gender dropdown
//        genderlabel.text = "Gender"
//        genderDropDown.anchorView = genderdropdown
//        genderDropDown.dataSource = ["Male", "Female"]
//        genderDropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
//        genderDropDown.direction = .bottom
        
        // Real time change when user selects data
//        genderDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
//            self.genderlabel.text = genderDropDown.dataSource[index]
//            genderlabel.textColor = UIColor.black
//            gender = genderDropDown.dataSource[index]
//        }
        
        
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

    // Show options
    @IBAction func showOptions(_ sender: Any) {
        dropDown.show()
    }
    
    
    @IBAction func showGender(_ sender: Any) {
        genderDropDown.show()
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
        
        
        let newUser = User(userUID: "", userType: self.cat, name: self.Name.text!, gender: "", phonenumber: self.phonenumber.text!, birthdate: Date(), pfpurl: "", isnewuser: 0)
            if (self.lblTitle.text == "Volunteer"){
                Auth.auth().createUser(withEmail: EmailAddress.text!, password: Password.text!) { (authResult, error) in
                    if let error = error as? NSError {
                        print(error)
                        self.errorLbl.text = "Something went wrong. Please try again."
                    }
                    else  {
                        print("success")
                        print(authResult?.user.uid)
                        //let u = User(userUID: (authResult?.user.uid)!, userType: self.cat, name: self.Name.text!)
                        //let newUser = User(userUID: (authResult?.user.uid)!, userType: self.cat, name: self.Name.text!, gender: self.gender, phonenumber: self.phonenumber.text!, birthdate: self.birthdate.date, pfpurl: "", isnewuser: 0)
                        var ref: DatabaseReference!
                        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
                        if #available(iOS 15.0, *) {
                            ref.child("users").child((authResult?.user.uid)!).setValue(["userUID" :(authResult?.user.uid)!, "UserType" : newUser.UserType, "Name" : newUser.n, "Gender" : newUser.Gender, "PhoneNumber" : newUser.PhoneNumber, "DOB" :  newUser.BirthDate.ISO8601Format(), "PFPURL" : newUser.profilepicurl, "isNewUser" : newUser.isNewUser])
                        } else {
                            // Fallback on earlier versions
                        }
                        
                        ref.child("volunteers").child((authResult?.user.uid)!).setValue(["Hours" : "0", "Qualifications" : ""])
                        
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        newUser.UID = (authResult?.user.uid)!
                        appDelegate.verifyUser = newUser
                        appDelegate.verifyEmail =  self.EmailAddress.text!
                        appDelegate.verifyPassword = self.Password.text!
                        self.performSegue(withIdentifier:"toIdentityVerificationSegue", sender: nil)
                        
                    }
                }
    //            let appDelegate = UIApplication.shared.delegate as! AppDelegate
    //            appDelegate.verifyUser = newUser
    //            appDelegate.verifyEmail =  EmailAddress.text!
    //            appDelegate.verifyPassword = Password.text!
    //            self.performSegue(withIdentifier:"toIdentityVerificationSegue", sender: nil)
                
            }
            else{
                Auth.auth().createUser(withEmail: EmailAddress.text!, password: Password.text!) { (authResult, error) in
                    if let error = error as? NSError {
                        print(error)
                        self.errorLbl.text = "Something went wrong. Please try again."
                    }
                    else  {
                        print("success")
                        print(authResult?.user.uid)
                        //let u = User(userUID: (authResult?.user.uid)!, userType: self.cat, name: self.Name.text!)
                        //let newUser = User(userUID: (authResult?.user.uid)!, userType: self.cat, name: self.Name.text!, gender: self.gender, phonenumber: self.phonenumber.text!, birthdate: self.birthdate.date, pfpurl: "", isnewuser: 0)
                        var ref: DatabaseReference!
                        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
                        if #available(iOS 15.0, *) {
                            ref.child("users").child((authResult?.user.uid)!).setValue(["userUID" :newUser.UID, "UserType" : newUser.UserType, "Name" : newUser.n, "Gender" : newUser.Gender, "PhoneNumber" : newUser.PhoneNumber, "DOB" : String(newUser.BirthDate.ISO8601Format()), "PFPURL" : newUser.profilepicurl, "isNewUser" : newUser.isNewUser])
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                }
            }
        
    }
        
}
    
//    
//import Foundation
//import UIKit
//import Firebase
//import FirebaseAuth
//
//class MyListTableViewController : UITableViewController{
//    var testList : [String] = []
//    var count = 0
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        //self.navigationController?.setNavigationBarHidden(false, animated: true)
//        
//        
//        var ref: DatabaseReference!
//        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
//        ref.child("test").child("beta").observeSingleEvent(of: .value, with: { snapshot in
//          // Get user value
//            let value = snapshot.value as? NSDictionary
//            print("----View did load----")
//            print(value)
//            print("----View did load----")
//            print(value?.allValues)
//            print("----View did load----")
//            for i in value!.allValues{
//                let string = i as? String ?? "Error"
//                self.testList.append(string)
//                self.count = self.testList.count
//            }
//        }) { error in
//          print(error.localizedDescription)
//        }
//        self.tableView.reloadData();
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        var ref: DatabaseReference!
//        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
//        ref.child("test").observeSingleEvent(of: .childAdded, with: { snapshot in
//            ref.child("test").child("beta").observeSingleEvent(of: .value, with: { snapshot in
//              // Get user value
//                let value = snapshot.value as? NSDictionary
//                print("----View will appear----")
//                print(value)
//                print("----View will appear----")
//                print(value?.allValues)
//                print("----View will appear----")
//                for i in value!.allValues{
//                    for k in self.testList{
//                        let string = i as? String ?? "Error"
//                        if (i as! String != k){
//                            self.testList.append(string)
//                        }
//                    }
//                }
//            
//            }) { error in
//              print(error.localizedDescription)
//            }
//        }) { error in
//          print(error.localizedDescription)
//        }
//        self.tableView.reloadData();
//    }
//    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
////        var transactList:[Transaction] = []
////        transactList = usercontroller.RetrieveAllTransactionsbyUser(user: AppDelegate.user!)
//        
//        return self.count
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = self.tableView.dequeueReusableCell(withIdentifier: "session", for: indexPath)
////        var transactList:[Transaction] = []
////        transactList = usercontroller.RetrieveAllTransactionsbyUser(user: AppDelegate.user!)
////
////        let transact = transactList[indexPath.row]
//        
//        cell.textLabel!.text = "\(testList[indexPath.row])"
//        cell.detailTextLabel!.text = "\(testList[indexPath.row])"
//        
//        return cell
//    }
//    
//    
//    
//    
//    
//    
//    
//    
//}
//
//    
