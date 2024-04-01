//
//  File.swift
//  
//
//  Created by 卓俊諺 on 2024/3/28.
//

import Foundation
import EventSourcingPractice
import EventStoreDB

enum IntParsingError: Error {
    case overflow
    case invalidInput(String)
}

enum InputError: Error {
    case overflow
    case invalidInput(String)
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

@main
struct Subscriber{
    static func main() async throws{
        
        try EventStoreDB.using(settings: .parse(connectionString: "esdb://localhost:2113?tls=false"))
        
        var repository = try WarehouseProductEventStoreRepository()
//        var repository = WarehouseProductInMemoryRepository()
        repeat {
//            goOn = true
            print("""
(R) 接收商品
(S) 商品派送
(I) 調整商品數量
(N) 現在存貨數量
(E) 全部事件
(Q) 離開
請輸入選項：
""", terminator: "")
            let option: String? = readLine()
            guard let op = option?.lowercased(), op != "q" else {
                print("quit")
                break
            }
            
            print("請輸入商品編號：", terminator: "")
            guard let sku = readLine() else {
                break
            }
            
            
                        
            switch op {
            case "r":
                var product = WarehouseProduct(sku: sku)
                let quantity = try inputQuantity(prompt: "請輸入接收商品數量：")
                try product.receive(quantity: quantity)
                try await repository.save(product: product)
//                print("已接收商品 \(quantity) ")
            case "s":
                do{
                    var product = WarehouseProduct(sku: sku)
                    let quantity = try inputQuantity(prompt: "請輸入出貨商品數量：")
                    try product.ship(quantity: quantity)
                    try await repository.save(product: product)
                } catch let EventSourcingError.invalidDomainException(message: message){
                    print(message)
                }
                
//                print("商品派送")
            case "i":
                var product = WarehouseProduct(sku: sku)
                let quantity = try inputQuantity(prompt: "請輸入要調整商品的數量：")
                let reason = try inputString(prompt: "請輸入調整的理由：")
                try product.adjustInventory(quantity: quantity, reason: reason)
                try await repository.save(product: product)
            case "n":
                let product = try await repository.get(sku: sku)
                print("現在商品的數量:", product.quantityOnHand)
            case "e":
                let product = try await repository.get(sku: sku)
                for event in product.events{
                    print(event)
                }
            case "q":
                fallthrough
            default:
                break
            }
        } while true
        
        
    }
}
