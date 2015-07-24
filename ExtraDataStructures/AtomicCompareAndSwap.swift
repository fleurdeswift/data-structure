//
//  AtomicCompareAndSwap.swift
//  ExtraDataStructures
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Foundation

#if arch(arm64) || arch(x86_64)
private func reinterpretCastToInt(f: CGFloat) -> Int64 {
    return unsafeBitCast(f.native, Int64.self);
}
#endif

#if arch(arm) || arch(i386)
private func reinterpretCastToInt(f: CGFloat) -> Int32 {
    return unsafeBitCast(f.native, Int32.self);
}
#endif

#if arch(arm64) || arch(x86_64)
private func OSAtomicCompareAndSwapCGFloat(o: Int64, _ n: Int64, _ p: UnsafeMutablePointer<CGFloat>) -> Bool {
    return OSAtomicCompareAndSwap64(o, n, UnsafeMutablePointer<Int64>(p));
}
#endif

#if arch(arm) || arch(i386)
private func OSAtomicCompareAndSwapCGFloat(o: Int32, _ n: Int32, _ p: UnsafeMutablePointer<CGFloat>) -> Bool {
    return OSAtomicCompareAndSwap32(o, n, UnsafeMutablePointer<Int32>(p));
}
#endif

private func OSAtomicCompareAndSwap32(o: Int32, _ n: Int32, _ p: UnsafeMutablePointer<UInt32>) -> Bool {
    return OSAtomicCompareAndSwap32(o, n, UnsafeMutablePointer<Int32>(p));
}

private func OSAtomicCompareAndSwap32(o: Int32, _ n: Int32, _ p: UnsafeMutablePointer<Float>) -> Bool {
    return OSAtomicCompareAndSwap32(o, n, UnsafeMutablePointer<Int32>(p));
}

private func OSAtomicCompareAndSwap64(o: Int64, _ n: Int64, _ p: UnsafeMutablePointer<UInt64>) -> Bool {
    return OSAtomicCompareAndSwap64(o, n, UnsafeMutablePointer<Int64>(p));
}

private func OSAtomicCompareAndSwap64(o: Int64, _ n: Int64, _ p: UnsafeMutablePointer<Double>) -> Bool {
    return OSAtomicCompareAndSwap64(o, n, UnsafeMutablePointer<Int64>(p));
}

public func AtomicCompareAndSwap(o: CGFloat, _ n: CGFloat, inout _ p: CGFloat) -> Bool {
    return OSAtomicCompareAndSwapCGFloat(reinterpretCastToInt(o), reinterpretCastToInt(n), &p);
}

public func AtomicCompareAndSwap(o: Float, _ n: Float, inout _ p: Float) -> Bool {
    return OSAtomicCompareAndSwap32(unsafeBitCast(o, Int32.self), unsafeBitCast(o, Int32.self), &p);
}

public func AtomicCompareAndSwap(o: Double, _ n: Double, inout _ p: Double) -> Bool {
    return OSAtomicCompareAndSwap64(unsafeBitCast(o, Int64.self), unsafeBitCast(o, Int64.self), &p);
}

public func AtomicCompareAndSwap(o: Int32, _ n: Int32, inout _ p: Int32) -> Bool {
    return OSAtomicCompareAndSwap32(o, n, &p);
}

public func AtomicCompareAndSwap(o: UInt32, _ n: UInt32, inout _ p: UInt32) -> Bool {
    return OSAtomicCompareAndSwap32(unsafeBitCast(o, Int32.self), unsafeBitCast(n, Int32.self), &p);
}

public func AtomicCompareAndSwap(o: Int64, _ n: Int64, inout _ p: Int64) -> Bool {
    return OSAtomicCompareAndSwap64(o, n, &p);
}

public func AtomicCompareAndSwap(o: UInt64, _ n: UInt64, inout _ p: UInt64) -> Bool {
    return OSAtomicCompareAndSwap64(unsafeBitCast(o, Int64.self), unsafeBitCast(n, Int64.self), &p);
}
