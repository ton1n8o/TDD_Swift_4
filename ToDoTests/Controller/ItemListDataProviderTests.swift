//
//  ItemListDataProviderTests.swift
//  ToDoTests
//
//  Created by Antonio da Silva on 14/07/2017.
//  Copyright © 2017 TNTStudios. All rights reserved.
//

import XCTest
@testable import ToDo

class ItemListDataProviderTests: XCTestCase {
    
    var sut: ItemListDataProvider!
    var tableView: UITableView!
    var controller: ItemListViewController!
    
    override func setUp() {
        super.setUp()
        
        sut = ItemListDataProvider()
        sut.itemManager = ItemManager()
        
        tableView = UITableView()
        tableView.dataSource = sut
        tableView.delegate = sut
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        controller = storyboard.instantiateViewController(withIdentifier: "ItemListViewController") as! ItemListViewController
        
        _ = controller.view
        
        tableView = controller.tableView
        tableView.dataSource = sut
    }
    
    override func tearDown() {
        super.tearDown()
        sut.itemManager?.removeAll()
    }
    
    func test_NumberOfSectionsIsTwo() {
        let numberOfSections = tableView.numberOfSections
        XCTAssertEqual(numberOfSections, 2)
    }
    
    func test_NumberOfRows_InFirstSection_IsToDoCount() {
        
        sut.itemManager?.add(ToDoItem(title: "Foo"))
        
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), 1)
        
        sut.itemManager?.add(ToDoItem(title: "Bar"))
        tableView.reloadData()
        
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), 2)
    }
    
    func test_NumberOfRows_InSecondSection_IsToDoDoneCount() {
        sut.itemManager?.add(ToDoItem(title: "Foo"))
        sut.itemManager?.add(ToDoItem(title: "Bar"))
        sut.itemManager?.checkItem(at: 0)
        
        XCTAssertEqual(tableView.numberOfRows(inSection: 1), 1, "Number of itens on section 1 should be 1")
        
        sut.itemManager?.checkItem(at: 0)
        tableView.reloadData()
        
        XCTAssertEqual(tableView.numberOfRows(inSection: 1), 2, "Number of itens on section 2 should be 2")
    }
    
    func test_CellForRow_ReturnsItemCell() {
        sut.itemManager?.add(ToDoItem(title: "Foo"))
        tableView.reloadData()
        
        let cell = tableView.cellForRow(at: IndexPath.init(row: 0, section: 0))
        
        XCTAssertTrue(cell is ItemCell)
    }
    
    func test_CellForRow_DequeuesCellFromTableView() {
        let mockTableView = MockTableView.mockTableView(withDataSource: sut)
        
        sut.itemManager?.add(ToDoItem(title: "Foo"))
        mockTableView.reloadData()
        
        _ = mockTableView.cellForRow(at: IndexPath(row: 0, section: 0))
        
        XCTAssertTrue(mockTableView.cellGotDequeued)
    }
    
    func test_CellForRow_CallsConfigCell() {
        let mockTableView = MockTableView.mockTableView(withDataSource: sut)
        
        let item = ToDoItem(title: "Foo")
        sut.itemManager?.add(item)
        mockTableView.reloadData()
        
        let cell = mockTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! MockItemCell
        
        XCTAssertEqual(cell.catchedItem, item)
    }
    
    func test_CellForRow_InSectionTwo_CallsConfigCellWithDoneItem() {
        let mockTableView = MockTableView.mockTableView(withDataSource: sut)
        
        sut.itemManager?.add(ToDoItem(title: "Foo"))
        
        let second = ToDoItem(title: "Bar")
        sut.itemManager?.add(second)
        sut.itemManager?.checkItem(at: 1)
        mockTableView.reloadData()
        
        let cell = mockTableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! MockItemCell
        
        XCTAssertEqual(cell.catchedItem, second)
    }
    
    func test_DeleteButton_InFirstSection_ShowsTitleCheck() {
        let path = IndexPath(row: 0, section: 0)
        let deleteButtonTitle = tableView.delegate?.tableView?(
            tableView,
            titleForDeleteConfirmationButtonForRowAt: path
        )
        XCTAssertEqual(deleteButtonTitle, "Check")
    }
    
    func test_DeleteButton_InSecondSection_ShowsTitleUncheck() {
        let path = IndexPath(row: 0, section: 1)
        let deleteButtonTitle = tableView.delegate?.tableView?(tableView, titleForDeleteConfirmationButtonForRowAt: path)
        
        XCTAssertEqual(deleteButtonTitle, "Uncheck")
    }
    
    func test_CheckingAnItem_ChecksInTheItemManager() {
        sut.itemManager?.add(ToDoItem(title: "Foo"))
        
        let path = IndexPath(row: 0, section: 0)
        tableView.dataSource?.tableView?(tableView, commit: .delete, forRowAt: path)
        
        XCTAssertEqual(sut.itemManager?.toDoCount, 0)
        XCTAssertEqual(sut.itemManager?.doneCount, 1)
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), 0)
        XCTAssertEqual(tableView.numberOfRows(inSection: 1), 1)
    }
    
    func test_UnchkingAnItem_UncheckstInTheItemManager() {
        sut.itemManager?.add(ToDoItem(title: "First"))
        sut.itemManager?.checkItem(at: 0)
        tableView.reloadData()
        
        let path = IndexPath(row: 0, section: 1)
        tableView.dataSource?.tableView?(tableView, commit: .delete, forRowAt: path)
        
        XCTAssertEqual(sut.itemManager?.toDoCount, 1)
        XCTAssertEqual(sut.itemManager?.doneCount, 0)
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), 1)
        XCTAssertEqual(tableView.numberOfRows(inSection: 1), 0)
    }
    
    func test_SelectingACell_SendsNotification() {
        let item = ToDoItem(title: "First")
        sut.itemManager?.add(item)
        
        let notificationName = NSNotification.Name.init("ItemSelectionNotification")
        
        expectation(forNotification: notificationName, object: nil) { (notification) -> Bool in
            guard let index = notification.userInfo?["index"] as? Int else {
                return false
            }
            return index == 0
        }
        
        tableView.delegate?.tableView!(
            tableView, didSelectRowAt: IndexPath(row: 0, section: 0)
        )
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
}

extension ItemListDataProviderTests {
    
    class MockTableView: UITableView {
        var cellGotDequeued = false
        
        override func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> UITableViewCell {
            cellGotDequeued =  true
            return super.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        }
        
        class func mockTableView(withDataSource dataSource: UITableViewDataSource) -> MockTableView {
            let frame = CGRect(x: 0, y: 0, width: 320, height: 480)
            let mockTableView = MockTableView(frame: frame, style: .plain)
            mockTableView.dataSource = dataSource
            mockTableView.register(MockItemCell.self, forCellReuseIdentifier: "ItemCell")
            return mockTableView
        }
    }
    
    class MockItemCell : ItemCell {
        
        var catchedItem: ToDoItem?
        
        override func configCell(with item: ToDoItem, checked: Bool = false) {
            catchedItem = item
        }
    }
    
}
