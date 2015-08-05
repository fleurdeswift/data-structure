//
//  Number+Hex.swift
//  ExtraDataStructures
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

public extension UInt8 {
    public var asHexString: String {
        get {
            var s = String(self, radix: 16, uppercase: false);

            while s.characters.count < 2 {
                s = "0" + s;
            }
        
            return s;
        }
    }
}

public extension UInt32 {
    public var asHexString: String {
        get {
            var s = String(self, radix: 16, uppercase: false);

            while s.characters.count < 8 {
                s = "0" + s;
            }
        
            return s;
        }
    }
}