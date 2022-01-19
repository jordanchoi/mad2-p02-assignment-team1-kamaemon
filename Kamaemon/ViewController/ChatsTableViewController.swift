//
//  ChatsTableViewController.swift
//  Kamaemon
//
//  Created by Jun Hong on 18/1/22.
//

import Foundation
import UIKit
import FirebaseAuth
import Firebase

class ChatsTableViewController : UITableViewController{
    
    var helpList : [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gethelp()
        newUser()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return self.helpList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "user", for: indexPath)
        
        let userhelp = helpList[indexPath.row]
        
        cell.textLabel!.text = "\(String(userhelp.n))"
        cell.detailTextLabel!.text = "\(String(userhelp.UID))"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.selectedUser = helpList[indexPath.row]
   
//        if let vc = presentingViewController as? MessageView {
//                  //before dismissing the Form ViewController, pass the data inside the closure
//                    dismiss(animated: true, completion: {
//                        vc.chosenuser = self.helpList[indexPath.row]
//                    })
//                }
    }
    
    func gethelp(){
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference().child("users")
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
          // Get user value
            let value = snapshot.value as? [String: AnyObject]
            for i in value!.keys{
                print(value![i]!["userUID"] as! String)
                let u = User(userUID: value![i]!["userUID"] as! String, userCategory: value![i]!["userCategory"] as! String, name: value![i]!["Name"] as! String)
                self.helpList.append(u)
            }
            DispatchQueue.global(qos: .background).async {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
//            print(value!["Name"])
//            print(value!["YWGGd41WyxYhl40TVHQvoMpc3FA3"]!["Name"])
//            print(value?.keys)
            //print(value?.values[0] as! String)
            
           
        
        }) { error in
          print(error.localizedDescription)
        }
        
        
        //        ref.observeSingleEvent(of: .childAdded, with: { snapshot in
        //
        //            if let dictionary = snapshot.value as? [String: AnyObject]{
        //                //let user = User(userUID: dictionary.val, userCategory: <#T##String#>, name: <#T##String#>)
        //                let user = User(userUID: (dictionary["userUID"] as? String)! , userCategory: (dictionary["userCategory"] as? String)!, name: (dictionary["Name"] as? String)!)
        //                print(user)
        //                self.helpList.append(user)
        //                DispatchQueue.global(qos: .background).async {
        //
        //                    DispatchQueue.main.async {
        //                    self.tableView.reloadData()
        //
        //                    }
        //                }
        //
        //            }
                    
                    
        //        ref.observeSingleEvent(of: .childAdded) { DataSnapshot in
        //            let value = DataSnapshot.value as? NSDictionary
        //            print(value)
        //            let Name = value?["Name"] as? String ?? "Error"
        //            let userCategory = value?["userCategory"] as? String ?? "Error"
        //            let userUID = value?["userUID"] as? String ?? "Error"
        //
        //            let user = User(userUID: userUID, userCategory: userCategory, name: Name)
        //
        //            self.helpList.append(user)
        //            DispatchQueue.global(qos: .background).async {
        //
        //                // Background Thread
        //
        //                DispatchQueue.main.async {
        //                    self.tableView.reloadData()
        //                }
        //            }
        //        } withCancel: { Error in
        //            print(Error)
        //        }
    }
    
    func newUser(){
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference().child("users")
        ref.observe(.childAdded) { (snapshot) in
            print("updated from database")
            let value = snapshot.value as? [String: AnyObject]
            let u = User(userUID: value!["userUID"] as! String, userCategory: value!["userCategory"] as! String, name: value!["Name"] as! String)
            var  count = 1
            //print(value!["Name"])
            print(value!.count)
            //self.helpList.append(u)
            for k in self.helpList{
                
                
                print(count)
                if(k.UID != value!["userUID"] as! String && count == self.helpList.count){
                    self.helpList.append(u)
                    print(self.helpList)
                }
                count = count + 1
                
                
//                if(count == self.helpList.count){
//                    self.helpList.append(u)
//                }
                
                
            }
//            for k in self.helpList{
//                if (value!["userUID"] as! String != k.UID){
//                    self.helpList.append(u)
//                }
//                count = count + 1
//            }
            
            DispatchQueue.global(qos: .background).async {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        } withCancel: { error in
            print(error)
        }

}

}
