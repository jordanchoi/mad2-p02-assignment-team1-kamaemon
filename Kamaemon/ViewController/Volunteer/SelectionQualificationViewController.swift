//
//  SelectionQualificationViewController.swift
//  Kamaemon
//
//  Created by Jun Hong on 21/1/22.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class SelectionQualificationViewController : UITableViewController{
    // set qualification data
    var Qualifications : [String] = ["First Aid", "CPR", "Technology", "Gardening", "Pets", "Tutor", "Cooking", "Electrical Skills"]
    
    // set ticked qualifications as the one selected in profile page
    var selectedQualifications : [String] = ProfilePageViewController().Qualifications
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // allow select multiple qualifications
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(true, animated: false)
        
        // get app delegate selected qualifications
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        selectedQualifications = appDelegate.qualificationsList
    }
    
    // set up table view
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.Qualifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "celled", for: indexPath)
        let userhelp = Qualifications[indexPath.row]
        cell.textLabel!.text = "\(String(userhelp))"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        func shouldSelect() -> Bool {
            
            let userhelp = Qualifications[indexPath.row]
            
            for i in selectedQualifications{
                if (i == userhelp){
                    return true
                }
            } ;return false
        }
        if shouldSelect() {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
    
    // if selected, append item to list
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedQualifications.append(Qualifications[indexPath.row])
    }

    // if deselected, remove item from list
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deselectedRow = Qualifications[indexPath.row]
        if(selectedQualifications.contains(deselectedRow)){
            let indx = selectedQualifications.index(of: deselectedRow)
            selectedQualifications.remove(at: indx!)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //update to firebase
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        
        ref.child("volunteers").child(Auth.auth().currentUser!.uid).child("Qualifications").setValue(selectedQualifications)
    }
}
