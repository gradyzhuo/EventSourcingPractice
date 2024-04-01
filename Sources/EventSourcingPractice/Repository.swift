//
//  File.swift
//  
//
//  Created by 卓俊諺 on 2024/3/30.
//

import Foundation
import EventStoreDB
import EventSourcing

public protocol WarehouseProductRepository{
    func get(sku: String) async throws -> WarehouseProduct
    func save(product: WarehouseProduct) async throws
}


