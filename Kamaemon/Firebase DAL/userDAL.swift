//
//  DAL.swift
//  Kamaemon
//
//  Created by Jun Hong on 21/1/22.
//

import Foundation
import FirebaseAuth
import Firebase

class userDAL{
    //var ref: DatabaseReference!
    var ref : DatabaseReference! = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
    //check if user is a volunteer
    func checkVolunteer(UserUID:String) -> Bool{
        var volunteer = false
        ref.child("users").child(UserUID).observeSingleEvent(of: .value) { DataSnapshot in
            let value = DataSnapshot.value as? NSDictionary
            let type = value?["UserType"] as? String
            if(type == "Volunteer"){
                volunteer = true
            }
        }
        
        return volunteer
     
    }
    
    
    //check if user is a user
    func checkUser(UserUID:String) -> Bool{
        var user = false
        ref.child("users").child(UserUID).observeSingleEvent(of: .value) { DataSnapshot in
            let value = DataSnapshot.value as? NSDictionary
            let type = value?["UserType"] as? String
            if(type == "Volunteer"){
                user = true
            }
        }
        
        return user
     
    }
    
    
    func createNewUser(newUser : User) {
        
        
        ref.child("users").child(newUser.UID).setValue(["userUID" :(newUser.UID), "userType" : newUser.UserType, "Name" : newUser.n, "Gender" : newUser.Gender, "PhoneNumber" : newUser.PhoneNumber, "BirthDate" : newUser.BirthDate, "ProfilePicURL" : newUser.profilepicurl, "IsNewUser" : newUser.isNewUser])
        
        
    }
    
    
    
}
