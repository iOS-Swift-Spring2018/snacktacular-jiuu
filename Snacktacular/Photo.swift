//
//  Photo.swift
//  Snacktacular
//
//
//  Created by Brian Wang on 4/26/18.
//

import Foundation
import Firebase

class Photo {
    var image: UIImage!
    var description: String
    var postingUserID: String
    var date: Date
    var documentID: String
    
    var dictionary: [String: Any] {
        return ["description": description, "postingUserID": postingUserID, "date": date ]
    }
    
    init(image: UIImage, description: String, postingUserID: String, date: Date, documentID: String) {
        self.image = image
        self.description = description
        self.postingUserID = postingUserID
        self.date = date
        self.documentID = documentID
    }
    
    convenience init() {
        let postingUserID = Auth.auth().currentUser?.uid ?? ""
        self.init(image: UIImage(), description: "", postingUserID: postingUserID, date: Date(), documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let image = dictionary["image"] as! UIImage? ?? UIImage()
        let description = dictionary["description"] as! String? ?? ""
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        let date = dictionary["date"] as! Date? ?? Date()
        self.init(image: image, description: description, postingUserID:
            postingUserID, date: date, documentID: "")
    }
    
    func saveData(spot: Spot, completion: @escaping (Bool) -> ())  {
        let db = Firestore.firestore()
        
        // Create the dictionary representing data we want to save
        let dataToSave: [String: Any] = self.dictionary
        
        // if we HAVE saved a record, we'll have an ID
        if self.documentID != "" {
            let ref = db.collection("spots").document(spot.documentID).collection("photos").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print("*** ERROR: updating document \(error.localizedDescription)")
                    completion(false)
                    return
                } else {
                    print("Photo updated with reference ID \(ref.documentID)")
                }
            }
        } else { // Otherwise we don't have a document ID so we need to create the ref ID and save a new document
            let ref = db.collection("spots").document(spot.documentID).collection("photos").addDocument(data: dataToSave) { (error) in
                if let error = error {
                    print("*** ERROR: adding photo document \(error.localizedDescription)")
                    completion(false)
                }
            }
            self.documentID = ref.documentID
        }
        
        // 1. What's the data we're going to save (to Storage)? photoData
        // Convert image to type Data so it can be saved to Storage
        guard let photoData = UIImageJPEGRepresentation(self.image, 0.5) else {
            print("*** ERROR: creating imageData from JPEGRepresentation")
            return completion(false)
        }
        // 2. Where are we going to save it (to Storage, not Firestore)? placeStorageRef
        let storage = Storage.storage()
        let storageRef = storage.reference().child(spot.documentID)
        // Create a ref to the file you want to upload
        let photoRef = storageRef.child(self.documentID)
        // 3. Save it & check the result
        photoRef.putData(photoData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("*** ERROR: \(error.localizedDescription) saving image \(self.documentID) to StorageReference \(photoRef).")
                completion(false)
            }
            print("*** Just Completed Save")
            completion(true)
        }
    }
    
    func deleteData(spot: Spot, completion: @escaping (Bool) -> ())  {
        // First delete photo reference
        let db = Firestore.firestore()
        db.collection("spots").document(spot.documentID).collection("photos").document(documentID).delete() { error in
            if let error = error {
                print("ERROR: deleting photo documentID \(self.documentID) \(error.localizedDescription)")
                return completion(false)
            } else {
                self.documentID = "photo documentID \(self.documentID) successfully deleted"
            }
        }
        
        // Then delete photo
        let storage = Storage.storage()
        let storageRef = storage.reference().child(spot.documentID).child(self.documentID)
        // Delete the file
        storageRef.delete { error in
            if let error = error {
                print("*** ERROR: \(error.localizedDescription) In deletePhoto trying to delete \(storageRef)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }

}
