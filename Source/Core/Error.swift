//
//  Error.swift
//  WisdomNetwork
//
//  Created by qmlt on 2023/11/29.
//

import Foundation

public enum WisdomSessionErrorStauts: NSInteger, CaseIterable {
    case Unauthorized    = 401
    case Forbidden       = 402
    case NotFound        = 403
    case ServiceNotFound = 404
    
    case ServerUnableToRespond = 500
    case ResourceUnavailable   = 503
}
