//
//  event.swift
//  Kamaemon
//
//  Created by mad2 on 19/1/22.
//

import Foundation
class Event {
    var ID:Int
    var Desc:String
    var Hours:Int
    var Location:String
    var UserID:String
    var VolunteerID:String
    
    init(id:Int,desc:String,hours:Int,location:String,uID:String,vID:String){
        self.ID = id
        self.Desc = desc
        self.Hours = hours
        self.Location = location
        self.UserID = uID
        self.VolunteerID = vID
    }
}
