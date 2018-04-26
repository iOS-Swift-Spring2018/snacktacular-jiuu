//
//  SpotDetailCollectionViewCell.swift
//  Snacktacular
//
//
//  Created by Brian Wang on 4/26/18.
//

import UIKit

class SpotDetailPhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var photoImageView: UIImageView!

    var photo: Photo! {
        didSet {
            if photoImageView.image != photo.image {
                photoImageView.image = photo.image
            }
        }
    }
}
