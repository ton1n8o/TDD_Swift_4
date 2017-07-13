//
//  ToDoItem.swift
//  ToDo
//
//  Created by Antonio da Silva on 10/07/2017.
//  Copyright © 2017 TNTStudios. All rights reserved.
//

import Foundation

struct ToDoItem : Equatable {
    
    let title: String
    let itemDescription: String?
    let timestamp: Double?
    let location: Location?
    
    init(title: String, itemDescription: String? = nil, timestamp: Double? = nil,
        location: Location? = nil) {
        self.title = title
        self.itemDescription = itemDescription
        self.timestamp = timestamp
        self.location = location
    }
    
    // MARK: - Equatable
    
    static func ==(lhs: ToDoItem, rhs: ToDoItem) -> Bool {
        if lhs.location?.name != rhs.location?.name {
            return false
        }
        return true
    }
    
}

