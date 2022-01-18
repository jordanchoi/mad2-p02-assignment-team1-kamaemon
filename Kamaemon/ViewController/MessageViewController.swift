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

class MessageViewController : UITableViewController{
    // Data model: These strings will be the data for the table view cells
    let animals: [String] = ["Horse", "Cow", "Camel", "Sheep", "Goat"]
    var chosenuser : User?{
        didSet{
            navigationItem.title = chosenuser?.n
        }
    }


    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "message")
           
           
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return self.animals.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "message", for: indexPath)
        
        let userhelp = animals[indexPath.row]
        
        cell.textLabel!.text = "\(String(userhelp))"
        //cell.detailTextLabel!.text = "\(String(userhelp.UID))"
        
        return cell
    }
    
    func sendMessage(){
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        let message = Message(Messageto: String(chosenuser!.UID), Messagefrom: Auth.auth().currentUser!.uid, m: "supposedly from text field")
        //ref.child("users").child((authResult?.user.uid)!).setValue(["userUID" :(authResult?.user.uid)!, "userCategory" : u.Category, "Name" : u.n])
        ref.child("Messages").childByAutoId().setValue(["Messageto" : message.MessageTo, "MessageFrom" : message.MessageFrom, "Message" : message.Message])
    
        
    }
    
    
    
    func loadMessages(){
        
        
        
    }
    
    
    func upcomingMessages(){
        
        
        
    }

}
