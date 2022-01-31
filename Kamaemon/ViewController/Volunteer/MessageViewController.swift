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
    var messages : [MessageType] = []
    var isNew : Bool!
    var chosenuser : User?{
        didSet{
            navigationItem.title = chosenuser?.n
            navigationItem.setLeftBarButton(UIBarButtonItem(title: "Back", style: .plain, target: nil, action: #selector(backTap(sender:))), animated: true)
        }
    }

    var selfSender = Sender(photourl: "", senderId: Auth.auth().currentUser!.uid, displayName: "Me")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isNew = true
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        chosenuser = appDelegate.selectedUser
        upcomingMessages()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.contentInset = UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 0)
        messagesCollectionView.scrollToLastItem()
    }
    
    func sendMessage(text: String){
        isNew = false
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        let m = Message(Messageto: String(chosenuser!.UID), Messagefrom: Auth.auth().currentUser!.uid, m: text)
        ref.child("Messages").childByAutoId().setValue(["MessageTo" : m.MessageTo, "MessageFrom" : m.MessageFrom, "Message" : m.Message])
        let msg = MessageUI(sender: Sender(photourl: "", senderId: m.MessageFrom, displayName: self.chosenuser!.n), messageId: "", sentDate: Date(), kind: .text(m.Message))
        if(isNew){
            self.messages.append(msg)
        }
    }
    
    func upcomingMessages(){
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference().child("Messages")
        
        ref.observe(.childAdded) { (snapshot) in
            print("updated from database")
            let value = snapshot.value as? [String: AnyObject]
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
    
    @objc func backTap(sender: UIBarButtonItem){
        self.navigationController?.dismiss(animated: true, completion: nil)
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
    sendMessage(text: text)
    inputBar.inputTextView.text = ""
    messagesCollectionView.reloadData()
    messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
    }
}
