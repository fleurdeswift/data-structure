//
//  ErrorDictionary.swift
//  ExtraDataStructures
//
//  Copyright © 2015 Fleur de Swift. All rights reserved.
//

import Foundation

public class ErrorDictionary : NSError {
    public  var errors = NSMutableDictionary();
    private var _description: String?;
    private var _localizedDescription: String?;
    
    public init(minimumCapacity: Int = 1) {
        super.init(domain: ExtraDataStructuresErrorDomain, code: ERROR_DICTIONARY, userInfo: nil);
    }

    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder);
    }
    
    public subscript (key: NSCopying) -> NSError? {
        get {
            return errors[key] as? NSError;
        }
        
        set {
            errors[key] = newValue;
        }
    }
  
    public var count: Int {
        get {
            return errors.count;
        }
    }
    
    public override var description: String {
        get {
            var d = "";
            
            if let heading = _description {
                d = heading;
            }
        
            if errors.count > 0 {
                d += "\n";
                for pair in errors {
                    d += "\n\(pair.key): \(pair.value.description)";
                }
            }
            
            return d;
        }
    }

    public override var localizedDescription: String {
        get {
            var d = "";
            
            if let heading = _localizedDescription {
                d = heading;
            }
            else if let heading = _description {
                d = heading;
            }
            
            if errors.count > 0 {
                d += "\n";
            
                for pair in errors {
                    d += "\n\(pair.key): \(pair.value.localizedDescription)";
                }
            }
            
            return d;
        }
    }
    
    public override var userInfo: [NSObject: AnyObject] {
        get {
            let info: [NSObject : AnyObject] = [
                "Errors":                  errors,
                NSLocalizedDescriptionKey: self.localizedDescription,
            ];
            
            return info;
        }
    }
}
