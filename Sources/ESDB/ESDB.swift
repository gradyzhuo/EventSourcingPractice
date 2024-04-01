//
//  File.swift
//  
//
//  Created by 卓俊諺 on 2024/3/28.
//

import Foundation
import EventSourcingPractice


@main
struct Publisher {
    
    public static func main() async throws{
        
        var product = WarehouseProduct(sku: "ABC1234")
        try product.receive(quantity: 900)
        print("product:", product.quantityOnHand)
        try product.receive(quantity: 100)
        try product.ship(quantity: 50)
        
        print("product:", product.quantityOnHand)
        
        var repo = WarehouseProductInMemoryRepository()
        repo.save(product: product)
        
        var p = try repo.get(sku: "ABC1234")
        print("quantity:", p.quantityOnHand)
        for event in p.events {
            switch event{
            case let receivedEvent as ProductReceived:
                try p.receive(quantity: receivedEvent.quantity)
            case let shipedEvent as ProductShiped:
                try p.ship(quantity: shipedEvent.quantity)
            case let event as InventoryAdjusted:
                try p.adjustInventory(quantity: event.quantity, reason: "")
            default:
                continue
            }
        }
        print("quantity:", p.quantityOnHand)
//        print(x)
    }
    

}


