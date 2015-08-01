//
//  Reference.swift
//  ExtraDataStructures
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

public protocol ReferenceType {
    typealias Element;

    var value: Element? { get };
    var isValid: Bool { get };
}

public class BaseReference<T: AnyObject> : ReferenceType {
    public typealias Element = T;

    public var value: Element? {
        get {
            return nil;
        }
    }

    public var isValid: Bool {
        get {
            return false;
        }
    }
}

public class WeakReference<T: AnyObject> : BaseReference<T> {
    private weak var val: Element?;
    
    public init(_ r: Element) {
        val = r;
    }
    
    public override var value: Element? {
        get {
            return val;
        }
    }
    
    public override var isValid: Bool {
        get {
            return value != nil;
        }
    }
}

public class StrongReference<T: AnyObject> : BaseReference<T> {
    private let val: Element;
    
    public init(_ r: Element) {
        val = r;
    }
    
    public override var value: Element? {
        get {
            return val;
        }
    }
    
    public override var isValid: Bool {
        get {
            return true;
        }
    }
}

public class ReferenceArrayGenerator<Element, Reference: ReferenceType, Sequence: SequenceType where Reference.Element == Element, Sequence.Generator.Element == Reference> : GeneratorType {
    private var gen: Sequence.Generator;

    public init(_ other: Sequence.Generator) {
        gen = other;
    }
    
    public func next() -> Element? {
        while true {
            if let n = gen.next() {
                if let v = n.value {
                    return v;
                }
            }
            else {
                break;
            }
        }
        
        return nil;
    }
}

public struct ReferenceArray<T: AnyObject> : SequenceType {
    public typealias Element = T;
    public typealias Generator = ReferenceArrayGenerator<T, BaseReference<T>, Array<BaseReference<T>>>;

    private var entries = [BaseReference<T>]();

    public init() {
    }
    
    public mutating func add(element: T, strong: Bool) -> Void {
        if strong {
            entries.append(StrongReference(element));
        }
        else {
            entries.append(WeakReference(element));
        }
    }

    public mutating func remove(element: T) -> Void {
        entries = entries.filter { $0.value !== element && $0.isValid };
    }

    // MARK: SequenceType
    public func generate() -> Generator {
        return Generator(entries.generate());
    }

    public func underestimateCount() -> Int {
        return entries.underestimateCount();
    }
}

public struct ReferenceDictionary<Key: Hashable, T: AnyObject> {
    public typealias Element = T;

    private var entries = [Key: BaseReference<T>]();

    public init() {
    }
    
    public subscript(key: Key) -> Element? {
        get {
            let ref = entries[key];

            if let ref = ref {
                return ref.value;
            }
            
            return nil;
        }
    
        set {
            if let value = newValue {
                entries[key] = StrongReference<T>(value);
            }
            else {
                entries.removeValueForKey(key);
            }
        }
    }
    
    public mutating func set(key: Key, value: T, strong: Bool) {
        if strong {
            entries[key] = StrongReference(value);
        }
        else {
            entries[key] = WeakReference(value);
        }
    }
    
    public mutating func removeAll() {
        entries.removeAll();
    }
}

public struct ReferenceWeakDictionary<Key: Hashable, T: AnyObject> {
    public typealias Element = T;

    private var entries = [Key: WeakReference<T>]();

    public init() {
    }
    
    public subscript(key: Key) -> Element? {
        get {
            let ref = entries[key];

            if let ref = ref {
                return ref.value;
            }
            
            return nil;
        }
    
        set {
            if let value = newValue {
                entries[key] = WeakReference<T>(value);
            }
            else {
                entries.removeValueForKey(key);
            }
        }
    }
    
    public mutating func removeAll() {
        entries.removeAll();
    }
}
