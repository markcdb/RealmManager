//
//  Message.swift
//  RealmManagerExample
//
//  Created by Mark Christian Buot on 03/09/2017.
//  Copyright © 2017 Morph. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers
class Message: Object {
    dynamic var content: String = ""
    
    override static func primaryKey() -> String? {
        return "content"
    }
}
