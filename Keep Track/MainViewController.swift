//
//  MainViewController.swift
//  Keep Track
//
//  Created by Christopher Hannah on 19/04/2017.
//  Copyright © 2017 Christopher Hannah. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    // Realm Database
    let realm = try! Realm()
    var collections: Results<Collection> {
        get {
            // All collections currently stored in the database
            return self.realm.objects(Collection.self)
        }
    }
    
    // UI Elements
    @IBOutlet weak var collectionCollectionView: UICollectionView!
    
    
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
            collectionVC.collection = collections[indexPath.row]
        }

        self.present(collectionVC, animated: true, completion: nil)
    }
}
