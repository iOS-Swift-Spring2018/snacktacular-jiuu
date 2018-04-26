//
//  Photos.swift
//  Snacktacular
//
//
//  Created by Brian Wang on 4/26/18.
//

import Foundation
import Firebase

class Photos {
    var photoArray = [Photo]()
    var db: Firestore!
    var storage: Storage!
    
    init() {
        db = Firestore.firestore()
        storage = Storage.storage()
    }
    
    func loadData(spot: Spot, completed: @escaping () -> ()) {
        guard spot.documentID != "" else {
            return
        }
        db.collection("spots").document(spot.documentID).collection("photos").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("*** ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.photoArray = []
            for document in querySnapshot!.documents {
                let photo = Photo(dictionary: document.data())
                photo.documentID = document.documentID
                self.photoArray.append(photo)
            }
            
            // Since you’re using the synchronous wait method which blocks the current thread, you use async to place the entire method into a background queue to ensure you don’t block the main thread.
            DispatchQueue.global(qos: .userInitiated).async {
                // Create the dispatch group
                let downloadGroup = DispatchGroup()
                let bucketID = spot.documentID
                for photo in self.photoArray {
                    let photoRef = self.storage.reference().child(bucketID+"/"+photo.documentID)
                    print("Loading imageReference for: \(photoRef)")
                    // Call enter() to notify the group that a task has started. You must balance out the number of enter() calls with the number of leave() calls or your app will crash
                    downloadGroup.enter()
                    photoRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
                        if error != nil {
                            print("An error occurred while reading data from file ref: \(photoRef), error \(error!.localizedDescription)")
                        } else {
                            let image = UIImage(data: data!)
                            photo.image = image!
                        }
                        // .leave notifies the group that work that was started is now done.
                        downloadGroup.leave()
                    }
                }
                // call wait() to block the current thread while waiting for tasks’ completion. This waits forever which is fine because we should complete each task with either data loaded, or an error - either way that task will be done. You can use wait(timeout:) to specify a timeout and bail out on waiting after a specified time.
                downloadGroup.wait()
                // At this point, you are guaranteed that all image tasks have either completed or timed out. You then make a call back to the main queue to run your completion closure.
                DispatchQueue.main.async {
                    completed()
                }
            } // last curly for DispatchQueue.global
        }
    }
}
