//
//  SerialTasks.swift
//  
//
//  Created by 王大爷 on 2023/1/19.
//

import Foundation

public actor SerialTasks<Success> {
    
    private var currentTask: Task<Success, Error>?
    
    public init() {
        // do nothing.
    }

    public func add(
        block: @Sendable @escaping () async throws -> Success,
        priority: TaskPriority = .medium
    ) async throws -> Success {
        let prevTask = self.currentTask
        let nextTask = Task(priority: priority) {
            let _ = await prevTask?.result
            return try await block()
        }
        
        self.currentTask = nextTask
        return try await nextTask.value
    }
}
