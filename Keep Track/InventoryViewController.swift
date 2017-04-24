//
//  InventoryViewController.swift
//  Keep Track
//
//  Created by Christopher Hannah on 31/01/2017.
//  Copyright © 2017 Christopher Hannah. All rights reserved.
//

import UIKit
import RealmSwift

class InventoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    // Realm Database
    let realm = try! Realm()
    var items: Results<Item> {
        get {
            // All items currently stored in the database
            return self.realm.objects(Item.self)
        }
    }
    
    // UI Elements
    @IBOutlet weak var inventoryCollectionView: UICollectionView!
    @IBOutlet weak var inventoryTitle: UINavigationBar!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    // Variables
    var collection: Collection? = nil
    var collectionDeleted = false
    
    
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
        if collection != nil {
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
    
        if collection != nil {
            addItemVC.collection = collection
        }
        
        self.present(addItemVC, animated: true, completion: nil)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editPressed(_ sender: Any) {
        // Load AddItemView with the current collection so that it can be edited
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
        // Return the amout of items in the selected collection, or if viewing all items, return the total count
        if collection != nil {
            return (collection?.items.count)!
        } else {
            return items.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create ItemViewCell object for configuring
        let cell: ItemViewCell = inventoryCollectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as! ItemViewCell
       
        
        // Load Item for the specific Cell Index, and configure the cell with the relevant data.
        var item: Item? = nil
        
        if collection != nil {
            item = (collection?.items[indexPath.row])!
        } else {
            item = items[indexPath.row]
        }
        
        cell.textLabel.text = item?.name.capitalizingFirstLetter()
        
        // If an image has been added to the item, display it, otherwise display the standard "No Image" image
        if let imageData = item?.image {
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
}
