//
//  File.swift
//  
//
//  Created by 卓俊諺 on 2024/4/1.
//

import Foundation
import EventStoreDB

//(R) 接收商品
//(S) 商品派送
//(I) 調整商品數量
//(N) 現在存貨數量
//(E) 全部事件

public protocol Command {
    var option: String { get }
    var name: String { get }
    
    func perform(sku: String) async throws
}

func inputQuantity(prompt: String) throws ->Int{
    print(prompt, terminator: "")
    guard let quantityString = readLine(), let quantity = Int(quantityString) else {
        print("請輸入數字")
        throw IntParsingError.invalidInput("錯誤的數字輸入")
    }
    return quantity
}

func inputString(prompt: String) throws ->String{
    print(prompt, terminator: "")
    guard let string = readLine() else {
        throw InputError.invalidInput("錯誤的輸入")
    }
    return string
}

public struct ReceiveCommand: Command {
    public let option: String
    public let name: String = "接收商品"
    public let repository: WarehouseProductRepository
    
    public init(option: String, repository: WarehouseProductRepository) {
        self.option = option
        self.repository = repository
    }
    
    public func perform(sku: String) async throws{
        var product: WarehouseProduct
        do{
            product = try await repository.get(sku: sku)
            product.clearDomainEvents()
        
        } catch ClientError.streamNotFound(_) {
            product = .init(sku: sku)
        }
        
        let quantity = try inputQuantity(prompt: "請輸入接收商品數量：")
        try product.receive(quantity: quantity)
        try await repository.save(product: product)
        product.clearDomainEvents()
    }
}

public struct ShipCommand: Command {
    public let option: String
    public let name: String = "商品派送"
    public let repository: WarehouseProductRepository
    
    public init(option: String, repository: WarehouseProductRepository) {
        self.option = option
        self.repository = repository
    }
    
    public func perform(sku: String) async throws{
        do{
            var product: WarehouseProduct = try await repository.get(sku: sku)
            product.clearDomainEvents()
            
            let quantity = try inputQuantity(prompt: "請輸入出貨商品數量：")
            try product.ship(quantity: quantity)
            try await repository.save(product: product)
        } catch EventSourcingError.invalidDomainException(let message){
            print(message)
        } catch ClientError.streamNotFound(_) {
            print("該商品 \(sku) 不存在")
        }
        
    }
}

public struct AdjustCommand: Command {
    public let option: String
    public let name: String = "調整商品數量"
    public let repository: WarehouseProductRepository
    
    public init(option: String, repository: WarehouseProductRepository) {
        self.option = option
        self.repository = repository
    }
    
    public func perform(sku: String) async throws{
        var product: WarehouseProduct
        do{
            product = try await repository.get(sku: sku)
            product.clearDomainEvents()
        
        } catch ClientError.streamNotFound(_) {
            print("該商品 \(sku) 不存在")
            return
        }
        
        let quantity = try inputQuantity(prompt: "請輸入要調整商品的數量：")
        let reason = try inputString(prompt: "請輸入調整的理由：")
        try product.adjustInventory(quantity: quantity, reason: reason)
        try await repository.save(product: product)
    }
}

public struct HandonCommand: Command {
    public let option: String
    public let name: String = "現在存貨數量"
    public let repository: WarehouseProductRepository
    
    public init(option: String, repository: WarehouseProductRepository) {
        self.option = option
        self.repository = repository
    }
    
    public func perform(sku: String) async throws{
        do{
            let product = try await repository.get(sku: sku)
            print("現在商品的數量:", product.quantityOnHand)
        } catch ClientError.streamNotFound(_) {
            print("該商品 \(sku) 不存在")
            return
        }
    }
}

public struct ShowEventsCommand: Command {
    public let option: String
    public let name: String = "全部事件"
    public let repository: WarehouseProductRepository
    
    public init(option: String, repository: WarehouseProductRepository) {
        self.option = option
        self.repository = repository
    }
    
    public func perform(sku: String) async throws{
        do{
            let product = try await repository.get(sku: sku)
            for event in product.events{
                print(event)
            }
        } catch ClientError.streamNotFound(_) {
            print("該商品 \(sku) 不存在")
            return
        }
        
        
    }
}

public struct DeleteCommand: Command {
    public let option: String
    public let name: String = "刪除商品"
    public let repository: WarehouseProductRepository
    
    public init(option: String, repository: WarehouseProductRepository) {
        self.option = option
        self.repository = repository
    }
    
    public func perform(sku: String) async throws{
        do{
            try await repository.delete(sku: sku)
            print("商品編號\(sku) 已刪除")
        } catch ClientError.streamNotFound(_) {
            print("該商品 \(sku) 不存在")
            return
        }
        
    }
}
