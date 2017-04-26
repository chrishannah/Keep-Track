//
//  AddItemViewController.swift
//  Keep Track
//
//  Created by Christopher Hannah on 27/02/2017.
//  Copyright © 2017 Christopher Hannah. All rights reserved.
//

import UIKit
import RealmSwift
import MobileCoreServices
import ImagePicker

class AddItemViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, ImagePickerDelegate {
    
    // Realm Database
    let realm = try! Realm()
    
    // UI Elements
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var titleBar: UINavigationBar!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    // Variables
    var isNameBeingEdited = false
    var isNotesBeingEdited = true
    
    var collection: Collection? = nil
    
    var itemHasImage = false
    var isEditingItem: Bool = false
    var itemToEdit:Item? = nil

    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add Observers for any Keyboard events
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: .UIKeyboardWillShow,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChange(_:)),
            name: .UIKeyboardWillChangeFrame,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: .UIKeyboardWillHide,
            object: nil)
        
        // If an Item has been passed for editing, load it in the UI
        loadUI(itemToEdit != nil)
    }
    
    func loadItem(item: Item) {
        nameTextField.text = itemToEdit?.name
        notesTextView.text = itemToEdit?.notes
        
        if let imageData = itemToEdit?.image {
            let image = UIImage(data: imageData as Data)
            imageView.image = image
            itemHasImage = true
        } else {
            let image = UIImage(named: "NoImage")
            imageView.image = image
            itemHasImage = false
        }
    }
    
    func loadUI(_ isEditingItem: Bool) {
        // Load Item into the UI
        if itemToEdit != nil {
            loadItem(item: itemToEdit!)
        }
        
        // Depending on the state of the item being added/edited, change the UI elements
        if isEditingItem {
            titleBar.topItem?.title = "Edit \(itemToEdit?.name.capitalizingFirstLetter() ?? "Item")"
        } else {
            titleBar.topItem?.title = "Add Item"
        }
        
        if itemHasImage {
            addPhotoButton.titleLabel?.text = "Change Photo"
        } else {
            addPhotoButton.titleLabel?.text = "Add Photo"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: UIViewController Actions
    
    @IBAction func addPhotoPressed(_ sender: Any) {
        // Scroll the view to the active section, and resign other active controls
        self.scrollView.scrollRectToVisible(imageView.frame, animated: true)
        nameTextField.resignFirstResponder()
        notesTextView.resignFirstResponder()
        
        // Display the Image Picker
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        present(imagePickerController, animated: true, completion: nil)
    }

    @IBAction func addTaskPressed(_ sender: Any) {
        // Scroll the view to the active section, and resign other active controls
        self.scrollView.scrollRectToVisible(imageView.frame, animated: true)
        nameTextField.resignFirstResponder()
        notesTextView.resignFirstResponder()
        
        // Create a new item based on the data in the UI
        let item = Item()
        item.name = nameTextField.text!
        item.notes = notesTextView.text!
        item.dateAdded = NSDate()
        let imageData: Data?
        
        // Generate a unique primary key using a mix of the current date/time and the name
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .full
        dateFormatter.dateStyle = .short
        let dateString = dateFormatter.string(from: Date())
        item.key = item.name + dateString
        
        // Check for missing name, if blank display a warning
        if (item.name == "") {
            let alertController = UIAlertController(title: "Error", message: "Item must have a name.", preferredStyle: .alert)
            let okayButton = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alertController.addAction(okayButton)
            alertController.view.tintColor = self.view.tintColor
            self.present(alertController, animated: true, completion: nil)
        } else {
            if itemHasImage {
                if let image = imageView.image {
                    imageData = UIImagePNGRepresentation(image)
                    item.image = imageData as NSData?}
            }
            // If the item was being edited, update that object, otherwise add a new one
            if isEditingItem {
                try! self.realm.write {
                    itemToEdit?.name = item.name
                    itemToEdit?.notes = item.notes
                    itemToEdit?.image = item.image
                }
                self.dismiss(animated: true, completion: nil)
            } else {
                if collection != nil {
                    try! self.realm.write {
                        collection?.items.append(item)
                    }
                } else {
                    try! self.realm.write {
                        self.realm.add(item, update: false)
                    }
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Keyboard Management
    
    func keyboardWillShow(_ notification: NSNotification) {
        // Move the view above the keyboard
        if let userInfo = notification.userInfo {
            let keyboardSize: CGRect = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
            moveScrollViewForKeyboard(true, keyboardHeight: keyboardSize.height)
        }
    }
    
    func keyboardWillChange(_ notification: NSNotification) {
        // Depending on the state of the keyboard, move the view
        if let userInfo = notification.userInfo {
            let keyboardSize: CGRect = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
            moveScrollViewForKeyboard(true, keyboardHeight: keyboardSize.height)
        }
    }
    
    func keyboardWillHide(_ notification: NSNotification) {
        // Move the view back to it's original position
        moveScrollViewForKeyboard(false, keyboardHeight: 0)
    }
    
    func moveScrollViewForKeyboard(_ shouldMove: Bool, keyboardHeight: CGFloat?) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.3)
        
        if shouldMove {
            var visibleFrame = CGRect(x: 0, y: 0, width: 1, height: 1)
            scrollViewBottomConstraint.constant = -keyboardHeight!
            
            if isNotesBeingEdited {
                let frame = notesTextView.frame
                visibleFrame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
            } else if isNameBeingEdited {
                let frame = nameTextField.frame
                visibleFrame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
            }
            scrollView.scrollRectToVisible(visibleFrame, animated: true)
        } else {
            scrollViewBottomConstraint.constant = 0
            scrollView.scrollRectToVisible(imageView.frame, animated: true)
        }

        UIView.commitAnimations()
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            isNameBeingEdited = true
        } else {
            isNameBeingEdited = false
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            isNameBeingEdited = false
        }
        return true
    }
    
    // MARK: UITextViewDelegate
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView == notesTextView {
            isNotesBeingEdited = true
        } else {
            isNotesBeingEdited = false
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView == notesTextView {
            isNotesBeingEdited = false
        }
        return true
    }
    
    // MARK: ImagePickerDelegate
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismiss(animated: true, completion: nil)
        if images.count > 0 {
            imageView.image = images[0]
            itemHasImage = true
        }
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismiss(animated: true, completion: nil)
        if images.count > 0 {
            imageView.image = images[0]
            itemHasImage = true
        }
    }
    
    
}
