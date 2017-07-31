//
//  DetailViewViewController.swift
//  ToDo
//
//  Created by Antonio da Silva on 20/07/2017.
//  Copyright © 2017 TNTStudios. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var placeLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var mapView: MKMapView!
    
    var itemInfo: (itemManager: ItemManager, index: Int)?
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let itemInfo = itemInfo else { return }
        
        let item = itemInfo.itemManager.item(at: itemInfo.index)
        
        titleLabel.text = item.title
        placeLabel.text = item.location?.name
        descriptionLabel.text = item.itemDescription
        
        if let timestamp = item.timestamp {
            let date = Date(timeIntervalSince1970: timestamp)
            dateLabel.text = dateFormatter.string(from: date)
        }
        
        if let coordinate = item.location?.coordinate {
            let region = MKCoordinateRegionMakeWithDistance(coordinate, 100, 100)
            mapView.region = region
        }
    }
    
    func checkItem() {
        if var itemInfo = itemInfo {
            itemInfo.itemManager.checkItem(at: itemInfo.index)
            self.itemInfo = itemInfo
        }
    }

}
