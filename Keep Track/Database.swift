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
    dynamic var name = ""
    dynamic var notes = ""
    dynamic var image: NSData?
    dynamic var dateAdded = NSDate()
}

class Collection: Object {
    dynamic var name = ""
    dynamic var image: NSData?
    let items = List<Item>()
}
