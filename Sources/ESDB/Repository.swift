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
    
    public func save(product: WarehouseProduct) async throws{
        try await save(entity: product)
    }
}


extension WarehouseProductEventStoreRepository: EventStoreRepository{
    
    public typealias AggregateRoot = WarehouseProduct
    
}
