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
    
    var Qualifications : [String] = ["First Aid", "CPR", "Technology", "Gardening", "Pets", "Tutor", "Cooking", "Electrical Skills"]
    var selectedQualifications : [String] = ProfilePageViewController().Qualifications
    //var ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
    //var selectedCells: [String] = self().selectedQualifications
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView.setEditing(true, animated: false)
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(true, animated: false)
        //gethelp()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        selectedQualifications = appDelegate.qualificationsList
        //print(selectedQualifications)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return self.Qualifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "celled", for: indexPath)
        
        let userhelp = Qualifications[indexPath.row]
        
//        for i in selectedQualifications{
//            if (i == userhelp){
//                cell.setSelected(true, animated: true)
//            }
//        }
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
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedQualifications.append(Qualifications[indexPath.row])
        print(selectedQualifications)
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deselectedRow = Qualifications[indexPath.row]
        if(selectedQualifications.contains(deselectedRow)){
            let indx = selectedQualifications.index(of: deselectedRow)
            selectedQualifications.remove(at: indx!)
            print(selectedQualifications)
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        //update to firebase
        //ref.child("volunteers").child(Auth.auth().currentUser?.uid!).child("Qualifications").setValue("f")
        
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        
        ref.child("volunteers").child(Auth.auth().currentUser!.uid).child("Qualifications").setValue(selectedQualifications)
        
    }
    
}
