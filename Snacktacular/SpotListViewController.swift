//
//  ViewController.swift
//  Snacktacular
//
//  Created by John Gallaugher on 1/27/18.
//  Copyright © 2018 John Gallaugher. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI

class SpotsListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    // var spots = [Spot]()
    var spots: Spots!
    var authUI: FUIAuth!
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        authUI = FUIAuth.defaultAuthUI()
        // You need to adopt a FUIAuthDelegate protocol to receive callback
        authUI?.delegate = self
        
        spots = Spots()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        spots.checkForUpdates {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        navigationController?.setToolbarHidden(false, animated: true)
        signIn()
    }
    
    func signIn() {
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth()
        ]
        if authUI.auth?.currentUser == nil {
            self.authUI?.providers = providers
            present(authUI.authViewController(), animated: true, completion: nil)
        } else {
            tableView.isHidden = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            print("*** ERROR: No identifier in prepare for segue in SpotListViewController")
            return
        }
        switch identifier {
        case "ShowSpot":
            let destination = segue.destination as! SpotDetailViewController
            // destination.spot = spots[tableView.indexPathForSelectedRow!.row]
            destination.spot = spots.spotArray[tableView.indexPathForSelectedRow!.row]
        case "AddSpot":
            if let indexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        default:
            print("*** ERROR: Unknown identifier in prepare for segue in SpotListViewController")
        }
    }
    
    @IBAction func unwindFromSpotDetailViewController(segue: UIStoryboardSegue) {
        if segue.identifier == "AddNewSpot" {
            let source = segue.source as! SpotDetailViewController
            // let newIndexPath = IndexPath(row: spots.count, section: 0)
            let newIndexPath = IndexPath(row: spots.spotArray.count, section: 0)
            // spots.append(source.spot)
            spots.spotArray.append(source.spot)
            tableView.insertRows(at: [newIndexPath], with: .bottom)
            tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
        }
    }
    
    @IBAction func signOutPressed(_ sender: UIBarButtonItem) {
        do {
            try authUI!.signOut()
            print("^^^ Successfully signed out!")
            tableView.isHidden = true
            signIn()
        } catch {
            print("*** ERROR: Couldn't sign out!")
        }
    }
}

extension SpotsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return spots.count
        return spots.spotArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        // cell.textLabel?.text = spots[indexPath.row].name
        cell.textLabel?.text = spots.spotArray[indexPath.row].name
        // cell.detailTextLabel?.text = spots[indexPath.row].postingUserID
        cell.detailTextLabel?.text = spots.spotArray[indexPath.row].postingUserID
        return cell
    }
}

extension SpotsListViewController: FUIAuthDelegate {
    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let user = user {
            print("*** We signed in with the user \(user.email ?? "no user e-mail")")
        }
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        let loginViewController = FUIAuthPickerViewController(authUI: authUI)
        loginViewController.view.backgroundColor = UIColor.white
        
        let marginInset: CGFloat = 16
        let imageHeight: CGFloat = 225
        let imageY = self.view.center.y - imageHeight
        let logoFrame = CGRect(x: self.view.frame.origin.x + marginInset
            , y: imageY, width: self.view.frame.width - (marginInset*2), height: imageHeight)
        let logoImageView = UIImageView(frame: logoFrame)
        logoImageView.image = UIImage(named: "logo")
        logoImageView.contentMode = .scaleAspectFit
        loginViewController.view.addSubview(logoImageView)
        return loginViewController
    }
}
