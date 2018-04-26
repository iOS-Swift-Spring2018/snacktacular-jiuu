//
//  Review.swift
//  Snacktacular
//
//
//  Created by Brian Wang on 4/26/18.
//

import Foundation
import Firebase

class Review {

    var title: String
    var text: String
    var rating: Int
    var reviewerUserID: String
    var date: Date
    var documentID: String
    
    var dictionary: [String: Any] {
        return ["title": title, "text": text, "rating": rating, "reviewerUserID": reviewerUserID, "date": date]
    }
    
    init(title: String, text: String, rating: Int, reviewerUserID: String, documentID: String, date: Date) {
        self.title = title
        self.text = text
        self.rating = rating
        self.reviewerUserID = reviewerUserID
        self.documentID = documentID
        self.date = Date()
    }
    
    convenience init() {
        let reviewerUserID = Auth.auth().currentUser?.uid ?? ""
        self.init(title: "", text: "", rating: 0, reviewerUserID: reviewerUserID, documentID: "", date: Date())
    }
    
    convenience init(dictionary: [String: Any]) {
        let title = dictionary["title"] as! String? ?? ""
        let text = dictionary["text"] as! String? ?? ""
        let rating = dictionary["rating"] as! Int? ?? 0
        let reviewerUserID = dictionary["reviewerUserID"] as! String? ?? ""
        let date = dictionary["date"] as! Date? ?? Date()
        self.init(title: title, text: text, rating: rating, reviewerUserID: reviewerUserID, documentID: "", date: date)
    }
    
    convenience init(reviewerUserID: String) {
        let reviewerUserID = Auth.auth().currentUser?.uid ?? "" // New review? It must be posted by the current user.
        self.init(title: "", text: "", rating: 0, reviewerUserID: reviewerUserID, documentID: "", date: Date())
    }

    func saveData(spot: Spot, completion: @escaping (Bool) -> ())  {

        // set up transaction
        // Get current Spot Avg. review
        // Update avg. reveiw value & # of reviews
        // Save new spot data
        // save new or updated review
        // execute transactions, with true or false result
        
        let db = Firestore.firestore()
        
        // For adding a new review... [will also need to do updating a review]
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            // rather than use Spot data, get a fresh Spot just in case someone updated our Spot between the time it was read it into the ReviewTableViewController and the time we called this update.
            let spotRef = db.collection("spots").document(spot.documentID)
            guard let document = try? transaction.getDocument(spotRef) else {
                print("*** ERROR trying to get document for spotRef = \(spotRef)")
                return nil
            }
            guard let dictionary = document.data() else {
                print("*** ERROR trying to get dictionary from document.data() of spotRef = \(spotRef)")
                return nil
            }
            // Update spot values with the dictionary you just got back. Make sure you've created an updateWith method in Spot
            spot.getUpdatedReviewInfoWith(dictionary: dictionary)
            // Update the restaurant's rating and rating count and post the new review at the
            // same time.
            let newAverage = (Double(spot.numberOfReviews) * spot.averageRating + Double(self.rating))
                / Double(spot.numberOfReviews + 1)
            spot.averageRating = newAverage
            spot.numberOfReviews += 1
            print(" >>> newAverage = \(spot.averageRating)")
            print(" >>> place.numberOfReviews = \(spot.numberOfReviews)")
            var reviewRef: DocumentReference!
            // if we HAVE saved a record, we'll have an ID
            if self.documentID != "" {
                reviewRef = spotRef.collection("reviews").document(self.documentID)
            } else {
                reviewRef = spotRef.collection("reviews").document()
            }
            transaction.setData(self.dictionary, forDocument: reviewRef)
            
            transaction.updateData([
                "averageRating": spot.averageRating,
                "numberOfReviews": spot.numberOfReviews
                ], forDocument: spotRef)
            return nil
        }) { (object, error) in
            if let error = error {
                print("*** ERROR: problem executing transaction in review.saveReview. \(error.localizedDescription)")
                completion(false)
            } else {
                print("^^^ Looks like transaction save succeeded!")
                completion(true)
            }
        }
    }
    
    func deleteData(spot: Spot, completion: @escaping (Bool) -> ())  {
        let db = Firestore.firestore()
        
        // For deleting a review...
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            // rather than use Spot data, get a fresh Spot just in case someone updated our Spot between the time it was read it into the ReviewTableViewController and the time we called this update.
            let spotRef = db.collection("spots").document(spot.documentID)
            guard let document = try? transaction.getDocument(spotRef) else {
                print("*** ERROR trying to get document for spotRef = \(spotRef)")
                return nil
            }
            guard let dictionary = document.data() else {
                print("*** ERROR trying to get dictionary from document.data() of spotRef = \(spotRef)")
                return nil
            }
            // Update spot values with the dictionary you just got back. Make sure you've created an updateWith method in Spot
            spot.getUpdatedReviewInfoWith(dictionary: dictionary)
            // Update the restaurant's rating and rating count and post the new review at the
            // same time.
            let newAverage = (Double(spot.numberOfReviews) * spot.averageRating - Double(self.rating))
                / Double(spot.numberOfReviews - 1)
            spot.averageRating = newAverage
            spot.numberOfReviews -= 1
            print(" >>> newAverage = \(spot.averageRating)")
            print(" >>> spot.numberOfReviews = \(spot.numberOfReviews)")
            var reviewRef: DocumentReference!
            reviewRef = spotRef.collection("reviews").document(self.documentID)
            transaction.deleteDocument(reviewRef)

            transaction.updateData([
                "averageRating": spot.averageRating,
                "numberOfReviews": spot.numberOfReviews
                ], forDocument: spotRef)
            return nil
        }) { (object, error) in
            if let error = error {
                print("*** ERROR: problem executing transaction in review.deleteData. \(error.localizedDescription)")
                completion(false)
            } else {
                print("^^^ Looks like transaction delete succeeded!")
                completion(true)
            }
        }
    }
}
