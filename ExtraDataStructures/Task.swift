//
//  Task.swift
//  ExtraDataStructures
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Foundation

public typealias TaskBlock = (Task) throws -> Void;

private let queue = dispatch_queue_create("ExtraDataStructures.Task", DISPATCH_QUEUE_SERIAL);

public let TaskDescriptionNotification = "ExtraDataStructures.TaskDescriptionNotification";
public let TaskProgressNotification    = "ExtraDataStructures.TaskProgressNotification";
public let TaskStateNotification       = "ExtraDataStructures.TaskStateNotification";

@objc
public class Task : NSObject {
    public enum State {
        case Initializing, Queued, Running, Completed
    }

    public let identifier: String;
    public let group:      dispatch_group_t = dispatch_group_create();

    public var inputs:      [String: AnyObject] = [String: AnyObject]();
    public var inputsError: [String: ErrorType] = [String: ErrorType]();
    public var outputs:     [String: AnyObject] = [String: AnyObject]();
    
    private var _description:  String;
    private var _progress:     Double              = 0;
    private var _dependants:   [Task]              = [];
    private var _dependancies: Int                 = 0;
    private var _state:        State               = .Initializing;
    private let _queue:        dispatch_queue_t;
    private let _barrier:      Bool;
    private let _block:        TaskBlock;
    private var _error:        ErrorType?;

    public init(createWithIdentifier identifier: String, description: String, dependsOn: [Task]?, queue: dispatch_queue_t, barrier: Bool, block: TaskBlock) {
        self.identifier   = identifier;
        self._description = description;
        self._queue       = queue;
        self._barrier     = barrier;
        self._block       = block;
        super.init();
        
        dispatch_async(queue) {
            if let depends = dependsOn {
                for dependancy in depends {
                    if dependancy._state != .Completed {
                        dependancy._dependants.append(self);
                        self._dependancies++;
                    }
                    else {
                        self._mergeInputs(dependancy);
                    }
                }
            }
            
            if self._dependancies == 0 {
                self._run();
            }
            else {
                self._setState(.Initializing);
            }
        }
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
            dispatch_barrier_async(_queue, block);
        }
        else {
            dispatch_async(_queue, block);
        }
        
        _setState(.Queued);
        dispatch_group_notify(group, queue, self._completed);
    }
    
    private func setRunning() {
        dispatch_async(queue) {
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
            inputsError[dependancy.identifier] = e;
        }
    }
    
    private func _dependancyHasCompleted(dependancy: Task) {
        assert(_dependancies > 0);
        _mergeInputs(dependancy);
        _dependancies--;
        
        if _dependancies == 0 {
            _run();
        }
    }
    
    public var error: ErrorType? {
        get {
            return dispatch_sync(queue) {
                return self._error;
            }
        }
        
        set {
            dispatch_sync(queue) {
                self._error = newValue;
            }
        }
    }

    public override var description: String {
        get {
            return dispatch_sync(queue) {
                return self._description;
            }
        }
        
        set {
            dispatch_sync(queue) {
                self._description = newValue;
                
                dispatch_async_main {
                    NSNotificationCenter.defaultCenter().postNotificationName(TaskDescriptionNotification, object: self, userInfo: nil);
                }
            }
        }
    }

    public var progress: Double {
        get {
            return dispatch_sync(queue) {
                return self._progress;
            }
        }
        
        set {
            dispatch_sync(queue) {
                self._progress = newValue;
                
                dispatch_async_main {
                    NSNotificationCenter.defaultCenter().postNotificationName(TaskProgressNotification, object: self, userInfo: nil);
                }
            }
        }
    }
}
