//
//  AnyContiguousArray.swift
//  ExtraDataStructures
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

public class AnyContiguousArray<Element> : SequenceType, CollectionType, MutableSliceable, RangeReplaceableCollectionType {
    public typealias Generator   = Swift.ContiguousArray.Generator;
    public typealias Index       = Swift.ContiguousArray.Index;
    public typealias SubSequence = Swift.ContiguousArray.SubSequence;
    
    internal(set) public var elements: ContiguousArray<Element>;

    public required init() {
        elements = ContiguousArray<Element>();
    }

    public init<S : SequenceType where S.Generator.Element == Element>(_ newElements: S) {
        elements = ContiguousArray<Element>(newElements);
    }
    
    // MARK: SequenceType
    public final func underestimateCount() -> Int {
        return elements.underestimateCount();
    }
    
    public final func generate() -> Generator {
        return elements.generate();
    }
    
    // MARK: CollectionType
    public subscript(index: Int) -> Element {
        get {
            return elements[index];
        }
        
        set {
            elements[index] = newValue;
        }
    }
    
    public final var count: Int {
        get {
            return elements.count;
        }
    }
    
    public final var isEmpty: Bool {
        get {
            return elements.isEmpty;
        }
    }
    
    public final var startIndex: Int {
        get {
            return 0;
        }
    }
    
    public final var endIndex: Int {
        get {
            return elements.endIndex;
        }
    }

    // MARK: Sliceable
    public final subscript(index: Range<Int>) -> SubSequence {
        get {
            return elements[index];
        }
        
        set {
            replaceRange(index, with: newValue);
        }
    }
    
    // MARK: ExtensibleCollectionType
    public func reserveCapacity(n: Int) {
        elements.reserveCapacity(n);
    }

    public func append(x: Element) {
        elements.append(x);
    }

    public func appendContentsOf<S : SequenceType where S.Generator.Element == Generator.Element>(newElements: S) {
        elements.appendContentsOf(newElements);
    }

    // MARK: RangeReplaceableCollectionType
    public func insertContentsOf<S : CollectionType where S.Generator.Element == Generator.Element>(newElements: S, at i: Int) {
        elements.insertContentsOf(newElements, at: i);
    }

    public func insert(newElement: Element, atIndex i: Int) {
        elements.insert(newElement, atIndex: i);
    }

    public func removeAtIndex(i: Int) -> Element {
        return elements.removeAtIndex(i);
    }

    public func removeRange(subRange: Range<Int>) {
        elements.removeRange(subRange);
    }

    public func replaceRange<C : CollectionType where C.Generator.Element == Generator.Element>(subRange: Range<Int>, with newElements: C) {
        elements.replaceRange(subRange, with: newElements);
    }

    public func removeAll(keepCapacity keepCapacity: Bool) {
        elements.removeAll(keepCapacity: keepCapacity);
    }
}
