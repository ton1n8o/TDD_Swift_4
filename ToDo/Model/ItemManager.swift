//
//  ItemManager.swift
//  ToDo
//
//  Created by Antonio da Silva on 11/07/2017.
//  Copyright © 2017 TNTStudios. All rights reserved.
//

import Foundation

struct ItemManager {
    
    var toDoCount: Int {
        return toDoItems.count
    }
    var doneCount: Int {
        return doneItems.count
    }
    
    private var toDoItems: [ToDoItem] = []
    private var doneItems: [ToDoItem] = []
    
    mutating func add(_ item: ToDoItem) {
        if !toDoItems.contains(item) {
            toDoItems.append(item)
            
        }
    }
    
    mutating func removeAll() {
        toDoItems.removeAll()
        doneItems.removeAll()
    }
    
    func item(at index: Int) -> ToDoItem {
        return toDoItems[index]
    }
    
    func doneItem(at index: Int) -> ToDoItem {
        return doneItems[index]
    }
    
    mutating func checkItem(at index: Int) {
        let item = toDoItems.remove(at: index)
        doneItems.append(item)
    }
    
}
