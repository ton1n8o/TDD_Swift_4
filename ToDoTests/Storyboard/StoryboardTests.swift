//
//  StoryboardTests.swift
//  ToDoTests
//
//  Created by Antonio da Silva on 27/07/2017.
//  Copyright © 2017 TNTStudios. All rights reserved.
//

import XCTest
@testable import ToDo

class StoryboardTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_InitialViewController_IsItemListViewController() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let navigationViewController  = storyboard.instantiateInitialViewController() as! UINavigationController
        let rootViewController = navigationViewController.viewControllers[0]
        
        XCTAssertTrue(rootViewController is ItemListViewController)
    }
    
}
