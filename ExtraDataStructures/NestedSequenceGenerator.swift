//
//  NestedSequenceGenerator.swift
//  ExtraDataStructures
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

public struct NestedSequenceGenerator<ElementType, Segment: SequenceType, SegmentGenerator: GeneratorType where Segment.Generator.Element == ElementType, SegmentGenerator.Element == Segment> : GeneratorType {
    public typealias Element = ElementType;

    private var segments: SegmentGenerator;
    private var segment:  SegmentGenerator.Element?;
    private var elements: Segment.Generator?;

    public init<T: SequenceType where T.Generator == SegmentGenerator>(container: T) {
        self.init(generator: container.generate());
    }
    
    public init(generator: SegmentGenerator) {
        self.segments = generator;
        self.segment  = self.segments.next();

        if segment != nil {
            elements = segment!.generate();
        }
    }
    
    public mutating func next() -> Element? {
        while true {
            if self.segment == nil {
                return nil;
            }
            
            if let elem = self.elements!.next() {
                return elem;
            }

            segment = self.segments.next();
            
            if segment != nil {
                elements = segment!.generate();
            }
        }
    }
}
