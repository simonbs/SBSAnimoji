//
//  Result.swift
//  YouTubeKit
//
//  Created by Simon Støvring on 08/11/2017.
//  Copyright © 2017 SimonBS. All rights reserved.
//

import Foundation

enum Result<T, E: Error> {
    case value(T)
    case error(E)
    
    init(_ value: T) {
        self = .value(value)
    }
    
    init(_ error: E) {
        self = .error(error)
    }
}
