//
//  AggregateArray.swift
//  ExtraDataStructures
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

public class AggregateArray<Element, Aggregate: AggregateType where Aggregate.Element == Element> : AnyContiguousArray<Element> {
    public var aggregate: Aggregate;
    
    public required init() {
        aggregate = Aggregate();
        super.init();
    }
    
    public override init<S : SequenceType where S.Generator.Element == Element>(_ newElements: S) {
        aggregate = Aggregate();
        super.init(newElements);
        aggregate.addElements(0..<elements.count, inArray: self);
    }

    public init<S : SequenceType where S.Generator.Element == Element>(_ newElements: S, aggregate: Aggregate) {
        self.aggregate = Aggregate(copy: aggregate);
        super.init(newElements);
    }
    
    public init(copy: AggregateArray) {
        aggregate = Aggregate(copy: copy.aggregate);
        super.init(copy.elements);
    }
    
    public final func split() -> AggregateArray<Element, Aggregate> {
        return splitAtIndex(elements.count / 2);
    }

    public final func splitAtIndex(index: Int) -> AggregateArray<Element, Aggregate> {
        let s     = self.dynamicType.init();
        let count = elements.count;
        
        if index == count {
            return s;
        }
        else if index == 0 {
            s.elements  = elements;
            s.aggregate = aggregate;
            aggregate = Aggregate();
            elements.removeAll(keepCapacity: true);
            return s;
        }
        
        let right  = index..<count;

        s.elements.splice(self.elements[right], atIndex: 0)
        s.aggregate.addElements(0..<right.count, inArray: self);
        removeRange(right);
        return s;
    }
    
    // MARK: CollectionType
    public final override subscript(index: Int) -> Element {
        get {
            return elements[index];
        }
        
        set {
            aggregate.removeElement(index, fromArray: self);
            elements[index] = newValue;
            aggregate.addElement(index, inArray: self);
        }
    }
    
    // MARK: ExtensibleCollectionType
    public override func append(element: Element) {
        elements.append(element);
        aggregate.addElement(elements.count - 1, inArray: self);
    }

    public override func extend<S : SequenceType where S.Generator.Element == Generator.Element>(newElements: S) {
        let start = elements.count;
        elements.extend(newElements);
        aggregate.addElements(start..<elements.count, inArray: self);
    }
    
    // MARK: RangeReplaceableCollectionType
    public  override func splice<S : CollectionType where S.Generator.Element == Generator.Element>(newElements: S, atIndex i: Int) {
        let count = elements.count;
        elements.splice(newElements, atIndex: i);
        let newCount = elements.count;
        aggregate.addElements(i..<(i + newCount - count), inArray: self);
    }

    public override func removeAtIndex(i: Int) -> Element {
        self.aggregate.removeElement(i, fromArray: self);
        return self.elements.removeAtIndex(i);
    }
    
    public override func removeRange(range: Range<Int>) {
        self.aggregate.removeElements(range, fromArray: self);
        self.elements.removeRange(range);
    }
    
    public override func insert(newElement: Element, atIndex i: Int) {
        self.elements.insert(newElement, atIndex: i);
        self.aggregate.addElement(i, inArray: self);
    }

    public override func replaceRange<C : CollectionType where C.Generator.Element == Generator.Element>(subRange: Range<Int>, with newElements: C) {
        removeRange(subRange);
        splice(newElements, atIndex: subRange.startIndex);
    }

    public override func removeAll(keepCapacity keepCapacity: Bool) {
        elements.removeAll(keepCapacity: keepCapacity);
        aggregate = Aggregate();
    }
}