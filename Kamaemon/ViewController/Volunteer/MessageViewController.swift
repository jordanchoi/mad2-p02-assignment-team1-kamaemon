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
import MessageKit
import InputBarAccessoryView

struct Sender:SenderType{
    var photourl: String
    var senderId:String
    var displayName:String
}

struct MessageUI:MessageType{
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

class MessageViewController : MessagesViewController{
    
    
    
    // Data model: These strings will be the data for the table view cells
//    @IBOutlet weak var tableView: UITableView!
    
//    @IBOutlet weak var messageText: UITextField!
    
    var messages : [MessageType] = []
    var isNew : Bool!
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

    var selfSender = Sender(photourl: "", senderId: Auth.auth().currentUser!.uid, displayName: "Me")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isNew = true
//        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "message")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        chosenuser = appDelegate.selectedUser
//        loadMessages()
        upcomingMessages()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
//
//        return self.messages.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = self.tableView.dequeueReusableCell(withIdentifier: "message", for: indexPath)
//
//        let userhelp = self.messages[indexPath.row]
//        cell.textLabel!.text = "\(userhelp.kind)"
//        //cell.detailTextLabel!.text = "\(String(userhelp.UID))"
//
//        return cell
//    }

    func sendMessage(text: String){
        isNew = false
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        let m = Message(Messageto: String(chosenuser!.UID), Messagefrom: Auth.auth().currentUser!.uid, m: text)
        //ref.child("users").child((authResult?.user.uid)!).setValue(["userUID" :(authResult?.user.uid)!, "userCategory" : u.Category, "Name" : u.n])
        ref.child("Messages").childByAutoId().setValue(["MessageTo" : m.MessageTo, "MessageFrom" : m.MessageFrom, "Message" : m.Message])
        let msg = MessageUI(sender: Sender(photourl: "", senderId: m.MessageFrom, displayName: self.chosenuser!.n), messageId: "", sentDate: Date(), kind: .text(m.Message))
        if(isNew){
            self.messages.append(msg)
        }
        //self.messages.append(message)
        //self.tableView.reloadData()
    }



//    func loadMessages(){
//        var ref: DatabaseReference!
//        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference().child("Messages")
//
//
//        ref.observeSingleEvent(of: .value, with: {snapshot in
//          // Get user value
//            let value = snapshot.value as? [String: AnyObject]
//            print("load")
//            print(value)
//            print(value!.keys)
//            if (!value!.isEmpty){
//                for i in value!.keys{
//                    print(value![i])
//                    print(value![i]!["MessageTo"] as! String)
//                    let m = Message(Messageto: value![i]!["MessageTo"] as! String, Messagefrom: value![i]!["MessageFrom"] as! String, m: value![i]!["Message"] as! String)
//                    if ((m.MessageTo == self.chosenuser!.UID  && m.MessageFrom == Auth.auth().currentUser!.uid) || (m.MessageTo == Auth.auth().currentUser!.uid && m.MessageFrom == self.chosenuser!.UID)){
//                        let msg = MessageUI(sender: Sender(photourl: "", senderId: m.MessageFrom, displayName: self.chosenuser!.n), messageId: "", sentDate: Date(), kind: .text(m.Message))
//                        self.messages.append(msg)
//                    }
//                }
//            }
//            DispatchQueue.global(qos: .background).async {
//                DispatchQueue.main.async {
//                    self.messagesCollectionView.reloadData()
//                    self.messagesCollectionView.scrollToLastItem()
//                }
//            }
//
//
//
//        }){ error in
//            print(error.localizedDescription)
//          }
//    }
//
        
    
    func upcomingMessages(){
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference().child("Messages")
        
        ref.observe(.childAdded) { (snapshot) in
            print("updated from database")
            let value = snapshot.value as? [String: AnyObject]
            //let u = User(userUID: value!["userUID"] as! String, userCategory: value!["userCategory"] as! String, name: value!["Name"] as! String)
            let m = Message(Messageto: value!["MessageTo"] as! String, Messagefrom: value!["MessageFrom"] as! String, m: value!["Message"] as! String)
        
            if ((m.MessageTo == self.chosenuser!.UID  && m.MessageFrom == Auth.auth().currentUser!.uid) || (m.MessageTo == Auth.auth().currentUser!.uid && m.MessageFrom == self.chosenuser!.UID)){
                let msg = MessageUI(sender: Sender(photourl: "", senderId: m.MessageFrom, displayName: self.chosenuser!.n), messageId: "", sentDate: Date(), kind: .text(m.Message))
                self.messages.append(msg)
            }
            
            DispatchQueue.global(qos: .background).async {
                DispatchQueue.main.async {
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem()
                }
            }
        } withCancel: { error in
        }
    }
}

extension MessageViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}


extension MessageViewController:InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
    //When use press send button this method is called.
    sendMessage(text: text)
    //clearing input field
    inputBar.inputTextView.text = ""
    messagesCollectionView.reloadData()
    messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
    // messagesCollectionView.scrollToBottom(animated: true)
    }
}
