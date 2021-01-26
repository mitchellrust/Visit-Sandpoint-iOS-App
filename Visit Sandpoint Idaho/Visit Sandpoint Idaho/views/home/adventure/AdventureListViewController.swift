//
//  AdventureListViewController.swift
//  Visit Sandpoint Idaho
//
//  Created by Mitchell Rust on 11/27/20.
//

import UIKit
import FirebaseFirestore
import SDWebImage

class AdventureListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchFooter: SearchFooter!
    @IBOutlet weak var searchFooterBottomConstraint: NSLayoutConstraint!
    let cellSpacingHeight: CGFloat = 20
    var tabBarHeight: CGFloat!
    
    var adventures: Array<Adventure> = []
    var filteredAdventures: Array<Adventure> = []
    var selectedAdventure: Adventure!
    
    var numTopAdventures: Int!
    
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
        searchController.searchBar.placeholder = "Search Adventures"
        self.navigationItem.searchController = searchController
        self.definesPresentationContext = true
        searchController.searchBar.scopeButtonTitles = ["All", "Hiking", "Mountain Biking"]
        searchController.searchBar.delegate = self
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver( forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) { (notification) in
            self.handleKeyboard(notification: notification)
        }
        notificationCenter.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (notification) in
            self.handleKeyboard(notification: notification)
        }
        
        self.showSpinner(onView: self.view)
        
        CloudFS.getAdventures(source: .cache, completion: { [self] adventures in
            guard adventures != nil && adventures!.count != self.numTopAdventures else {
                CloudFS.getAdventures(source: .server, completion: { [self] serverAdventures in
                    self.removeSpinner()
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
            self.removeSpinner()
            self.adventures = adventures!
            self.tableView.reloadData()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.shadowImage = nil
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
            searchFooter.setIsFilteringToShow(filteredItemCount: filteredAdventures.count, of: adventures.count)
            return filteredAdventures.count
        }

        searchFooter.setNotFiltering()
        return adventures.count
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
            selectedAdventure = filteredAdventures[indexPath.section]
        } else {
            selectedAdventure = adventures[indexPath.section]
        }
        performSegue(withIdentifier: "ShowAdventureDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAdventureDetail" {
            let vc = segue.destination as! AdventureDetailViewController
            vc.adventure = selectedAdventure
        }
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AdventureCell", for: indexPath) as! AdventureTableViewCell
        
        cell.thumbnail.image = nil // reset image for reuse
        
        let adventure: Adventure
        if isFiltering {
            adventure = filteredAdventures[indexPath.section]
        } else {
            adventure = adventures[indexPath.section]
        }
                
        cell.nameLabel.text = adventure.name
        cell.typeLabel.text = adventure.type
        if adventure.rating != nil && adventure.rating != 0.0 {
            cell.ratingLabel.text = "\(String(adventure.rating)) stars"
            if adventure.rating.truncatingRemainder(dividingBy: 1.0) == 0 { // remove .0
                cell.ratingLabel.text = "\(String(cell.ratingLabel!.text!.prefix(1))) stars"
            }
        } else {
            cell.ratingLabel.text = "Not Rated"
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
    }
    
    func filterContentForSearchText(_ searchText: String, type: String? = nil) {
        filteredAdventures = adventures.filter { (adventure: Adventure) -> Bool in
            let doesTypeMatch = type == nil || adventure.type == type
            if isSearchBarEmpty {
                return doesTypeMatch
            } else {
                return doesTypeMatch &&
                    (adventure.name.lowercased().contains(searchText.lowercased()) ||
                    adventure.location.lowercased().contains(searchText.lowercased()) ||
                    adventure.summary.lowercased().contains(searchText.lowercased()))
            }
        }

        tableView.reloadData()
    }

}

extension AdventureListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let type = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        if type == "All" {
            filterContentForSearchText(searchBar.text!)
        } else {
            filterContentForSearchText(searchBar.text!, type: type)
        }
    }
}

extension AdventureListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let type = searchBar.scopeButtonTitles![selectedScope]
        if type == "All" {
            filterContentForSearchText(searchBar.text!)
        } else {
            filterContentForSearchText(searchBar.text!, type: type)
        }
    }
}
