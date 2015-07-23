//
//  AggregateSum.swift
//  ExtraDataStructures
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

public func sum<S: SequenceType where S.Generator.Element: Additionable, S.Generator.Element: Zeroable>(elements: S) -> S.Generator.Element {
    var s = S.Generator.Element.zero();
    
    for element in elements {
        s += element;
    }
    
    return s;
}

public func sum<S: SequenceType, DataType where DataType: Additionable, DataType: Zeroable>(elements: S, @noescape block: (element: S.Generator.Element) -> DataType) -> DataType {
    var s = DataType.zero();
    
    for element in elements {
        s += block(element: element);
    }
    
    return s;
}
