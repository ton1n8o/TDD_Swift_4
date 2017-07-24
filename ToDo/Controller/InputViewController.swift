//
//  InputViewController.swift
//  ToDo
//
//  Created by Antonio da Silva on 21/07/2017.
//  Copyright © 2017 TNTStudios. All rights reserved.
//

import UIKit
import CoreLocation

class InputViewController: UIViewController {
    
    // MARK: - UI Elements
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var dateTextField: UITextField!
    @IBOutlet var locationTextField: UITextField!
    @IBOutlet var addressTextField: UITextField!
    @IBOutlet var descriptionTextField: UITextField!
    
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    
    // MARK: - Variables
    
    var itemManager: ItemManager?
    
    lazy var geocoder = CLGeocoder()
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter
    }()
    
    // MARK: - ViewController lifecycle
    
    // MARK: - Actions
    
    @IBAction func save() {
        
        guard let titleString = titleTextField.text, !titleString.isEmpty else {
            return
        }
        
        let date: Date?
        if let dateText = self.dateTextField.text, !dateText.isEmpty {
            date = dateFormatter.date(from: dateText)
        } else {
            date = nil
        }
        
        let descriptionString = descriptionTextField.text
        if let locationName = locationTextField.text, !locationName.isEmpty {
            if let address = addressTextField.text, !address.isEmpty {
                geocoder.geocodeAddressString(address) {
                    [unowned self] (placeMarks, error) -> Void in
                    
                    let placeMarker = placeMarks?.first
                    
                    let location = Location(
                        name: locationName,
                        coordinate: placeMarker?.location?.coordinate
                    )
                    
                    let item = ToDoItem(
                        title: titleString,
                        itemDescription: descriptionString,
                        timestamp: date?.timeIntervalSince1970,
                        location: location
                    )
                    
                    self.itemManager?.add(item)
                }
            }
        }
    }
}
