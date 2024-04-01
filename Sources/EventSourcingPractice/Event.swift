//
//  File.swift
//  
//
//  Created by 卓俊諺 on 2024/3/31.
//

import Foundation
import EventSourcing

public struct ProductShiped{
    public let sku: String
    public let quantity: Int
    public let datetime: Date
    
    public init(sku: String, quantity: Int, datetime: Date) {
        self.sku = sku
        self.quantity = quantity
        self.datetime = datetime
    }
}

extension ProductShiped: Event {
    public var updated: Date{
        return datetime
    }
    
    public var description: String{
        return "The Product '\(sku)' shipped \(quantity) at \(datetime.description)."
    }
}

public struct ProductReceived{
    public let sku: String
    public let quantity: Int
    public let datetime: Date
    
    
    public init(sku: String, quantity: Int, datetime: Date) {
        self.sku = sku
        self.quantity = quantity
        self.datetime = datetime
    }

}

extension ProductReceived: Event{
    public var updated: Date{
        return datetime
    }
    
    public var description: String{
        return "The Product '\(sku)' received \(quantity) at \(datetime.description)."
    }
}


public struct InventoryAdjusted{
    public let sku: String
    public let quantity: Int
    public let reason: String
    public let datetime: Date
    
    public init(sku: String, quantity: Int, reason: String, datetime: Date) {
        self.sku = sku
        self.quantity = quantity
        self.reason = reason
        self.datetime = datetime
    }
}

extension InventoryAdjusted: Event {
    public var updated: Date{
        return datetime
    }
    
    public var description: String{
        return "The Product '\(sku)' adjust \(quantity) by \(reason) at \(datetime.description). "
    }
}
