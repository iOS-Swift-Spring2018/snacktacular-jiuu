//
//  SpotDetailReviewsTableViewCell.swift
//  Snacktacular
//
//  Created by John Gallaugher on 3/3/18.
//  Copyright © 2018 John Gallaugher. All rights reserved.
//

import UIKit

class SpotDetailReviewsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var reviewTitleLabel: UILabel!
    @IBOutlet weak var reviewTextLabel: UILabel!
    @IBOutlet var starImageCollection: [UIImageView]!
    
    var review: Review! {
        didSet {
            reviewTitleLabel.text = review.title
            reviewTextLabel.text = review.text
            for starNumber in 0...4 {
                if starNumber < review.rating {
                    starImageCollection[starNumber].image = UIImage(named: "star-filled")
                } else {
                    starImageCollection[starNumber].image = UIImage(named: "star-empty")
                }
            }
        }
    }
    
}
