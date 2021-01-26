//
//  FavoritesViewController.swift
//  Visit Sandpoint Idaho
//
//  Created by Mitchell Rust on 11/20/20.
//

import UIKit
import CoreData
import FirebaseFirestore
import SDWebImage
import FirebaseAuth

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var noFavoritesScrollView: UIScrollView!
    @IBOutlet weak var findFavoritesButton: UIButton!
    @IBOutlet weak var findFavoritesText: UILabel!
    
    var selectedIndex: Int = 0
    let cellSpacingHeight: CGFloat = 20
    
    var adventureIds: Array<String>!
    var adventures: Array<Adventure>!
    
    var restaurantIds: Array<String>!
    var restaurants: Array<Business>!
    
    var shopIds: Array<String>!
    var shops: Array<Business>!
    
    var selectedAdventure: Adventure!
    var selectedBusiness: Business!
    
    var numTopAdventures: Int!
    var numTopRestaurants: Int!
    var numTopShops: Int!
    
    let managedObjectContainer: NSPersistentContainer = CoreDataController.getInstance()
    var currentUser: FirebaseAuth.User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove back button text
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.navigationBar.shadowImage = nil
        // Round corners of buttons
        signUpButton.layer.cornerRadius = 5
        logInButton.layer.cornerRadius = 5
        findFavoritesButton.layer.cornerRadius = 5
        
        let defaults = UserDefaults.standard
        numTopAdventures = defaults.stringArray(forKey: "topAdventures")?.count ?? 0
        numTopRestaurants = defaults.stringArray(forKey: "topRestaurants")?.count ?? 0
        numTopShops = defaults.stringArray(forKey: "topShops")?.count ?? 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        adventureIds = []
        restaurantIds = []
        shopIds = []
        
        adventures = []
        restaurants = []
        shops = []

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.font: UIFont(name: "Gotham-Bold", size: 18)!]
                
        currentUser = Authentication.getCurrentUser()
        
        if currentUser != nil { // logged in
            scrollView.isHidden = true
            segmentControl.isHidden = false
            // Get user from core data if logged in
            let favoritesFetchRequest: NSFetchRequest = Favorite.fetchRequest()
            do {
                let fetchResults = try managedObjectContainer.viewContext.fetch(favoritesFetchRequest)

                for result in fetchResults {
                    if result.collection == "adventures" {
                        adventureIds.append(result.id!)
                    } else if result.collection == "restaurants" {
                        restaurantIds.append(result.id!)
                    } else if result.collection == "shops" {
                        shopIds.append(result.id!)
                    }
                }
            } catch {
                print(exception.self)
            }
            
            if adventureIds.count > 0 {
                CloudFS.getAdventures(source: .cache, docIds: adventureIds, completion: { [self] fsAdventures in
                    guard fsAdventures != nil else {
                        CloudFS.getAdventures(source: .server, docIds: adventureIds, completion: { [self] serverAdventures in
                            guard serverAdventures != nil else {
                                print("Could not get adventures")
                                return
                            }
                            self.adventures = serverAdventures!
                            self.tableView.reloadData()
                            return
                        })
                        return
                    }
                    self.adventures = fsAdventures!
                    
                    if selectedIndex == 0 {
                        self.tableView.isHidden = false
                        self.noFavoritesScrollView.isHidden = true
                        self.tableView.reloadData()
                    }
                })
            } else if selectedIndex == 0 {
                findFavoritesText.text = "It looks like you haven't saved any adventures yet."
                findFavoritesButton.setTitle("Find an Adventure", for: .normal)
                tableView.isHidden = true
                noFavoritesScrollView.isHidden = false
            }
            
            if restaurantIds.count > 0 {
                CloudFS.getRestaurants(source: .cache, docIds: restaurantIds, completion: { [self] fsRestaurants in
                    guard fsRestaurants != nil else {
                        CloudFS.getRestaurants(source: .server, docIds: restaurantIds, completion: { [self] serverRestaurants in
                            guard serverRestaurants != nil else {
                                print("Could not get restaurants")
                                return
                            }
                            self.restaurants = serverRestaurants!
                            self.tableView.reloadData()
                            return
                        })
                        return
                    }
                    self.restaurants = fsRestaurants!
                    
                    if selectedIndex == 1 {
                        self.tableView.isHidden = false
                        self.noFavoritesScrollView.isHidden = true
                        self.tableView.reloadData()
                    }
                })
            } else if selectedIndex == 1 {
                findFavoritesText.text = "It looks like you haven't saved any restaurants yet."
                findFavoritesButton.setTitle("Find a Restaurant", for: .normal)
                tableView.isHidden = true
                noFavoritesScrollView.isHidden = false
            }
            
            if shopIds.count > 0 {
                CloudFS.getShops(source: .cache, docIds: shopIds, completion: { [self] fsShops in
                    guard fsShops != nil else {
                        CloudFS.getShops(source: .server, docIds: shopIds, completion: { [self] serverShops in
                            guard serverShops != nil else {
                                print("Could not get shops")
                                return
                            }
                            self.shops = serverShops!
                            self.tableView.reloadData()
                            return
                        })
                        return
                    }
                    self.shops = fsShops!
                    
                    if selectedIndex == 2 {
                        self.tableView.isHidden = false
                        self.noFavoritesScrollView.isHidden = true
                        self.tableView.reloadData()
                    }
                })
            } else if selectedIndex == 2 {
                findFavoritesText.text = "It looks like you haven't saved any shops yet."
                findFavoritesButton.setTitle("Find a Shop", for: .normal)
                tableView.isHidden = true
                noFavoritesScrollView.isHidden = false
            }

        } else { // not logged in
            segmentControl.isHidden = true
            tableView.isHidden = true
            noFavoritesScrollView.isHidden = true
            scrollView.isHidden = false
        }
    }
    
    func checkIfFavorites() -> Bool {
        if adventures.count == 0 && selectedIndex == 0 {
            findFavoritesText.text = "It looks like you haven't saved any adventures yet."
            findFavoritesButton.setTitle("Find an Adventure", for: .normal)
            tableView.isHidden = true
            noFavoritesScrollView.isHidden = false
            return false
        } else if restaurants.count == 0 && selectedIndex == 1 {
            findFavoritesText.text = "It looks like you haven't saved any restaurants yet."
            findFavoritesButton.setTitle("Find a Restaurant", for: .normal)
            tableView.isHidden = true
            noFavoritesScrollView.isHidden = false
            return false
        } else if shops.count == 0 && selectedIndex == 2 {
            findFavoritesText.text = "It looks like you haven't saved any shops yet."
            findFavoritesButton.setTitle("Find a Shop", for: .normal)
            tableView.isHidden = true
            noFavoritesScrollView.isHidden = false
            return false
        }
        
        // There are favorites to show
        tableView.isHidden = false
        noFavoritesScrollView.isHidden = true
        return true
    }
    
    @IBAction func segmentControlIndexChanged(_ sender: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
            case 0:
                selectedIndex = 0
            case 1:
                selectedIndex = 1
            case 2:
                selectedIndex = 2
            default:
                break
        }
        let areFavorites: Bool = checkIfFavorites()
        if areFavorites {
            tableView.reloadData()
        }
    }
    
    // Number of cells we want
    func numberOfSections(in tableView: UITableView) -> Int {
        if selectedIndex == 0 {
            return adventures.count
        } else if selectedIndex == 1 {
            return restaurants.count
        } else {
            return shops.count
        }
    }
    
    // 1 row in every spaced section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if selectedIndex == 0 {
            selectedAdventure = adventures[indexPath.section]
            performSegue(withIdentifier: "ShowAdventureDetail", sender: self)
        } else if selectedIndex == 1 {
            selectedBusiness = restaurants[indexPath.section]
            performSegue(withIdentifier: "ShowRestaurantDetail", sender: self)
        } else {
            selectedBusiness = shops[indexPath.section]
            performSegue(withIdentifier: "ShowShopDetail", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAdventureList" {
            let vc = segue.destination as! AdventureListViewController
            vc.numTopAdventures = numTopAdventures
        } else if segue.identifier == "ShowAdventureDetail" {
            let vc = segue.destination as! AdventureDetailViewController
            vc.adventure = selectedAdventure
        } else if segue.identifier == "ShowRestaurantList" {
            let vc = segue.destination as! BusinessListViewController
            vc.numTopBusinesses = numTopRestaurants
            vc.businessType = "restaurants"
        } else if segue.identifier == "ShowRestaurantDetail" {
            let vc = segue.destination as! BusinessDetailViewController
            vc.business = selectedBusiness
            vc.collection = "restaurants"
        } else if segue.identifier == "ShowShopList" {
            let vc = segue.destination as! BusinessListViewController
            vc.numTopBusinesses = numTopShops
            vc.businessType = "shops"
        } else if segue.identifier == "ShowShopDetail" {
            let vc = segue.destination as! BusinessDetailViewController
            vc.business = selectedBusiness
            vc.collection = "shops"
        } 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if selectedIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as! FavoritesTableViewCell
            
            cell.thumbnail.image = nil // reset image for reuse
            
            let adventure: Adventure = adventures[indexPath.section]
            
            cell.headingLabel.text = adventure.name
            cell.sub1Label.text = adventure.type
            
            if adventure.rating != nil && adventure.rating != 0.0 {
                cell.sub2Label.text = "\(String(adventure.rating)) stars"
                if adventure.rating.truncatingRemainder(dividingBy: 1.0) == 0 { // remove .0
                    cell.sub2Label.text = "\(String(cell.sub2Label!.text!.prefix(1))) stars"
                }
            } else {
                cell.sub2Label.text = "Not Rated"
            }
            
            if adventure.imgUrl != "" {
                let url = URL(string: adventure.imgUrl)
                cell.thumbnail.sd_setImage(with: url, placeholderImage: UIImage(named: "warm-mountains"), completed: { [cell] (image, error, cacheType, imageUrl) in
                    guard error == nil else {
                        cell.thumbnail.image = UIImage(named: "warm-mountains")
                        return
                    }
                })
            } else {
                cell.thumbnail.image = UIImage(named: "warm-mountains")
            }
            
            cell.contentView.layer.cornerRadius = 10
            cell.contentView.layer.masksToBounds = true
            
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOffset = CGSize(width: 0, height: 2)
            cell.layer.shadowRadius = 2
            cell.layer.shadowOpacity = 0.5
            cell.layer.masksToBounds = false
            cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
            
            return cell
        } else if selectedIndex == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as! FavoritesTableViewCell
            
            cell.thumbnail.image = nil // reset image for reuse
            
            let restaurant: Business = restaurants[indexPath.section]
            
            cell.headingLabel.text = restaurant.name
            cell.sub1Label.text = restaurant.type
            cell.sub2Label.text = restaurant.streetAddress
            
            if restaurant.imgUrl != "" {
                let url = URL(string: restaurant.imgUrl)
                cell.thumbnail.sd_setImage(with: url, placeholderImage: UIImage(named: "warm-mountains"), completed: { [cell] (image, error, cacheType, imageUrl) in
                    guard error == nil else {
                        cell.thumbnail.image = UIImage(named: "warm-mountains")
                        return
                    }
                })
            } else {
                cell.thumbnail.image = UIImage(named: "warm-mountains")
            }
            
            cell.contentView.layer.cornerRadius = 10
            cell.contentView.layer.masksToBounds = true
            
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOffset = CGSize(width: 0, height: 2)
            cell.layer.shadowRadius = 2
            cell.layer.shadowOpacity = 0.5
            cell.layer.masksToBounds = false
            cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
            
            return cell
        }
        // else, shop cells
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as! FavoritesTableViewCell
        
        cell.thumbnail.image = nil // reset image for reuse
        
        let shop: Business = shops[indexPath.section]
        
        cell.headingLabel.text = shop.name
        cell.sub1Label.text = shop.type
        cell.sub2Label.text = shop.streetAddress
        
        if shop.imgUrl != "" {
            let url = URL(string: shop.imgUrl)
            cell.thumbnail.sd_setImage(with: url, placeholderImage: UIImage(named: "warm-mountains"), completed: { [cell] (image, error, cacheType, imageUrl) in
                guard error == nil else {
                    cell.thumbnail.image = UIImage(named: "warm-mountains")
                    return
                }
            })
        } else {
            cell.thumbnail.image = UIImage(named: "warm-mountains")
        }
        
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.masksToBounds = true
        
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowRadius = 2
        cell.layer.shadowOpacity = 0.5
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        
        return cell
    }

    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        let storyBoard: UIStoryboard! = UIStoryboard(name: "Main", bundle: nil)
        let signupViewController = storyBoard.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        signupViewController.modalPresentationStyle = .fullScreen
        signupViewController.onDoneBlock = { result in }
        self.present(signupViewController, animated: true, completion: nil)
    }
    
    @IBAction func logInButtonTapped(_ sender: UIButton) {
        let storyBoard: UIStoryboard! = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        loginViewController.modalPresentationStyle = .fullScreen
        loginViewController.onDoneBlock = { result in }
        self.present(loginViewController, animated: true, completion: nil)
    }
    
    @IBAction func findFavoritesButtonTapped(_ sender: UIButton) {
        if selectedIndex == 0 {
            performSegue(withIdentifier: "ShowAdventureList", sender: nil)
        } else if selectedIndex == 1 {
            performSegue(withIdentifier: "ShowRestaurantList", sender: nil)
        } else {
            performSegue(withIdentifier: "ShowShopList", sender: nil)
        }
    }

}
