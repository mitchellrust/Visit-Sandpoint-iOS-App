//
//  ProfileViewController.swift
//  Visit Sandpoint Idaho
//
//  Created by Mitchell Rust on 11/20/20.
//

import UIKit
import FirebaseAuth
import CoreData
import Photos

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    fileprivate var cellObjects: Array<TableCellProps> = []
    var currentUser: FirebaseAuth.User!
    var coreUser: CoreUser!
    let managedObjectContainer: NSPersistentContainer = CoreDataController.getInstance()
    let imagePickerController = UIImagePickerController()
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        // Remove back button text
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Add table cells
//        let preferences = TableCellProps(title: "Preferences", actionId: "prefs", iconName: "settings-icon")
//        cellObjects.append(preferences)
        let support = TableCellProps(title: "Contact Us", actionId: "support", iconName: "support-icon")
        cellObjects.append(support)
        let acknowledgements = TableCellProps(title: "Acknowledgements", actionId: "ack", iconName: "ack-icon")
        cellObjects.append(acknowledgements)
        let request = TableCellProps(title: "Don't see a business?", actionId: "request", iconName: "marker-icon")
        cellObjects.append(request)
        
        tableView.tableFooterView = UIView() // cover all extra lines without populated cells
        tableView.separatorInset.right = 20 // keep seperator lines from going to edge
        
        // create tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(gesture:)))

        // add it to the image view;
        profileImage.addGestureRecognizer(tapGesture)
        // make sure imageView can be interacted with by user
        profileImage.isUserInteractionEnabled = true
    }

    @objc func imageTapped(gesture: UIGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil { // profile photo tapped
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { (alertAction) in
                self.imagePickerController.sourceType = .photoLibrary
                self.present(self.imagePickerController, animated: true, completion: nil)
            }))
            alertController.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (alertAction) in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    self.imagePickerController.sourceType = .camera
                    self.present(self.imagePickerController, animated: true, completion: nil)
                }
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            present(alertController, animated: true, completion: nil)
        }
    }
    
    // Dismiss image picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    // Photo was selected
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let chosenImage = info[.editedImage] as! UIImage
        
        // Get binary data for storing
        let data = chosenImage.jpegData(compressionQuality: 0.75)!
        
        // Save to firebase storage
        self.showSpinner(onView: self.view)
        FSStorage.addProfilePicture(userId: coreUser.id!, data: data, completion: { [self] url in
            guard url != nil else {
                self.removeSpinner()
                let alert = UIAlertController(title: "An error occurred", message: "Your profile photo could not be saved. Please try again later.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            
            CloudFS.setUserDocument(docId: self.coreUser.id!, data: ["profilePhotoUrl": url as Any], merge: true, completion: { [self] error in
                guard error == nil else {
                    self.updateHeader()
                    return // The photo url didn't get saved, but this isn't the end of the world
                }
            })
            
            // Save to core data
            coreUser.profileImage = data
            CoreDataController.saveContext()
            self.removeSpinner()
            self.updateHeader()
        })
        
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        // Do any additional setup before the view appears
        self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.font: UIFont(name: "Gotham-Bold", size: 18)!]
        
        // Make profile photo circular
        profileImage.layer.masksToBounds = false
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.clipsToBounds = true
        
        // Round corners of buttons
        signUpButton.layer.cornerRadius = 5
        logInButton.layer.cornerRadius = 5
        
        // Get initial header view
        updateHeader()
    }
    
    func updateHeader() {
        currentUser = Authentication.getCurrentUser()
        
        if currentUser != nil { // logged in
            // Get user from core data if logged in
            let userFetchRequest: NSFetchRequest = CoreUser.fetchRequest()
            do {
                let fetchResults = try managedObjectContainer.viewContext.fetch(userFetchRequest)

                coreUser = fetchResults[0]
                nameLabel.text = coreUser.firstName! + " " + coreUser.lastName!
                profileImage.image = UIImage(data: coreUser.profileImage ?? UIImage(named: "warm-mountains")!.pngData()!)
            } catch {
                print(exception.self)
            }
            
            // Add logout button to table
            // Remove logout button from table
            let index: Int = cellObjects.firstIndex(where: { (obj) -> Bool in
                return obj.actionId == "logOut"
            }) ?? -1
            if index == -1 {
                let logOut = TableCellProps(title: "Log Out", actionId: "logOut", iconName: "logout-icon")
                cellObjects.append(logOut)
                tableView.reloadData()
            }
            
            // show profile information
            nameLabel.isHidden = false
            profileImage.isHidden = false
            
            // Hide signup/login buttons
            signUpButton.isHidden = true
            logInButton.isHidden = true
            messageLabel.isHidden = true
        } else { // not logged in
            // Remove logout button from table
            let index: Int = cellObjects.firstIndex(where: { (obj) -> Bool in
                return obj.actionId == "logOut"
            }) ?? -1
            if index != -1 {
                cellObjects.remove(at: index)
                tableView.reloadData()
            }
            
            // show signup/login buttons
            signUpButton.isHidden = false
            logInButton.isHidden = false
            messageLabel.isHidden = false
            
            // hide profile information
            nameLabel.isHidden = true
            profileImage.isHidden = true
        }
    }
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        let storyBoard: UIStoryboard! = UIStoryboard(name: "Main", bundle: nil)
        let signupViewController = storyBoard.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        signupViewController.modalPresentationStyle = .fullScreen
        signupViewController.onDoneBlock = { result in
            guard result == true else {
                return
            }
            self.updateHeader()
        }
        self.present(signupViewController, animated: true, completion: nil)
    }
    
    @IBAction func logInButtonTapped(_ sender: UIButton) {
        let storyBoard: UIStoryboard! = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        loginViewController.modalPresentationStyle = .fullScreen
        loginViewController.onDoneBlock = { [self] result in
            guard result == true else {
                return
            }
            self.updateHeader()
        }
        self.present(loginViewController, animated: true, completion: nil)
    }
    
    // Get number of cells in table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellObjects.count
    }
    
    // Create cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableCell")!
        let props: TableCellProps = cellObjects[indexPath.row]
        let iconView: UIImageView = UIImageView(image: UIImage(named: props.iconName)!)
        cell.textLabel?.text = props.title
        cell.textLabel?.font = UIFont(name: "Gotham-Light", size: 17)!
        cell.accessoryView = iconView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let actionId: String = cellObjects[indexPath.row].actionId
        if actionId == "logOut" {
            let alert = UIAlertController(title: "Are you sure?", message: "You will have to log back in to access your favorites.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Log Out", style: .default, handler: { [self] _ in 
                let error = Authentication.logOut()
                guard error == nil else {
                    let alert = UIAlertController(title: "Could not log out", message: "This is an unexpected error. Please try again later.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                // Remove user from Core Data
                managedObjectContainer.viewContext.delete(self.coreUser)
                
                // Remove Favorites from Core Data
                // Create Fetch Request
                let favoritesRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorite")

                // Create Batch Delete Request
                let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: favoritesRequest)

                do {
                    try managedObjectContainer.viewContext.execute(batchDeleteRequest)
                } catch {
                    // Error Handling
                    print("Error")
                }
                
                CoreDataController.saveContext()
                self.updateHeader()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        } else if actionId == "prefs" {
            performSegue(withIdentifier: "ShowPreferences", sender: self)
        } else if actionId == "request" {
            performSegue(withIdentifier: "ShowBusinessRequest", sender: self)
        } else if actionId == "support" {
            performSegue(withIdentifier: "ShowSupport", sender: self)
        } else if actionId == "ack" {
            performSegue(withIdentifier: "ShowAcknowledgements", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60 // height for tableview cells
    }

}

// Object class for defining the different properties of a
// table cell
private class TableCellProps {
    let title: String!
    let actionId: String!
    let iconName: String!
    
    init(title: String, actionId: String, iconName: String) {
        self.title = title
        self.actionId = actionId
        self.iconName = iconName
    }
}
