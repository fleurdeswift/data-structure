//
//  Dispatch.swift
//  ExtraDataStructures
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Dispatch

// MARK: Sync
public func dispatch_sync(queue: dispatch_queue_t, block: () throws -> Void) throws -> Void {
    var throwed: ErrorType?;

    dispatch_sync(queue) {
        do {
            try block();
        }
        catch {
            throwed = error;
        }
    }
    
    if let throwed = throwed {
        throw throwed;
    }
}

public func dispatch_sync<T>(queue: dispatch_queue_t, block: () throws -> T) throws -> T {
    var throwed: ErrorType?;
    var result: T?;

    dispatch_sync(queue) {
        do {
            result = try block();
        }
        catch {
            throwed = error;
        }
    }
    
    if let throwed = throwed {
        throw throwed;
    }
    
    return result!;
}

public func dispatch_sync<T>(queue: dispatch_queue_t, block: () throws -> T?) throws -> T? {
    var throwed: ErrorType?;
    var result: T?;

    dispatch_sync(queue) {
        do {
            result = try block();
        }
        catch {
            throwed = error;
        }
    }
    
    if let throwed = throwed {
        throw throwed;
    }
    
    return result;
}

public func dispatch_sync<T>(queue: dispatch_queue_t, block: () -> T) -> T {
    var result: T?;

    dispatch_sync(queue) {
        result = block();
    }
    
    return result!;
}

public func dispatch_sync<T>(queue: dispatch_queue_t, block: () -> T?) -> T? {
    var result: T?;

    dispatch_sync(queue) {
        result = block();
    }
    
    return result;
}

// MARK: Sync (Barrier)
public func dispatch_barrier_sync(queue: dispatch_queue_t, block: () throws -> Void) throws -> Void {
    var throwed: ErrorType?;

    dispatch_barrier_sync(queue) {
        do {
            try block();
        }
        catch {
            throwed = error;
        }
    }
    
    if let throwed = throwed {
        throw throwed;
    }
}

public func dispatch_barrier_sync<T>(queue: dispatch_queue_t, block: () throws -> T) throws -> T {
    var throwed: ErrorType?;
    var result: T?;

    dispatch_barrier_sync(queue) {
        do {
            result = try block();
        }
        catch {
            throwed = error;
        }
    }
    
    if let throwed = throwed {
        throw throwed;
    }
    
    return result!;
}

public func dispatch_barrier_sync<T>(queue: dispatch_queue_t, block: () throws -> T?) throws -> T? {
    var throwed: ErrorType?;
    var result: T?;

    dispatch_barrier_sync(queue) {
        do {
            result = try block();
        }
        catch {
            throwed = error;
        }
    }
    
    if let throwed = throwed {
        throw throwed;
    }
    
    return result;
}

public func dispatch_barrier_sync<T>(queue: dispatch_queue_t, block: () -> T) -> T {
    var result: T?;

    dispatch_sync(queue) {
        result = block();
    }
    
    return result!;
}

public func dispatch_barrier_sync<T>(queue: dispatch_queue_t, block: () -> T?) -> T? {
    var result: T?;

    dispatch_sync(queue) {
        result = block();
    }
    
    return result;
}

public func dispatch_sync_main(block: dispatch_block_t) -> Void {
    dispatch_sync(dispatch_get_main_queue(), block);
}

public func dispatch_async_main(block: dispatch_block_t) -> Void {
    dispatch_async(dispatch_get_main_queue(), block);
}

public func dispatch_async_global(block: dispatch_block_t) -> Void {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}
