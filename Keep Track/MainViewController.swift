//
//  MainViewController.swift
//  Keep Track
//
//  Created by Christopher Hannah on 19/04/2017.
//  Copyright © 2017 Christopher Hannah. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource {

    @IBOutlet weak var collectionCollectionView: UICollectionView!
    
    let realm = try! Realm()
    var collections: Results<Collection> {
        get {
            return self.realm.objects(Collection.self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        collectionCollectionView.reloadData()
    }
    
    @IBAction func addCollectionPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let collectionVC: AddCollectionViewController = storyboard.instantiateViewController(withIdentifier: "AddCollectionViewController") as! AddCollectionViewController
        self.present(collectionVC, animated: true, completion: nil)
        collectionCollectionView.reloadData()
    }
    
    // MARK: DataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collections.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CollectionViewCell = collectionCollectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CollectionViewCell
        
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
        
        cell.layer.cornerRadius = 4
        cell.contentView.layer.cornerRadius = 4
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let collectionVC: InventoryViewController = storyboard.instantiateViewController(withIdentifier: "InventoryViewController") as! InventoryViewController
        
        if indexPath.row != collections.count {
            collectionVC.collection = collections[indexPath.row]
        }

        self.present(collectionVC, animated: true, completion: nil)
    }
}
