//
//  File.swift
//  
//
//  Created by 卓俊諺 on 2024/4/1.
//

import Foundation
import EventStoreDB
import EventSourcing


public struct GenericExecutor<Repository: EventSourcing.Repository>{
    package var repository: Repository
    
    var commands: [Command] = []
    var productStorages: [String: WarehouseProduct] = [:]
    
    var menu: String {
        return commands.reduce("") { partialResult, element in
            partialResult + "(\(element.option.uppercased())) \(element.name)\n"
        } + "(Q) 離開\n" + "請輸入選項："
        
    }
    
    package init(repository: Repository) {
        self.repository = repository
    }
    
    public mutating func add<C: Command>(command: C){
        self.commands.append(command)
    }
    
    subscript(option: String)->Command?{
        return self.commands.first{
            $0.option == option
        }
    }
}

public enum IntParsingError: Error {
    case overflow
    case invalidInput(String)
}

public enum InputError: Error {
    case overflow
    case invalidInput(String)
}

extension GenericExecutor where Repository.AggregateRoot == WarehouseProduct{
    
    func inputOption()->String?{
        print(self.menu, terminator: "")
        let option: String? = readLine()
        return option?.lowercased()
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
    
    
    package mutating func execute() async throws{

        repeat {
            guard let op = inputOption(), op != "q", let command = self[op] else {
                print("quit")
                break
            }
            
            print("請輸入商品編號：", terminator: "")
            guard let sku = readLine(), sku != "" else {
                print("請輸入正確的商品編號!")
                continue
            }
            
            var product: WarehouseProduct = try await repository.find(id: sku) ?? .init(id: sku)
            product.clearDomainEvents()
            
            try await command.perform(product: &product)
 
        } while true
        
        
    }
}
