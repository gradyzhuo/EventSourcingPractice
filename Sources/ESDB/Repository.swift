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
    
    let client: EventStoreDB.Client
    
    public init() throws {
        self.client = try .init()
    }
    
    public func get(sku: String) async throws -> WarehouseProduct {
        return try await find(id: sku) ?? .init(sku: sku)
    }
    
    public func save(product: WarehouseProduct) async throws{
        try await save(entity: product)
    }
}


extension WarehouseProductEventStoreRepository: Repository{
    
    public typealias AggregateRoot = WarehouseProduct
    
    public func find(id: String) async throws -> WarehouseProduct? {
        
        let responses = try client.read(streamName: "product::\(id)", cursor: .start) { options in
            options
        }
        
        var iterator = responses.makeAsyncIterator()
        guard let firstResponse = await iterator.next() else {
            return nil
        }
        
        
        func handle(response: StreamClient.Read.Response)->ReadEvent?{
            return switch response.content {
            case .event(readEvent: let event):
                event
            default:
                nil
            }
        }
        
        guard let readEvent = handle(response: firstResponse) else {
            return nil
        }
        
        var warehouseProduct = WarehouseProduct(sku: id)
        try warehouseProduct.add(event: readEvent)
        
        for try await response in responses{
            if let readEvent = handle(response: response){
                try warehouseProduct.add(event: readEvent)
            }
        }
        
        return warehouseProduct
    }
    
    public func save(entity: WarehouseProduct) async throws {
        let events: [EventData] = try entity.events.map{
            return try .init(eventType: "\(type(of: $0))", payload: $0)
        }
        _ = try await client.appendTo(streamName: "product::\(entity.id)", events: events) { options in
            options.expectedRevision(.any)
        }
    }
    
    public func delete(id: String) async throws {
        
    }
    
    public func contains(id: String) async throws -> Bool {
        let responses = try client.read(streamName: "product::\(id)", cursor: .start) { options in
            options.countBy(limit: 1)
        }
        
        return await responses.contains {
            switch $0.content {
            case .event(_):
                return true
            default:
                return false
            }
        }
        
    }
    
}
