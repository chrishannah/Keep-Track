//
//  InventoryViewController.swift
//  Keep Track
//
//  Created by Christopher Hannah on 31/01/2017.
//  Copyright © 2017 Christopher Hannah. All rights reserved.
//

import UIKit
import RealmSwift

class InventoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var inventoryCollectionView: UICollectionView!
    
    let realm = try! Realm()
    var items: Results<Item> {
        get {
            return self.realm.objects(Item.self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Realm.Configuration.defaultConfiguration.fileURL)
        self.inventoryCollectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.inventoryCollectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: DataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CollectionViewCell = inventoryCollectionView.dequeueReusableCell(withReuseIdentifier: "defaultSquareCell", for: indexPath) as! CollectionViewCell
        let item = items[indexPath.row]
        cell.textLabel.text = item.name
        if let imageData = item.image {
            cell.imageView.image = UIImage(data: imageData as Data)
        } else {
            let image = UIImage(named: "NoImage")
            cell.imageView.image = image
        }
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
//        try! self.realm.write {
//            self.realm.delete(items[indexPath.row])
//        }
//        inventoryCollectionView.reloadData()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let itemVC: ItemViewController = storyboard.instantiateViewController(withIdentifier: "ItemViewController") as! ItemViewController
        itemVC.item = items[indexPath.row]
        self.present(itemVC, animated: true, completion: nil)
    }

    @IBAction func addPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let addItemVC = storyboard.instantiateViewController(withIdentifier: "AddItemViewController")
        self.present(addItemVC, animated: true, completion: nil)
    }
}
