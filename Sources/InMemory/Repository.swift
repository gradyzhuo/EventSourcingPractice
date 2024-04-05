//
//  File.swift
//  
//
//  Created by 卓俊諺 on 2024/4/1.
//

import Foundation
import EventSourcingPractice
import EventSourcing

public class WarehouseProductInMemoryRepository: WarehouseProductRepository{
    
    private var _inMemoryStreams: [String: [Event]]
    
    public init() {
        self._inMemoryStreams = [:]
    }
    
    public func get(sku: String) async throws -> WarehouseProduct {
        return try await get(id: sku)
    }
    
    public func exists(sku: String) async throws -> Bool {
        return if let _ = try await find(id: sku){
            true
        }else{
            false
        }
    }
    
    public func save(product: WarehouseProduct) async throws {
        try await save(entity: product)
    }
    
    public func delete(sku: String) async throws {
        try await delete(id: sku)
    }
    
}

extension WarehouseProductInMemoryRepository: Repository {
    public typealias ReadEvents = [any Event]
    public typealias AggregateRoot = WarehouseProduct
    
    public func find(id: String) async throws -> [any Event]? {
        return _inMemoryStreams[id] ?? []
    }
    
    public func get(id: String) async throws -> WarehouseProduct {
        var warehouseProduct = WarehouseProduct(sku: id)
        guard let events = try await find(id: id) else {
            return warehouseProduct
        }
        
        for event in events {
            try warehouseProduct.add(event: event)
        }
        return warehouseProduct
    }
    
    public func save(entity: WarehouseProduct) async throws {
        if try await contains(id: entity.id){
            _inMemoryStreams[entity.id]?.append(contentsOf: entity.events)
        }else{
            _inMemoryStreams[entity.id] = entity.events
        }
        
    }
    
    public func delete(id: String) async throws {
        _inMemoryStreams.removeValue(forKey: id)
    }
    
    public func contains(id: String) async throws -> Bool {
        return _inMemoryStreams.contains{ $0.key == id }
    }
    
}
