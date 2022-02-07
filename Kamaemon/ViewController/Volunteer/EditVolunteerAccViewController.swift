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
import FirebaseStorage

class EditVolunteerAccViewController:UIViewController , UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    
    // UI elements
    @IBOutlet weak var profilepic: UIImageView!
    @IBOutlet weak var genderSelect: UIView!
    @IBOutlet weak var mail: UITextField!
    @IBOutlet weak var mobileNum: UITextField!
    @IBOutlet weak var date: UIDatePicker!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    
    // initialise variables
    var usergender:String = ""
    let genderDropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // real time change when user selects data
        genderDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.gender.text = genderDropDown.dataSource[index]
            gender.textColor = UIColor { tc in
                switch tc.userInterfaceStyle {
                case .dark:
                    return UIColor.white
                default:
                    return UIColor.black
                }
            }
            usergender = genderDropDown.dataSource[index]
        }
        
        // label texts set color
        dateLabel.text = "Date of Birth (age >= 16)"
        gender.text = "Gender"
        gender.textColor = UIColor { tc in
            switch tc.userInterfaceStyle {
            case .dark:
                return UIColor.white
            default:
                return UIColor.black
            }
        }
        
        // data for gender and set up dropdown
        genderDropDown.anchorView = genderSelect
        genderDropDown.dataSource = ["Male", "Female"]
        genderDropDown.bottomOffset = CGPoint(x: 0, y:(genderDropDown.anchorView?.plainView.bounds.height)!)
        genderDropDown.direction = .bottom
        
        // date formatter
        let dateFormatter = ISO8601DateFormatter()
        
        let currentuser = Auth.auth().currentUser
        
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        
        // get user details and display as default for edit view
        self.mail.text = currentuser?.email
        ref.child("users").child(currentuser!.uid).observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            
            self.name.text =  value?["Name"] as? String ?? "Error"
            self.gender.text = value?["Gender"] as? String ?? "Gender"
            if(self.gender.text == ""){
                self.gender.text = "Gender"
                self.gender.textColor = .lightGray
            }
            let mdate = value!["DOB"] as! String
            self.date.date = dateFormatter.date(from: mdate)as? Date ?? Date()
            self.mobileNum.text = value?["PhoneNumber"] as? String ?? "0"
            if let url = URL(string: value!["PFPURL"] as! String){
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data){
                        DispatchQueue.main.async {
                            self.profilepic.layer.cornerRadius = (self.profilepic.frame.size.width ) / 2
                            self.profilepic.clipsToBounds = true
                            self.profilepic.image = image
                        }
                    }
                }
            }
        }) { error in
          return
        }
        
        // delegates
        mobileNum.delegate = self
        mail.delegate = self
        name.delegate = self
        
        // set paddings
        mail.setLeftPaddingPoints(10)
        mobileNum.setLeftPaddingPoints(10)
        name.setLeftPaddingPoints(10)
    
        // Dismiss keyboard on click background
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
    }
    
    // show dropdown
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
        // set picker source type to photo library
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // get selected image
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage {
            profilepic.image = image
        }
        
        // upload to firebase storage
        if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            var ref: DatabaseReference!
            ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
            let storageRef = Storage.storage().reference()
                
            let imagePickerSourceURL = url
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let imageRef = storageRef.child("images/pfp/\(uid)_pfp.png")

            let uploadTask = imageRef.putFile(from: imagePickerSourceURL, metadata: nil) {metadata, error in
                guard metadata != nil else {
                    return
                }
                imageRef.downloadURL { url, error in
                    if error != nil {
                    return
                  } else {
                      // upload / set value of url
                      ref.child("users").child(uid).child("PFPURL").setValue(url!.absoluteString)
                  }
               }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    // dismiss image picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // on press save
    @IBAction func save(_ sender: Any) {
        let dateFormatter = ISO8601DateFormatter()
        let currentuser = Auth.auth().currentUser
        
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        
        // update values
        ref.child("users").child(currentuser!.uid).child("Name").setValue(self.name.text)
        if(self.gender.text == "Gender"){
            self.gender.text = ""
        }
        ref.child("users").child(currentuser!.uid).child("Gender").setValue(self.gender.text)
        ref.child("users").child(currentuser!.uid).child("DOB").setValue(dateFormatter.string(for:self.date.date)! as String)
        ref.child("users").child(currentuser!.uid).child("PhoneNumber").setValue(self.mobileNum.text)
        if(self.mail.text != currentuser?.email){
            currentuser?.updateEmail(to: self.mail.text!, completion:nil)
        }
        
        // go to previous page
        navigationController?.popViewController(animated: true)
    }
}

