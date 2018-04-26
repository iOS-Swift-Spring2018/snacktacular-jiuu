//
//  SnackUsers.swift
//  Snacktacular
//
//
//  Created by Brian Wang on 4/26/18.
//

import Foundation
import Firebase

class SnackUsers {
    var userArray = [SnackUser]()
    var db: Firestore!
    var storage: Storage!
    
    init() {
        db = Firestore.firestore()
        storage = Storage.storage()
    }

    func loadData(completed: @escaping () -> ()) {
        db.collection("users").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return
            }
            self.userArray = []
            for document in querySnapshot!.documents {
                let snackUser = SnackUser(dictionary: document.data())
                self.userArray.append(snackUser)
            }
            completed()
        }
    }

}
