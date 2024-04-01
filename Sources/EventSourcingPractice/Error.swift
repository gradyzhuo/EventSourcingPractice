//
//  File.swift
//  
//
//  Created by 卓俊諺 on 2024/3/30.
//

import Foundation

public enum EventSourcingError: Error {
    case invalidDomainException(message: String)
    case invalidOperationException(message: String)
}
