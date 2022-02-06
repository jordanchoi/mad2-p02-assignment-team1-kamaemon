//
//  MessageViewController.swift
//  Kamaemon
//
//  Created by mad2 on 3/2/22.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import MessageKit
import InputBarAccessoryView

class MessageViewController : MessagesViewController{
    
    // initialise variables
    var messages : [MessageType] = []
    var isNew : Bool!
    var chosenuser : User?{
        didSet{
            // set title as chosen user's username
            navigationItem.title = chosenuser?.n
        }
    }
    
    // set logged in user as selfSender (to determine bubble appears in left or right)
    var selfSender = Sender(photourl: "", senderId: Auth.auth().currentUser!.uid, displayName: "Me")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // new = true . first time texting after being out
        isNew = true
        
        // set chosenUser as app delegate's selected user
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        chosenuser = appDelegate.selectedUser
        
        // load messages from database
        upcomingMessages()
        
        // delegates
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        // minimise bug when text is too long and bubble get pushed up
        messagesCollectionView.contentInset = UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 0)
        messagesCollectionView.scrollToLastItem()
    }
    
    // send message
    func sendMessage(text: String){
        
        // once 1 text is sent, not new anymore
        isNew = false
        
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        
        // create message object
        let m = Message(Messageto: String(chosenuser!.UID), Messagefrom: Auth.auth().currentUser!.uid, m: text)
        
        // add message object to firebase
        ref.child("Messages").childByAutoId().setValue(["MessageTo" : m.MessageTo, "MessageFrom" : m.MessageFrom, "Message" : m.Message])
        
        // create messageUI object - for display
        let msg = MessageUI(sender: Sender(photourl: "", senderId: m.MessageFrom, displayName: self.chosenuser!.n), messageId: "", sentDate: Date(), kind: .text(m.Message))
        
        // append msg if new
        if(isNew){
            self.messages.append(msg)
        }
    }
    
    // load existing messages real time
    func upcomingMessages(){
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference().child("Messages")
        
        ref.observe(.childAdded) { (snapshot) in
            let value = snapshot.value as? [String: AnyObject]
            
            // create message object from the values in database
            let m = Message(Messageto: value!["MessageTo"] as! String, Messagefrom: value!["MessageFrom"] as! String, m: value!["Message"] as! String)
            
            // filter chat of logged in user and chosen user
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

// to conform to library's message class
struct MessageUI:MessageType{
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

// to conform to library's user/ sender class
struct Sender:SenderType{
    var photourl: String
    var senderId:String
    var displayName:String
}

// layout of 'table view'
extension MessageViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return selfSender as! SenderType
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}

// on press send button
extension MessageViewController:InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        // add message object to firebase
        sendMessage(text: text)
            
        // clear text
        inputBar.inputTextView.text = ""
            
        // reload data
        messagesCollectionView.reloadData()
        
        // scroll
        messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
    }
}
