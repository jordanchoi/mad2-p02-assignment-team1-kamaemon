//
//  Message.swift
//  Kamaemon
//
//  Created by Jun Hong on 19/1/22.
//

import Foundation
class Message {
    var Message:String = ""
    var MessageTo:String = ""
    var MessageFrom:String = ""
    
    init() {
    }
    init(Messageto:String, Messagefrom:String, m:String){
        self.MessageTo = Messageto
        self.MessageFrom = Messagefrom
        self.Message = m
    }
}
