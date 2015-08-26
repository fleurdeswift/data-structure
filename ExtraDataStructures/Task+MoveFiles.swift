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
    
        public func move(urls urls: [NSURL: NSURL], errorBehavior: ErrorBehavior) {
            var moves   = [NSURL: NSURL]();
            var renames = [NSURL: NSURL]();
            let errors  = ErrorDictionary();
            
            typealias statStruct = stat;
            
            var destinationStats = [NSURL: DarwinStatStruct]();
            var bytes: Int64 = 0;

            for (source, destination) in urls {
                if !source.fileURL {
                    errors[source] = NSError(domain: NSPOSIXErrorDomain, code: Int(EBADF), userInfo: [NSURLErrorKey: source]);
                    continue;
                }
                
                if !destination.fileURL {
                    errors[source] = NSError(domain: NSPOSIXErrorDomain, code: Int(EBADF), userInfo: [NSURLErrorKey: source]);
                    continue;
                }
            
                var destinationStat: DarwinStatStruct;
                let destinationParent = destination.URLByDeletingLastPathComponent!;
            
                if let cached = destinationStats[destinationParent] {
                    destinationStat = cached;
                }
                else {
                    destinationStat = DarwinStatStruct();
                    
                    do {
                        try DarwinStat(destinationParent, &destinationStat);
                        try DarwinAccess(destinationParent, W_OK);
                    }
                    catch {
                        errors[destinationParent] = error as NSError;
                    }
                }
            
                do {
                    var sourceStat = DarwinStatStruct();
                    
                    try DarwinStat(source, &sourceStat);
                    try DarwinAccess(source, R_OK);
                    try DarwinAccess(source.URLByDeletingLastPathComponent!, W_OK);
                    
                    if sourceStat.st_dev != destinationStat.st_dev {
                        moves[source] = destination;
                        bytes += sourceStat.st_size;
                    }
                    else {
                        renames[source] = destination;
                        bytes += 1;
                    }
                }
                catch {
                    errors[source] = error as NSError;
                }
            }
            
            if errors.count != 0 {
                if errorBehavior != .Ignore {
                    self.error = errors;
                    return;
                }
            }
            
            bytes = min(1, bytes);
            
            var results       = [NSURL]();
            var moved         = [NSURL: NSURL]();
            var renamed       = [NSURL: NSURL]();
            var readed: Int64 = 0;

            for (source, destination) in renames {
                do {
                    try DarwinRename(old: source, new: destination);
                    renamed[source] = destination;
                    readed += 1;
                    self.progress = Double(readed) / Double(bytes);
                    results.append(destination);
                }
                catch {
                    errors[destination] = error as NSError;
                    
                    if errorBehavior != .Ignore {
                        break;
                    }
                }
            }
            
            if errors.count != 0 && errorBehavior == .Revert {
                MoveFiles.revertRenames(renamed);
                self.error = errors;
                return;
            }
            
            if moves.count > 0 {
                let blockSize  = 65536 * 4;
                let block      = Darwin.malloc(blockSize);
                defer { Darwin.free(block); }
                
                for (source, destination) in moves {
                    do {
                        try moveFile(source, destination, block, blockSize, &readed, bytes);
                        moved[source] = destination;
                        results.append(destination);
                    }
                    catch {
                        Darwin.unlink(destination.fileSystemRepresentation);
                        errors[destination] = error as NSError;
                        
                        if errorBehavior != .Ignore {
                            break;
                        }
                    }
                    
                    self.progress = Double(readed) / Double(bytes);
                }
            }
            
            if errors.count != 0 {
                self.error = errors;
                
                if errorBehavior == .Revert {
                    MoveFiles.revertRenames(renamed);
                    MoveFiles.revertMoves(moved);
                    return;
                }
            }
            
            MoveFiles.deleteMoves(moved);
            self.outputs = ["destinationURLs": results];
        }
    }

    private func moveFile(source: NSURL, _ destination: NSURL, _ block: UnsafeMutablePointer<Void>, _ blockSize: Int, inout _ readed: Int64, _ bytes: Int64) throws {
        var blockIndex = 0;
        
        let rfd = try DarwinOpen(source, O_RDONLY);
        defer { Darwin.close(rfd); }
        let wfd = try DarwinOpen(destination, O_WRONLY | O_CREAT | O_EXCL);
        defer { Darwin.close(wfd); }
        
        while true {
            let blockReaded = try DarwinRead(rfd, block, blockSize);

            if blockReaded == 0 {
                break;
            }

            readed += Int64(blockReaded);

            try DarwinWrite(wfd, block, blockReaded);

            if blockIndex++ > 16 {
                blockIndex = 0;
                self.progress = Double(readed) / Double(bytes);
            }
        }
    }
    
    private static func revertMoves(moves: [NSURL: NSURL]) {
        for (_, destination) in moves {
            Darwin.unlink(destination.fileSystemRepresentation);
        }
    }
    
    private static func deleteMoves(moves: [NSURL: NSURL]) {
        for (source, _) in moves {
            Darwin.unlink(source.fileSystemRepresentation);
        }
    }
    
    private static func revertRenames(renames: [NSURL: NSURL]) {
        for (source, destination) in renames {
            do {
                try DarwinRename(old: destination, new: source);
            }
            catch {
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

