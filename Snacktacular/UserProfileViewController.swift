//
//  UserProfileViewController.swift
//  Snacktacular
//
//
//  Created by Brian Wang on 4/26/18.
//

import UIKit

class UserProfileViewController: UIViewController {

    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var memberSinceLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    var snackUser: SnackUser!
    let dateFormatter = DateFormatter()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard snackUser != nil else {
            print("*** ERROR: snackUser was nil in UserProfileViewController")
            return
        }
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        configureUserInterface()
//        snackUser.loadUser { (_) in
//            self.configureUserInterface()
//        }
    }
    
    func configureUserInterface() {
        displayNameLabel.text = snackUser.displayName
        emailLabel.text = snackUser.email
        memberSinceLabel.text = dateFormatter.string(from: snackUser.userSince)
        
        guard let url = URL(string: snackUser.photoURL) else {
            print("*** No Photo URL")
            return
        }
        
        guard let data = try? Data(contentsOf: url) else {
            print("*** ERROR: No user.photoURL")
            return
        }
        profileImage.sd_setImage(with: URL(string: snackUser.photoURL), placeholderImage: UIImage(named: "singleUser"))
    }
}
