//
//  SegmentedArray.swift
//  ExtraDataStructures
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

public class SegmentedArray<Element, Aggregate: AggregateType where Aggregate.Element == Element> : SequenceType, CollectionType, MutableCollectionType, MutableSliceable, RangeReplaceableCollectionType {
    public typealias Segment   = AggregateArray<Element, Aggregate>;
    public typealias Generator = NestedSequenceGenerator<Element, Segment, IndexingGenerator<[Segment]>>;
    public typealias Index     = Int;
    public typealias SubSlice  = Swift.Array<Element>;
    public typealias Entry     = SegmentedArrayEntry<Element, Aggregate>;
    
    public required init() {
        self.maxSegmentSize = 128;
    }
    
    public init(maxSegmentSize: Int) {
        self.maxSegmentSize = maxSegmentSize;
    }
    
    public init<S : SequenceType where S.Generator.Element == Element>(_ newElements: S, maxSegmentSize: Int) {
        self.maxSegmentSize = maxSegmentSize;

        for element in newElements {
            append(element);
        }
    }
    
    public func traverse(@noescape block: (elements: AnyContiguousArray<Element>, aggregate: Aggregate) -> Void) {
        for segment in segments {
            block(elements: segment, aggregate: segment.aggregate);
        }
    }
    
    // MARK: Aggregates
    public func aggregateForSegment(segmentIndex: Int) -> Aggregate {
        return segments[segmentIndex].aggregate;
    }
    
    public var aggregates: [Aggregate] {
        get {
            return segments.map { $0.aggregate };
        }
    }

    // MARK: Entries
    public func entryForIndex(index: Int, load: Int) -> Entry {
        var i = index;
        var segmentIndex: Int = 0;
    
        for segment in segments {
            let c = segment.count;
        
            if i >= c {
                i -= c;
            }
            else {
                if load > 0 {
                    if (segment.count + load) > maxSegmentSize {
                        var newSegment = segment.splitAtIndex(i);
                        
                        segmentIndex++;
                        segments.insert(newSegment, atIndex: segmentIndex);
                        
                        if (newSegment.count > 0) && ((newSegment.count + load) > maxSegmentSize) {
                            newSegment = Segment();
                            segments.insert(newSegment, atIndex: segmentIndex);
                        }
                        
                        return Entry(segment: newSegment, segmentIndex: segmentIndex, index: 0);
                    }
                }
            
                return Entry(segment: segment, segmentIndex: segmentIndex, index: i);
            }
            
            segmentIndex++;
        }
    
        if let lastSegment = segments.last {
            return Entry(segment: lastSegment, segmentIndex: segmentIndex - 1, index: lastSegment.count);
        }
    
        let lastSegment = Segment();
        
        segments.append(lastSegment);
        return Entry(segment: lastSegment, segmentIndex: 0, index: 0);
    }

    public final func entryForIndex(index: Int) -> Entry {
        return entryForIndex(index, load: 0);
    }

    // MARK: Segments
    internal var segments = [Segment]();
    public let maxSegmentSize: Int;
    
    public var segmentCount: Int {
        get {
            return segments.count;
        }
    }

    public var segmentCapacity: Int {
        get {
            return segments.capacity;
        }
    }

    internal func segmentsForRange(range: Range<Int>, @noescape callback: (range: Range<Int>, elements: AnyContiguousArray<Element>, aggregate: Aggregate) -> Void) -> Void {
        var i = range.startIndex;
        var j = range.endIndex;
        var firstSegment = false;
        var lastSegment  = false;
        var inside       = false;
    
        for segment in segments {
            let c = segment.count;
        
            if !inside {
                if i >= c {
                    i -= c;
                }
                else {
                    firstSegment = true;
                    inside       = true;
                }
            }
            else {
                firstSegment = false;
            }

            if j >= c {
                j -= c;
            }
            else {
                lastSegment = true;
            }
            
            if inside {
                if firstSegment && lastSegment {
                    callback(range: i..<j, elements: segment, aggregate: segment.aggregate);
                    break;
                }
                else if firstSegment {
                    callback(range: i..<segment.count, elements: segment, aggregate: segment.aggregate);
                }
                else if lastSegment {
                    callback(range: 0..<j, elements: segment, aggregate: segment.aggregate);
                    break;
                }
                else {
                    callback(range: 0..<segment.count, elements: segment, aggregate: segment.aggregate);
                }
            }
        }
    }
    
    // MARK: SequenceType
    public func underestimateCount() -> Int {
        var c: Int = 0;
    
        for segment in segments {
            c += segment.underestimateCount();
        }
        
        return c;
    }
    
    public func generate() -> Generator {
        return NestedSequenceGenerator(container: segments);
    }

    // MARK: CollectionType
    public var isEmpty: Bool {
        get {
            return segments.isEmpty;
        }
    }
    
    public var count: Int {
        get {
            var c: Int = 0;

            for segment in segments {
                c += segment.count;
            }
            
            return c;
        }
    }

    public subscript (position: Int) -> Element {
        get {
            return entryForIndex(position).element;
        }
        
        set {
            var entry = entryForIndex(position);
            entry.element = newValue;
        }
    }
    
    public var startIndex: Int {
        get {
            return 0;
        }
    }
    
    public var endIndex: Int {
        get {
            return self.count;
        }
    }
    
    // MARK: Sliceable
    public subscript (bounds: Range<Index>) -> SubSlice {
        get {
            var b = [Element]();
            
            b.reserveCapacity(bounds.count);
            
            segmentsForRange(bounds) {
                (range: Range<Int>, elements: AnyContiguousArray<Element>, aggregate: Aggregate) in
                    if range.count == elements.count {
                        b.appendContentsOf(elements.elements);
                    }
                    else {
                        b.appendContentsOf(elements.elements[range]);
                    }
            }
            
            return b;
        }
        
        set {
            replaceRange(bounds, with: newValue);
        }
    }
    
    // MARK: ExtensibleCollectionType
    public func reserveCapacity(n: Int) {
        segments.reserveCapacity(max(1, n / maxSegmentSize));
    }
    
    public func append(element: Element) {
        if segments.isEmpty {
            let newSegment = Segment();
            
            newSegment.append(element);
            segments.append(newSegment);
            return;
        }
        
        let lastSegment = segments.last!;
        
        if lastSegment.count >= maxSegmentSize {
            let newSegment = Segment();
            
            newSegment.append(element);
            segments.append(newSegment);
            return;
        }
        
        lastSegment.append(element);
    }
    
    public func extend<S: SequenceType where S.Generator.Element == Element>(newElements: S) {
        if segments.isEmpty {
            segments.append(Segment());
        }

        var lastSegment = segments.last!;
        
        for element in newElements {
            if lastSegment.count >= maxSegmentSize {
                lastSegment = Segment();
                segments.append(lastSegment);
            }
            
            lastSegment.append(element);
        }
    }

    // MARK: RangeReplaceableCollectionType
    public func removeAtIndex(i: Int) -> Element {
        let entry = entryForIndex(i);
        return entry.segment.removeAtIndex(entry.index);
    }
    
    public func insert(newElement: Element, atIndex i: Int) {
        let entry = entryForIndex(i, load: 1);
        entry.segment.insert(newElement, atIndex: entry.index);
    }

    public func removeRange(range: Range<Int>) {
        var i = range.startIndex;
        var j = range.endIndex;
        var firstSegment = false;
        var lastSegment  = false;
        var inside       = false;
    
        segments = segments.filter { (segment: Segment) -> Bool in
            if lastSegment {
                return true;
            }
        
            let c = segment.count;
        
            if !inside {
                if i >= c {
                    i -= c;
                }
                else {
                    firstSegment = true;
                    inside       = true;
                }
            }
            else {
                firstSegment = false;
            }

            if j >= c {
                j -= c;
            }
            else {
                lastSegment = true;
            }
            
            if inside {
                var range: Range<Int>;
            
                if firstSegment && lastSegment {
                    range = i..<j;
                }
                else if firstSegment {
                    range = i..<segment.count;
                }
                else if lastSegment {
                    range = 0..<j;
                }
                else {
                    return false;
                }
                
                segment.removeRange(range);
            }
            
            return true;
        }
    }
    
    public func replaceRange<C: CollectionType where C.Generator.Element == Generator.Element>(subRange: Range<Int>, with newElements: C) {
        removeRange(subRange);
        splice(newElements, atIndex: subRange.startIndex);
    }
    
    public func splice<C: CollectionType where C.Generator.Element == Generator.Element>(newElements: C, atIndex i: Int) -> Void {
        var entry = entryForIndex(i, load: max(1, newElements.underestimateCount()));
        
        for element in newElements {
            if entry.index >= maxSegmentSize {
                entry.segmentIndex++;
                entry.segment = Segment();
                entry.index = 0;
                segments.insert(entry.segment, atIndex: entry.segmentIndex);
            }
            
            entry.segment.insert(element, atIndex: entry.index);
            entry.index++;
        }
    }
    
    public func removeAll() {
        segments.removeAll();
    }

    public func removeAll(keepCapacity keepCapacity: Bool) {
        segments.removeAll(keepCapacity: keepCapacity);
    }

    // MARK: CustomStringConvertible
    public var description: String {
        get {
            if segments.count == 0 {
                return "[]";
            }
            
            var desc = "[";
            var index = 0;
            
            for segment in segments {
                for element in segment.elements {
                    if index > 0 {
                        desc += ", ";
                    }
                    
                    print(element, toStream: &desc);
                    index++;
                }
            }
            
            desc += "]";
            return desc;
        }
    }
}
