//
//  SharedPrefs.swift
//  Kamaemon
//
//  Created by mad2 on 31/1/22.
//

import Foundation
class SharedPrefs{
    var hasLoggedIn : Bool = false
    var isNew : Bool = false
    var isVerified : Bool = false
    var userID : String = ""
    
    init(login:Bool, new:Bool, verified:Bool ,id:String){
        self.hasLoggedIn = login
        self.isNew = new
        self.isVerified = verified
        self.userID = id
    }
}
