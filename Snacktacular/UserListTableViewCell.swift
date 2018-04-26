//
//  UserListTableViewCell.swift
//  Snacktacular
//
//
//  Created by Brian Wang on 4/26/18.
//

import UIKit
import SDWebImage
import Firebase
import FirebaseGoogleAuthUI
import GoogleSignIn

class UserListTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    var user: SnackUser! {
        didSet {
            
            nameLabel.text = user.displayName
            emailLabel.text = user.email
            
            guard let url = URL(string: user.photoURL) else {
                print("*** No Photo URL")
                return
            }
            
            guard let data = try? Data(contentsOf: url) else {
                print("*** ERROR: No user.photoURL")
                return
            } // make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            // profileImage.image = UIImage(data: data!)
            profileImageView.sd_setImage(with: URL(string: user.photoURL), placeholderImage: UIImage(named: "singleUser"))
        }
    }
    
 }
