//
//  SpotsListTableViewCell.swift
//  Snacktacular
//
//  Created by John Gallaugher on 3/7/18.
//  Copyright © 2018 John Gallaugher. All rights reserved.
//

import UIKit
import CoreLocation

class SpotsListTableViewCell: UITableViewCell {

    @IBOutlet weak var spotNameLabel: UILabel!
    @IBOutlet weak var spotDistanceLabel: UILabel!
    @IBOutlet weak var spotRatingLabel: UILabel!
    
    var currentLocation: CLLocation!
    var spot: Spot! {
        didSet {
            spotNameLabel.text = spot.name
            spotRatingLabel.text = "Avg. Rating: \(spot.averageRating.roundTo(places: 1))"
            
            var distanceInMiles = ""
            if currentLocation != nil {
                let distanceInMeters = spot.location.distance(from: currentLocation)
                distanceInMiles = "Distance: " + String(format: "%.2f", (distanceInMeters * 0.00062137)) + " miles"
            }
            spotDistanceLabel.text = distanceInMiles
        }
    }
    
}
