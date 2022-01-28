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

class ChatsTableViewController : UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    var helpList : [User] = []
    var lastMessage : [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //gethelp()
        newUser()
        getLatestMessage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return self.helpList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "user", for: indexPath)
        
        var pMessage : [Message] = []
        
        
        let userhelp = helpList[indexPath.row]
        
        for i in lastMessage{
            if (i.MessageFrom == userhelp.UID && i.MessageTo == Auth.auth().currentUser!.uid){
                pMessage.append(i)
            }
        }
        
        
        var last = ""
        
        if (!pMessage.isEmpty){
            last = pMessage[pMessage.endIndex-1].Message
        }
        
        
        
        cell.textLabel!.text = "\(String(userhelp.n))"
        cell.detailTextLabel!.text = "Last Message: \(last)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
                let u = User(userUID: value![i]!["userUID"] as! String, userType: value![i]!["userCategory"] as! String, name: value![i]!["Name"] as! String)
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
            let u = User(userUID: value!["userUID"] as! String, userType: value!["userCategory"] as! String, name: value!["Name"] as! String)
            //print(value!["Name"])
            print(value!.count)
            if (u.UID == Auth.auth().currentUser?.uid){
                print("==")
            }
            else{
                self.helpList.append(u)
            }
            

            DispatchQueue.global(qos: .background).async {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        } withCancel: { error in
            print(error)
        }
}
    func getLatestMessage(){
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference().child("Messages")
        
        ref.observe(.childAdded) { (snapshot) in
            print("updated from database")
            let value = snapshot.value as? [String: AnyObject]
            //let u = User(userUID: value!["userUID"] as! String, userCategory: value!["userCategory"] as! String, name: value!["Name"] as! String)
            let m = Message(Messageto: value!["MessageTo"] as! String, Messagefrom: value!["MessageFrom"] as! String, m: value!["Message"] as! String)
        
            self.lastMessage.append(m)
            
            DispatchQueue.global(qos: .background).async {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        } withCancel: { error in
            
        }
        
        
        
    }

}
