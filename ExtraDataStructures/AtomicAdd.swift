//
//  AtomicAdd.swift
//  ExtraDataStructures
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

public func AtomicAdd(inout left: CGFloat, _ right: CGFloat) -> CGFloat {
    while true {
        let initialValue = left;
        let newValue     = initialValue + right;
        
        if (AtomicCompareAndSwap(initialValue, newValue, &left)) {
            return newValue;
        }
    }
}

public func AtomicAdd(inout left: Float, _ right: Float) -> Float {
    while true {
        let initialValue = left;
        let newValue     = initialValue + right;
        
        if (AtomicCompareAndSwap(initialValue, newValue, &left)) {
            return newValue;
        }
    }
}

public func AtomicAdd(inout left: Double, _ right: Double) -> Double {
    while true {
        let initialValue = left;
        let newValue     = initialValue + right;
        
        if (AtomicCompareAndSwap(initialValue, newValue, &left)) {
            return newValue;
        }
    }
}
