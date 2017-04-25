//
//  MainViewController.swift
//  Keep Track
//
//  Created by Christopher Hannah on 19/04/2017.
//  Copyright © 2017 Christopher Hannah. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {

    // Realm Database
    let realm = try! Realm()
    var collections: Results<Collection> {
        get {
            // If currently searching, show the filtered results, otherwise show all collections
            if isSearching {
                // All collections currently stored in the database that have the query text in the name
                return self.realm.objects(Collection.self).filter("name CONTAINS[c] '\(searchText)'").sorted(byKeyPath: "name", ascending: sortAscending)
            } else {
                // All collections currently stored in the database
                return self.realm.objects(Collection.self).sorted(byKeyPath: "name", ascending: sortAscending)
            }
        }
    }
    
    // UI Elements
    @IBOutlet weak var collectionCollectionView: UICollectionView!
    
    // Variables
    var isSearching: Bool = false
    var searchText: String = ""
    var sortAscending = true
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Print the Realm database file to the console
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        loadUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadUI()
    }
    
    func loadUI() {
        collectionCollectionView.reloadData()
    }
    
    // MARK: UIViewController Actions
    
    @IBAction func addCollectionPressed(_ sender: Any) {
        // Load AddCollectionView
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let collectionVC: AddCollectionViewController = storyboard.instantiateViewController(withIdentifier: "AddCollectionViewController") as! AddCollectionViewController
        self.present(collectionVC, animated: true, completion: nil)
    }
    
    @IBAction func sortPressed(_ sender: UIBarButtonItem) {
        // Create an alert view with the sorting options
        let alertController = UIAlertController(title: "", message: "Sort by:", preferredStyle: .alert)
        let nameAsc = UIAlertAction(title: "Name - Ascending", style: .default) { (action) in
            // Change the sorting direction to ascending and reload
            self.sortAscending = true
            self.loadUI()
        }
        let nameDesc = UIAlertAction(title: "Name - Descending", style: .default) { (action) in
            // Change the sorting direction to descending and reload
            self.sortAscending = false
            self.loadUI()
        }
        alertController.addAction(nameAsc)
        alertController.addAction(nameDesc)
        
        // Present the alert
        alertController.view.tintColor = self.view.tintColor
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Total amount of collections, and +1 for the "All Items" collection
        return collections.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create CollectionViewCell object for configuring
        let cell: CollectionViewCell = collectionCollectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CollectionViewCell
        
        // Load Collection for the specific Cell Index, and configure the cell with the relevant data.
        let collection:Collection
        
        if indexPath.row == collections.count {
            collection = Collection()
            collection.name = "All Items"
            cell.backgroundColor = UIColor.darkGray
            cell.textLabel.textColor = UIColor.white
        } else {
            collection = collections[indexPath.row]
            cell.backgroundColor = UIColor.white
            cell.textLabel.textColor = UIColor.darkGray
        }
        
        cell.textLabel.text = collection.name.capitalizingFirstLetter()
        
        // Add a rounded corner to the cell
        cell.layer.cornerRadius = 4
        cell.contentView.layer.cornerRadius = 4
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        
        // Add a shadow to the cell
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        
        // Return the configured cell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Load InventoryViewController with the relevant Collection that was selected
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let collectionVC: InventoryViewController = storyboard.instantiateViewController(withIdentifier: "InventoryViewController") as! InventoryViewController
        
        if indexPath.row != collections.count {
            collectionVC.collectionKey = collections[indexPath.row].key
        }

        self.present(collectionVC, animated: true, completion: nil)
    }
    
    
    // MARK: UISearchBarDelegate
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Resign Keyboard
        searchBar.resignFirstResponder()
        
        // Clear search filters and reset stated
        searchText = ""
        isSearching = false
        
        // Reload the objects
        loadUI()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Resign Keyboard but keep filtered results showing
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Make sure state is set to searching
        isSearching = true
        
        // Change search filter to the active text
        self.searchText = searchText
        
        // Reload the objects
        collectionCollectionView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // Set state to filter out search results
        isSearching = true
        
        // Reload the objects
        collectionCollectionView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // Set state to normal results
        isSearching = false
        
        // Reload the objects
        collectionCollectionView.reloadData()
        
        // Resign Keyboard
        searchBar.resignFirstResponder()
    }

}
