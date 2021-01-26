//
//  BusinessDetailViewController.swift
//  Visit Sandpoint Idaho
//
//  Created by Mitchell Rust on 11/24/20.
//

import UIKit
import MapKit
import FirebaseAuth
import CoreData
import SDWebImage

class BusinessDetailViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {

    var business: Business!
    var collection: String! // collection the business belongs to, for CoreData use
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var heartImage: UIImageView!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var coreFavorite: Favorite?
    let managedObjectContainer: NSPersistentContainer = CoreDataController.getInstance()
    
    var coord: CLLocationCoordinate2D!
    let image: UIImage = UIImage(named: "warm-mountains")!
    var isFavorite: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        coord = CLLocationCoordinate2D(latitude: business.latitude, longitude: business.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate.latitude = coord.latitude
        annotation.coordinate.longitude = coord.longitude
        mapView.addAnnotation(annotation)
        let mapRegion = MKCoordinateRegion(center: coord, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(mapRegion, animated: false)
        
        let imageViewGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(imageViewTapped(_:)))
        imageViewGestureRecognizer.delegate = self
        imageView.addGestureRecognizer(imageViewGestureRecognizer)
        
        let mapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(openMaps(_:)))
        mapGestureRecognizer.delegate = self
        mapView.addGestureRecognizer(mapGestureRecognizer)
        
        let favoritesGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(toggleFavorites(_:)))
        favoritesGestureRecognizer.delegate = self
        heartImage.addGestureRecognizer(favoritesGestureRecognizer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.shadowImage = nil
        
        // Check if is favorite
        let favoriteFetchRequest: NSFetchRequest = Favorite.fetchRequest()
        do {
            let fetchResults = try managedObjectContainer.viewContext.fetch(favoriteFetchRequest)
            
            if(fetchResults.count > 0) {
                for favorite in fetchResults {
                    if favorite.id == business.id {
                        coreFavorite = favorite
                        isFavorite = true
                        break
                    } else {
                        isFavorite = false
                    }
                }
            }
            
        } catch {
            print(exception.self)
        }
        
        // Set UI button, image, and label values
        if business.imgUrl != "" {
            let url = URL(string: business.imgUrl)
            imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "warm-mountains"), completed: { [self] (image, error, cacheType, imageUrl) in
                guard error == nil else {
                    self.imageView.image = UIImage(named: "warm-mountains")
                    self.imageView.contentMode = .scaleAspectFill
                    return
                }
            })
        } else {
            imageView.image = UIImage(named: "warm-mountains")
            imageView.contentMode = .scaleAspectFill
        }
        nameLabel.text = business.name
        heartImage.image = isFavorite ? UIImage(systemName: "suit.heart.fill") : UIImage(systemName: "suit.heart")
        
        
        
        // Set UI button, image, and label values
        addressLabel.text = business.streetAddress
        typeLabel.text = business.type
        
        if business.summary == "" {
            descriptionLabel.text = "No description"
        } else {
            descriptionLabel.text = business.summary
        }
        
        if business.rating != nil && business.rating != 0.0 {
            ratingLabel.text = "\(String(business.rating)) stars"
            if business.rating.truncatingRemainder(dividingBy: 1.0) == 0 { // remove .0
                ratingLabel.text = "\(String(ratingLabel.text!.prefix(1))) stars"
            }
        } else {
            ratingLabel.text = "Not Rated"
        }
        
        let phoneString: String = business.phone.prettyPhoneNumber(phoneNumber: business.phone)
        phoneButton.setTitle(phoneString, for: .normal)
        websiteButton.setTitle(business.url, for: .normal)
    }
    
    @IBAction func phoneButtonTapped(_ sender: UIButton) {
        if let url = URL(string: "tel://\(business.phone!))"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func websiteButtonTapped(_ sender: UIButton) {
        if let url = URL(string: business.url), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    // Keep annotation from expanding on tap
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for view in views {
            view.isEnabled = false
        }
    }
    
    @objc func imageViewTapped(_ sender: UITapGestureRecognizer) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "FullscreenImageViewController") as FullscreenImageViewController
        vc.image = imageView.image
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func toggleFavorites(_ sender: UITapGestureRecognizer?) {
        let user = Authentication.getCurrentUser()
        guard user != nil else {
            // prompt signup or login
            let alert = UIAlertController(title: "It looks like you aren't logged in!", message: "To add to your favorites, you must be logged in.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Log In", style: .default, handler: { [self] _ in
                let storyBoard: UIStoryboard! = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                loginViewController.modalPresentationStyle = .fullScreen
                loginViewController.onDoneBlock = { [self] result in
                    guard result == true else {
                        // user not logged in
                        print("Did not log in")
                        return
                    }
                    print("User logged in")
                    self.toggleFavorites(nil)
                }
                self.present(loginViewController, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Sign Up", style: .default, handler: { [self] _ in
                let storyBoard: UIStoryboard! = UIStoryboard(name: "Main", bundle: nil)
                let signupViewController = storyBoard.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
                signupViewController.modalPresentationStyle = .fullScreen
                signupViewController.onDoneBlock = { [self] result in
                    guard result == true else {
                        // user not signed up
                        print("did not sign up")
                        return
                    }
                    print("User signed up")
                    self.toggleFavorites(nil)
                }
                self.present(signupViewController, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        let favorite: [String: String] = [
            "id": business.id,
            "collection": collection
        ]
        
        if isFavorite {
            let newImage = UIImage(systemName: "suit.heart")
            UIView.transition(with: self.heartImage, duration: 0.25, options: .transitionCrossDissolve, animations: { [self] in
                self.heartImage.image = newImage
            }, completion: nil)
            
            CloudFS.removeFromFavorites(userId: user!.uid, favorite: favorite, completion: { [self] error in
                guard error == nil else {
                    // failed to update
                    let alert = UIAlertController(title: "Could not remove from favorites", message: "An error occurred. Check your internet connection and try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] _ in
                        let newImage = UIImage(systemName: "suit.heart.fill")
                        UIView.transition(with: self.heartImage, duration: 0.25, options: .transitionCrossDissolve, animations: { [self] in
                            self.heartImage.image = newImage
                        }, completion: nil)
                    }))
                    self.present(alert, animated: true)
                    return
                }
                self.isFavorite = false
                
                // Remove from Core Data
                self.managedObjectContainer.viewContext.delete(self.coreFavorite!)
                CoreDataController.saveContext()
            })
        } else {
            // Update UI
            let newImage = UIImage(systemName: "suit.heart.fill")
            UIView.transition(with: self.heartImage, duration: 0.25, options: .transitionCrossDissolve, animations: { [self] in
                self.heartImage.image = newImage
            }, completion: nil)
            
            CloudFS.addToFavorites(userId: user!.uid, favorite: favorite, completion: { [self] error in
                guard error == nil else {
                    // failed to update
                    let alert = UIAlertController(title: "Could not add to favorites", message: "An error occurred. Check your internet connection and try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] _ in
                        // Update UI
                        let newImage = UIImage(systemName: "suit.heart")
                        UIView.transition(with: self.heartImage, duration: 0.25, options: .transitionCrossDissolve, animations: { [self] in
                            self.heartImage.image = newImage
                        }, completion: nil)
                    }))
                    self.present(alert, animated: true)
                    return
                }
                self.isFavorite = true
                
                // Add to core data
                self.coreFavorite = Favorite(context: self.managedObjectContainer.viewContext)
                self.coreFavorite!.id = self.business.id
                self.coreFavorite!.collection = self.collection
                CoreDataController.saveContext()
            })
        }
    }
    
    @objc func openMaps(_ sender: UITapGestureRecognizer) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Open in Maps", style: .default, handler: { [self] (alertAction) in
            let regionDistance:CLLocationDistance = 100
            let regionSpan = MKCoordinateRegion(center: self.coord, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: self.coord, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = self.business.name
            mapItem.openInMaps(launchOptions: options)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alertController, animated: true, completion: nil)
    }

}
