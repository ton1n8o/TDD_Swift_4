//
//  ItemManager.swift
//  ToDo
//
//  Created by Antonio da Silva on 11/07/2017.
//  Copyright © 2017 TNTStudios. All rights reserved.
//

import Foundation

class ItemManager: NSObject {
    
    // MARK: - properties
    
    var toDoCount: Int {
        return toDoItems.count
    }
    var doneCount: Int {
        return doneItems.count
    }
    
    private var toDoItems: [ToDoItem] = []
    private var doneItems: [ToDoItem] = []
    
    // MARK: - Initializers
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(save), name: .UIApplicationWillResignActive, object: nil)
        
        if let nsDoneItems = NSArray(contentsOf: toDoPathURL()) {
            for dict in nsDoneItems {
                if let doneItem = ToDoItem(dict: dict as! [String : Any]) {
                    toDoItems.append(doneItem)
                }
            }
        }
        
        if let nsDoneItems = NSArray(contentsOf: donePathURL()) {
            for dict in nsDoneItems {
                if let doneItem = ToDoItem(dict: dict as! [String : Any]) {
                    doneItems.append(doneItem)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    func toDoPathURL() -> URL {
        return buildURL(plistName: "toDoItems.plist")
    }
    
    func donePathURL() -> URL {
        return buildURL(plistName: "doneItems.plist")
    }
    
    func buildURL(plistName: String) -> URL {
        let fileURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentURL =  fileURLs.first else {
            print("Somethind went wrong. Documents url could not be found.")
            fatalError()
        }
        return documentURL.appendingPathComponent(plistName)
    }
    
    // MARK: - Actions
    
    @objc func save() {
        
        let nsToDoItems = toDoItems.map { $0.plistDict }
        let nsDoneItems = doneItems.map { $0.plistDict }
        
        if nsToDoItems.isEmpty {
            try? FileManager.default.removeItem(at: toDoPathURL())
        }
        if nsDoneItems.isEmpty {
            try? FileManager.default.removeItem(at: donePathURL())
        }
        
        do {
            
            if nsToDoItems.isEmpty == false {
                let plistDataToDo = try PropertyListSerialization.data(
                    fromPropertyList: nsToDoItems,
                    format: PropertyListSerialization.PropertyListFormat.xml,
                    options: PropertyListSerialization.WriteOptions(0)
                )
                
                try plistDataToDo.write(to: toDoPathURL(), options: Data.WritingOptions.atomic)
            }
            
            if nsDoneItems.isEmpty == false {
                let plistDataDone = try PropertyListSerialization.data(
                    fromPropertyList: nsDoneItems,
                    format: PropertyListSerialization.PropertyListFormat.xml,
                    options: PropertyListSerialization.WriteOptions(0)
                )
                
                try plistDataDone.write(to: donePathURL(), options: Data.WritingOptions.atomic)
            }
            
        } catch {
            print(error)
        }
    }
    
    func add(_ item: ToDoItem) {
        if !toDoItems.contains(item) {
            toDoItems.append(item)
        }
    }
    
    func removeAll() {
        toDoItems.removeAll()
        doneItems.removeAll()
    }
    
    func item(at index: Int) -> ToDoItem {
        return toDoItems[index]
    }
    
    func doneItem(at index: Int) -> ToDoItem {
        return doneItems[index]
    }
    
    func checkItem(at index: Int) {
        let item = toDoItems.remove(at: index)
        doneItems.append(item)
    }
    
    func uncheckItem(at index: Int) {
        let item = doneItems.remove(at: index)
        toDoItems.append(item)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        save()
    }
    
}
