//
//  HomeViewController.swift
//  Kamaemon
//
//  Created by Jun Hong on 16/1/22.
//

import Foundation
import UIKit
import FirebaseAuth

class HomeViewController : UIViewController{
    
    @IBOutlet weak var user: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let userInfo = Auth.auth().currentUser
        let email = userInfo?.email
        user.text = "Hello, " + "Balqis" + " 👋"
        
        print("Email: \(email)")

        
    }
    
    
    
}
