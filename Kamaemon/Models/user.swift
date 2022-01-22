//
//  user.swift
//  Kamaemon
//
//  Created by Jun Hong on 17/1/22.
//

import Foundation


class User {
    var UID:String = ""
    var UserType:String = ""
    var PhoneNumber:String = ""
    var BirthDate:Date = Date()
    var Gender:String = ""
    var n:String = ""
    var profilepicurl:String = ""
    var isNewUser:Int = 0
    //add NRIC and selfie under a different path
    
    init() {
    }
    init(userUID:String, userType:String, name:String){
        self.UID = userUID
        self.UserType = userType
        self.n = name
    }
    
    init(userUID:String, userType:String, name:String, gender:String, phonenumber:String, birthdate:Date, pfpurl:String, isnewuser:Int){
        
        self.UID = userUID
        self.UserType = userType
        self.n = name
        self.Gender = gender
        self.PhoneNumber = phonenumber
        self.BirthDate = birthdate
        self.profilepicurl = pfpurl
        self.isNewUser = isnewuser

        
    }
    
}
