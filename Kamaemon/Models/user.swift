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
    var n:String = ""
    
    
    init(userUID:String, userCategory:String, name:String){
        self.UID = userUID
        self.Category = userCategory
        self.n = name
    }
    
    
    
}
