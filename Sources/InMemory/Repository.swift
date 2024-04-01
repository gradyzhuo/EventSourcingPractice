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
        return try await find(id: sku) ?? .init(sku: sku)
    }
    
    public func save(product: WarehouseProduct) async throws {
        try await save(entity: product)
    }
    
    
}

extension WarehouseProductInMemoryRepository: Repository {
    public typealias AggregateRoot = WarehouseProduct
    
    public func find(id: String) async throws -> WarehouseProduct? {
        
        guard let events = _inMemoryStreams[id] else {
            return nil
        }
        
        var warehouseProduct = WarehouseProduct(sku: id)
        for event in events {
            try warehouseProduct.add(event: event)
        }
        return warehouseProduct
    }
    
    public func save(entity: WarehouseProduct) async throws {
        if try await contains(id: entity.id){
            _inMemoryStreams[entity.sku]?.append(contentsOf: entity.events)
        }else{
            _inMemoryStreams[entity.sku] = entity.events
        }
        
    }
    
    public func delete(id: String) async throws {
        _inMemoryStreams.removeValue(forKey: id)
    }
    
    public func contains(id: String) async throws -> Bool {
        return _inMemoryStreams.contains{ $0.key == id }
    }
    
}
