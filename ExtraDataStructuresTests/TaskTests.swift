//
//  TaskTests.swift
//  ExtraDataStructures
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Foundation

import XCTest
@testable import ExtraDataStructures

public class TaskTests : XCTestCase {
    public func testSimpleTask() {
        let expect = self.expectationWithDescription("Expect task to be executed")
    
        Task.createWithIdentifier("Task", description: "Initializing...", dependsOn: nil, queue: dispatch_get_main_queue(), barrier: false) { task in
            expect.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(2, handler: nil);
    }

    public func testDependanciesTask() {
        var expectFirst1: XCTestExpectation? = self.expectationWithDescription("Expect task to be executed first (1)");
        var expectFirst2: XCTestExpectation? = self.expectationWithDescription("Expect task to be executed first (2)");
        let expectSecond: XCTestExpectation  = self.expectationWithDescription("Expect task to be executed second");
        
        self.expectationForNotification(TaskDescriptionNotification, object: nil, handler: nil);
        self.expectationForNotification(TaskProgressNotification,    object: nil, handler: nil);
        self.expectationForNotification(TaskStateNotification,       object: nil, handler: nil);
    
        let firstTask1 = Task.createWithIdentifier("Task1", description: "Initializing...", dependsOn: nil, queue: dispatch_get_main_queue(), barrier: false) { task in
            task.outputs[task.identifier] = 1;
            expectFirst1?.fulfill();
            expectFirst1 = nil;
        }

        let firstTask2 = Task.createWithIdentifier("Task2", description: "Initializing...", dependsOn: nil, queue: dispatch_get_main_queue(), barrier: false) { task throws in
            task.outputs[task.identifier] = 2;
            expectFirst2?.fulfill();
            expectFirst2 = nil;
            
            throw NSError(domain: NSPOSIXErrorDomain, code: Int(EINVAL), userInfo: nil);
        }

        Task.createWithIdentifier("Task", description: "Initializing...", dependsOn: [firstTask1, firstTask2], queue: dispatch_get_main_queue(), barrier: false) { task in
            task.progress = 0.5
            XCTAssert(task.inputs["Task1"] as! Int == 1);
            XCTAssert(task.inputs["Task2"] as! Int == 2);
            XCTAssertNil(expectFirst1);
            XCTAssertNil(expectFirst2);
            expectSecond.fulfill()
            task.description = "Finished"
            task.progress    = 1
        }
        
        self.waitForExpectationsWithTimeout(2, handler: nil);
    }

    public func testDependanciesTaskGroup() {
        var expectFirst1: XCTestExpectation? = self.expectationWithDescription("Expect task to be executed first (1)");
        var expectFirst2: XCTestExpectation? = self.expectationWithDescription("Expect task to be executed first (2)");
        let expectSecond: XCTestExpectation  = self.expectationWithDescription("Expect task to be executed second");
        
        let firstTask1 = Task.createWithIdentifier("Task1", description: "Initializing...", dependsOn: nil, queue: dispatch_get_main_queue(), barrier: false) { task in
            dispatch_group_async(task.group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                sleep(1);
                task.outputs[task.identifier] = 1;
            }
        
            expectFirst1?.fulfill();
            expectFirst1 = nil;
        }

        let firstTask2 = Task.createWithIdentifier("Task2", description: "Initializing...", dependsOn: nil, queue: dispatch_get_main_queue(), barrier: false) { task in
            task.outputs[task.identifier] = 2;
            expectFirst2?.fulfill();
            expectFirst2 = nil;
        }

        Task.createWithIdentifier("Task", description: "Initializing...", dependsOn: [firstTask1, firstTask2], queue: dispatch_get_main_queue(), barrier: false) { task in
            XCTAssert(task.inputs["Task1"] as! Int == 1);
            XCTAssert(task.inputs["Task2"] as! Int == 2);
            XCTAssertNil(expectFirst1);
            XCTAssertNil(expectFirst2);
            expectSecond.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(3, handler: nil);
    }
}
