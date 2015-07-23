//
//  AggregateType.swift
//  ExtraDataStructures
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

public protocol AggregateType {
    typealias Element;

    init();
    init(copy: Self);
    
    mutating func addElement(element: Int, inArray: AnyContiguousArray<Element>);
    mutating func addElements(elements: Range<Int>, inArray: AnyContiguousArray<Element>);
    mutating func removeElement(element: Int, fromArray: AnyContiguousArray<Element>);
    mutating func removeElements(elements: Range<Int>, fromArray: AnyContiguousArray<Element>);
}
