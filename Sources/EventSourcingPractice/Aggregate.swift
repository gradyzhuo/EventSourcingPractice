//
//  File.swift
//  
//
//  Created by 卓俊諺 on 2024/3/28.
//

import Foundation
import EventStoreDB
import EventSourcing



public struct WarehouseProduct: Aggregate{
    
    public enum EventMapper : String, EventMappable {
        case productShiped = "ProductShiped"
        case productReceived = "ProductReceived"
        case inventoryAdjusted = "InventoryAdjusted"
        
        public func convert(readEvent: ReadEvent) throws -> (any Event)? {
            return switch self {
            case .productShiped:
                try readEvent.recordedEvent.decode(to: ProductShiped.self)
            case .productReceived:
                try readEvent.recordedEvent.decode(to: ProductReceived.self)
            case .inventoryAdjusted:
                try readEvent.recordedEvent.decode(to: InventoryAdjusted.self)
            }
        }
    }
    
    public static var category: String = "WarehouseProduct"
    
//    public static func getStreamName(id: String) -> String {
//        return "product::\(id)"
//    }
    
    public typealias ID = String
    
    public let id: String

    public var events: [any Event] = []
    public private(set) var quantityOnHand: Int = 0
    public var revision: UInt64? = nil
    
    public mutating func clearDomainEvents(){
        self.events.removeAll()
    }

    
    public mutating func add<E>(event: E) throws where E : EventSourcing.Event {
        switch event {
        case let e as ProductShiped:
            try self.apply(event: e)
        case let e as ProductReceived:
            try self.apply(event: e)
        case let e as InventoryAdjusted:
            try self.apply(event: e)
        default:
            throw EventSourcingError.invalidOperationException(message: "Unsupported Event Type.")
        }
        
        events.append(event)
    }
//    public mutating func add(event: Event) throws{
//        switch event {
//        case let e as ProductShiped:
//            try self.apply(event: e)
//        case let e as ProductReceived:
//            try self.apply(event: e)
//        case let e as InventoryAdjusted:
//            try self.apply(event: e)
//        default:
//            throw EventSourcingError.invalidOperationException(message: "Unsupported Event Type.")
//        }
//        
//        events.append(event)
//    }
    
    public init(sku: String) {
        self.init(id: sku)
    }
    
    public init(id: String) {
        self.id = id
    }
    
    public mutating func ship(quantity: Int) throws {
        if quantity > quantityOnHand {
            throw EventSourcingError.invalidDomainException(message: "Ah... we don't have enough product to ship?")
        }
        let event = ProductShiped(sku: id, quantity: quantity, datetime: .init())
        try add(event: event)
    }
    
    public mutating func receive(quantity: Int) throws {
        try add(event: ProductReceived(sku: id, quantity: quantity, datetime: .init()))
    }
    
    public mutating func adjustInventory(quantity: Int, reason: String) throws {
        if quantityOnHand + quantity < 0{
            throw EventSourcingError.invalidDomainException(message: "Cannot adjust to a ")
        }
        try add(event: InventoryAdjusted(sku: id, quantity: quantity, reason: reason, datetime: .init()))
    }
    
//    public mutating func apply<E>(event: E) throws where E : Event {
//        apply(event: event)
//    }
    
    public mutating func apply(event: ProductShiped) throws{
        quantityOnHand -= event.quantity
    }
    
    public mutating func apply(event: ProductReceived) throws {
        quantityOnHand += event.quantity
    }
    
    public mutating func apply(event: InventoryAdjusted) throws{
        quantityOnHand += event.quantity
    }
    
}

