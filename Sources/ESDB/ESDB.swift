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
struct ESDB {
    public static func main() async throws{
        try EventStoreDB.using(settings: .parse(connectionString: "esdb://localhost:2113?tls=false"))
        var executor: GenericExecutor<WarehouseProductEventStoreRepository> = try .init(repository: .init())
        
        executor.add(command: ReceiveCommand(repository: executor.repository))
        executor.add(command: ShipCommand(repository: executor.repository))
        executor.add(command: AdjustCommand(repository: executor.repository))
        executor.add(command: HandonCommand(repository: executor.repository))
        executor.add(command: ShowEventsCommand(repository: executor.repository))
        
        try await executor.execute()
        
    }
    

}


