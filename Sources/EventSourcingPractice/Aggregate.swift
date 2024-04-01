//
//  File.swift
//  
//
//  Created by 卓俊諺 on 2024/3/28.
//

import Foundation
import EventStoreDB
import EventSourcing

public struct WarehouseProduct: Entity{
    public static func getStreamName(id: String) -> String {
        return "product::\(id)"
    }
    
    public typealias ID = String
    
    public let id: String
    public var sku: String {
        get{
            return id
        }
    }
    public private(set) var events: [Event] = []
    public private(set) var quantityOnHand: Int = 0
    
    public mutating func clearDomainEvents(){
        self.events.removeAll()
    }

    public mutating func add(event: Event) throws{
        switch event {
        case let e as ProductShiped:
            self.apply(event: e)
        case let e as ProductReceived:
            self.apply(event: e)
        case let e as InventoryAdjusted:
            self.apply(event: e)
        default:
            throw EventSourcingError.invalidOperationException(message: "Unsupported Event Type.")
        }
        
        events.append(event)
    }
    
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
        let event = ProductShiped(sku: sku, quantity: quantity, datetime: .init())
        try add(event: event)
    }
    
    public mutating func receive(quantity: Int) throws {
        try add(event: ProductReceived(sku: sku, quantity: quantity, datetime: .init()))
    }
    
    public mutating func adjustInventory(quantity: Int, reason: String) throws {
        if quantityOnHand + quantity < 0{
            throw EventSourcingError.invalidDomainException(message: "Cannot adjust to a ")
        }
        try add(event: InventoryAdjusted(sku: sku, quantity: quantity, reason: reason, datetime: .init()))
    }
    
    public mutating func apply(event: ProductShiped){
        quantityOnHand -= event.quantity
    }
    
    public mutating func apply(event: ProductReceived){
        quantityOnHand += event.quantity
    }
    
    public mutating func apply(event: InventoryAdjusted){
        quantityOnHand += event.quantity
    }
    
}

