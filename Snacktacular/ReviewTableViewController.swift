//
//  ReviewTableViewController.swift
//  Snacktacular
//
//
//  Created by Brian Wang on 4/26/18.
//

import UIKit
import Firebase

class ReviewTableViewController: UITableViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var postedByLabel: UILabel!
    @IBOutlet weak var reviewTitle: UITextField!
    @IBOutlet weak var reviewDateLabel: UILabel!
    @IBOutlet weak var reviewView: UITextView!
    @IBOutlet weak var reviewDate: UILabel!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet var starButtonCollection: [UIButton]!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var buttonsBackgroundView: UIView!
    
    let dateFormatter = DateFormatter()
    var review: Review!
    var spot: Spot!
    var currentUser = Auth.auth().currentUser
    var rating = 0 {
        didSet {
            review.rating = rating
            for index in 0...4 {
                let image = UIImage(named: (starButtonCollection[index].tag < review.rating ? "star-filled": "star-empty"))
                starButtonCollection[index].setImage(image, for: .normal)
            }
            print(">>> new Rating \(rating)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard spot != nil else {
            print("*** ERROR: No spot passed to ReviewTableViewController.swift")
            return
        }
        
        // Set up DateFormatter
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        if review == nil {
            review = Review()
        }
        updateUserInterface()
    }
    
    func updateUserInterface() {
        nameLabel.text = spot.name
        addressLabel.text = spot.address
        reviewTitle.text = review.title
        reviewView.text = review.text
        rating = review.rating
        let formattedDate = dateFormatter.string(from: review.date)
        reviewDateLabel.text = "posted: \(formattedDate)"
        if review.documentID != "" { // this is an existing review
            if review.reviewerUserID != currentUser?.uid  { // Not posted by user
                saveBarButton.title = ""
                cancelBarButton.title = ""
                // Get posting user's e-mail address to put into postedByLabel:
                let postingUser = SnackUser(userID: review.reviewerUserID)
                postingUser.loadUser() {success in
                    if success {
                        self.postedByLabel.text = "Posted by: \(postingUser.email)"
                    } else {
                        self.postedByLabel.text = "Posted by: unknown user"
                    }
                }
                for starButton in starButtonCollection {
                    starButton.backgroundColor = UIColor.white
                    starButton.adjustsImageWhenDisabled = false
                    starButton.isEnabled = false
                }
                reviewTitle.isEnabled = false
                reviewTitle.backgroundColor = UIColor.white
                reviewView.isEditable = false
                reviewView.backgroundColor = UIColor.white
            } else { // posted by user so it can be edited
                self.navigationItem.leftItemsSupplementBackButton = false // hide < Back
                self.saveBarButton.title = "Update"
                deleteButton.isHidden = false // show Delete button
                addBordersToEditableObjects()
            }
        } else { // must be a new review
            addBordersToEditableObjects()
        }
        enableDisableSaveButton()
    }
    
    func addBordersToEditableObjects() {
        reviewView.addBorder(borderWidth: 0.5, cornerRadius: 5.0)
        reviewTitle.addBorder(borderWidth: 0.5, cornerRadius: 5.0)
        buttonsBackgroundView.addBorder(borderWidth: 0.5, cornerRadius: 5.0)
    }
    
    func leaveViewController() {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func enableDisableSaveButton() {
        if reviewTitle.text != "" {
            saveBarButton.isEnabled = true
        } else {
            saveBarButton.isEnabled = false
        }
    }
    
    func saveThenSegue() {
        review.title = reviewTitle.text!
        review.text = reviewView.text!
        review.saveData(spot: spot) { success in
            if success {
                self.leaveViewController()
            } else {
                print("Can't unwind segue from Review because of review saving error")
            }
        }
    }
    
    @IBAction func descriptionChanged(_ sender: UITextField) {
        enableDisableSaveButton()
    }
    
    @IBAction func descriptionDoneKeyPressed(_ sender: UITextField) {
        saveThenSegue()
    }
    
    @IBAction func starButtonPressed(_ sender: UIButton) {
        rating = Int(sender.tag) + 1 // bump up zero indexing to start at 1
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        review.deleteData(spot: spot) { success in
            if success {
                self.leaveViewController()
            } else {
                print("Can't unwind segue from Review because of review deletion error")
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        saveThenSegue()
    }
}
