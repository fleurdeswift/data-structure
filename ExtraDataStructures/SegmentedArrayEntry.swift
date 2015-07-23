//
//  SegmentedArrayEntry.swift
//  ExtraDataStructures
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

public struct SegmentedArrayEntry<Element, Aggregate: AggregateType where Aggregate.Element == Element> {
    public typealias Segment = AggregateArray<Element, Aggregate>;
   
    internal(set) var segment: Segment;
    internal(set) var segmentIndex: Int;
    internal(set) public var index: Int;
   
    public init(segment: Segment, segmentIndex: Int, index: Int) {
        self.segment = segment;
        self.segmentIndex = segmentIndex;
        self.index = index;
    }
    
    public var aggregate: Aggregate {
        get {
            return segment.aggregate;
        }
    }
    
    public var siblings: AnyContiguousArray<Element> {
        get {
            return segment;
        }
    }
    
    public var element: Element {
        get {
            return segment.elements[index];
        }
        
        set {
            segment[index] = newValue;
        }
    }
}
