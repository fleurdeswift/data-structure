//
//  Array+Reference.swift
//  ExtraDataStructures
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

public extension Array where Element : AnyObject {
    public func indexOf(ref: Element) -> Index? {
        return self.indexOf({ return $0 === ref });
    }
}
