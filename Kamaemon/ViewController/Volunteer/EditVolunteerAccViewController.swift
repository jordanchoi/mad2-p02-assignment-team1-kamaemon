//
//  EditVolunteerAccViewController.swift
//  Kamaemon
//
//  Created by mad2 on 23/1/22.
//

import Foundation
import UIKit
import DropDown

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
        genderDropDown.dataSource = ["M", "F"]
        genderDropDown.bottomOffset = CGPoint(x: 0, y:(genderDropDown.anchorView?.plainView.bounds.height)!)
        genderDropDown.direction = .bottom
        
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
}
