//
//  ReferenceCache.swift
//  ExtraDataStructures
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

public class ReferenceCache<Key: Hashable, T: AnyObject> {
    public typealias Element = T;

    private var queue = dispatch_queue_create("ReferenceCache", DISPATCH_QUEUE_SERIAL);
    private var entries = [Key: WeakReference<T>]();

    public init() {
    }
    
    public subscript(key: Key) -> Element? {
        get {
            return dispatch_sync(queue) {
                let ref = self.entries[key];

                if let ref = ref {
                    return ref.value;
                }
                
                return nil;
            }
        }
    }

    public func getOrSet(key: Key, value: T) -> T {
        return dispatch_sync(queue) {
            let ref = self.entries[key];

            if let ref = ref {
                if let refValue = ref.value {
                    return refValue;
                }
            }
            
            self.entries[key] = WeakReference<T>(value);
            return value;
        }
    }

    public func get(key: Key, creatorBlock: () -> T) -> T {
        let cv = self[key];
        
        if let v = cv {
            return v;
        }
        
        return getOrSet(key, value: creatorBlock());
    }

    public func get(key: Key, creatorBlock: () throws -> T) throws -> T {
        let cv = self[key];
        
        if let v = cv {
            return v;
        }
        
        return getOrSet(key, value: try creatorBlock());
    }
    
    public func get(key: Key, creatorBlock: () -> T?) -> T? {
        var v = self[key];
        
        if let v = v {
            return v;
        }
        
        v = creatorBlock();
        
        if let v = v {
            return getOrSet(key, value: v);
        }
        
        return v;
    }

    public func get(key: Key, creatorBlock: () throws -> T?) throws -> T? {
        var v = self[key];
        
        if let v = v {
            return v;
        }
        
        v = try creatorBlock();
        
        if let v = v {
            return getOrSet(key, value: v);
        }
        
        return v;
    }
    
    public func removeAll() {
        dispatch_async(queue) {
            self.entries.removeAll();
        }
    }
}
