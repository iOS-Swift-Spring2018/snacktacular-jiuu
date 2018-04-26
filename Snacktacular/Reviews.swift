//
//  Reviews.swift
//  Snacktacular
//
//
//  Created by Brian Wang on 4/26/18.
//

import Foundation
import Firebase

class Reviews {
    var reviewArray = [Review]()
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(spot: Spot, completed: @escaping () -> ()) {
        guard spot.documentID != "" else {
            return
        }
        db.collection("spots").document(spot.documentID).collection("reviews").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("*** ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return
            }
            self.reviewArray = []
            print("*** there are \(querySnapshot!.documents.count) documents in the reviews snapshot for \(spot.name)")
            for document in querySnapshot!.documents {
                let review = Review(dictionary: document.data())
                review.documentID = document.documentID
                self.reviewArray.append(review)
            }
            completed()
        }
    }
}
