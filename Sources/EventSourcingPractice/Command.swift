//
//  File.swift
//  
//
//  Created by 卓俊諺 on 2024/4/1.
//

import Foundation

//(R) 接收商品
//(S) 商品派送
//(I) 調整商品數量
//(N) 現在存貨數量
//(E) 全部事件

public protocol Command {
    var option: String { get }
    var name: String { get }
    
    func perform(product: inout WarehouseProduct) async throws
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
    public let option: String = "r"
    public let name: String = "接收商品"
    public let repository: WarehouseProductRepository
    
    public init(repository: WarehouseProductRepository) {
        self.repository = repository
    }
    
    public func perform(product: inout WarehouseProduct) async throws{
        let quantity = try inputQuantity(prompt: "請輸入接收商品數量：")
        try product.receive(quantity: quantity)
        try await repository.save(product: product)
        product.clearDomainEvents()
    }
}

public struct ShipCommand: Command {
    public let option: String = "s"
    public let name: String = "商品派送"
    public let repository: WarehouseProductRepository
    
    public init(repository: WarehouseProductRepository) {
        self.repository = repository
    }
    
    public func perform(product: inout WarehouseProduct) async throws{
        do{
            let quantity = try inputQuantity(prompt: "請輸入出貨商品數量：")
            try product.ship(quantity: quantity)
            try await repository.save(product: product)
        } catch let EventSourcingError.invalidDomainException(message: message){
            print(message)
        }
        product.clearDomainEvents()
    }
}

public struct AdjustCommand: Command {
    public let option: String = "i"
    public let name: String = "調整商品數量"
    public let repository: WarehouseProductRepository
    
    public init(repository: WarehouseProductRepository) {
        self.repository = repository
    }
    
    public func perform(product: inout WarehouseProduct) async throws{
        let quantity = try inputQuantity(prompt: "請輸入要調整商品的數量：")
        let reason = try inputString(prompt: "請輸入調整的理由：")
        try product.adjustInventory(quantity: quantity, reason: reason)
        try await repository.save(product: product)
    }
}

public struct HandonCommand: Command {
    public let option: String = "n"
    public let name: String = "現在存貨數量"
    public let repository: WarehouseProductRepository
    
    public init(repository: WarehouseProductRepository) {
        self.repository = repository
    }
    
    public func perform(product: inout WarehouseProduct) async throws{
        print("現在商品的數量:", product.quantityOnHand)
    }
}

public struct ShowEventsCommand: Command {
    public let option: String = "e"
    public let name: String = "全部事件"
    public let repository: WarehouseProductRepository
    
    public init(repository: WarehouseProductRepository) {
        self.repository = repository
    }
    
    public func perform(product: inout WarehouseProduct) async throws{
        let product = try await repository.get(sku: product.id)
        for event in product.events{
            print(event)
        }
    }
}
