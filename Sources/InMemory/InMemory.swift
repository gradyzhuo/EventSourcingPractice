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
        
        executor.add(command: ReceiveCommand(repository: executor.repository))
        executor.add(command: ShipCommand(repository: executor.repository))
        executor.add(command: AdjustCommand(repository: executor.repository))
        executor.add(command: HandonCommand(repository: executor.repository))
        executor.add(command: ShowEventsCommand(repository: executor.repository))
        
        try await executor.execute()
    }
    
}
