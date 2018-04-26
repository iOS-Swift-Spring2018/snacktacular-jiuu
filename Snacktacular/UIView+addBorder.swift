//
//  UIView+addBorder.swift
//  Snacktacular
//
//
//  Created by Brian Wang on 4/26/18.
//

import UIKit

extension UIView {
    func addBorder(borderWidth: CGFloat, cornerRadius: CGFloat) {
        let borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.layer.cornerRadius = cornerRadius
    }
}
