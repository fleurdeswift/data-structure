//
//  Task+MoveTask.swift
//  ExtraDataStructures
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Foundation

public extension Task {
    public class MoveFiles : Task {
        public enum ErrorBehavior {
            case Revert, Stop, Ignore
        }
    
        private func handle(error error: ErrorType, behavior: ErrorBehavior) -> Bool {
            switch (behavior) {
            case .Revert, .Stop:
                return true;
            default:
                return false;
            }
        }
    
        public func move(urls urls: [NSURL: NSURL], errorBehavior: ErrorBehavior) {
            let manager     = NSFileManager.defaultManager();
            var manualMoves = [NSURL:  NSURL]();
            var linkMoves   = [String: String]();
            var attributes  = [NSURL:  [String: AnyObject]]();
            
            typealias statStruct = stat;
            
            var destinationStats = [NSURL: statStruct]();

            for (source, destination) in urls {
                if source.fileURL && destination.fileURL {
                    if let sourcePath = source.path, destinationPath = destination.path {
                        var destinationStat: statStruct;
                        let destinationParent = destination.URLByDeletingLastPathComponent!;
                    
                        if let cached = destinationStats[destinationParent] {
                            destinationStat = cached;
                        }
                        else {
                            destinationStat = statStruct();
                            
                            if Darwin.stat(destinationParent.path!, &destinationStat) != 0 {
                                if handle(error: NSError(domain: NSPOSIXErrorDomain, code: Int(errno), userInfo: [
                                    NSURLErrorKey: destination
                                ]), behavior: errorBehavior) {
                                    break;
                                }
                                else {
                                    continue;
                                }
                            }
                            
                            destinationStats[destinationParent] = destinationStat;
                        }
                    
                        do {
                            var sourceStat = stat();
                        
                            Darwin.stat(sourcePath, &sourceStat);
                            let attr = try manager.attributesOfItemAtPath(sourcePath);

                            if Darwin.link(sourcePath, destinationPath) == 0 {
                                linkMoves[sourcePath] = destinationPath;
                                continue;
                            }
                            
                            attributes[source] = attr;
                        }
                        catch {
                            if handle(error: error, behavior: errorBehavior) {
                                break;
                            }
                        }
                    }
                }

                manualMoves[source] = destination;
            }
        }
    }
    
    public class func moveFiles(identifier: String, urls: [NSURL: NSURL], errorBehavior: MoveFiles.ErrorBehavior) -> Task.MoveFiles {
        return MoveFiles(createWithIdentifier: identifier, description: "Move Files...", dependsOn: nil, queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), barrier: false) { task in
            (task as! MoveFiles).move(urls: urls, errorBehavior: errorBehavior);
        }
    }
}

/*
public class MoveFileTask : NSObject, LongTask {
    public var progress: Double?;
    public var status:   String = "Moving files..."

    public func cancel() {
    }

    public let links: [String: String];
    public let moves: [NSURL: NSURL];
    public let block: ([NSURL: NSError]?) -> Void

    public init(linkMoves: [String: String], manualMoves: [NSURL: NSURL], manualAttributes: [NSURL: [String: AnyObject]], completionBlock: ([NSURL: NSError]?) -> Void) {
        self.links = linkMoves;
        self.moves = manualMoves;
        self.block = completionBlock;
        super.init();

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
            var totalBytes: UInt64 = 0;
            var readed:     UInt64 = 0;

            for (_, attributes) in manualAttributes {
                if let bytes = attributes[NSFileSize] as? NSNumber {
                    totalBytes += bytes.unsignedLongLongValue;
                }
            }

            var blockIndex = 0;
            let blockSize = 65536;
            let block     = Darwin.malloc(blockSize);
            defer { Darwin.free(block); }

            for (sourceURL, destinationURL) in manualMoves {
                let input  = NSInputStream(URL: sourceURL)!;
                let output = NSOutputStream(URL: destinationURL, append: false)!;

                input.open();
                output.open();

                defer {
                    input.close();
                    output.close();
                }

                while true {
                    let blockReaded = input.read(UnsafeMutablePointer<UInt8>(block), maxLength: blockSize);

                    if blockReaded == 0 {
                        break;
                    }
                    else if blockReaded < 0 {
                        self.revert(sourceURL, error: input.streamError);
                        return;
                    }

                    readed += UInt64(blockReaded);

                    if output.write(UnsafeMutablePointer<UInt8>(block), maxLength: blockReaded) < 0 {
                        self.revert(destinationURL, error: output.streamError);
                        return;
                    }

                    if blockIndex++ > 16 {
                        blockIndex = 0;

                        let up = readed;
                        let upt = totalBytes;

                        dispatch_async(dispatch_get_main_queue()) {
                            self.progress = min(0.999, Double(up) / Double(upt));
                            NSNotificationCenter.defaultCenter().postNotificationName(LongTaskProgressChanged, object: self);
                        }
                    }
                }
            }

            self.commit();
        }
    }

    public class func moveFiles(files: [NSURL: NSURL], presentingViewController: NSViewController, completionBlock: ([NSURL: NSError]?) -> Void) throws {
        if let task = try self.moveFiles(files, completionBlock: completionBlock) {
            LongTaskSheet.show(task, parent: presentingViewController);
        }
    }

    /// This function returns nil if the move operation can be performed using the POSIX command
    /// rename.
    public class func moveFiles(files: [NSURL: NSURL], completionBlock: ([NSURL: NSError]?) -> Void) throws -> LongTask? {
        let manager     = NSFileManager.defaultManager();
        var manualMoves = [NSURL: NSURL]();
        var linkMoves   = [String: String]();
        var attributes  = [NSURL: [String: AnyObject]]();

        for (source, destination) in files {

            if  source.fileURL && destination.fileURL {
                if let sourcePath = source.path, destinationPath = destination.path {
                    let attr = try manager.attributesOfItemAtPath(sourcePath);

                    if Darwin.link(sourcePath, destinationPath) == 0 {
                        linkMoves[sourcePath] = destinationPath;
                        continue;
                    }
                    
                    attributes[source] = attr;
                }
            }

            manualMoves[source] = destination;
        }

        if manualMoves.count == 0 {
            for (sourcePath, _) in linkMoves {
                Darwin.unlink(sourcePath);
            }

            completionBlock(nil);
            return nil;
        }

        return MoveFileTask(linkMoves: linkMoves, manualMoves: manualMoves, manualAttributes: attributes, completionBlock: completionBlock);
    }

    private func commit() {
        for (sourcePath, _) in links {
            Darwin.unlink(sourcePath);
        }

        for (sourceURL, _) in moves {
            if sourceURL.fileURL {
                if let path = sourceURL.path {
                    Darwin.unlink(path);
                }
            }
        }

        dispatch_async(dispatch_get_main_queue()) {
            self.progress = 1.0;
            NSNotificationCenter.defaultCenter().postNotificationName(LongTaskProgressChanged, object: self);
            self.block(nil);
        }
    }

    private func revert(url: NSURL, error: NSError?) {
        for (_, destinationPath) in links {
            Darwin.unlink(destinationPath);
        }

        for (_, destinationURL) in moves {
            if destinationURL.fileURL {
                if let path = destinationURL.path {
                    Darwin.unlink(path);
                }
                else {
                    assert(false);
                }
            }

            assert(false);
        }

        dispatch_async(dispatch_get_main_queue()) {
            self.progress = 1.0;
            NSNotificationCenter.defaultCenter().postNotificationName(LongTaskProgressChanged, object: self);

            if let e = error {
                self.block([url: e]);
            }
            else {
                self.block([url: NSError(domain: NSPOSIXErrorDomain, code: Int(EFAULT), userInfo: nil)]);
            }
        }
    }
}*/

