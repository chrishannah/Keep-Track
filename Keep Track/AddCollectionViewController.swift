//
//  AddCollectionViewController.swift
//  Keep Track
//
//  Created by Christopher Hannah on 24/04/2017.
//  Copyright © 2017 Christopher Hannah. All rights reserved.
//

import UIKit
import RealmSwift

class AddCollectionViewController: UIViewController {
    
    var collectionToEdit: Collection? = nil
    var inventoryViewController: InventoryViewController? = nil
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var deleteButton: UIButton!
    
    let realm = try! Realm()
    
    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if collectionToEdit != nil {
            loadCollection(collection: collectionToEdit!)
        }
    }
    
    func loadUI() {
        if collectionToEdit != nil {
            loadCollection(collection: collectionToEdit!)
            navigationBar.topItem?.title = "Edit Collection"
            deleteButton.isEnabled = true
        } else {
            navigationBar.topItem?.title = "Add Collection"
            deleteButton.isEnabled = false
        }
    }
    
    func loadCollection(collection: Collection) {
        nameTextField.text = collection.name
    }

    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func savePressed(_ sender: Any) {
        nameTextField.resignFirstResponder()
        
        let collection = Collection()
        collection.name = nameTextField.text!
        
        if (collection.name == "") {
            let alertController = UIAlertController(title: "Error", message: "Collection must have a name.", preferredStyle: .alert)
            let okayButton = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alertController.addAction(okayButton)
            present(alertController, animated: true, completion: nil)
        } else {
            if collectionToEdit != nil {
                try! self.realm.write {
                    collectionToEdit?.name = collection.name
                }
            } else {
                try! self.realm.write {
                    self.realm.add(collection, update: false)
                }
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        var collectionName = ""
        if let name = collectionToEdit?.name {
            collectionName = name
        }
        let alertController = UIAlertController(title: "Delete Collection", message: "Are you sure you want to delete \"\(collectionName)\"", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "OK", style: .default) { action in
            try! self.realm.write {
                self.realm.delete(self.collectionToEdit!)
            }
            self.inventoryViewController?.collectionDeleted = true
            self.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { action in
        }
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
