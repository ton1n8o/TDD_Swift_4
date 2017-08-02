//
//  ItemManagerTests.swift
//  ToDoTests
//
//  Created by Antonio da Silva on 11/07/2017.
//  Copyright © 2017 TNTStudios. All rights reserved.
//

import XCTest

@testable import ToDo

class ItemManagerTests: XCTestCase {
    
    var sut: ItemManager!
    
    override func setUp() {
        super.setUp()
        sut = ItemManager()
    }
    
    override func tearDown() {
        super.tearDown()
        sut.removeAll()
        sut = nil
    }
    
    func test_ToDoCount_Initially_Is_Zero() {
        XCTAssertEqual(sut.toDoCount, 0)
    }
    
    func test_DoneCount_Initially_IsZero() {
        XCTAssertEqual(sut.doneCount, 0)
    }
    
    func test_AddItem_IncreasesToDoCountToOne() {
        sut.add(ToDoItem(title: ""))
        
        XCTAssertEqual(sut.toDoCount, 1)
    }
    
    func test_ItemAt_AfeterAddingAnItem_ReturnsThatItem() {
        let item = ToDoItem(title: "Foo")
        sut.add(item)
        
        let returnedItem = sut.item(at: 0)
        
        XCTAssertEqual(returnedItem, item)
    }
    
    func test_CheckedItemAt_ChangesCount() {
        sut.add(ToDoItem(title: ""))
        
        sut.checkItem(at: 0)
        
        XCTAssertEqual(sut.toDoCount, 0)
        XCTAssertEqual(sut.doneCount, 1)
    }
    
    func test_CheckItemAt_RemovesItFromToDoItems() {
        let first = ToDoItem(title: "First")
        let second = ToDoItem(title: "Second")
        
        sut.add(first)
        sut.add(second)
        
        sut.checkItem(at: 0)
        
        XCTAssertEqual(sut.item(at: 0), second)
    }
    
    func test_DoneItemAt_ReturnsCheckdItem() {
        let item = ToDoItem(title: "Foo")
        sut.add(item)
        
        sut.checkItem(at: 0)
        
        let returnedItem = sut.doneItem(at: 0)
        
        XCTAssertEqual(returnedItem, item)
    }
    
    func test_RemoveAll_ResultsInCountsBeZero() {
        sut.add(ToDoItem(title: "Foo"))
        sut.add(ToDoItem(title: "Bar"))
        sut.checkItem(at: 0)
        
        XCTAssertEqual(sut.toDoCount, 1)
        XCTAssertEqual(sut.doneCount, 1)
        
        sut.removeAll()
        
        XCTAssertEqual(sut.toDoCount, 0)
        XCTAssertEqual(sut.doneCount, 0)
    }
    
    func test_Add_WhenItemIsAlreadyAdded_DoesNotIncreaseCount() {
        sut.add(ToDoItem(title: "Foo"))
        sut.add(ToDoItem(title: "Foo"))
        
        XCTAssertEqual(sut.toDoCount, 1)
    }
    
    func test_ToDoItemsGetSerialized() {
        var itemManager: ItemManager? = ItemManager()
        
        let firstItem = ToDoItem(title: "First")
        itemManager?.add(firstItem)
        
        let secondItem = ToDoItem(title: "Second")
        itemManager?.add(secondItem)
        
        NotificationCenter.default.post(name: .UIApplicationWillResignActive, object: nil)
        
        itemManager = nil
        
        XCTAssertNil(itemManager)
        
        itemManager = ItemManager()
        
        XCTAssertEqual(itemManager?.toDoCount, 2)
        XCTAssertEqual(itemManager?.item(at: 0), firstItem)
        XCTAssertEqual(itemManager?.item(at: 1), secondItem)
    }
    
    func test_DoneItemsGetSerialized() {
        var itemManager: ItemManager? = ItemManager()
        
        let firstItem = ToDoItem(title: "First")
        itemManager?.add(firstItem)
        
        let secondItem = ToDoItem(title: "Second")
        itemManager?.add(secondItem)
        
        itemManager?.checkItem(at: 0)
        itemManager?.checkItem(at: 0)

        NotificationCenter.default.post(name: .UIApplicationWillResignActive, object: nil)
        
        itemManager = nil
        
        XCTAssertNil(itemManager)
        
        itemManager = ItemManager()
        
        XCTAssertEqual(itemManager?.doneCount, 2)
        XCTAssertEqual(itemManager?.doneItem(at: 0), firstItem)
        XCTAssertEqual(itemManager?.doneItem(at: 1), secondItem)
    }
    
}
