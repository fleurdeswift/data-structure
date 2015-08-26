//
//  Task.swift
//  ExtraDataStructures
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Foundation

public typealias TaskBlock = (Task) throws -> Void;

private let taskQueue = dispatch_queue_create("ExtraDataStructures.Task", DISPATCH_QUEUE_SERIAL);

public let TaskDescriptionNotification = "ExtraDataStructures.TaskDescriptionNotification";
public let TaskProgressNotification    = "ExtraDataStructures.TaskProgressNotification";
public let TaskStateNotification       = "ExtraDataStructures.TaskStateNotification";

@objc
public class Task : NSObject {
    public enum State {
        case Initializing, Queued, Running, Completed
    }

    public let identifier:   String;
    public let dependancies: Set<Task>;
    public let group:        dispatch_group_t = dispatch_group_create();
    public let queue:        dispatch_queue_t;

    public var inputs      = [String: AnyObject]();
    public var inputsError : ErrorDictionary?;
    public var outputs     = [String: AnyObject]();
    
    private var _description:   String;
    private var _progress:      Double               = 0;
    private var _dependants:    [Task]               = [];
    private var _pending:       Int                  = 0;
    private var _state:         State                = .Initializing;
    private let _barrier:       Bool;
    private let _block:         TaskBlock;
    private var _error:         ErrorType?;

    public init(createWithIdentifier identifier: String, description: String, dependsOn: [Task]?, queue: dispatch_queue_t, barrier: Bool, block: TaskBlock) {
        self.identifier   = identifier;
        self.queue        = queue;
        self._description = description;
        self._barrier     = barrier;
        self._block       = block;
        
        if let depends = dependsOn {
            self.dependancies = Set<Task>(depends);
        }
        else {
            self.dependancies = Set<Task>();
        }
        
        super.init();
        
        dispatch_async(taskQueue) {
            for dependancy in self.dependancies {
                if dependancy._state != .Completed {
                    dependancy._dependants.append(self);
                    self._pending++;
                }
                else {
                    self._mergeInputs(dependancy);
                }
            }
            
            if self._pending == 0 {
                self._run();
            }
            else {
                self._setState(.Initializing);
            }
        }
    }
    
    public func then(identifier identifier: String, description: String, queue: dispatch_queue_t, barrier: Bool, block: TaskBlock) -> Task {
        return Task(createWithIdentifier: identifier, description: description, dependsOn: [self], queue: queue, barrier: barrier, block: block);
    }

    public func then(identifier identifier: String, description: String, queue: dispatch_queue_t, block: TaskBlock) -> Task {
        return Task(createWithIdentifier: identifier, description: description, dependsOn: [self], queue: queue, barrier: false, block: block);
    }

    public func thenOnMainThread(identifier identifier: String, description: String, block: TaskBlock) -> Task {
        return Task(createWithIdentifier: identifier, description: description, dependsOn: [self], queue: dispatch_get_main_queue(), barrier: false, block: block);
    }

    public func thenOnMainThread(block: TaskBlock) -> Task {
        return Task(createWithIdentifier: self.identifier + "-conclude", description: self.description, dependsOn: [self], queue: dispatch_get_main_queue(), barrier: false, block: block);
    }

    public func then(queue: dispatch_queue_t, barrier: Bool, block: TaskBlock) -> Task {
        return Task(createWithIdentifier: self.identifier + "-conclude", description: self.description, dependsOn: [self], queue: queue, barrier: barrier, block: block);
    }

    public func then(queue: dispatch_queue_t, block: TaskBlock) -> Task {
        return Task(createWithIdentifier: self.identifier + "-conclude", description: self.description, dependsOn: [self], queue: queue, barrier: false, block: block);
    }
    
    public class func createWithIdentifier(identifier: String, description: String, dependsOn: [Task]?, queue: dispatch_queue_t, barrier: Bool, block: TaskBlock) -> Task {
        return Task(createWithIdentifier: identifier, description: description, dependsOn: dependsOn, queue: queue, barrier: barrier, block: block)
    }
    
    private func _run() {
        dispatch_group_enter(group);
        
        let block: dispatch_block_t = {
            self.setRunning();
        
            do {
                try self._block(self);
            }
            catch {
                self.error = error;
            }
            
            dispatch_group_leave(self.group);
        }
        
        if _barrier {
            dispatch_barrier_async(queue, block);
        }
        else {
            dispatch_async(queue, block);
        }
        
        _setState(.Queued);
        dispatch_group_notify(group, taskQueue, self._completed);
    }
    
    private func setRunning() {
        dispatch_async(taskQueue) {
            self._setState(.Running);
        }
    }
    
    private func _setState(newState: State) {
        self._state = newState;
        
        dispatch_async_main {
            NSNotificationCenter.defaultCenter().postNotificationName(TaskStateNotification, object: self, userInfo: nil);
        }
    }
    
    private func _completed() {
        _setState(.Completed);
        
        for depend in _dependants {
            depend._dependancyHasCompleted(self);
        }
        
        _dependants.removeAll();
    }
    
    private func _mergeInputs(dependancy: Task) {
        for pair in dependancy.outputs {
            inputs[pair.0] = pair.1;
        }
        
        if let e = dependancy._error {
            if inputsError == nil {
                inputsError = ErrorDictionary();
            }
            
            inputsError![dependancy.identifier] = e as NSError;
        }
    }
    
    private func _dependancyHasCompleted(dependancy: Task) {
        assert(_pending > 0);
        _mergeInputs(dependancy);
        _pending--;
        
        if _pending == 0 {
            _run();
        }
    }
    
    public var error: ErrorType? {
        get {
            return dispatch_sync(taskQueue) {
                return self._error;
            }
        }
        
        set {
            dispatch_sync(taskQueue) {
                self._error = newValue;
            }
        }
    }

    public override var description: String {
        get {
            return dispatch_sync(taskQueue) {
                return self._description;
            }
        }
        
        set {
            dispatch_sync(taskQueue) {
                self._description = newValue;
                
                dispatch_async_main {
                    NSNotificationCenter.defaultCenter().postNotificationName(TaskDescriptionNotification, object: self, userInfo: nil);
                }
            }
        }
    }

    public var globalProgress: Double {
        get {
            let deps = self.allDependancies;
        
            return dispatch_sync(taskQueue) {
                var p: Double = self._progress;
                
                for dep in deps {
                    p += dep._progress;
                }
            
                return p / Double(1 + deps.count);
            }
        }
    }
    
    public var progress: Double {
        get {
            return dispatch_sync(taskQueue) {
                return self._progress;
            }
        }
        
        set {
            dispatch_sync(taskQueue) {
                self._progress = newValue;
                
                dispatch_async_main {
                    NSNotificationCenter.defaultCenter().postNotificationName(TaskProgressNotification, object: self, userInfo: nil);
                }
            }
        }
    }
    
    private func visitAllDependancies(inout deps: Set<Task>) {
        for dependancy in dependancies {
            if deps.contains(dependancy) {
                continue;
            }
            
            deps.insert(dependancy);
            dependancy.visitAllDependancies(&deps);
        }
    }
    
    public var allDependancies: Set<Task> {
        get {
            var deps = Set<Task>();
        
            visitAllDependancies(&deps);
            return deps;
        }
    }
}
