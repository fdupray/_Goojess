//
//  CCString.swift
//  Goojess
//
//  Created by Frederick Dupray.
//  Copyright © 2017 Simon Blomqvist EHL. All rights reserved.
//

import Foundation

extension String {

    var whiteSpaceTrimmedString: String {
        
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}
