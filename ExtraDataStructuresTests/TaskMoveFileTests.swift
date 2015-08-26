//
//  TaskMoveFileTests.swift
//  ExtraDataStructures
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import XCTest
@testable import ExtraDataStructures

public class TaskMoveFileTests: XCTestCase {
    public func testMoveFile() {
        do {
            let tempDir = NSURL(fileURLWithPath: NSTemporaryDirectory());
            let manager = NSFileManager.defaultManager();
            
            try manager.createDirectoryAtURL(tempDir.URLByAppendingPathComponent("Folder1"), withIntermediateDirectories: true, attributes: nil);
            try manager.createDirectoryAtURL(tempDir.URLByAppendingPathComponent("Folder2"), withIntermediateDirectories: true, attributes: nil);
            
            let source      = tempDir.URLByAppendingPathComponent("Folder1/Info.plist");
            let destination = tempDir.URLByAppendingPathComponent("Folder2/Info.plist");
            
            Darwin.unlink(source.fileSystemRepresentation);
            Darwin.unlink(destination.fileSystemRepresentation);
            
            NSDictionary(dictionary: ["Test": "Data"]).writeToURL(source, atomically: true);
            
            XCTAssertTrue(manager.fileExistsAtPath(source.path!));
            XCTAssertFalse(manager.fileExistsAtPath(destination.path!));
            
            let expect = self.expectationWithDescription("Expect")
        
            let task = Task.moveFiles("Move File", urls: [
                source: destination
            ], errorBehavior: .Revert);
            
            task.thenOnMainThread { task in
                expect.fulfill();
            }
            
            self.waitForExpectationsWithTimeout(1, handler: nil)
            XCTAssertFalse(manager.fileExistsAtPath(source.path!));
            XCTAssertTrue(manager.fileExistsAtPath(destination.path!));
            XCTAssert(task.outputs.count == 1);
            XCTAssertNil(task.error);
            
            let d         = NSDictionary(contentsOfURL: destination)!;
            let s: String = d["Test"]! as! String;
            
            XCTAssert(s == "Data");
        }
        catch {
            XCTFail();
        }
    }

    @objc
    public dynamic func testMoveFileRevert() {
        do {
            let tempDir = NSURL(fileURLWithPath: NSTemporaryDirectory());
            let manager = NSFileManager.defaultManager();
            
            try manager.createDirectoryAtURL(tempDir.URLByAppendingPathComponent("Folder1"), withIntermediateDirectories: true, attributes: nil);
            try manager.createDirectoryAtURL(tempDir.URLByAppendingPathComponent("Folder2"), withIntermediateDirectories: true, attributes: nil);
            
            let source      = tempDir.URLByAppendingPathComponent("Folder1/Info.plist");
            let destination = tempDir.URLByAppendingPathComponent("Folder2/Info.plist");
            
            Darwin.unlink(source.fileSystemRepresentation);
            Darwin.unlink(destination.fileSystemRepresentation);
            
            XCTAssertFalse(manager.fileExistsAtPath(source.path!));
            XCTAssertFalse(manager.fileExistsAtPath(destination.path!));
            
            let expect = self.expectationWithDescription("Expect")
            let task = Task.moveFiles("Move File", urls: [
                source: destination
            ], errorBehavior: .Revert)
            
            task.thenOnMainThread { task in
                expect.fulfill();
            }
            
            self.waitForExpectationsWithTimeout(1, handler: nil)
            XCTAssertTrue(manager.fileExistsAtPath(source.path!));
            XCTAssertFalse(manager.fileExistsAtPath(destination.path!));
            XCTAssert(task.outputs.count == 0);
            XCTAssertNotNil(task.error);
        }
        catch {
            XCTFail();
        }
    }
}
