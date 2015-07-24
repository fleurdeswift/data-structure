//
//  AtomicMax.swift
//  ExtraDataStructures
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Foundation

public func AtomicMax(inout left: CGFloat, _ right: CGFloat) -> CGFloat {
    while true {
        let initialValue = left;
        let newValue     = max(initialValue, right);
        
        if (AtomicCompareAndSwap(initialValue, newValue, &left)) {
            return newValue;
        }
    }
}

public func AtomicMax(inout left: Float, _ right: Float) -> Float {
    while true {
        let initialValue = left;
        let newValue     = max(initialValue, right);
        
        if (AtomicCompareAndSwap(initialValue, newValue, &left)) {
            return newValue;
        }
    }
}

public func AtomicMax(inout left: Double, _ right: Double) -> Double {
    while true {
        let initialValue = left;
        let newValue     = max(initialValue, right);
        
        if (AtomicCompareAndSwap(initialValue, newValue, &left)) {
            return newValue;
        }
    }
}
