//
//  NSTimeInterval.swift
//  ExtraDataStructures
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Foundation

public extension NSTimeInterval {
    public var secondsAsString: String {
        get {
            if (self < 60) {
                return "\(Int(self))s";
            }
            else if (self < (60 * 60)) {
                let minutes = floor(self / 60);
                let seconds = Int(self - (minutes * 60));

                return "\(Int(minutes))m \(seconds)s";
            }
            else {
                let hours   = floor(self / (60 * 60));
                let minutes = Int((self / 60) - (hours * 60));

                return "\(Int(hours))h \(minutes)m";
            }
        }
    }

    public static func equalsWithAccuracy(t1: NSTimeInterval?, _ t2: NSTimeInterval?, accuracy: NSTimeInterval) -> Bool {
        if t1 == nil && t2 == nil {
            return true;
        }

        if t1 == nil || t2 == nil {
            return false;
        }

        return abs(t1! - t2!) < accuracy;
    }
}
