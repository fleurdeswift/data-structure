//
//  Array+Move.swift
//  ExtraDataStructures
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

public extension Array {
    public mutating func moveFromIndex(from: Int, to: Int) {
        if from == to {
            return;
        }

        let fromData = self[from];

        if from < to {
            self.insert(fromData, atIndex: to);
            self.removeAtIndex(from);
        }
        else {
            self.insert(fromData, atIndex: to);
            self.removeAtIndex(from + 1);
        }
    }
}
