//
//  Database.swift
//  Keep Track
//
//  Created by Christopher Hannah on 27/02/2017.
//  Copyright © 2017 Christopher Hannah. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit

class Item: Object {
    
    dynamic var key = ""
    dynamic var name = ""
    dynamic var notes = ""
    dynamic var image: NSData?
    dynamic var dateAdded = NSDate()
    
    override static func primaryKey() -> String? {
        return "key"
    }

}

class Collection: Object {
    
    dynamic var key = ""
    dynamic var name = ""
    let items = List<Item>()
    
    override static func primaryKey() -> String? {
        return "key"
    }
    
}
