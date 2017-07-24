//
//  InputViewControllerTests.swift
//  ToDoTests
//
//  Created by Antonio da Silva on 21/07/2017.
//  Copyright © 2017 TNTStudios. All rights reserved.
//

import XCTest
import CoreLocation
@testable import ToDo

class InputViewControllerTests: XCTestCase {
    
    var sut: InputViewController!
    var placeMark: MockPlaceMarker!
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "InputViewController") as! InputViewController
        _ = sut.view
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_HasTitleTextField() {
        XCTAssertNotNil(sut.titleTextField)
    }
    
    func test_HasDateTextField() {
        XCTAssertNotNil(sut.dateTextField)
    }
    
    func test_HasLocationTextField() {
        XCTAssertNotNil(sut.locationTextField)
    }
    
    func test_HasAddressTextField() {
        XCTAssertNotNil(sut.addressTextField)
    }
    
    func test_HasDrescriptionTextField() {
        XCTAssertNotNil(sut.descriptionTextField)
    }
    
    func test_HasSaveButton() {
        XCTAssertNotNil(sut.saveButton)
    }
    
    func test_HasCancelButton() {
        XCTAssertNotNil(sut.cancelButton)
    }
    
    func test_Save_UsesGeocoderToGetCoordinateFromAddress() {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let timestamp = 1456070400.0 // 1456070400
        let date = Date(timeIntervalSince1970: timestamp)
        
        sut.titleTextField.text = "Foo"
        sut.dateTextField.text = dateFormatter.string(from: date)
        sut.locationTextField.text = "Bar"
        sut.addressTextField.text = "Infinite Loop 1, Cupertino"
        sut.descriptionTextField.text = "Baz"
        
        let mockGeocoder = MockGeocoder()
        sut.geocoder = mockGeocoder
        
        sut.itemManager = ItemManager()
        
        sut.save()
        
        placeMark = MockPlaceMarker()
        let coordinate = CLLocationCoordinate2DMake(37.3316851, -122.0300674)
        
        placeMark.mockCoordinate = coordinate
        mockGeocoder.completionHandler?([placeMark], nil)
        
        let item = sut.itemManager?.item(at: 0)
        
        let location = Location(name: "Bar", coordinate: coordinate)
        let testItem = ToDoItem(
            title: "Foo",
            itemDescription: "Baz",
            timestamp: timestamp,
            location: location
        )
        
        XCTAssertEqual(item, testItem)
        
    }
    
    func test_SaveButtonHasSaveAction() {
        let saveButton = sut.saveButton
        
        guard let actions = saveButton?.actions(forTarget: sut, forControlEvent: .touchUpInside) else {
            XCTFail(); return
        }
        
        XCTAssertTrue(actions.contains("save"))
    }
    
}

extension InputViewControllerTests {
    class MockGeocoder: CLGeocoder {
        var completionHandler: CLGeocodeCompletionHandler?
        
        override func geocodeAddressString(_ addressString: String, completionHandler: @escaping CLGeocodeCompletionHandler) {
            self.completionHandler = completionHandler
        }
    }
    class MockPlaceMarker: CLPlacemark {
        var mockCoordinate: CLLocationCoordinate2D?
        
        override var location: CLLocation? {
            guard let coordinate = mockCoordinate else {
                return CLLocation()
            }
            return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
    }
}
