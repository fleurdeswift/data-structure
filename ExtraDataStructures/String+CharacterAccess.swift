//
//  String+CharacterAccess.swift
//  ExtraDataStructures
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Foundation

public extension String {
    public subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }

    public subscript (i: Int) -> String {
        return String(self[i] as Character)
    }

    public subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: startIndex.advancedBy(r.startIndex), end: startIndex.advancedBy(r.endIndex)))
    }

    public func suffix(start start: Int) -> String {
        return substringWithRange(Range(start: startIndex.advancedBy(start), end: endIndex))
    }
}
