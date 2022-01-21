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
    var PhoneNumber:String = ""
    var BirthDate:Date = Date()
    var Gender:String = ""
    var n:String = ""
    var profilepicurl:String = ""
    
    init() {
    }
    init(userUID:String, userCategory:String, name:String){
        self.UID = userUID
        self.Category = userCategory
        self.n = name
    }
    
    
    
}
