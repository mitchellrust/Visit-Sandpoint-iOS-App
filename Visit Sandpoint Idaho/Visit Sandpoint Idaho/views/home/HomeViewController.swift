//
//  HomeViewController.swift
//  Visit Sandpoint Idaho
//
//  Created by Mitchell Rust on 11/17/20.
//

import UIKit
import FirebaseFirestore

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    
    var statusBarFrame: CGRect!
    var statusBarView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    // Header outlets
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var welcomeBlackLabel: UILabel!
    @IBOutlet weak var sandpointLabel: UILabel!
    @IBOutlet weak var sandpointBlackLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    
    // Adventure scroll outlets
    @IBOutlet weak var adventureCollectionView: UICollectionView!
    
    // Restaurant scroll outlets
    @IBOutlet weak var restaurantCollectionView: UICollectionView!
    
    // Shop scroll outlets
    @IBOutlet weak var shopCollectionView: UICollectionView!
    
    var config: HomeConfig!
    var topAdventures: Array<Adventure> = []
    var topRestaurants: Array<Business> = []
    var topShops: Array<Business> = []
    
    var topAdventuresLoaded: Bool = false
    var topRestaurantsLoaded: Bool = false
    var topShopsLoaded: Bool = false
    
    var selectedAdventure: Adventure!
    var selectedBusiness: Business!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Get Home Config information and set up UI
        let defaults = UserDefaults.standard
        let data: [String: Any] = [
            "lastAdventureUpdate": defaults.string(forKey: "lastAdventureUpdate") as Any,
            "lastRestaurantUpdate": defaults.string(forKey: "lastRestaurantUpdate") as Any,
            "lastShopUpdate": defaults.string(forKey: "lastShopUpdate") as Any,
            "topAdventures": defaults.stringArray(forKey: "topAdventures") ?? [String](),
            "topRestaurants": defaults.stringArray(forKey: "topRestaurants") ?? [String](),
            "topShops": defaults.stringArray(forKey: "topShops") ?? [String]()
        ]
        config = HomeConfig(data: data)
        
        // Remove back button text
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Set horizontal scroll flow for collection views
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: self.view.bounds.width * 4/5, height: 325)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        flowLayout.minimumInteritemSpacing = 0.0
        restaurantCollectionView.collectionViewLayout = flowLayout
        adventureCollectionView.collectionViewLayout = flowLayout
        shopCollectionView.collectionViewLayout = flowLayout
                
        // Add gradient to header image
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = headerImage.frame
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.locations = [0.2, 0.8]
        headerImage.layer.insertSublayer(gradient, at: 0)
        
        // Initialize black labels to transparent
        sandpointBlackLabel.alpha = 0.0
        welcomeBlackLabel.alpha = 0.0
        
        // Get top adventures
        CloudFS.getAdventures(source: .cache, docIds: config.topAdventures, completion: { [self] adventures in
            guard adventures != nil && adventures!.count == config.topAdventures.count else {
                CloudFS.getAdventures(source: .server, docIds: config.topAdventures, completion: { [self] serverAdventures in
                    guard serverAdventures != nil else {
                        print("Could not get top adventures")
                        return
                    }
                    self.topAdventures = serverAdventures!
                    self.topAdventuresLoaded = true
                    self.checkAllDataLoaded()
                    return
                })
                return
            }
            self.topAdventures = adventures!
            self.topAdventuresLoaded = true
            self.checkAllDataLoaded()
        })
        
        // Get top restaurants
        CloudFS.getRestaurants(source: .cache, docIds: config.topRestaurants, completion: { [self] restaurants in
            guard restaurants != nil && restaurants!.count == config.topRestaurants.count else {
                CloudFS.getRestaurants(source: .server, docIds: config.topRestaurants, completion: { [self] serverRestaurants in
                    guard serverRestaurants != nil else {
                        print("Could not get top restaurants")
                        return
                    }
                    self.topRestaurants = serverRestaurants!
                    self.topRestaurantsLoaded = true
                    self.checkAllDataLoaded()
                    return
                })
                return
            }
            self.topRestaurants = restaurants!
            self.topRestaurantsLoaded = true
            self.checkAllDataLoaded()
        })
        
        // Get top shops
        CloudFS.getShops(source: .cache, docIds: config.topShops, completion: { [self] shops in
            guard shops != nil && shops!.count == config.topShops.count else {
                CloudFS.getRestaurants(source: .server, docIds: config.topShops, completion: { [self] serverShops in
                    guard serverShops != nil else {
                        print("Could not get top shops")
                        return
                    }
                    self.topShops = serverShops!
                    self.topShopsLoaded = true
                    self.checkAllDataLoaded()
                    return
                })
                return
            }
            self.topShops = shops!
            self.topShopsLoaded = true
            self.checkAllDataLoaded()
        })
    }
    
    func checkAllDataLoaded() {
        if topAdventuresLoaded && topRestaurantsLoaded && topShopsLoaded {
            DispatchQueue.main.async {
                self.adventureCollectionView.reloadData()
                self.restaurantCollectionView.reloadData()
                self.shopCollectionView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView != self.scrollView {
            return
        }
        
        // Check if sandpoint label should change colors
        let sandpointY: CGFloat = (sandpointBlackLabel.superview?.convert(sandpointBlackLabel.frame.origin, to: nil).y)!
        if sandpointBlackLabel.alpha == 0.0 && sandpointY >= 475 {
            UIView.transition(with: sandpointBlackLabel, duration: 0.25, options: .transitionCrossDissolve, animations: { [self] in
                self.sandpointBlackLabel.alpha = 1.0
            }, completion: nil)
        } else if sandpointBlackLabel.alpha == 1.0 && sandpointY < 475 {
            UIView.transition(with: sandpointBlackLabel, duration: 0.25, options: .transitionCrossDissolve, animations: { [self] in
                self.sandpointBlackLabel.alpha = 0.0
            }, completion: nil)
        }
        
        // check if welcome label should change colors
        let welcomeY: CGFloat = (welcomeBlackLabel.superview?.convert(welcomeBlackLabel.frame.origin, to: nil).y)!
        if welcomeBlackLabel.alpha == 0.0 && welcomeY >= 480 {
            UIView.transition(with: welcomeBlackLabel, duration: 0.25, options: .transitionCrossDissolve, animations: { [self] in
                self.welcomeBlackLabel.alpha = 1.0
            }, completion: nil)
        } else if welcomeBlackLabel.alpha == 1.0 && welcomeY < 480 {
            UIView.transition(with: welcomeBlackLabel, duration: 0.25, options: .transitionCrossDissolve, animations: { [self] in
                self.welcomeBlackLabel.alpha = 0.0
            }, completion: nil)
        }
        
        var offset: CGFloat = scrollView.contentOffset.y / 200
        if offset > 1 {
            offset = 1
            self.navigationController?.navigationBar.shadowImage = nil
        } else {
            self.navigationController?.navigationBar.shadowImage = UIImage()
        }
        let color: UIColor = UIColor(red: 1, green: 1, blue: 1, alpha: offset)
        self.navigationController?.navigationBar.backgroundColor = color
        
        if let viewWithTag = self.view.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }
        statusBarFrame = self.view.window?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero
        statusBarView = UIView(frame: statusBarFrame)
        statusBarView.tag = 100
        statusBarView.backgroundColor = color
        self.view.addSubview(statusBarView)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == adventureCollectionView {
            return topAdventures.count
        } else if collectionView == restaurantCollectionView {
            return topRestaurants.count
        } else { // shopCollectionView
            return topShops.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == adventureCollectionView {
            selectedAdventure = topAdventures[indexPath.row]
            performSegue(withIdentifier: "ShowAdventureDetail", sender: self)
            return
        } else if collectionView == restaurantCollectionView {
            selectedBusiness = topRestaurants[indexPath.row]
            performSegue(withIdentifier: "ShowRestaurantDetail", sender: self)
            return
        } else {
            selectedBusiness = topShops[indexPath.row]
            performSegue(withIdentifier: "ShowShopDetail", sender: self)
            return
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAdventureList" {
            let vc = segue.destination as! AdventureListViewController
            vc.numTopAdventures = topAdventures.count
        } else if segue.identifier == "ShowAdventureDetail" {
            let vc = segue.destination as! AdventureDetailViewController
            vc.adventure = selectedAdventure
        } else if segue.identifier == "ShowRestaurantList" {
            let vc = segue.destination as! BusinessListViewController
            vc.numTopBusinesses = topRestaurants.count
            vc.businessType = "restaurants"
        } else if segue.identifier == "ShowRestaurantDetail" {
            let vc = segue.destination as! BusinessDetailViewController
            vc.business = selectedBusiness
            vc.collection = "restaurants"
        } else if segue.identifier == "ShowShopList" {
            let vc = segue.destination as! BusinessListViewController
            vc.numTopBusinesses = topShops.count
            vc.businessType = "shops"
        } else if segue.identifier == "ShowShopDetail" {
            let vc = segue.destination as! BusinessDetailViewController
            vc.business = selectedBusiness
            vc.collection = "shops"
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == adventureCollectionView {
            let cell = adventureCollectionView.dequeueReusableCell(withReuseIdentifier: "HomeScrollCell", for: indexPath) as! HomeCollectionViewCell
            
            let adventure: Adventure = topAdventures[indexPath.row]
            
            cell.nameLabel.text = adventure.name
            cell.typeLabel.text = adventure.type
            
            let imageView: UIImageView = UIImageView(image: UIImage(named: "warm-mountains"))
            imageView.contentMode = .scaleAspectFill
            
            if adventure.imgUrl != "" {
                let url = URL(string: adventure.imgUrl)
                imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "warm-mountains"), completed: { [imageView] (image, error, cacheType, imageUrl) in
                    guard error == nil else {
                        imageView.image = UIImage(named: "warm-mountains")
                        return
                    }
                })
            } else {
                imageView.image = UIImage(named: "warm-mountains")
            }
            
            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.frame = imageView.frame
            gradient.colors = [UIColor.clear.cgColor, UIColor.white.cgColor]
            gradient.locations = [0.1, 0.125]
            
            imageView.layer.insertSublayer(gradient, at: 0)
            
            cell.contentView.layer.cornerRadius = 10
            cell.contentView.layer.masksToBounds = true
            
            cell.backgroundView = imageView
            cell.backgroundView!.layer.cornerRadius = 10
            cell.backgroundView!.layer.masksToBounds = true
            
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOffset = CGSize(width: 0, height: 2)
            cell.layer.shadowRadius = 2
            cell.layer.shadowOpacity = 0.5
            cell.layer.masksToBounds = false
            cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
            
            return cell
        }
        
        if collectionView == restaurantCollectionView {
            let cell = restaurantCollectionView.dequeueReusableCell(withReuseIdentifier: "HomeScrollCell", for: indexPath) as! HomeCollectionViewCell

            let restaurant: Business = topRestaurants[indexPath.row]

            cell.nameLabel.text = restaurant.name
            cell.typeLabel.text = restaurant.type

            let imageView: UIImageView = UIImageView(image: UIImage(named: "warm-mountains"))
            imageView.contentMode = .scaleAspectFill

            if restaurant.imgUrl != "" {
                let url = URL(string: restaurant.imgUrl)
                imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "warm-mountains"), completed: { [imageView] (image, error, cacheType, imageUrl) in
                    guard error == nil else {
                        imageView.image = UIImage(named: "warm-mountains")
                        return
                    }
                })
            } else {
                imageView.image = UIImage(named: "warm-mountains")
            }

            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.frame = imageView.frame
            gradient.colors = [UIColor.clear.cgColor, UIColor.white.cgColor]
            gradient.locations = [0.1, 0.125]

            imageView.layer.insertSublayer(gradient, at: 0)

            cell.contentView.layer.cornerRadius = 10
            cell.contentView.layer.masksToBounds = true

            cell.backgroundView = imageView
            cell.backgroundView!.layer.cornerRadius = 10
            cell.backgroundView!.layer.masksToBounds = true

            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOffset = CGSize(width: 0, height: 2)
            cell.layer.shadowRadius = 2
            cell.layer.shadowOpacity = 0.5
            cell.layer.masksToBounds = false
            cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath

            return cell
        }
        
        // otherwise is a shop cell
        let cell = shopCollectionView.dequeueReusableCell(withReuseIdentifier: "HomeScrollCell", for: indexPath) as! HomeCollectionViewCell
        
        let shop: Business = topShops[indexPath.row]
        
        cell.nameLabel.text = shop.name
        cell.typeLabel.text = shop.type
        
        let imageView: UIImageView = UIImageView(image: UIImage(named: "warm-mountains"))
        imageView.contentMode = .scaleAspectFill
        
        if shop.imgUrl != "" {
            let url = URL(string: shop.imgUrl)
            imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "warm-mountains"), completed: { [imageView] (image, error, cacheType, imageUrl) in
                guard error == nil else {
                    imageView.image = UIImage(named: "warm-mountains")
                    return
                }
            })
        } else {
            imageView.image = UIImage(named: "warm-mountains")
        }
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = imageView.frame
        gradient.colors = [UIColor.clear.cgColor, UIColor.white.cgColor]
        gradient.locations = [0.1, 0.125]
        
        imageView.layer.insertSublayer(gradient, at: 0)
        
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.masksToBounds = true
        
        cell.backgroundView = imageView
        cell.backgroundView!.layer.cornerRadius = 10
        cell.backgroundView!.layer.masksToBounds = true
        
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowRadius = 2
        cell.layer.shadowOpacity = 0.5
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        
        return cell
    }

}
