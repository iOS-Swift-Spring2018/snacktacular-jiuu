//
//  PhotoTableViewController.swift
//  Snacktacular
//
//
//  Created by Brian Wang on 4/26/18.
//

import UIKit
import Firebase

class PhotoTableViewController: UITableViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    
    var spot: Spot!
    var photo: Photo!
    let dateFormatter = DateFormatter()
    let currentUser = Auth.auth().currentUser!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard spot != nil else {
            print("*** ERROR: for some reason spot was nil when PhotoTableViewController loaded.")
            return
        }
        
        // These three lines will dismiss the keyboard when one taps outside of a textField
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        // Set up DateFormatter
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        if photo == nil {
            photo = Photo()
        }
        configureUserInterface()
    }
    
    func configureUserInterface() {
        photoImageView.image = photo.image
        descriptionField.text = photo.description
        let formattedDate = dateFormatter.string(from: photo.date)
        dateLabel.text = formattedDate
        if photo.documentID != "" { // this is an existing photo
            if photo.postingUserID != currentUser.uid  { // Not posted by current user
                saveBarButton.title = ""
                cancelBarButton.title = ""
                descriptionField.isEnabled = false
                descriptionField.backgroundColor = UIColor.white
                // Get posting user's e-mail address to put into postedByLabel:
                let postingUser = SnackUser(userID: photo.postingUserID)
                postingUser.loadUser() {success in
                    if success {
                        self.userLabel.text = postingUser.email
                    } else {
                        self.userLabel.text = "unknown user"
                    }
                }
            } else { // posted by user so it can be edited
                self.navigationItem.leftItemsSupplementBackButton = false // hide < Back
                deleteButton.isHidden = false // show Delete button
                descriptionField.addBorder(borderWidth: 0.5, cornerRadius: 5.0)
                userLabel.text = "You"
                saveBarButton.title = "Update"
            }
        } else { // must be a new review
            userLabel.text = "You"
            descriptionField.addBorder(borderWidth: 0.5, cornerRadius: 5.0)
        }
        enableDisableSaveButton()
    }
    
    func enableDisableSaveButton() {
        if descriptionField.text != "" {
            saveBarButton.isEnabled = true
        } else {
            saveBarButton.isEnabled = false
        }
    }
    
    func leaveViewController() {
        let isPrestingInAddMode = presentingViewController is UINavigationController
        if isPrestingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func saveThenSegue() {
        photo.description = descriptionField.text!
        photo.saveData(spot: self.spot) {success in
            if success {
                self.leaveViewController()
            } else {
                print("Can't unwind segue from PhotoTableViewController because of Photo saving error")
            }
        }
    }
    
    @IBAction func descriptionChanged(_ sender: UITextField) {
        enableDisableSaveButton()
    }
    
    @IBAction func descriptionDoneKeyPressed(_ sender: UITextField) {
        saveThenSegue()
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        photo.deleteData(spot: spot) { (success) in
            if success {
                self.leaveViewController()
            } else {
                print("Can't unwind segue from PhotoTableViewController because of Photo saving error")
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        self.leaveViewController()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        saveThenSegue()
    }
}
