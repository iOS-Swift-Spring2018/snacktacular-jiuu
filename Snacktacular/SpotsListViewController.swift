//
//  SpotsListViewController.swift
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
    @IBOutlet weak var sortSegmentControl: UISegmentedControl!
    @IBOutlet weak var signOutBarButton: UIBarButtonItem!
    
    var spots: Spots!
    var snackUser: SnackUser!
    var authUI: FUIAuth!
    var db: Firestore!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLeftBarButtonItems() // needed to create smaller space
        
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
        
        spots.loadData {
            self.sortBasedOnSegmentPressed()
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getLocation()
        navigationController?.setToolbarHidden(false, animated: true)
        signIn()
    }
    
    func closestSort() {
        spots.spotArray.sort(by: {$0.location.distance(from: currentLocation) < $1.location.distance(from: currentLocation) } )
        tableView.reloadData()
    }
    
    func sortBasedOnSegmentPressed() {
        switch sortSegmentControl.selectedSegmentIndex {
        case 0: // A-Z
            spots.spotArray.sort(by: {$0.name < $1.name})
            tableView.reloadData()
        case 1: // closest
            if currentLocation != nil {
                closestSort()
                getLocation()
            } else {
                getLocation()
            }
        case 2: // averageRating
            spots.spotArray.sort(by: {$0.averageRating > $1.averageRating})
            tableView.reloadData()
        default:
            print("HEY, you shouldn't have gotten her. Check out the segmented control for an error.")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "AddSpot":
            if let indexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        case "ShowSpot":
            let destination = segue.destination as! SpotDetailViewController
            destination.spot = spots.spotArray[tableView.indexPathForSelectedRow!.row]
        case "ShowSingleUser":
            let destination = segue.destination as! UserProfileViewController
            destination.snackUser = SnackUser(user: Auth.auth().currentUser!)
        case "ShowUsersTable":
            print("Nothing to do for segue ShowUsersTable")
        default:
            print("*** ERROR: Unknown identifier in prepare for segue in SpotListViewController")
        }
    }
    
    // Return a square bar button item of dimension passed (which should be 25 for standard
    func configureImageBarButton(imageName: String, selector: Selector, dimension: CGFloat) -> UIBarButtonItem {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: dimension, height: dimension))
        button.setBackgroundImage(UIImage(named: imageName), for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        let barButtonItem = UIBarButtonItem(customView: button)
        return barButtonItem
    }
    
    func configureLeftBarButtonItems() {
        var barButtonItemArray = [signOutBarButton!]
        barButtonItemArray.append(configureImageBarButton(imageName: "singleUser", selector: #selector(singleUserPressed), dimension: 20))
        barButtonItemArray.append(configureImageBarButton(imageName: "users", selector: #selector(usersPressed), dimension: 20))
        navigationItem.leftBarButtonItems = barButtonItemArray
    }
    
    @objc func singleUserPressed() {
        performSegue(withIdentifier: "ShowSingleUser", sender: nil)
    }
    
    @objc func usersPressed() {
        performSegue(withIdentifier: "ShowUsersTable", sender: nil)
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
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func sortSegmentPressed(_ sender: UISegmentedControl) {
        sortBasedOnSegmentPressed()
    }
}

extension SpotsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return spots.count
        return spots.spotArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SpotsListTableViewCell
        if let currentLocation = currentLocation {
            cell.currentLocation = currentLocation
        }
        cell.spot = spots.spotArray[indexPath.row]
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
    
    func signIn() {
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth()
        ]
        if let currentUser = authUI.auth?.currentUser {
            tableView.isHidden = false
            snackUser = SnackUser(user: currentUser)
            snackUser.saveIfNewUser()
        } else {
            self.authUI?.providers = providers
            present(authUI.authViewController(), animated: true, completion: nil)
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

extension SpotsListViewController: CLLocationManagerDelegate {
    
    func getLocation(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    func handleLocationAuthorizationStatus(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        case .denied:
            showAlertToPrivacySettings(title: "User has not authorized location services", message: "Select 'Settings' below to open device settings and enable location services for this app.")
        case .restricted:
            showAlert(title: "Location services denied", message: "It may be that parental controls are restricting location use in this app")
        }
    }
    
    func showAlertToPrivacySettings(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        guard let settingsURL = URL(string: UIApplicationOpenSettingsURLString) else {
            print("Something went wrong getting the UIApplicationOpenSettingsURLString")
            return
        }
        let settingsActions = UIAlertAction(title: "Settings", style: .default) { value in
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(settingsActions)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleLocationAuthorizationStatus(status: status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        print("CURRENT LOCATION = \(currentLocation.coordinate.latitude) \(currentLocation.coordinate.longitude)")
        sortBasedOnSegmentPressed()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location.")
    }
}
