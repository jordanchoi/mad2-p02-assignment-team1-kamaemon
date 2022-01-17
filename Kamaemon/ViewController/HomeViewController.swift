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
        // Do any additional setup after loading the view.\
        let displayName = "Balqris"
        
        
        user.text = "Hello, " + displayName + " 👋"
        


        
    }
    
    
    
}
