//
//  ItemViewController.swift
//  Keep Track
//
//  Created by Christopher Hannah on 06/03/2017.
//  Copyright © 2017 Christopher Hannah. All rights reserved.
//

import UIKit
import RealmSwift

class ItemViewController: UIViewController {
    
    // Realm Database
    let realm = try! Realm()
    
    // UI Elements
    @IBOutlet weak var navigationTitleItem: UINavigationItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    
    // Variables
    var item: Item? = nil
    
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUI()
    }
    
    func loadUI() {
        // If the item object exists, load it
        if item != nil {
            loadItem(item: item!)
        }
    }
    
    func loadItem(item: Item) {
        // Load the item data into the UI
        navigationTitleItem.title = item.name.capitalizingFirstLetter()
        
        let date = item.dateAdded
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let stringOutput = dateFormatter.string(from: date as Date)
        dateLabel.text = "Added: \(stringOutput)"
        
        if (item.notes == "") {
            notesLabel.text = "Press edit to add notes to this item..."
        } else {
            notesLabel.text = item.notes
        }
        
        if let imageData = item.image {
            let image = UIImage(data: imageData as Data)
            imageView.image = image
        } else {
            let image = UIImage(named: "NoImage")
            imageView.image = image
        }

    }
    
    // MARK: UIViewController Actions
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func editItemPressed(_ sender: Any) {
        // Load AddItemView with the current item so that it can be edited
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addItemVC: AddItemViewController = storyboard.instantiateViewController(withIdentifier: "AddItemViewController") as! AddItemViewController
        addItemVC.isEditingItem = true
        addItemVC.itemToEdit = item!
        self.present(addItemVC, animated: true, completion: nil)
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        // Display a warning regarding deleting the item
        var itemText = ""
        if let name = item?.name {
            itemText = name
        }
        let alertController = UIAlertController(title: "Delete Item", message: "Are you sure you want to delete \"\(itemText)\"", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "OK", style: .default) { action in
            try! self.realm.write {
                self.realm.delete(self.item!)
            }
            self.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { action in
        }
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        alertController.view.tintColor = self.view.tintColor
        self.present(alertController, animated: true, completion: nil)
    }

}
