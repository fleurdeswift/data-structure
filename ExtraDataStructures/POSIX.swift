//
//  POSIX.swift
//  ExtraDataStructures
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Foundation

public typealias DarwinStatStruct = Darwin.stat;

public func DarwinStat(url: NSURL, inout _ buf: DarwinStatStruct) throws -> Void {
    if Darwin.stat(url.fileSystemRepresentation, &buf) != 0 {
        throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno), userInfo: [
            NSURLErrorKey: url
        ]);
    }
}

public func DarwinAccess(url: NSURL, _ amode: Int32) throws -> Void {
    if Darwin.access(url.fileSystemRepresentation, amode) != 0 {
        throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno), userInfo: [
            NSURLErrorKey: url
        ]);
    }
}

public func DarwinRename(old old: NSURL, new: NSURL) throws -> Void {
    if Darwin.rename(old.fileSystemRepresentation, new.fileSystemRepresentation) != 0 {
        throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno), userInfo: [
            NSURLErrorKey: [old, new] as NSArray
        ]);
    }
}

public func DarwinOpen(path: NSURL, _ oflags: Int32, _ mode: Darwin.mode_t = 0o755) throws -> Int32 {
    let fd = Darwin.open(path.fileSystemRepresentation, oflags, mode);
    
    if fd == -1 {
        throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno), userInfo: [
            NSURLErrorKey: path
        ]);
    }
    
    return fd;
}

public func DarwinRead(fd: Int32, _ buf: UnsafeMutablePointer<Void>, _ nbyte: Int) throws -> Int {
    let readed = Darwin.read(fd, buf, nbyte);
    
    if readed == -1 {
        throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno), userInfo: nil);
    }
    
    return readed;
}

public func DarwinWrite(fd: Int32, _ buf: UnsafePointer<Void>, _ nbyte: Int) throws -> Int {
    let written = Darwin.write(fd, buf, nbyte);
    
    if written == -1 {
        throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno), userInfo: nil);
    }
    
    return written;
}

public func DarwinClose(fd: Int32) throws {
    if Darwin.close(fd) != 0 {
        throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno), userInfo: nil);
    }
}
