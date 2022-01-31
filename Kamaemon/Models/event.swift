//
//  event.swift
//  Kamaemon
//
//  Created by mad2 on 19/1/22.
//

import Foundation

class Event {
    var ID:String = ""
    var Desc:String = ""
    var Hours:Int = 0
    var Location:String = ""
    var UserID:String = ""
    var VolunteerID:String = ""
    var VolunteerName:String? = ""
    var Name:String = ""
    var Status:String = ""
    var Category:String = ""
    var EventDate:Date = Date()
    var volunteer:User? = nil
    
    init(){}
    
    init(id:String,desc:String,hours:Int,location:String,uID:String,vID:String,name:String,stat:String,cat:String, date:Date){
        self.ID = id
        self.Desc = desc
        self.Hours = hours
        self.Location = location
        self.UserID = uID
        self.VolunteerID = vID
        self.Name = name
        self.Status = stat
        self.Category = cat
        self.EventDate = date
    }
    
    init(desc:String,hours:Int,location:String,uID:String,vID:String,name:String,stat:String,cat:String, date:Date){
        self.Desc = desc
        self.Hours = hours
        self.Location = location
        self.UserID = uID
        self.VolunteerID = vID
        self.Name = name
        self.Status = stat
        self.Category = cat
        self.EventDate = date
    }
    // Jordan added constructor for retrieval of events from firebase
    init(desc:String,hours:Int,location:String,uID:String,vID:String, vName:String, name:String,stat:String,cat:String, date:Date){
        self.Desc = desc
        self.Hours = hours
        self.Location = location
        self.UserID = uID
        self.VolunteerID = vID
        self.VolunteerName = vName
        self.Name = name
        self.Status = stat
        self.Category = cat
        self.EventDate = date
    }
}
