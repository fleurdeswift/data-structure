//
//  ArithmeticProtocols.swift
//  ExtraDataStructures
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

public protocol Additionable {
    func + (left: Self, right: Self) -> Self;
    func += (inout left: Self, right: Self);
}

public protocol Zeroable {
    static func zero() -> Self;
}

extension UInt : Additionable, Zeroable {
    public static func zero() -> UInt {
        return 0;
    }
}

extension UInt8 : Additionable, Zeroable {
    public static func zero() -> UInt8 {
        return 0;
    }
}

extension UInt16 : Additionable, Zeroable {
    public static func zero() -> UInt16 {
        return 0;
    }
}

extension UInt32 : Additionable, Zeroable {
    public static func zero() -> UInt32 {
        return 0;
    }
}

extension UInt64 : Additionable, Zeroable {
    public static func zero() -> UInt64 {
        return 0;
    }
}

extension Int : Additionable, Zeroable {
    public static func zero() -> Int {
        return 0;
    }
}

extension Int8 : Additionable, Zeroable {
    public static func zero() -> Int8 {
        return 0;
    }
}

extension Int16 : Additionable, Zeroable {
    public static func zero() -> Int16 {
        return 0;
    }
}

extension Int32 : Additionable, Zeroable {
    public static func zero() -> Int32 {
        return 0;
    }
}

extension Int64 : Additionable, Zeroable {
    public static func zero() -> Int64 {
        return 0;
    }
}

extension Float : Additionable, Zeroable {
    public static func zero() -> Float {
        return 0;
    }
}

extension Float80 : Additionable, Zeroable {
    public static func zero() -> Float80 {
        return 0;
    }
}

extension Double : Additionable, Zeroable {
    public static func zero() -> Double {
        return 0;
    }
}
