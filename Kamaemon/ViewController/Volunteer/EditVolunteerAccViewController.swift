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
    
    @IBOutlet weak var profilepic: UIImageView!
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
            if let url = URL(string: value!["PFPURL"] as! String){
                if let data = try? Data(contentsOf: url) {
                                if let image = UIImage(data: data){
                                    DispatchQueue.main.async {
//                                        self.profilePic = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                                        self.profilepic.layer.cornerRadius = (self.profilepic.frame.size.width ) / 2
                                        self.profilepic.clipsToBounds = true
                                        self.profilepic.image = image
                                    }
                                }
                            }
            }
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
        // Configuration for camera - delegate to device
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        
        // Set cameraDevice depending on documents to be uploaded.
        switch ((sender as AnyObject).tag) {
        case 1:
            picker.cameraDevice = .rear;
            break
        case 2:
            picker.cameraDevice = .front;
            picker.cameraFlashMode = .off
            break
        default:
            print("Other buttons clicked..")
        }
        
        present(picker, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage {
            profilepic.image = image
        }
        if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            print(url)
            var ref: DatabaseReference!
            ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
            let storageRef = Storage.storage().reference()
                
            let imagePickerSourceURL = url
//            let thisurl:String = url.absoluteString
//            let fullNameArr = thisurl.components(separatedBy: "/")
//            let firstName: String = fullNameArr[fullNameArr.count-1]
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let imageRef = storageRef.child("images/pfp/\(uid)_pfp.png")

            let uploadTask = imageRef.putFile(from: imagePickerSourceURL, metadata: nil) {metadata, error in
              guard let metadata = metadata else {
                return
              }
              // Metadata contains file metadata such as size, content-type.
              let size = metadata.size
              // You can also access to download URL after upload.
                imageRef.downloadURL { url, error in
                  if let error = error {
                    // Handle any errors
                      print(error)
                  } else {
                    // Get the download URL for 'images/stars.jpg'
                      print(url!)
                      ref.child("users").child(uid).child("PFPURL").setValue(url!.absoluteString)
                  }
               }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
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

