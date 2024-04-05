//
//  File.swift
//  
//
//  Created by 卓俊諺 on 2024/3/28.
//

import Foundation
import EventSourcingPractice
import EventStoreDB

@main
struct InMemory{
    
    static func main() async throws{
        var executor: GenericExecutor<WarehouseProductInMemoryRepository> = .init(repository: .init())
        
        executor.add(command: ReceiveCommand(option: "r", repository: executor.repository))
        executor.add(command: ShipCommand(option: "s", repository: executor.repository))
        executor.add(command: AdjustCommand(option: "i", repository: executor.repository))
        executor.add(command: DeleteCommand(option: "d", repository: executor.repository))
        executor.add(command: HandonCommand(option: "n", repository: executor.repository))
        executor.add(command: ShowEventsCommand(option:"e", repository: executor.repository))
        
        try await executor.execute()
    }
    
}
