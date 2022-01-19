//
//  MessageViewController.swift
//  Kamaemon
//
//  Created by Jun Hong on 18/1/22.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class MessageViewController : UIViewController, UITableViewDataSource, UITableViewDelegate{
    // Data model: These strings will be the data for the table view cells
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var messageText: UITextField!
    
    var messages : [Message] = []
    
    var chosenuser : User?{
        didSet{
                   navigationItem.title = chosenuser?.n
               }
    }
//    var chosenuser : User?{
//        didSet{
//            navigationItem.title = chosenuser?.n
//        }
//    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "message")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        chosenuser = appDelegate.selectedUser
        //loadMessages()
        upcomingMessages()
    
        
           
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "message", for: indexPath)
        
        let userhelp = self.messages[indexPath.row]
        
        cell.textLabel!.text = "\(String(userhelp.Message))"
        //cell.detailTextLabel!.text = "\(String(userhelp.UID))"
        
        return cell
    }
    
    func sendMessage(){
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        let message = Message(Messageto: String(chosenuser!.UID), Messagefrom: Auth.auth().currentUser!.uid, m: messageText.text!)
        //ref.child("users").child((authResult?.user.uid)!).setValue(["userUID" :(authResult?.user.uid)!, "userCategory" : u.Category, "Name" : u.n])
        ref.child("Messages").childByAutoId().setValue(["MessageTo" : message.MessageTo, "MessageFrom" : message.MessageFrom, "Message" : message.Message])
        
        //self.messages.append(message)
        
        //self.tableView.reloadData()
    
        
    }
    
    
    
    func loadMessages(){
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference().child("Messages")
        
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
          // Get user value
            let value = snapshot.value as? [String: AnyObject]
            print("load")
            print(value)
            print(value!.keys)
            if (!value!.isEmpty){
                for i in value!.keys{
                    print(value![i])
                    print(value![i]!["MessageTo"] as! String)
                    let m = Message(Messageto: value![i]!["MessageTo"] as! String, Messagefrom: value![i]!["MessageFrom"] as! String, m: value![i]!["Message"] as! String)
                    if ((m.MessageTo == self.chosenuser!.UID  && m.MessageFrom == Auth.auth().currentUser!.uid) || (m.MessageTo == Auth.auth().currentUser!.uid && m.MessageFrom == self.chosenuser!.UID)){
                        self.messages.append(m)
                    }
                }
            }
            DispatchQueue.global(qos: .background).async {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }

           
        
        }){ error in
            print(error.localizedDescription)
          }
    }
        
        
    
    func upcomingMessages(){
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference().child("Messages")
        
        ref.observe(.childAdded) { (snapshot) in
            print("updated from database")
            let value = snapshot.value as? [String: AnyObject]
            //let u = User(userUID: value!["userUID"] as! String, userCategory: value!["userCategory"] as! String, name: value!["Name"] as! String)
            let m = Message(Messageto: value!["MessageTo"] as! String, Messagefrom: value!["MessageFrom"] as! String, m: value!["Message"] as! String)
        
            if ((m.MessageTo == self.chosenuser!.UID  && m.MessageFrom == Auth.auth().currentUser!.uid) || (m.MessageTo == Auth.auth().currentUser!.uid && m.MessageFrom == self.chosenuser!.UID)){
                self.messages.append(m)
            }
            
            DispatchQueue.global(qos: .background).async {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        } withCancel: { error in
            
        }

        
    }

    @IBAction func sendMessage(_ sender: Any) {
        
        sendMessage()
        messageText.text = ""
    }
}
