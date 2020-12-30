//
//  RapRoom.swift
//  spillb
//
//  Created by Projects on 9/15/20.
//  Copyright © 2020 Jen. All rights reserved.
//

import UIKit
import VoxeetSDK

class RapRoom {
    
    var title: String    // Name of the room
    var participants: [String] = []  // All participants
    var numParticipantsAllowed: Int    // Number of participants
    var isAvailable : Bool
    //var currentRapper : String
    
    init(title: String, participants: [String], numParticipantsAllowed : Int, isAvailable: Bool) {
        self.title = title
        self.numParticipantsAllowed = numParticipantsAllowed
        self.participants = participants
        self.isAvailable = isAvailable
        //self.currentRapper = currentRapper
    }
}
