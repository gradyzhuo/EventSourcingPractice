//
//  File.swift
//  
//
//  Created by 卓俊諺 on 2024/4/1.
//

import Foundation
import EventSourcingPractice
import EventStoreDB

extension WarehouseProduct{
//    public mutating func add(event: ReadEvent) throws {
//
//        switch event.recordedEvent.eventType{
//        case "ProductShiped":
//            if let event = try event.recordedEvent.decode(to: ProductShiped.self){
//                try add(event: event)
//            }
//            self.revision = event.recordedEvent.revision
//        case "ProductReceived":
//            if let event = try event.recordedEvent.decode(to: ProductReceived.self){
//                try add(event: event)
//            }
//            self.revision = event.recordedEvent.revision
//        case "InventoryAdjusted":
//            if let event = try event.recordedEvent.decode(to: InventoryAdjusted.self){
//                try add(event: event)
//            }
//            self.revision = event.recordedEvent.revision
//        default:
//            return
//        }
//        
//    }
}
