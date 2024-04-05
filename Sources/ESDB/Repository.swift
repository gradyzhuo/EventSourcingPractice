//
//  File.swift
//  
//
//  Created by 卓俊諺 on 2024/4/1.
//

import Foundation
import EventSourcingPractice
import EventSourcing
import EventStoreDB

public struct WarehouseProductEventStoreRepository: WarehouseProductRepository{

    public let client: EventStoreDB.Client
    
    public init() throws {
        self.client = try .init()
    }
    
    public func get(sku: String) async throws -> WarehouseProduct {
        return try await get(id: sku)
    }
    
    public func exists(sku: String) async throws -> Bool {
        guard let _ = try await find(id: sku) else {
            return false
        }
        return true
    }
    
    public func save(product: WarehouseProduct) async throws{
        try await save(entity: product)
    }
    
    public func delete(sku: String) async throws {
        try await delete(id: sku)
    }
}


extension WarehouseProductEventStoreRepository: EventStoreRepository{
    
    public typealias AggregateRoot = WarehouseProduct
    
}
