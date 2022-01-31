//
//  UserViewEventDetailsViewController.swift
//  Kamaemon
//
//  Created by Jordan Choi on 31/1/22.
//

import Foundation
import UIKit

class UserViewEventDetailsViewController : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // disable navigation bar
        navigationController?.hidesBarsOnSwipe = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        // disable navigation bar
        navigationController?.hidesBarsOnSwipe = false
    }
    
}
