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
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    let realm = try! Realm()
    
    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if collectionToEdit != nil {
            loadCollection(collection: collectionToEdit!)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if collectionToEdit != nil {
            loadCollection(collection: collectionToEdit!)
            navigationBar.topItem?.title = "Edit Collection"
        } else {
            navigationBar.topItem?.title = "Add Collection"
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
}
