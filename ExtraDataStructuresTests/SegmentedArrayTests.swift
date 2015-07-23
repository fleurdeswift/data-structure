//
//  ExtraDataStructuresTests.swift
//  ExtraDataStructuresTests
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import XCTest
@testable import ExtraDataStructures

public struct StringAggregate : AggregateType {
    public typealias Element = String;
    
    public var characterCount: Int = 0;
    
    public init() {
    }
    
    public init(copy: StringAggregate) {
        self.characterCount = copy.characterCount;
    }
    
    public mutating func addElement(element: Int, inArray: AnyContiguousArray<Element>) {
        characterCount += inArray[element].characters.count;
    }
    
    public mutating func addElements(elements: Range<Int>, inArray: AnyContiguousArray<Element>) {
        for element in inArray[elements] {
            characterCount += element.characters.count;
        }
    }
    
    public mutating func removeElement(element: Int, fromArray: AnyContiguousArray<Element>) {
        characterCount -= fromArray[element].characters.count;
    }

    public mutating func removeElements(elements: Range<Int>, fromArray: AnyContiguousArray<Element>) {
        for element in fromArray.elements[elements] {
            characterCount -= element.characters.count;
        }
    }
};

class SegmentedArrayTests: XCTestCase {
    func testGeneratorEmpty() {
        let b = SegmentedArray<String, StringAggregate>(maxSegmentSize: 8);
        var g = b.generate();
        
        XCTAssertEqual(b.segmentCount, 0);
        XCTAssertNil(g.next());
    }

    func testGenerator() {
        let b = SegmentedArray<String, StringAggregate>(maxSegmentSize: 8);
        
        b.append("1");
        XCTAssertEqual(b.segmentCount, 1);
        XCTAssertEqual(b.count, 1);
        XCTAssertEqual(b.maxSegmentSize, 8);
        b.append("2");
        b.append("3");
        b.append("4");

        do {
            var g = b.generate();
            XCTAssert(g.next() == "1");
            XCTAssert(g.next() == "2");
            XCTAssert(g.next() == "3");
            XCTAssert(g.next() == "4");
        }

        b.append("5");
        b.append("6");
        b.append("7");
        b.append("8");
        XCTAssertEqual(b.segmentCount, 1);
        XCTAssertEqual(b.count, 8);
        b.append("9");
        XCTAssertEqual(b.count, 9);
        XCTAssertEqual(b.segmentCount, 2);
        XCTAssertEqual(b.aggregateForSegment(0).characterCount, 8);
        XCTAssertEqual(b.aggregateForSegment(1).characterCount, 1);

        do {
            var g = b.generate();
            XCTAssert(g.next() == "1");
            XCTAssert(g.next() == "2");
            XCTAssert(g.next() == "3");
            XCTAssert(g.next() == "4");
            XCTAssert(g.next() == "5");
            XCTAssert(g.next() == "6");
            XCTAssert(g.next() == "7");
            XCTAssert(g.next() == "8");
            XCTAssert(g.next() == "9");
        }
    }

    func testSubscript() {
        let b = SegmentedArray<String, StringAggregate>(maxSegmentSize: 8);
        
        b.append("0");
        b.append("1");
        b.append("2");
        b.append("3");
        b.append("4");
        b.append("5");
        b.append("6");
        b.append("7");
        b.append("8");
        XCTAssertEqual(b.segmentCount, 2);
        XCTAssertEqual(b.count, 9);
        
        XCTAssertEqual(b[0], "0");
        XCTAssertEqual(b[1], "1");
        XCTAssertEqual(b[2], "2");
        XCTAssertEqual(b[3], "3");
        XCTAssertEqual(b[4], "4");
        XCTAssertEqual(b[5], "5");
        XCTAssertEqual(b[6], "6");
        XCTAssertEqual(b[7], "7");
        XCTAssertEqual(b[8], "8");
        XCTAssertEqual(b.aggregateForSegment(0).characterCount, 8);
        XCTAssertEqual(b.aggregateForSegment(1).characterCount, 1);
        
        b[1] = "1b";
        b[8] = "8b";

        XCTAssertEqual(b[1], "1b");
        XCTAssertEqual(b[8], "8b");
        XCTAssertEqual(b.aggregateForSegment(0).characterCount, 9);
        XCTAssertEqual(b.aggregateForSegment(1).characterCount, 2);
    }
    
    func testSliceSingleBlock() {
        let b = SegmentedArray<String, StringAggregate>(maxSegmentSize: 8);
        
        b.append("0");
        b.append("1");
        b.append("2");
        b.append("3");
        
        let s = b[1...2];

        XCTAssertEqual(s[0], "1");
        XCTAssertEqual(s[1], "2");
        XCTAssertEqual(s.count, 2);
        XCTAssertEqual(["0", "1", "2", "3"][1...2].count, 2);
    }

    func testSliceMutableBlock() {
        let b = SegmentedArray<String, StringAggregate>(maxSegmentSize: 4);
        
        b.append("0");
        b.append("1");
        b.append("2");
        b.append("3");
        b.append("4");
        b.append("5");
        b.append("6");
        b.append("7");
        b.append("8");
        b.append("9");
        b.append("10");
        b.append("11");
        b.append("12");
        b.append("13");
        b.append("14");
        b.append("15");
        
        let s = b[1...14];

        XCTAssertEqual(s[0], "1");
        XCTAssertEqual(s[1], "2");
        XCTAssertEqual(s.count, 14);
        XCTAssertEqual([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15][1...14].count, 14);
    }
    
    func testRemoveRange() {
        let b = SegmentedArray<String, StringAggregate>(maxSegmentSize: 4);
        
        b.append("0");
        b.append("1");
        b.append("2");
        b.append("3");
        b.append("4");
        b.append("5");
        b.append("6");
        b.append("7");
        b.append("8");
        b.append("9");
        b.append("10");
        b.append("11");
        b.append("12");
        b.append("13");
        b.append("14");
        b.append("15");
        
        b.removeRange(1...14);
        XCTAssertEqual(b.count, 2);
        XCTAssertEqual(b[0], "0");
        XCTAssertEqual(b[1], "15");
    }

    func testSplice() {
        let b = SegmentedArray<String, StringAggregate>(["1", "2", "4", "5"], maxSegmentSize: 4);
        
        XCTAssertEqual(b.count, 4);
        XCTAssertEqual(b.segmentCount, 1);
        XCTAssertEqual(b.aggregateForSegment(0).characterCount, 4);
        b.splice(["6", "7", "8", "9"], atIndex:3);
        
        XCTAssertEqual(b.count, 8);
        XCTAssertGreaterThanOrEqual(b.segmentCount, 2);
        XCTAssertEqual(sum(b.aggregates) { return $0.characterCount }, 8);
    }
    
    func testReplaceRange() {
        let b = SegmentedArray<String, StringAggregate>(["1", "2", "4", "5"], maxSegmentSize: 4);
        
        XCTAssertEqual(b.count, 4);
        XCTAssertEqual(b.segmentCount, 1);
        XCTAssertEqual(b.aggregateForSegment(0).characterCount, 4);
        b[1...2] = ["2b", "3", "4b"];
        XCTAssertEqual(b.count, 5);
        XCTAssertEqual(b.segmentCount, 2);
        XCTAssertEqual(sum(b.aggregates) { return $0.characterCount }, 7);
    }
}
