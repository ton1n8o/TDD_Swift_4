//
//  ItemListViewControllerTest.swift
//  ToDoTests
//
//  Created by Antonio da Silva on 13/07/2017.
//  Copyright © 2017 TNTStudios. All rights reserved.
//

import XCTest
@testable import ToDo

class ItemListViewControllerTest: XCTestCase {
    
    var sut: ItemListViewController!
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ItemListViewController")
        
        sut = viewController as! ItemListViewController
        _ = sut.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_TableView_AfterViewDidLoad_IsNotNil() {
        XCTAssertNotNil(sut.tableView)
    }
    
    func test_LoadingView_SetsTableViewDataSource() {
        XCTAssertTrue(sut.tableView?.dataSource is ItemListDataProvider)
    }
    
    func test_LoadingView_SetsTableViewDelegate() {
        XCTAssertTrue(sut.tableView?.delegate is ItemListDataProvider)
    }
    
    func test_LoadingView_SetsDataSourceAndDelegateToSameObject() {
        XCTAssertEqual(sut.tableView?.dataSource as? ItemListDataProvider,
                       sut.tableView?.delegate as? ItemListDataProvider)
    }
    
    func test_ItemListViewController_HasAddBarButtonWithSelfAsTarget() {
        let target = sut.navigationItem.rightBarButtonItem?.target
        XCTAssertEqual(target as? UIViewController, sut)
    }
    
    func test_AddItem_PresentsAddItemViewController() {
        XCTAssertNil(sut.presentedViewController)
        
        configRootView()
        
        XCTAssertNotNil(sut.presentedViewController)
        XCTAssertTrue(sut.presentedViewController is InputViewController)
        let inputViewController = sut.presentedViewController as! InputViewController
        XCTAssertNotNil(inputViewController.titleTextField)
    }
    
    func testItemListVC_SharesItemManagerWithInputVC() {
        
        configRootView()
        
        guard let inputViewController = sut.presentedViewController as? InputViewController else {
            XCTFail(); return
        }
        
        guard let inputItemManager = inputViewController.itemManager else {
            XCTFail(); return
        }
        
        XCTAssertTrue(sut.itemManager === inputItemManager)
        
    }
    
    func configRootView() {
        guard let addButton = sut.navigationItem.rightBarButtonItem else {
            XCTFail(); return
        }
        guard let action = addButton.action else { XCTFail(); return }
        
        UIApplication.shared.keyWindow?.rootViewController = sut
        
        sut.performSelector(onMainThread: action, with: addButton, waitUntilDone: true)
    }
    
    func test_ViewDidLoad_SetsItemManagerToDataProvider() {
        XCTAssertTrue(sut.itemManager === sut.dataProvider.itemManager)
    }
    
    func test_ReloadData_MustBeCalled_OnceAnItemIsAdded() {
        let tableView = MockTableView()
        sut.tableView = tableView
        
        sut.beginAppearanceTransition(true, animated: true)
        sut.endAppearanceTransition()
        
        XCTAssertTrue(tableView.realodDataGotCalled)
    }
    
    func testItemSelectedNotification_PushesDetailVC() {
        let mockNavigationController = MockNavigationController(rootViewController: sut)
        UIApplication.shared.keyWindow?.rootViewController = mockNavigationController
        
        sut.itemManager.add(ToDoItem(title: "Foo"))
        
        _ = sut.view
        
        let notification = NSNotification.Name.init("ItemSelectionNotification")
        NotificationCenter.default.post(name: notification, object: self, userInfo: ["index": 0])
        
        guard let detailViewController = mockNavigationController.pushedViewController as? DetailViewController else {
            XCTFail(); return
        }
        
        guard let detailItemManager = detailViewController.itemInfo?.itemManager else {
            XCTFail(); return
        }
        
        guard let index = detailViewController.itemInfo?.index else {
            XCTFail(); return
        }
        
        _ = detailViewController.view
        
        XCTAssertNotNil(detailViewController.titleLabel)
        XCTAssertTrue(detailItemManager === sut.itemManager)
        XCTAssertEqual(index, 0)
    }

}

extension ItemListViewControllerTest {
    class MockTableView: UITableView {
        var realodDataGotCalled = false
        
        override func reloadData() {
            realodDataGotCalled = true
        }
    }
    class MockNavigationController: UINavigationController {
        var pushedViewController: UIViewController?
        override func pushViewController(_ viewController: UIViewController, animated: Bool) {
            pushedViewController = viewController
            super.pushViewController(viewController, animated: animated)
        }
    }
}
