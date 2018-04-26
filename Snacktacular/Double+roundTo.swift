//
//  Double+roundTo.swift
//  Snacktacular
//
//
//  Created by Brian Wang on 4/26/18.
//

import Foundation

extension Double {
    func roundTo(places: Double) -> Double {
        let tenToPower = pow(10.0, places)
        let rounded = (self * tenToPower).rounded() / tenToPower
        return rounded
    }
}
