//
//  EditVolunteerAccViewController.swift
//  Kamaemon
//
//  Created by mad2 on 23/1/22.
//
/*
import Foundation
import UIKit
import DropDown
import Firebase
import FirebaseAuth

class EditVolunteerAccViewController:UIViewController , UITextFieldDelegate{
    
    @IBOutlet weak var genderSelect: UIView!
    @IBOutlet weak var pass: UITextField!
    @IBOutlet weak var mail: UITextField!
    @IBOutlet weak var mobileNum: UITextField!
    @IBOutlet weak var date: UIDatePicker!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var name: UITextField!
    
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
        
        gender.text = "Gender"
        genderDropDown.anchorView = genderSelect
        genderDropDown.dataSource = ["Male", "Female"]
        genderDropDown.bottomOffset = CGPoint(x: 0, y:(genderDropDown.anchorView?.plainView.bounds.height)!)
        genderDropDown.direction = .bottom
        
        let currentuser = Auth.auth().currentUser
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        ref.child("users").child(currentuser!.uid).observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            self.name.text =  value?["Name"] as? String ?? "Error"
            self.gender.text = value?["Gender"] as? String ?? "Gender"
            self.date.date = value?["DOB"] as? Date ?? Date()
            self.mobileNum.text = value?["PhoneNumber"] as? String ?? "0"
            //let Name = value?["Name"] as? String ?? "Error"
        }) { error in
          print(error.localizedDescription)
        }
        
        self.mail.text = currentuser?.email
        
        pass.delegate = self
        mail.delegate = self
        mobileNum.delegate = self
        name.delegate = self
        
        pass.setLeftPaddingPoints(10)
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
        pass.resignFirstResponder()
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
    
    @IBAction func save(_ sender: Any) {
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        //update values here
        let currentuser = Auth.auth().currentUser
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        ref.child("users").child(currentuser!.uid).child("Name").setValue(self.name.text)
        ref.child("users").child(currentuser!.uid).child("Gender").setValue(self.gender.text)
        ref.child("users").child(currentuser!.uid).child("DOB").setValue(self.date.date)
        ref.child("users").child(currentuser!.uid).child("PhoneNumber").setValue(self.mobileNum.text)
        
        if(self.mail.text != currentuser?.email){
            currentuser?.updateEmail(to: self.mail.text, completion: { Error? in
                print(Error)
            })
        }
        
        if(!self.pass.text?.isEmpty){
            currentuser?.updatePassword(to: self.pass.text, completion: { (error) in
                print(error)
            })
        }
        //update email and password through authentication 
    }
}
*/
