//
//  Extensions.swift
//  Keep Track
//
//  Created by Christopher Hannah on 23/04/2017.
//  Copyright © 2017 Christopher Hannah. All rights reserved.
//

import Foundation

extension String {
    func capitalizingFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
