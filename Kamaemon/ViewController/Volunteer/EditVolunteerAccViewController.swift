//
//  EditVolunteerAccViewController.swift
//  Kamaemon
//
//  Created by mad2 on 23/1/22.
//

import Foundation
import UIKit
import DropDown
import Firebase
import FirebaseAuth

class EditVolunteerAccViewController:UIViewController , UITextFieldDelegate{
    
    @IBOutlet weak var genderSelect: UIView!
    @IBOutlet weak var mail: UITextField!
    @IBOutlet weak var mobileNum: UITextField!
    @IBOutlet weak var date: UIDatePicker!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    
    var usergender:String = ""
    //gender dropdown
    let genderDropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Real time change when user selects data
        genderDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.gender.text = genderDropDown.dataSource[index]
            gender.textColor = UIColor.black
            usergender = genderDropDown.dataSource[index]
            
        }
        dateLabel.text = "Date of Birth"
        gender.textColor = UIColor.black
        gender.text = "Gender"
        genderDropDown.anchorView = genderSelect
        genderDropDown.dataSource = ["Male", "Female"]
        genderDropDown.bottomOffset = CGPoint(x: 0, y:(genderDropDown.anchorView?.plainView.bounds.height)!)
        genderDropDown.direction = .bottom
        let dateFormatter = ISO8601DateFormatter()
        let currentuser = Auth.auth().currentUser
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        ref.child("users").child(currentuser!.uid).observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            self.name.text =  value?["Name"] as? String ?? "Error"
            self.gender.text = value?["Gender"] as? String ?? "Gender"
            let mdate = value!["DOB"] as! String
            self.date.date = dateFormatter.date(from: mdate)as? Date ?? Date()
            self.mobileNum.text = value?["PhoneNumber"] as? String ?? "0"
            //let Name = value?["Name"] as? String ?? "Error"
        }) { error in
          print(error.localizedDescription)
        }
        
        self.mail.text = currentuser?.email
        mail.delegate = self
        mobileNum.delegate = self
        name.delegate = self
        
        mail.setLeftPaddingPoints(10)
        mobileNum.setLeftPaddingPoints(10)
        name.setLeftPaddingPoints(10)
    
        // Dismiss keyboard on click background
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func showGender(_ sender: Any) {
        genderDropDown.show()
    }
    
    // Background press
    @objc func handleTap() {
        genderSelect.resignFirstResponder()
        mail.resignFirstResponder()
        mobileNum.resignFirstResponder()
        date.resignFirstResponder()
        name.resignFirstResponder()
    }
    
    // Return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func changePFP(_ sender: Any) {
    }
    
    @IBAction func save(_ sender: Any) {
        let dateFormatter = ISO8601DateFormatter()
        //update values here
        let currentuser = Auth.auth().currentUser
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        ref.child("users").child(currentuser!.uid).child("Name").setValue(self.name.text)
        ref.child("users").child(currentuser!.uid).child("Gender").setValue(self.gender.text)
        ref.child("users").child(currentuser!.uid).child("DOB").setValue(dateFormatter.string(for:self.date.date)! as String)
        ref.child("users").child(currentuser!.uid).child("PhoneNumber").setValue(self.mobileNum.text)
        
        if(self.mail.text != currentuser?.email){
            currentuser?.updateEmail(to: self.mail.text!, completion:nil)
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        let dateFormatter = ISO8601DateFormatter()
//        //update values here
//        let currentuser = Auth.auth().currentUser
//        var ref: DatabaseReference!
//        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
//        ref.child("users").child(currentuser!.uid).child("Name").setValue(self.name.text)
//        ref.child("users").child(currentuser!.uid).child("Gender").setValue(self.gender.text)
//        ref.child("users").child(currentuser!.uid).child("DOB").setValue(dateFormatter.string(for:self.date.date)! as String)
//        ref.child("users").child(currentuser!.uid).child("PhoneNumber").setValue(self.mobileNum.text)
//
//        if(self.mail.text != currentuser?.email){
//            currentuser?.updateEmail(to: self.mail.text!, completion:nil)
//        }
    }
}

