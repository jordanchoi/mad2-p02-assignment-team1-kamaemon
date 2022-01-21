//
//  user.swift
//  Kamaemon
//
//  Created by Jun Hong on 17/1/22.
//

import Foundation


class User {
    var UID:String = ""
    var Category:String = ""
    //var PhoneN
    var n:String = ""
    
    init() {
    }
    init(userUID:String, userCategory:String, name:String){
        self.UID = userUID
        self.Category = userCategory
        self.n = name
    }
    
    
    
}
