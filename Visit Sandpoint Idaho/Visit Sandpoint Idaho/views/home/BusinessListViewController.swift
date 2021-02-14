//
//  BusinessListViewController.swift
//  Visit Sandpoint Idaho
//
//  Created by Mitchell Rust on 11/24/20.
//

import UIKit
import FirebaseFirestore
import SDWebImage

class BusinessListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchFooter: SearchFooter!
    @IBOutlet weak var searchFooterBottomConstraint: NSLayoutConstraint!
    let cellSpacingHeight: CGFloat = 20
    var tabBarHeight: CGFloat!
    
    var businessType: String!
    
    var businesses: Array<Business> = []
    var filteredBusinesses: Array<Business> = []
    var selectedBusiness: Business!
    
    var numTopBusinesses: Int!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!isSearchBarEmpty || searchBarScopeIsFiltering)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Remove back button text
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        tabBarHeight = self.tabBarController!.tabBar.frame.size.height
        
        // Search bar setup
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        if businessType == "restaurants" {
            searchController.searchBar.placeholder = "Search Restaurants"
        } else {
            searchController.searchBar.placeholder = "Search Shops"
        }
        self.navigationItem.searchController = searchController
        self.definesPresentationContext = true
        self.navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.scopeButtonTitles = ["All", "3+ stars", "4+ stars"]
        searchController.searchBar.delegate = self
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver( forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) { (notification) in
            self.handleKeyboard(notification: notification)
        }
        notificationCenter.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (notification) in
            self.handleKeyboard(notification: notification)
        }
        
        self.showSpinner(onView: self.view)
        
        CloudFS.getBusinesses(source: .cache, collection: businessType, completion: { [self] businesses in
            guard businesses != nil && businesses!.count != self.numTopBusinesses else {
                CloudFS.getBusinesses(source: .server, collection: businessType, completion: { [self] serverBusinesses in
                    self.removeSpinner()
                    guard serverBusinesses != nil else {
                        print("Could not get businesses")
                        return
                    }
                    self.businesses = serverBusinesses!
                    self.tableView.reloadData()
                    return
                })
                return
            }
            self.removeSpinner()
            self.businesses = businesses!
            self.tableView.reloadData()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func handleKeyboard(notification: Notification) {
        guard notification.name == UIResponder.keyboardWillChangeFrameNotification else {
            searchFooterBottomConstraint.constant = 0
            view.layoutIfNeeded()
            return
        }

        guard let info = notification.userInfo, let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }

        let keyboardHeight = keyboardFrame.cgRectValue.size.height
        UIView.animate(withDuration: 0.1, animations: { [self] () -> Void in
            self.searchFooterBottomConstraint.constant = keyboardHeight - self.tabBarHeight
            self.view.layoutIfNeeded()
        })
    }
    
    // Number of cells we want
    func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering {
            searchFooter.setIsFilteringToShow(filteredItemCount: filteredBusinesses.count, of: businesses.count)
            return filteredBusinesses.count
        }

        searchFooter.setNotFiltering()
        return businesses.count
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
        if isFiltering {
            selectedBusiness = filteredBusinesses[indexPath.section]
        } else {
            selectedBusiness = businesses[indexPath.section]
        }
        performSegue(withIdentifier: "ShowBusinessDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowBusinessDetail" {
            let vc = segue.destination as! BusinessDetailViewController
            vc.business = selectedBusiness
            vc.collection = businessType
        }
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessTableViewCell
        
        cell.thumbnail.image = nil // reset image for reuse
        
        let business: Business
        if isFiltering {
            business = filteredBusinesses[indexPath.section]
        } else {
            business = businesses[indexPath.section]
        }
        
        cell.nameLabel.text = business.name
        cell.typeLabel.text = business.type
        cell.addressLabel.text = business.streetAddress
        
        if business.imgUrl != "" {
            let url = URL(string: business.imgUrl)
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
    
    func filterContentForSearchText(_ searchText: String, rating: Double? = nil) {
        filteredBusinesses = businesses.filter { (business: Business) -> Bool in
            let doesRatingMatch = rating == nil || business.rating >= rating!
            if isSearchBarEmpty {
                return doesRatingMatch
            } else {
                return doesRatingMatch &&
                    (business.name.lowercased().contains(searchText.lowercased()) ||
                    business.type.lowercased().contains(searchText.lowercased()) ||
                    business.summary.lowercased().contains(searchText.lowercased()))
            }
        }

        tableView.reloadData()
    }

}

extension BusinessListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let ratingString = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        if ratingString == "All" {
            filterContentForSearchText(searchBar.text!)
        } else {
            let rating = Double(ratingString.prefix(1))
            filterContentForSearchText(searchBar.text!, rating: rating)
        }
    }
}

extension BusinessListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let ratingString = searchBar.scopeButtonTitles![selectedScope]
        if ratingString == "All" {
            filterContentForSearchText(searchBar.text!)
        } else {
            let rating = Double(ratingString.prefix(1))
            filterContentForSearchText(searchBar.text!, rating: rating)
        }
    }
}
