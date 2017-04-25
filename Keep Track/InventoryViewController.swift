//
//  InventoryViewController.swift
//  Keep Track
//
//  Created by Christopher Hannah on 31/01/2017.
//  Copyright © 2017 Christopher Hannah. All rights reserved.
//

import UIKit
import RealmSwift

class InventoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {

    // Realm Database
    let realm = try! Realm()
    var items: Results<Item> {
        get {
            // If Collection Primary key has been passed, return that object
            if collectionKey != nil {
                let collection = self.realm.object(ofType: Collection.self, forPrimaryKey: collectionKey!)
                
                // If currently searching, show the filtered results, otherwise show all items
                if isSearching {
                    // All items currently stored in the database that have the query text in the name
                    return (collection?.items.filter("name CONTAINS[c] '\(searchText)'"))!
                } else {
                    // All items currently stored in the database
                    return (collection?.items.filter("name != ''"))!
                }
            } else {
                // If currently searching, show the filtered results, otherwise show all items
                if isSearching {
                    // All items currently stored in the database that have the query text in the name
                    return self.realm.objects(Item.self).filter("name CONTAINS[c] '\(searchText)'")
                } else {
                    // All items currently stored in the database
                    return self.realm.objects(Item.self)
                }
            }
        }
    }
    
    var collection: Collection? {
        get {
            // If Collection Primary key has been passed, return that object
            if collectionKey != nil {
                return self.realm.object(ofType: Collection.self, forPrimaryKey: collectionKey!)!
            } else {
                return nil
            }
        }
    }
    
    // UI Elements
    @IBOutlet weak var inventoryCollectionView: UICollectionView!
    @IBOutlet weak var inventoryTitle: UINavigationBar!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    // Variables
    var collectionKey: String? = nil
    var collectionDeleted = false
    var isSearching: Bool = false
    var searchText: String = ""
    
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // If the view was presented after the collection was deleted, return to the main view
        if collectionDeleted {
            self.dismiss(animated: true, completion: nil)
        } else {
            loadUI()
        }
        
    }
    
    func loadUI() {
        // Load the collection data into the UI
        if collectionKey != nil {
            editButton.isEnabled = true
            inventoryTitle.topItem?.title = collection?.name.capitalizingFirstLetter()
        } else {
            editButton.isEnabled = false
            inventoryTitle.topItem?.title = "All Items"
        }
        self.inventoryCollectionView.reloadData()
    }
    
    // MARK: UIViewController Actions
    
    @IBAction func addPressed(_ sender: Any) {
        // Load AddItemView
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addItemVC: AddItemViewController = (storyboard.instantiateViewController(withIdentifier: "AddItemViewController") as? AddItemViewController)!
    
        if collectionKey != nil {
            addItemVC.collection = collection
        }
        
        self.present(addItemVC, animated: true, completion: nil)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editPressed(_ sender: Any) {
        // Load AddCollectionView with the current collection so that it can be edited
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let collectionVC: AddCollectionViewController = storyboard.instantiateViewController(withIdentifier: "AddCollectionViewController") as! AddCollectionViewController
        collectionVC.collectionToEdit = collection
        collectionVC.inventoryViewController = self
        self.present(collectionVC, animated: true, completion: nil)
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return the amout of items in the selected collection, or if viewing all items, return the total count (this is all done dynamically in the variable)
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create ItemViewCell object for configuring
        let cell: ItemViewCell = inventoryCollectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as! ItemViewCell
       
        // Load Item for the specific Cell Index, and configure the cell with the relevant data.
        let item = items[indexPath.row]
        
        cell.textLabel.text = item.name.capitalizingFirstLetter()
        
        // If an image has been added to the item, display it, otherwise display the standard "No Image" image
        if let imageData = item.image {
            cell.imageView.image = UIImage(data: imageData as Data)
        } else {
            let image = UIImage(named: "NoImage")
            cell.imageView.image = image
        }
        
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
        // Load ItemViewController with the relevant Item that was selected
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let itemVC: ItemViewController = storyboard.instantiateViewController(withIdentifier: "ItemViewController") as! ItemViewController
        
        itemVC.item = items[indexPath.row]
        
        self.present(itemVC, animated: true, completion: nil)
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
        inventoryCollectionView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // Set state to filter out search results
        isSearching = true
        
        // Reload the objects
        inventoryCollectionView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // Set state to normal results
        isSearching = false
        
        // Reload the objects
        inventoryCollectionView.reloadData()
        
        // Resign Keyboard
        searchBar.resignFirstResponder()
    }
}
