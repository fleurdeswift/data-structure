//
//  AggregateArrayTests.swift
//  ExtraDataStructures
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import XCTest
@testable import ExtraDataStructures

class AggregateArrayTests: XCTestCase {
    func testSplitMiddle() {
        let b = AggregateArray<String, StringAggregate>(["1", "2", "3", "4", "5", "6", "7", "8"]);
        let c = b.split();
        
        XCTAssertEqual(b.count, 4);
        XCTAssertEqual(c.count, 4);
        XCTAssertEqual(b.aggregate.characterCount, 4);
        XCTAssertEqual(c.aggregate.characterCount, 4);
    }

    func testSplitBegin() {
        let b = AggregateArray<String, StringAggregate>(["1", "2", "3", "4", "5", "6", "7", "8"]);
        let c = b.splitAtIndex(0);
        
        XCTAssertEqual(b.count, 0);
        XCTAssertEqual(c.count, 8);
        XCTAssertEqual(b.aggregate.characterCount, 0);
        XCTAssertEqual(c.aggregate.characterCount, 8);
    }

    func testSplitEnd() {
        let b = AggregateArray<String, StringAggregate>(["1", "2", "3", "4", "5", "6", "7", "8"]);
        let c = b.splitAtIndex(8);
        
        XCTAssertEqual(b.count, 8);
        XCTAssertEqual(c.count, 0);
        XCTAssertEqual(b.aggregate.characterCount, 8);
        XCTAssertEqual(c.aggregate.characterCount, 0);
    }
    
    func testExtend() {
        let b = AggregateArray<String, StringAggregate>(["1", "2", "3", "4", "5", "6", "7", "8"]);
        
        b.appendContentsOf(["9", "10", "11", "12"]);
        XCTAssertEqual(b.count, 12);
        XCTAssertEqual(b.aggregate.characterCount, 15);
    }

    func testReplaceRange() {
        let b = AggregateArray<String, StringAggregate>(["1", "2", "4", "5"]);
        
        XCTAssertEqual(b.count, 4);
        XCTAssertEqual(b.aggregate.characterCount, 4);
        b[1...2] = ["2b", "3", "4b"];
        XCTAssertEqual(b.count, 5);
        XCTAssertEqual(b.aggregate.characterCount, 7);
    }

    func testRemoveAtIndex() {
        let b = AggregateArray<String, StringAggregate>(["1", "2b", "4", "5"]);
        
        XCTAssertEqual(b.count, 4);
        XCTAssertEqual(b.aggregate.characterCount, 5);
        b.removeAtIndex(1);
        XCTAssertEqual(b.count, 3);
        XCTAssertEqual(b.aggregate.characterCount, 3);
    }

    func testRemoveAll() {
        let b = AggregateArray<String, StringAggregate>(["1", "2", "4", "5"]);
        
        XCTAssertEqual(b.count, 4);
        XCTAssertEqual(b.aggregate.characterCount, 4);
        b.removeAll(keepCapacity: true);
        XCTAssertEqual(b.count, 0);
        XCTAssertEqual(b.aggregate.characterCount, 0);
    }
}
