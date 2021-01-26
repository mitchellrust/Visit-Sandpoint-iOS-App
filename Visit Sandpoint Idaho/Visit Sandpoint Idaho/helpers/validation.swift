//
//  validation.swift
//  Visit Sandpoint Idaho
//
//  Created by Mitchell Rust on 11/19/20.
//

// Helper functions for validating textfields and
// other user input.

import Foundation

class Validation {
 
    // Trim leading and trailing whitespace
    static func trimWhitespace(str: String) -> String {
        return str.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
}
